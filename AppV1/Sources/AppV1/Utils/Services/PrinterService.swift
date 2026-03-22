//
//  PrinterService.swift
//  bookletPdf
//
//  Created on 22/03/25.
//

import Foundation

#if os(macOS)
import AppKit
#endif

protocol PrinterServiceProtocol {
    func printDocument(url: URL) -> Bool
}

final class PrinterService: PrinterServiceProtocol, @unchecked Sendable {
    static let shared = PrinterService()

    private init() {}

    func printDocument(url: URL) -> Bool {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        return true
        #else
        return false
        #endif
    }
}
