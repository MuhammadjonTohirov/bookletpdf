//
//  TwoInOnePdfGeneratorUseCaseImpl.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/02/25.
//

import Foundation
import PDFKit

public protocol BookletPDFGeneratorUseCase: Sendable {
    func makeBookletPDF(url: URL) async throws -> URL
}

public struct TwoInOnePdfGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    private static let pagesPerSheet = 4
    private let storage = BookletFileStorage()

    public init() {}

    public func makeBookletPDF(url: URL) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            guard let originalPDF = PDFDocument(url: url) else {
                throw BookletError.invalidDocument
            }

            return try self.convertToBooklet2B2(originalPDF: originalPDF, url: url)
        }.value
    }

    private func convertToBooklet2B2(originalPDF: PDFDocument, url: URL) throws -> URL {
        var pageCount = originalPDF.pageCount

        let blankPagesNeeded = (Self.pagesPerSheet - (pageCount % Self.pagesPerSheet)) % Self.pagesPerSheet
        originalPDF.addBlankPages(count: blankPagesNeeded)

        pageCount = originalPDF.pageCount

        let bookletPDF = PDFDocument()

        var bookletPage = 0
        for i in 0..<pageCount / 2 {
            let li = pageCount - 1 - i
            let ri = i

            if let p1 = originalPDF.page(at: li), let p2 = originalPDF.page(at: ri) {
                bookletPDF.insert(p1, at: bookletPage)
                bookletPDF.insert(p2, at: bookletPage + 1)
                bookletPage += 2
            }
        }

        return try storage.saveToTemporary(
            document: bookletPDF,
            prefix: "booklet_2in1",
            originalName: url.lastPathComponent
        )
    }
}

public enum BookletError: LocalizedError {
    case invalidDocument
    case exportFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidDocument: return "The PDF document is invalid or could not be read."
        case .exportFailed: return "Failed to save the generated booklet PDF."
        }
    }
}