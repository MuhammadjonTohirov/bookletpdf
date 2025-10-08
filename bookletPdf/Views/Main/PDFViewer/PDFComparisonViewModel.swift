//
//  PDFComparisonViewModel.swift
//  bookletPdf
//
//  ViewModel for PDF comparison functionality
//

import SwiftUI
import PDFKit
import Combine

#if os(macOS)
import AppKit
#endif

class PDFComparisonViewModel: ObservableObject {
    @Published var showFullScreen = false
    @Published var selectedDocument: PDFDocument?
    @Published var selectedTitle: String = ""
    #if os(macOS)
    @Published var fullScreenWindow: NSWindow?
    #endif
    
    private let originalDocument: PDFDocument
    private let convertedDocument: PDFDocument
    private let originalTitle: String
    private let convertedTitle: String
    
    init(originalDocument: PDFDocument, convertedDocument: PDFDocument, originalTitle: String, convertedTitle: String) {
        self.originalDocument = originalDocument
        self.convertedDocument = convertedDocument
        self.originalTitle = originalTitle
        self.convertedTitle = convertedTitle
    }
    
    func openFullScreen(document: PDFDocument, title: String) {
        selectedDocument = document
        selectedTitle = title
        
        #if os(iOS)
        showFullScreen = true
        #else
        openMacFullScreen(document: document, title: title)
        #endif
    }
    
    func openConvertedFullScreen() {
        openFullScreen(document: convertedDocument, title: convertedTitle)
    }
    
    #if os(macOS)
    private func openMacFullScreen(document: PDFDocument, title: String) {
        let contentView = FullScreenPDFView(
            document: document,
            initialPage: 0,
            title: title
        )
        
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = title
        window.contentViewController = hostingController
        window.center()
        window.setFrameAutosaveName("PDFComparisonWindow")
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        
        // Store reference to prevent deallocation
        fullScreenWindow = window
        
        // Close window when done
        fullScreenWindow?.delegate = WindowDelegate { [weak self] in
            self?.fullScreenWindow = nil
        }
    }
    
    private class WindowDelegate: NSObject, NSWindowDelegate {
        private let onClose: () -> Void
        
        init(onClose: @escaping () -> Void) {
            self.onClose = onClose
        }
        
        func windowWillClose(_ notification: Notification) {
            onClose()
        }
    }
    #endif
}
