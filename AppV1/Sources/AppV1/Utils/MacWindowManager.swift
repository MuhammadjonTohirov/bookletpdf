//
//  MacWindowManager.swift
//  bookletPdf
//

#if os(macOS)
import AppKit
import SwiftUI
import ObjectiveC

nonisolated(unsafe) private var windowDelegateKey: UInt8 = 0

enum MacWindowManager {

    /// Opens a SwiftUI view in a new macOS window and returns it.
    @discardableResult
    @MainActor
    static func openFullScreen(
        content: some View,
        title: String,
        autosaveName: String,
        onClose: @escaping () -> Void
    ) -> NSWindow {
        let hostingController = NSHostingController(rootView: content)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let delegate = WindowDelegate(onClose: onClose)

        window.title = title
        window.contentViewController = hostingController
        window.center()
        window.setFrameAutosaveName(autosaveName)
        window.isReleasedWhenClosed = false
        window.delegate = delegate
        window.makeKeyAndOrderFront(nil)

        // Retain the delegate via associated object since NSWindow.delegate is weak
        objc_setAssociatedObject(window, &windowDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return window
    }

    private class WindowDelegate: NSObject, NSWindowDelegate {
        private let onClose: () -> Void

        init(onClose: @escaping () -> Void) {
            self.onClose = onClose
        }

        func windowWillClose(_ notification: Notification) {
            onClose()
        }
    }
}
#endif
