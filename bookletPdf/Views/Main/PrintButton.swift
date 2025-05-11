//
//  PrintButton.swift
//  bookletPdf
//
//  Created on 22/03/25.
//

import SwiftUI
import PDFKit
import BookletPDFKit

struct PrintButton: View {
    var documentURL: URL?
    var isEnabled: Bool
    var bookletType: BookletType // Add this parameter
    
    @State private var showingPrintError = false
    @State private var errorMessage = ""
    @State private var showingInstructions = false
    
    var body: some View {
        Button(action: {
            showingInstructions = true
        }) {
            Image(systemName: "printer")
                .imageScale(.medium)
        }
        .help("Print document")
        .disabled(!isEnabled)
        .alert("Booklet Printing Instructions", isPresented: $showingInstructions) {
            Button("Cancel", role: .cancel) { }
            Button("Print") {
                printDocument()
            }
        } message: {
            Text(bookletType == .type2 ? twoInOneInstructions : fourInOneInstructions)
        }
        // Rest of implementation...
    }
    
    private var twoInOneInstructions: String {
            """
            When the print dialog appears:
            
            1. Select "Pages per Sheet: 2" in the Layout section
            2. Choose appropriate orientation for your booklet
            3. For best results with double-sided printing:
               - First print odd pages
               - Then flip paper and print even pages
            """
    }
    
    private var fourInOneInstructions: String {
            """
            For 4-in-1 booklet printing:
            
            1. Select "Pages per Sheet: 1" (pages are already arranged 4-up)
            2. Set paper orientation to match your document
            3. For double-sided printing:
               - Print all pages
               - Ensure "Print on both sides" is selected
               - Choose "Flip on short edge" binding option
            4. After printing, fold pages in half twice to create your booklet
            """
    }
    
    private func printDocument() {
        guard let url = documentURL, isEnabled else {
            showError(message: "No document is currently open for printing.")
            return
        }
        
        let _ = PrinterService.shared.printPDFWithPreview(url: url)
    }
    
    private func showError(message: String) {
        errorMessage = message
        showingPrintError = true
    }
}

// Extension to MainView to add the print button
extension DocumentConvertView {
    var printToolbarButton: some View {
        #if os(macOS)
        PrintButton(
            documentURL: viewModel.document?.url,
            isEnabled: viewModel.document != nil && !viewModel.isConverting,
            bookletType: viewModel.bookletType  // Update this line to use the selected type
        )
        #else
        EmptyView()
        #endif
    }
}
