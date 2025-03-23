//
//  PrintButton.swift
//  bookletPdf
//
//  Created on 22/03/25.
//

import SwiftUI
import PDFKit

struct PrintButton: View {
    var documentURL: URL?
    var isEnabled: Bool
    
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
            Text("""
            When the print dialog appears:
            
            1. Select "Pages per Sheet: 2" in the Layout section
            2. Choose appropriate orientation for your booklet
            3. For best results with double-sided printing:
               - First print odd pages
               - Then flip paper and print even pages
            """)
        }
        .alert("Print Error", isPresented: $showingPrintError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
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
extension MainView {
    var printToolbarButton: some View {
        PrintButton(
            documentURL: viewModel.document?.url,
            isEnabled: viewModel.document != nil && !viewModel.isConverting
        )
    }
}
