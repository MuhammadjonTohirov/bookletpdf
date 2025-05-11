//
//  FourInOneGeneratorUseCaseImpl.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 24/03/25.
//

import Foundation
import PDFKit
#if canImport(UIKit)
import UIKit
typealias OSImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias OSImage = NSImage
#endif

public final class FourInOneGeneratorUseCaseImpl: BookletPDFGeneratorUseCase {
    public init() {}
    
    public func makeBookletPDF(url: URL, completion: @Sendable @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                if let originalPDF = PDFDocument(url: url) {
                    self.convertToFourInOneBooklet(originalPDF: originalPDF, url: url, completion: completion)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func convertToFourInOneBooklet(
        originalPDF: PDFDocument,
        url: URL,
        completion: @escaping (URL?) -> Void
    ) {
        // 1. Collect all pages
        var pages: [PDFPage] = []
        for i in 0..<originalPDF.pageCount {
            if let pg = originalPDF.page(at: i) {
                pages.append(pg)
            }
        }
        guard let first = pages.first else {
            completion(nil)
            return
        }
        
        // 2. Determine page size
        let mediaBox = first.bounds(for: .mediaBox)
        let size = mediaBox.size
        
        // 3. Create a white blank OSImage of that size
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
        
        // 4. Make a PDFPage from it
        guard let blankPage = PDFPage(image: blankImage) else {
            completion(nil)
            return
        }
        
        // 5. Pad to multiple of 8
        let remainder = pages.count % 8
        if remainder != 0 {
            for _ in 0..<(8 - remainder) {
                pages.append(blankPage)
            }
        }
        let total = pages.count
        let sheets = total / 8
        
        // 6. Reorder into 4-up booklet
        let result = PDFDocument()
        for k in 0..<sheets {
            // low-end pages
            let l1 = 1 + 4*k, l2 = 2 + 4*k, l3 = 3 + 4*k, l4 = 4 + 4*k
            // high-end pages
            let h1 = total - 4*k, h2 = total - 4*k - 1, h3 = total - 4*k - 2, h4 = total - 4*k - 3
            
            let fSeq = [h1, l1, h3, l3]
            let bSeq = [h2, l2, h4, l4]
            let seq  = fSeq + bSeq
            
            print("Sheet \(k+1) page order: \(seq.map(String.init).joined(separator: ", "))")
            
            for idx in seq {
                result.insert(pages[idx - 1], at: result.pageCount)
            }
        }
        
        // 7. Save out
        guard let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first else {
            completion(nil)
            return
        }
        let saveURL = docs.appendingPathComponent("four_in_one_booklet_\(url.lastPathComponent)")
        
        try? FileManager.default.removeItem(at: saveURL)
        if result.write(to: saveURL) {
            try? FileManager.default.removeItem(at: url)
            completion(saveURL)
        } else {
            completion(nil)
        }
    }
}
