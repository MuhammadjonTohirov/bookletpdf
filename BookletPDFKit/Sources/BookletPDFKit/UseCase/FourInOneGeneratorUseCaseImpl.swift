//
//  FourInOneGeneratorUseCaseImpl.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/03/25.
//

import Foundation
import PDFKit

public protocol FourInOneGeneratorUseCase: Sendable {
    func makeFourInOnePDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}

public final class FourInOneGeneratorUseCaseImpl: FourInOneGeneratorUseCase {
    public init() {}
    
    public func makeFourInOnePDF(url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        makeDocumentAsBooklet(url, completion: completion)
    }

    private func makeDocumentAsBooklet(_ url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                if let originalPDF = PDFDocument(url: url) {
                    self.convertToFourInOneBooklet(originalPDF: originalPDF, url: url, completion: completion)
                }
            }
        }
    }
    
    private func convertToFourInOneBooklet(originalPDF: PDFDocument, url: URL, completion: @escaping (URL?) -> Void) {
        var pageCount = originalPDF.pageCount
        
        // Calculate blank pages needed to make total divisible by 8 (4 pages per sheet, front and back)
        let blankPagesNeeded = (8 - (pageCount % 8)) % 8
        
        if blankPagesNeeded > 0 {
            originalPDF.addBlankPages(count: blankPagesNeeded)
            pageCount = originalPDF.pageCount
        }
        
        let resultPDF = PDFDocument()
        
        // Total number of sheets needed (each sheet has 4 pages on front and 4 on back)
        let sheetCount = pageCount / 8
        
        for sheetIndex in 0..<sheetCount {
            // For each sheet, we need to create 2 pages (front and back)
            // Front page arrangement (for sheet N): [8N+8, 8N+1, 8N+4, 8N+5]
            // Back page arrangement (for sheet N): [8N+2, 8N+7, 8N+3, 8N+6]
            
            // Front page
            let frontPageIndices = [
                pageCount - 1 - (sheetIndex * 8),     // Last page of this signature
                (sheetIndex * 8),                     // First page of this signature
                (sheetIndex * 8) + 3,                 // Fourth page
                pageCount - 1 - (sheetIndex * 8) - 3  // Fifth-last page
            ]
            
            if let frontPage = createFourInOnePage(from: originalPDF, pageIndices: frontPageIndices) {
                resultPDF.insert(frontPage, at: resultPDF.pageCount)
            }
            
            // Back page
            let backPageIndices = [
                (sheetIndex * 8) + 1,                 // Second page
                pageCount - 1 - (sheetIndex * 8) - 1, // Second-last page
                (sheetIndex * 8) + 2,                 // Third page
                pageCount - 1 - (sheetIndex * 8) - 2  // Third-last page
            ]
            
            if let backPage = createFourInOnePage(from: originalPDF, pageIndices: backPageIndices) {
                resultPDF.insert(backPage, at: resultPDF.pageCount)
            }
        }
        
        // Save the resulting PDF
        if let saveURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first?.appendingPathComponent("four_in_one_booklet_\(url.lastPathComponent)") {
            
            try? FileManager.default.removeItem(at: saveURL)
            resultPDF.write(to: saveURL)
            try? FileManager.default.removeItem(at: url)
            
            completion(saveURL)
            return
        }
        
        completion(nil)
    }

    private func createFourInOnePage(from pdf: PDFDocument, pageIndices: [Int]) -> PDFPage? {
        // Standard letter size
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        
        // Calculate the size for each sub-page
        let subPageWidth = pageWidth / 2
        let subPageHeight = pageHeight / 2
        
        // Create a new PDF context
        let pdfData = NSMutableData()
        
        // Platform-specific implementation (keeping your existing code structure)
        #if os(iOS)
        // iOS implementation
        // ...similar to your existing code but using pageIndices instead of sequential pages
        #elseif os(macOS)
        // macOS implementation
        // ...similar to your existing code but using pageIndices instead of sequential pages
        #endif
        
        // Create a PDFDocument from the generated data
        if let newPDFDocument = PDFDocument(data: pdfData as Data) {
            return newPDFDocument.page(at: 0)
        }
        
        return nil
    }
}
