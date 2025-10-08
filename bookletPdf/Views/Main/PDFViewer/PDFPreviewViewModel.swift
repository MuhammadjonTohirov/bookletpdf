//
//  PDFPreviewViewModel.swift
//  bookletPdf
//
//  ViewModel for PDF preview functionality
//

import SwiftUI
import PDFKit
import Combine

#if os(macOS)
import AppKit
#endif

class PDFPreviewViewModel: ObservableObject {
    @Published var selectedPageIndex: Int = 0
    @Published var showFullScreen: Bool = false
    #if os(macOS)
    @Published var fullScreenWindow: NSWindow?
    #endif
    private let document: PDFDocument
    private let title: String
    
    init(document: PDFDocument, title: String) {
        self.document = document
        self.title = title
    }
    
    func selectPage(_ pageIndex: Int) {
        selectedPageIndex = pageIndex
        openFullScreen()
    }
    
    private func openFullScreen() {
        #if os(iOS)
        showFullScreen = true
        #else
        openMacFullScreen()
        #endif
    }
    
    #if os(macOS)
    private func openMacFullScreen() {
        let contentView = FullScreenPDFView(
            document: document,
            initialPage: selectedPageIndex,
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
        window.setFrameAutosaveName("PDFFullScreenWindow")
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
    
    var adaptiveColumnCount: Int {
        #if os(macOS)
        return 4
        #else
        return 2
        #endif
    }
}
