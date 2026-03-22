//
//  PDFDocument+Extensions.swift
//  bookletPdf
//
//  Created by applebro on 28/09/23.
//

import Foundation
import PDFKit.PDFDocument
import SwiftUI

extension PDFDocument: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .pdf) { pdf in
            guard let data = pdf.dataRepresentation() else {
                throw BookletError.exportFailed
            }
            return data
        } importing: { data in
            guard let pdf = PDFDocument(data: data) else {
                throw BookletError.invalidDocument
            }
            return pdf
        }

        DataRepresentation(exportedContentType: .pdf) { pdf in
            guard let data = pdf.dataRepresentation() else {
                throw BookletError.exportFailed
            }
            return data
        }
    }

    public func addBlankPages(count: Int) {
        let pageCount = self.pageCount
        for _ in 0..<count {
            let blankPage = PDFPage()
            self.insert(blankPage, at: pageCount)
        }
    }
}
