//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/02/25.
//

import Foundation
import PDFKit

public protocol BookletPDFGeneratorUseCase: Sendable {
    func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void)
}

public struct TwoInOnePdfGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    public init() {}
    
    public func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                if let originalPDF = PDFDocument(url: url) {
                    self.convertToBooklet2B2(originalPDF: originalPDF, url: url, completion: completion)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    // Existing 2B2 booklet conversion
    private func convertToBooklet2B2(originalPDF: PDFDocument, url: URL, completion: @escaping (URL?) -> Void) {
        var pageCount = originalPDF.pageCount
        
        let blankPagesNeeded = (4 - (pageCount % 4)) % 4
        
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
}
