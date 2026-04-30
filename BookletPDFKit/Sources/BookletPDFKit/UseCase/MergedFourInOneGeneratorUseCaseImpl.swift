//
//  MergedFourInOneGeneratorUseCaseImpl.swift
//  BookletPDFKit
//

import Foundation
import CoreGraphics
import PDFKit

/// Produces a pre-merged 4-up booklet PDF.
///
/// Each output page is **one physical sheet face** containing four source
/// pages drawn in a 2×2 grid in saddle-stitch imposition order. Unlike
/// `FourInOneGeneratorUseCaseImpl` (which only rearranges pages and relies
/// on the print dialog's 4-up layout setting), this generator bakes the
/// imposition into the PDF itself — so the print dialog needs no
/// layout/direction/odd-even configuration beyond odd/even filtering for
/// manual simplex printing.
///
/// On iOS, where the print dialog cannot filter odd/even,
/// `MergedPDFSplitter.split(mergedURL:)` separates this output into front
/// and back PDFs for the two-step assistant flow.
public struct MergedFourInOneGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    private static let pagesPerCutStrip = 4
    private static let cutStripsPerSheet = 2
    private static let pagesPerSheet = pagesPerCutStrip * cutStripsPerSheet
    private let storage = BookletFileStorage()

    public init() {}

    public func makeBookletPDF(url: URL) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let originalPDF = PDFDocument(url: url) else {
                throw BookletError.invalidDocument
            }
            return try self.convertToMerged4Up(originalPDF: originalPDF, url: url)
        }.value
    }

    private func convertToMerged4Up(originalPDF: PDFDocument, url: URL) throws -> URL {
        let sourcePageCount = originalPDF.pageCount
        guard sourcePageCount > 0, let firstPage = originalPDF.page(at: 0) else {
            throw BookletError.invalidDocument
        }
        let layout = Self.logicalLayout(for: sourcePageCount)

        let quadSize = firstPage.bounds(for: .mediaBox).size
        let sheetSize = CGSize(width: quadSize.width * 2, height: quadSize.height * 2)

        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data as CFMutableData) else {
            throw BookletError.exportFailed
        }
        var mediaBox = CGRect(origin: .zero, size: sheetSize)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw BookletError.exportFailed
        }

        let stripCount = layout.pageCount / Self.pagesPerCutStrip
        let sheets = Int(ceil(Double(stripCount) / Double(Self.cutStripsPerSheet)))
        for k in 0..<sheets {
            let faces = Self.sheetFaces(k: k, layout: layout, sheetCount: sheets)
            Self.emitFace(faces.front, pdf: originalPDF, context: context, quadSize: quadSize)
            Self.emitFace(faces.back, pdf: originalPDF, context: context, quadSize: quadSize)
        }

        context.closePDF()

        guard let bookletPDF = PDFDocument(data: data as Data) else {
            throw BookletError.exportFailed
        }

        return try storage.saveToTemporary(
            document: bookletPDF,
            prefix: "booklet_4in1_merged",
            originalName: url.lastPathComponent
        )
    }

    /// 0-based page indices for each quadrant of a sheet's front and back.
    ///
    /// Arranges each physical sheet as two horizontal cut strips. After
    /// printing fronts, flipping top-to-bottom, printing backs, cutting across
    /// the middle, stacking the top cuts over the bottom cuts, and folding each
    /// strip vertically, the cut strips read in normal saddle-stitch order.
    private static func sheetFaces(k: Int, layout: LogicalLayout, sheetCount: Int) -> (front: QuadFace, back: QuadFace) {
        let top = cutStrip(at: k, layout: layout)
        let bottom = cutStrip(at: k + sheetCount, layout: layout)

        let front = QuadFace(
            topLeft: top.backCover,
            topRight: top.front,
            bottomLeft: bottom.backCover,
            bottomRight: bottom.front
        )
        let back = QuadFace(
            topLeft: top.insideFront,
            topRight: top.insideBack,
            bottomLeft: bottom.insideFront,
            bottomRight: bottom.insideBack
        )
        return (front, back)
    }

    private static func cutStrip(at stripIndex: Int, layout: LogicalLayout) -> CutStrip {
        let stripCount = layout.pageCount / Self.pagesPerCutStrip
        guard stripIndex < stripCount else {
            return .blank
        }

        let front = 1 + 2 * stripIndex
        let insideFront = front + 1
        let insideBack = layout.pageCount - 1 - 2 * stripIndex
        let backCover = layout.pageCount - 2 * stripIndex
        let hasBackSide = insideFront < insideBack

        return CutStrip(
            front: page(front, rotated: false, layout: layout),
            insideFront: hasBackSide ? page(insideFront, rotated: false, layout: layout) : .blank,
            insideBack: hasBackSide ? page(insideBack, rotated: false, layout: layout) : .blank,
            backCover: page(backCover, rotated: false, layout: layout)
        )
    }

    private static func page(_ logicalPageNumber: Int, rotated: Bool, layout: LogicalLayout) -> QuadPage {
        guard (1...layout.pageCount).contains(logicalPageNumber),
              let sourceIndex = layout.sourceIndex(for: logicalPageNumber) else {
            return .blank
        }
        return QuadPage(index: sourceIndex, rotated: rotated)
    }

    private static func logicalLayout(for sourcePageCount: Int) -> LogicalLayout {
        let remainder = sourcePageCount % Self.pagesPerSheet
        let blankCount = remainder == 0 ? 0 : Self.pagesPerSheet - remainder
        return LogicalLayout(sourcePageCount: sourcePageCount, blankCount: blankCount)
    }

    private struct LogicalLayout {
        let sourcePageCount: Int
        let blankCount: Int

        var pageCount: Int { sourcePageCount + blankCount }

        func sourceIndex(for logicalPageNumber: Int) -> Int? {
            if logicalPageNumber <= sourcePageCount {
                return logicalPageNumber - 1
            }
            return nil
        }
    }

    private struct QuadPage {
        let index: Int?
        let rotated: Bool

        static let blank = QuadPage(index: nil, rotated: false)
    }

    private struct CutStrip {
        let front: QuadPage
        let insideFront: QuadPage
        let insideBack: QuadPage
        let backCover: QuadPage

        static let blank = CutStrip(
            front: .blank,
            insideFront: .blank,
            insideBack: .blank,
            backCover: .blank
        )
    }

    private struct QuadFace {
        let topLeft: QuadPage
        let topRight: QuadPage
        let bottomLeft: QuadPage
        let bottomRight: QuadPage
    }

    private static func emitFace(
        _ face: QuadFace,
        pdf: PDFDocument,
        context: CGContext,
        quadSize: CGSize
    ) {
        // CG origin is bottom-left; top row sits at y = quadSize.height.
        let topY = quadSize.height
        let bottomY: CGFloat = 0
        let leftX: CGFloat = 0
        let rightX = quadSize.width

        context.beginPDFPage(nil)
        drawQuadrant(face.topLeft,     at: CGPoint(x: leftX,  y: topY),    pdf: pdf, quadSize: quadSize, in: context)
        drawQuadrant(face.topRight,    at: CGPoint(x: rightX, y: topY),    pdf: pdf, quadSize: quadSize, in: context)
        drawQuadrant(face.bottomLeft,  at: CGPoint(x: leftX,  y: bottomY), pdf: pdf, quadSize: quadSize, in: context)
        drawQuadrant(face.bottomRight, at: CGPoint(x: rightX, y: bottomY), pdf: pdf, quadSize: quadSize, in: context)
        context.endPDFPage()
    }

    private static func drawQuadrant(
        _ quadPage: QuadPage,
        at offset: CGPoint,
        pdf: PDFDocument,
        quadSize: CGSize,
        in context: CGContext
    ) {
        guard let index = quadPage.index else { return }
        let page = pdf.page(at: index)
        guard let page else { return }

        let pageBox = page.bounds(for: .mediaBox)
        let scaleX = quadSize.width / max(pageBox.width, 1)
        let scaleY = quadSize.height / max(pageBox.height, 1)
        let scale = min(scaleX, scaleY)

        let scaledWidth = pageBox.width * scale
        let scaledHeight = pageBox.height * scale
        let centerX = offset.x + (quadSize.width - scaledWidth) / 2
        let centerY = offset.y + (quadSize.height - scaledHeight) / 2

        context.saveGState()
        if quadPage.rotated {
            context.translateBy(x: offset.x + quadSize.width / 2, y: offset.y + quadSize.height / 2)
            context.rotate(by: .pi)
            context.translateBy(x: -scaledWidth / 2, y: -scaledHeight / 2)
        } else {
            context.translateBy(x: centerX, y: centerY)
        }
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -pageBox.origin.x, y: -pageBox.origin.y)
        page.draw(with: .mediaBox, to: context)
        context.restoreGState()
    }
}
