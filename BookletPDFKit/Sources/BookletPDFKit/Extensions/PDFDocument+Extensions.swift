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
                if let data = pdf.dataRepresentation() {
                    return data
                } else {
                    return Data()
                }
            } importing: { data in
                if let pdf = PDFDocument(data: data) {
                    return pdf
                } else {
                    return PDFDocument()
                }
            }
        
        DataRepresentation(exportedContentType: .pdf) { pdf in
            if let data = pdf.dataRepresentation() {
                return data
            } else {
                return Data()
            }
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
