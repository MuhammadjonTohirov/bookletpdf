//
//  PDFPreviewViewModel.swift
//  bookletPdf
//
//  ViewModel for PDF preview functionality
//

import SwiftUI
import PDFKit
import Combine

@MainActor
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

        fullScreenWindow = MacWindowManager.openFullScreen(
            content: contentView,
            title: title,
            autosaveName: "PDFFullScreenWindow"
        ) { [weak self] in
            self?.fullScreenWindow = nil
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
