//
//  PDFComparisonViewModel.swift
//  bookletPdf
//
//  ViewModel for PDF comparison functionality
//

import SwiftUI
import PDFKit
import Combine

@MainActor
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

        fullScreenWindow = MacWindowManager.openFullScreen(
            content: contentView,
            title: title,
            autosaveName: "PDFComparisonWindow"
        ) { [weak self] in
            self?.fullScreenWindow = nil
        }
    }
    #endif
}
