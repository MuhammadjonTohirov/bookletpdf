import Foundation
import SwiftUI
import BookletCore

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
            alert.messageText = "str.no_document_open".localize
            alert.informativeText = "str.open_document_first".localize
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
