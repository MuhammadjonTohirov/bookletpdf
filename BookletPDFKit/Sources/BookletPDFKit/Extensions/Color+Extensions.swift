//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

public extension Color {
    #if os(macOS)
    init(uiColor: NSColor) {
        self.init(nsColor: uiColor)
    }
    #endif
}

#if canImport(AppKit)

public extension NSColor {
    // Standard Colors
    static var systemRed: NSColor { NSColor(named: "systemRed") ?? NSColor(red: 1.0, green: 0.23, blue: 0.188, alpha: 1.0) }
    static var systemGreen: NSColor { NSColor(named: "systemGreen") ?? NSColor(red: 0.298, green: 0.851, blue: 0.392, alpha: 1.0) }
    static var systemBlue: NSColor { NSColor(named: "systemBlue") ?? NSColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0) }
    static var systemOrange: NSColor { NSColor(named: "systemOrange") ?? NSColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 1.0) }
    static var systemYellow: NSColor { NSColor(named: "systemYellow") ?? NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) }
    static var systemPink: NSColor { NSColor(named: "systemPink") ?? NSColor(red: 1.0, green: 0.176, blue: 0.333, alpha: 1.0) }
    static var systemPurple: NSColor { NSColor(named: "systemPurple") ?? NSColor(red: 0.686, green: 0.321, blue: 0.871, alpha: 1.0) }
    static var systemTeal: NSColor { NSColor(named: "systemTeal") ?? NSColor(red: 0.0, green: 0.737, blue: 0.831, alpha: 1.0) }
    static var systemIndigo: NSColor { NSColor(named: "systemIndigo") ?? NSColor(red: 0.345, green: 0.337, blue: 0.839, alpha: 1.0) }
    static var systemGray: NSColor { NSColor(named: "systemGray") ?? NSColor(red: 0.556, green: 0.556, blue: 0.576, alpha: 1.0) }

    // System Backgrounds
    static var systemBackground: NSColor {
        NSColor(named: "systemBackground") ?? NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    static var secondarySystemBackground: NSColor {
        NSColor(named: "secondarySystemBackground") ?? NSColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    }
    static var tertiarySystemBackground: NSColor {
        NSColor(named: "tertiarySystemBackground") ?? NSColor(red: 0.89, green: 0.89, blue: 0.91, alpha: 1.0)
    }

    // Labels
    static var label: NSColor {
        NSColor(named: "label") ?? NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    static var secondaryLabel: NSColor {
        NSColor(named: "secondaryLabel") ?? NSColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
    }
    static var tertiaryLabel: NSColor {
        NSColor(named: "tertiaryLabel") ?? NSColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0)
    }
    static var quaternaryLabel: NSColor {
        NSColor(named: "quaternaryLabel") ?? NSColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0)
    }

    // Fill Colors
    static var systemFill: NSColor {
        NSColor(named: "systemFill") ?? NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    }
    static var secondarySystemFill: NSColor {
        NSColor(named: "secondarySystemFill") ?? NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    }
    static var tertiarySystemFill: NSColor {
        NSColor(named: "tertiarySystemFill") ?? NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }
    static var quaternarySystemFill: NSColor {
        NSColor(named: "quaternarySystemFill") ?? NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    }
}

#endif
