//
//  AppMenuCommand.swift
//  bookletPdf
//
//  Created by applebro on 22/03/25.
//

import Foundation
import SwiftUI
import BookletCore

struct AppMenuCommands: Commands {
    @ObservedObject var viewModel: DocumentConvertViewModel
    
    var body: some Commands {
        CommandGroup(after: .printItem) {
            Button("str.print_booklet_menu".localize) {
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
            alert.messageText = "str.no_document_open".localize
            alert.informativeText = "str.open_document_first".localize
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
