//
//  AppPDF.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import Foundation
import PDFKit
import UIKit

struct AppPDF {
    var url: URL?
    
    func makeBookletPDF(completion: @escaping (URL?) -> Void) {
        if let url {
            makeDocumentAsBooklet(url, completion: completion)
        }
    }
    
    var createTemporaryPdfFromUrl: URL? {
        guard let url else {
            return nil
        }
        
        guard url.startAccessingSecurityScopedResource() else {
            print("No access to \(url)")
            return nil
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }
                
        let tempDirectoryURL: URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        let targetURL = tempDirectoryURL.appendingPathComponent("Temp_\(url.lastPathComponent)")
        
        do {
            if FileManager.default.fileExists(atPath: targetURL.path()) {
                try? FileManager.default.removeItem(at: targetURL)
            }
            
            try FileManager.default.copyItem(at: url, to: targetURL)
            return targetURL
        } catch {
            print("Error \(error.localizedDescription)")
            return targetURL
        }
    }

    private func makeDocumentAsBooklet(_ url: URL, completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            autoreleasepool {
                if let originalPDF = PDFDocument(url: url) {
                    originalPDF.converTo(booklet: .type2B2, completion: completion)
                }
            }
        }
    }
}
