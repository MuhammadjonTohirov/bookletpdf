//
//  PrinterService.swift
//  bookletPdf
//
//  Created on 22/03/25.
//

import Foundation
import SwiftUI
import PDFKit

#if os(macOS)
import AppKit
#endif

protocol PrinterServiceProtocol {
    func printPDF(url: URL) -> Bool
}

class PrinterService: PrinterServiceProtocol {
    static let shared = PrinterService()
    
    private init() {}
    
    func printPDF(url: URL, from view: NSView) -> Bool {
#if os(macOS)
        // Create print operation from file URL
        let printOperation = NSPrintOperation(view: view, printInfo: NSPrintInfo.shared)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        
        // Run the print operation modally
        return printOperation.run()
#else
        return false
#endif
    }
    
    // Print PDF using shell command
    func printPDF(url: URL) -> Bool {
        #if os(macOS)
        // This is the most direct approach - using the system print command
        let process = Process()
        process.launchPath = "/usr/bin/lpr"
        process.arguments = [url.path]
        
        do {
            try process.run()
            return true
        } catch {
            NSLog("Failed to print: \(error.localizedDescription)")
            
            // Fallback - just open the PDF in Preview
            NSWorkspace.shared.open(url)
            return false
        }
        #else
        return false
        #endif
    }
    
    // Alternative function that shows instructions then opens Preview for printing
    func printPDFWithPreview(url: URL) -> Bool {
        #if os(macOS)
        showBookletPrintInstructions()
        
        // Open in Preview which has reliable printing support
        NSWorkspace.shared.open(url)
        return true
        #else
        return false
        #endif
    }
    
    #if os(macOS)
    private func showBookletPrintInstructions() {
        let alert = NSAlert()
        alert.messageText = "Booklet Printing Instructions"
        alert.informativeText = """
        The document will open in Preview. When printing:
        
        1. Press Command+P or select File > Print
        2. In the "Layout" section, set "Pages per Sheet" to 2
        3. Select appropriate "Layout Direction"
        4. For duplex printing:
           - First print odd pages only
           - Then flip the paper and print even pages only
        
        These settings will create the proper booklet layout.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    #endif
}
