//
//  PDFDocument+Extensions.swift
//  bookletPdf
//
//  Created by applebro on 28/09/23.
//

import Foundation
import PDFKit
import SwiftUI

extension PDFDocument: Transferable {
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
        
        FileRepresentation(exportedContentType: .pdf) { pdf in
            SentTransferredFile(pdf.documentURL!)
        }
     }
    
    func addBlankPages(to pdf: PDFDocument, count: Int) {
        for _ in 0..<count {
            let blankPage = PDFPage()
            pdf.insert(blankPage, at: pdf.pageCount)
        }
    }
    
    func converTo(booklet: BookletType, completion: @escaping (URL?) -> Void) {
        guard let url = self.documentURL else {
            fatalError()
        }
        
        let originalPDF = self
        var pageCount = originalPDF.pageCount
        
        let blankPagesNeeded = (4 - (pageCount % 4)) % 4
        
        addBlankPages(to: originalPDF, count: blankPagesNeeded)
        
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
        
        if let saveURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first?.appendingPathComponent("booklet_\(url.lastPathComponent)") {
            
            try? FileManager.default.removeItem(at: saveURL)
            
            bookletPDF.write(to: saveURL)
            
            try? FileManager.default.removeItem(at: url)
            
            DispatchQueue.main.async {
                completion(saveURL)
            }
            return
        }
    }
}
