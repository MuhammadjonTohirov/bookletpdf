//
//  PrintButton.swift
//  bookletPdf
//
//  Created on 22/03/25.
//

import SwiftUI
import BookletCore
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
        .help(Text("str.print_document"))
        .disabled(!isEnabled)
        .alert(Text("str.printing_instructions_title"), isPresented: $showingInstructions) {
            Button("str.cancel", role: .cancel) { }
            Button("str.print") {
                printDocument()
            }
        } message: {
            Text(bookletType == .type2 ? twoInOneInstructions : fourInOneInstructions)
        }
        // Rest of implementation...
    }
    
    private var twoInOneInstructions: LocalizedStringKey {
        "str.printing_instructions_2in1"
    }
    
    private var fourInOneInstructions: LocalizedStringKey {
        "str.printing_instructions_4in1"
    }
    
    private func printDocument() {
        guard let url = documentURL, isEnabled else {
            showError(message: String(localized: "str.no_document_for_printing"))
            return
        }
        
        let _ = PrinterService.shared.printDocument(url: url)
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