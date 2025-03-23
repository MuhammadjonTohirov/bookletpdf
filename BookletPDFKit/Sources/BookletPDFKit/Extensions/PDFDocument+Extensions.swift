//
//  PDFDocument+Extensions.swift
//  bookletPdf
//
//  Created by applebro on 28/09/23.
//

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
        
        FileRepresentation(exportedContentType: .pdf) { pdf in
            SentTransferredFile(pdf.documentURL!)
        }
     }
    
    public func addBlankPages(to pdf: PDFDocument, count: Int) {
        for _ in 0..<count {
            let blankPage = PDFPage()
            pdf.insert(blankPage, at: pdf.pageCount)
        }
    }
    
    func converTo(booklet: BookletType, completion: @escaping (URL?) -> Void) {
        guard let url = self.documentURL else {
            completion(nil)
            return
        }
        
        switch booklet {
        case .type2:
            convertToBooklet2B2(url: url, completion: completion)
        case .type4:
            convertToFourInOne(url: url, completion: completion)
        }
    }
    
    // Existing 2B2 booklet conversion
    private func convertToBooklet2B2(url: URL, completion: @escaping (URL?) -> Void) {
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
            
            completion(saveURL)
            return
        }
        
        completion(nil)
    }
    
    // New 4B1 (4-in-1) conversion
    private func convertToFourInOne(url: URL, completion: @escaping (URL?) -> Void) {
        let originalPDF = self
        var pageCount = originalPDF.pageCount
        
        // Calculate how many blank pages we need to add to make the total divisible by 4
        let blankPagesNeeded = (4 - (pageCount % 4)) % 4
        
        if blankPagesNeeded > 0 {
            addBlankPages(to: originalPDF, count: blankPagesNeeded)
            pageCount = originalPDF.pageCount
        }
        
        // Create a new PDF document for the result
        let resultPDF = PDFDocument()
        
        // Create pages with 4 original pages on each
        for i in stride(from: 0, to: pageCount, by: 4) {
            if let page = createFourInOnePage(from: originalPDF, startIndex: i) {
                resultPDF.insert(page, at: resultPDF.pageCount)
            }
        }
        
        // Save the resulting PDF
        if let saveURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first?.appendingPathComponent("four_in_one_\(url.lastPathComponent)") {
            
            try? FileManager.default.removeItem(at: saveURL)
            resultPDF.write(to: saveURL)
            try? FileManager.default.removeItem(at: url)
            
            completion(saveURL)
            return
        }
        
        completion(nil)
    }
    
    // Helper method to create a single page with 4 pages arranged in a 2x2 grid
    private func createFourInOnePage(from pdf: PDFDocument, startIndex: Int) -> PDFPage? {
        // Standard letter size
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        
        // Calculate the size for each sub-page
        let subPageWidth = pageWidth / 2
        let subPageHeight = pageHeight / 2
        
        // Create a new PDF context
        let pdfData = NSMutableData()
        
        #if os(iOS)
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), nil)
        UIGraphicsBeginPDFPage()
        
        let context = UIGraphicsGetCurrentContext()
        
        // Draw the four pages in the grid
        for i in 0..<4 {
            if startIndex + i < pdf.pageCount, let page = pdf.page(at: startIndex + i) {
                let row = i / 2
                let col = i % 2
                
                let xPos = CGFloat(col) * subPageWidth
                let yPos = CGFloat(row) * subPageHeight
                
                // Draw the page
                context?.saveGState()
                context?.translateBy(x: xPos, y: pageHeight - yPos - subPageHeight) // Adjust for PDF coordinate system
                
                if let pageImage = page.thumbnail(of: CGSize(width: subPageWidth, height: subPageHeight), for: .cropBox) {
                    pageImage.draw(in: CGRect(x: 0, y: 0, width: subPageWidth, height: subPageHeight))
                }
                
                context?.restoreGState()
            }
        }
        
        UIGraphicsEndPDFContext()
        #elseif os(macOS)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_four_in_one.pdf")
        try? FileManager.default.removeItem(at: tempURL)
        
        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        guard let context = CGContext(tempURL as CFURL, mediaBox: &mediaBox, nil) else {
            return nil
        }
        
        // Begin PDF page
        context.beginPDFPage(nil)
        
        // Draw the four pages in the grid
        for i in 0..<4 {
            if startIndex + i < pdf.pageCount, let page = pdf.page(at: startIndex + i) {
                let row = i / 2
                let col = i % 2
                
                let xPos = CGFloat(col) * subPageWidth
                let yPos = CGFloat(1 - row) * subPageHeight // Adjust for coordinate system
                
                // Draw the page
                context.saveGState()
                context.translateBy(x: xPos, y: yPos - subPageHeight)
                
                let pageImage = page.thumbnail(of: CGSize(width: subPageWidth, height: subPageHeight), for: .cropBox)
                
                if let cgImage = pageImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: subPageWidth, height: subPageHeight))
                }
                
                context.restoreGState()
            }
        }
        
        // End the PDF context
        context.endPDFPage()
        context.closePDF()
        
        // Read the created PDF
        if let pdfDataFromFile = try? Data(contentsOf: tempURL) {
            pdfData.append(pdfDataFromFile)
        }
        
        try? FileManager.default.removeItem(at: tempURL)
        #endif
        
        // Create a PDFDocument from the generated data
        if let newPDFDocument = PDFDocument(data: pdfData as Data) {
            return newPDFDocument.page(at: 0)
        }
        
        return nil
    }
}
