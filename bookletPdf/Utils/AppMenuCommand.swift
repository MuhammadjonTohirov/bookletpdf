//
//  AppMenuCommand.swift
//  bookletPdf
//
//  Created by applebro on 22/03/25.
//

import Foundation
import SwiftUI

struct AppMenuCommands: Commands {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some Commands {
        CommandGroup(after: .printItem) {
            Button("Print Booklet...") {
                printCurrentDocument()
            }
            .keyboardShortcut("p", modifiers: [.command])
            .disabled(viewModel.document == nil || viewModel.isConverting)
        }
    }
    
    private func printCurrentDocument() {
        guard let documentURL = viewModel.document?.url else {
            #if os(macOS)
            let alert = NSAlert()
            alert.messageText = "No Document Open"
            alert.informativeText = "Please open a document first."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            #endif
            return
        }
        
        #if os(macOS)
        if let window = NSApplication.shared.keyWindow,
           let contentView = window.contentView {
            let _ = PrinterService.shared.printPDF(url: documentURL, from: contentView)
        } else {
            let _ = PrinterService.shared.printPDF(url: documentURL)
        }
        #endif
    }
}
