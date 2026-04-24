//
//  MergedPDFSplitter.swift
//  BookletPDFKit
//

import Foundation
import PDFKit

/// Separates an already-imposed merged booklet PDF into front and back
/// PDFs by sheet parity (even pages → front, odd pages → back).
///
/// Unlike `MergedTwoInOneGeneratorUseCaseImpl.makeSplitBookletPDFs(url:)`
/// which builds the split straight from the raw input, this splitter
/// operates on a pre-branded merged output — so any watermark or cover
/// already baked into the merged PDF is preserved on both sides.
public struct MergedPDFSplitter: Sendable {
    private let storage = BookletFileStorage()

    public init() {}

    public func split(mergedURL: URL) async throws -> SplitBookletPDFs {
        return try await Task.detached(priority: .userInitiated) {
            guard let doc = PDFDocument(url: mergedURL) else {
                throw BookletError.invalidDocument
            }

            let frontDoc = PDFDocument()
            let backDoc = PDFDocument()

            for i in 0..<doc.pageCount {
                guard let page = doc.page(at: i) else { continue }
                let target = (i % 2 == 0) ? frontDoc : backDoc
                target.insert(page, at: target.pageCount)
            }

            let originalName = mergedURL.lastPathComponent
            let frontURL = try self.storage.saveToTemporary(
                document: frontDoc,
                prefix: "booklet_2in1_front",
                originalName: originalName
            )
            let backURL = try self.storage.saveToTemporary(
                document: backDoc,
                prefix: "booklet_2in1_back",
                originalName: originalName
            )

            return SplitBookletPDFs(front: frontURL, back: backURL)
        }.value
    }
}
