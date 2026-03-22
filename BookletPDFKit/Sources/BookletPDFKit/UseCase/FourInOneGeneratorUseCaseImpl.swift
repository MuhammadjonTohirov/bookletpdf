//
//  FourInOneGeneratorUseCaseImpl.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/03/25.
//

import Foundation
import PDFKit

public final class FourInOneGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    private static let pagesPerSheet = 8
    private let storage = BookletFileStorage()

    public init() {}

    public func makeBookletPDF(url: URL) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let originalPDF = PDFDocument(url: url) else {
                throw BookletError.invalidDocument
            }
            return try self.convertToFourInOneBooklet(originalPDF: originalPDF, url: url)
        }.value
    }

    private func convertToFourInOneBooklet(
        originalPDF: PDFDocument,
        url: URL
    ) throws -> URL {
        var pages: [PDFPage] = []
        for i in 0..<originalPDF.pageCount {
            if let pg = originalPDF.page(at: i) {
                pages.append(pg)
            }
        }
        guard let first = pages.first else {
            throw BookletError.invalidDocument
        }

        let mediaBox = first.bounds(for: .mediaBox)
        let size = mediaBox.size

        let blankImage: OSImage = {
        #if canImport(UIKit)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { ctx in
                UIColor.white.setFill()
                ctx.fill(CGRect(origin: .zero, size: size))
            }
        #elseif canImport(AppKit)
            let img = OSImage(size: size)
            img.lockFocus()
            NSColor.white.setFill()
            NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
            img.unlockFocus()
            return img
        #endif
        }()

        guard let blankPage = PDFPage(image: blankImage) else {
            throw BookletError.exportFailed
        }

        let remainder = pages.count % Self.pagesPerSheet
        if remainder != 0 {
            for _ in 0..<(Self.pagesPerSheet - remainder) {
                pages.append(blankPage)
            }
        }
        let total = pages.count
        let sheets = total / Self.pagesPerSheet

        let result = PDFDocument()
        for k in 0..<sheets {
            let l1 = 1 + 4*k, l2 = 2 + 4*k, l3 = 3 + 4*k, l4 = 4 + 4*k
            let h1 = total - 4*k, h2 = total - 4*k - 1, h3 = total - 4*k - 2, h4 = total - 4*k - 3

            let seq = [h1, l1, h3, l3, h2, l2, h4, l4]

            for idx in seq {
                result.insert(pages[idx - 1], at: result.pageCount)
            }
        }

        return try storage.saveToTemporary(
            document: result,
            prefix: "booklet_4in1",
            originalName: url.lastPathComponent
        )
    }
}