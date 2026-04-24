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

    #if os(iOS)
    /// Presents the iOS print sheet and resolves with whether the user
    /// actually sent the job to the printer. Used by the guided two-step
    /// flow to decide when to advance to the next side.
    @MainActor
    func printDocumentAwaitingCompletion(url: URL) async -> Bool {
        guard UIPrintInteractionController.isPrintingAvailable else { return false }

        let printController = UIPrintInteractionController.shared
        printController.printingItem = url

        return await withCheckedContinuation { continuation in
            printController.present(animated: true) { _, completed, _ in
                continuation.resume(returning: completed)
            }
        }
    }
    #endif
}
