import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

final class PrinterService: @unchecked Sendable {
    static let shared = PrinterService()
    private init() {}

    @MainActor
    func printDocument(url: URL) -> Bool {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        return true
        #elseif os(iOS)
        guard UIPrintInteractionController.isPrintingAvailable else { return false }

        let printController = UIPrintInteractionController.shared
        printController.printingItem = url
        printController.present(animated: true)
        return true
        #else
        return false
        #endif
    }
}
