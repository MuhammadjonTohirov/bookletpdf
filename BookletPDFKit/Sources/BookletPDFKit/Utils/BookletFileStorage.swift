//
//  BookletFileStorage.swift
//  BookletPDFKit
//

import Foundation
import PDFKit

public struct BookletFileStorage: Sendable {

    public init() {}

    /// Saves a PDFDocument to a temporary file and returns the URL.
    func saveToTemporary(document: PDFDocument, prefix: String, originalName: String) throws -> URL {
        let fileManager = FileManager.default
        let saveURL = fileManager.temporaryDirectory
            .appendingPathComponent("\(prefix)_\(UUID().uuidString)_\(originalName)")

        if fileManager.fileExists(atPath: saveURL.path) {
            try fileManager.removeItem(at: saveURL)
        }

        guard document.write(to: saveURL) else {
            throw BookletError.exportFailed
        }

        return saveURL
    }
}
