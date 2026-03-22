import Foundation
import SwiftUI

public struct AppMenuCommands: Commands {
    @ObservedObject var viewModel: DocumentConvertViewModel

    public init(viewModel: DocumentConvertViewModel) {
        self.viewModel = viewModel
    }

    public var body: some Commands {
        CommandGroup(after: .printItem) {
            Button("str.print_booklet_menu") {
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
            alert.messageText = String(localized: "str.no_document_open")
            alert.informativeText = String(localized: "str.open_document_first")
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            #endif
            return
        }

        #if os(macOS)
        let _ = PrinterService.shared.printDocument(url: documentURL)
        #endif
    }
}
