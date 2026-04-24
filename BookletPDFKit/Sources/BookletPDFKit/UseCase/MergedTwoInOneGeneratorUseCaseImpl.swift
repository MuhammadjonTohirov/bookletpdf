//
//  MergedTwoInOneGeneratorUseCaseImpl.swift
//  BookletPDFKit
//

import Foundation
import CoreGraphics
import PDFKit

/// Pair of PDFs produced for manual simplex printing: first print `front`,
/// flip the stack vertically (short-edge), reload, then print `back`.
public struct SplitBookletPDFs: Sendable {
    public let front: URL
    public let back: URL

    public init(front: URL, back: URL) {
        self.front = front
        self.back = back
    }
}

/// Emits a booklet as two separate PDFs — one for each side of the paper.
///
/// Useful on platforms whose print dialog cannot filter odd/even sheets
/// (notably iOS `UIPrintInteractionController`): the user prints `front`,
/// flips the stack, and prints `back` without touching any per-job settings.
public protocol SplitBookletPDFGeneratorUseCase: Sendable {
    func makeSplitBookletPDFs(url: URL) async throws -> SplitBookletPDFs
}

/// Produces a pre-merged landscape 2-up booklet PDF.
///
/// Each output page is **one physical sheet face** containing two source pages
/// drawn side-by-side in saddle-stitch imposition order. Unlike
/// `TwoInOnePdfGeneratorUseCaseImpl` (which only rearranges pages and relies
/// on the print dialog's 2-up layout), this generator bakes the imposition
/// into the PDF itself — so the print dialog needs no layout/odd-even
/// configuration.
///
/// For iOS — whose print dialog cannot filter odd/even sheets —
/// `makeSplitBookletPDFs(url:)` emits two PDFs (front + back) so the user
/// prints the front, flips the stack, and prints the back straight through.
public struct MergedTwoInOneGeneratorUseCaseImpl: BookletPDFGeneratorUseCase, SplitBookletPDFGeneratorUseCase {
    private static let pagesPerSheet = 4
    private let storage = BookletFileStorage()

    public init() {}

    public func makeBookletPDF(url: URL) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let originalPDF = PDFDocument(url: url) else {
                throw BookletError.invalidDocument
            }
            let layout = try Self.prepareLayout(from: originalPDF)
            let data = try Self.renderImposedPDF(pdf: originalPDF, layout: layout, side: .both)
            return try self.savePDF(
                data: data,
                prefix: "booklet_2in1_merged",
                originalName: url.lastPathComponent
            )
        }.value
    }

    public func makeSplitBookletPDFs(url: URL) async throws -> SplitBookletPDFs {
        return try await Task.detached(priority: .userInitiated) {
            guard let originalPDF = PDFDocument(url: url) else {
                throw BookletError.invalidDocument
            }
            let layout = try Self.prepareLayout(from: originalPDF)
            let frontData = try Self.renderImposedPDF(pdf: originalPDF, layout: layout, side: .front)
            let backData = try Self.renderImposedPDF(pdf: originalPDF, layout: layout, side: .back)
            let frontURL = try self.savePDF(
                data: frontData,
                prefix: "booklet_2in1_front",
                originalName: url.lastPathComponent
            )
            let backURL = try self.savePDF(
                data: backData,
                prefix: "booklet_2in1_back",
                originalName: url.lastPathComponent
            )
            return SplitBookletPDFs(front: frontURL, back: backURL)
        }.value
    }

    private func savePDF(data: Data, prefix: String, originalName: String) throws -> URL {
        guard let pdf = PDFDocument(data: data) else {
            throw BookletError.exportFailed
        }
        return try storage.saveToTemporary(
            document: pdf,
            prefix: prefix,
            originalName: originalName
        )
    }

    private static func prepareLayout(from originalPDF: PDFDocument) throws -> SheetLayout {
        let remainder = originalPDF.pageCount % pagesPerSheet
        let blankNeeded = remainder == 0 ? 0 : pagesPerSheet - remainder
        originalPDF.addBlankPages(count: blankNeeded)

        let pageCount = originalPDF.pageCount
        guard pageCount > 0, let firstPage = originalPDF.page(at: 0) else {
            throw BookletError.invalidDocument
        }

        let sourceSize = firstPage.bounds(for: .mediaBox).size
        let sheetSize = CGSize(width: sourceSize.width * 2, height: sourceSize.height)
        return SheetLayout(pageCount: pageCount, sourceSize: sourceSize, sheetSize: sheetSize)
    }

    private static func renderImposedPDF(
        pdf: PDFDocument,
        layout: SheetLayout,
        side: SheetSide
    ) throws -> Data {
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else {
            throw BookletError.exportFailed
        }
        var mediaBox = CGRect(origin: .zero, size: layout.sheetSize)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw BookletError.exportFailed
        }

        for k in 0..<(layout.pageCount / 2) where side.includes(k) {
            let indices = imposedIndices(k: k, pageCount: layout.pageCount)
            context.beginPDFPage(nil)
            drawPage(
                pdf.page(at: indices.left),
                in: context,
                offsetX: 0,
                halfSize: layout.sourceSize
            )
            drawPage(
                pdf.page(at: indices.right),
                in: context,
                offsetX: layout.sourceSize.width,
                halfSize: layout.sourceSize
            )
            context.endPDFPage()
        }

        context.closePDF()
        return data as Data
    }

    private static func imposedIndices(k: Int, pageCount: Int) -> (left: Int, right: Int) {
        let isBackSide = k % 2 == 1
        if isBackSide {
            return (left: k, right: pageCount - 1 - k)
        } else {
            return (left: pageCount - 1 - k, right: k)
        }
    }

    private static func drawPage(
        _ page: PDFPage?,
        in context: CGContext,
        offsetX: CGFloat,
        halfSize: CGSize
    ) {
        guard let page else { return }

        let pageBox = page.bounds(for: .mediaBox)
        let scaleX = halfSize.width / max(pageBox.width, 1)
        let scaleY = halfSize.height / max(pageBox.height, 1)
        let scale = min(scaleX, scaleY)

        let scaledWidth = pageBox.width * scale
        let scaledHeight = pageBox.height * scale
        let centerX = offsetX + (halfSize.width - scaledWidth) / 2
        let centerY = (halfSize.height - scaledHeight) / 2

        context.saveGState()
        context.translateBy(x: centerX, y: centerY)
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -pageBox.origin.x, y: -pageBox.origin.y)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()
    }

    private struct SheetLayout {
        let pageCount: Int
        let sourceSize: CGSize
        let sheetSize: CGSize
    }

    private enum SheetSide {
        case front
        case back
        case both

        func includes(_ sheetIndex: Int) -> Bool {
            let isBack = sheetIndex % 2 == 1
            switch self {
            case .front: return !isBack
            case .back: return isBack
            case .both: return true
            }
        }
    }
}
