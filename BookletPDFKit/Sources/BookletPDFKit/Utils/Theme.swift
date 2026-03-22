//
//  Theme.swift
//  BookletPDFKit
//
//  Created by applebro on 11/05/25.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#endif

public enum Theme {
    // MARK: - Colors
    public enum Colors {
        // Background Colors - Adaptive to light/dark mode
        public static var background: Color {
            #if os(iOS)
            Color(.systemBackground)
            #elseif os(macOS)
            Color(nsColor: .windowBackgroundColor)
            #endif
        }
        public static var secondaryBackground: Color {
            #if os(iOS)
            Color(.secondarySystemBackground)
            #elseif os(macOS)
            Color(nsColor: .controlBackgroundColor)
            #endif
        }
        public static var tertiaryBackground: Color {
            #if os(iOS)
            Color(.tertiarySystemBackground)
            #elseif os(macOS)
            Color(nsColor: .underPageBackgroundColor)
            #endif
        }

        // Surface Colors with Glassmorphism - Adaptive
        public static var glassSurface: Color {
            background.opacity(0.8)
        }
        public static var glassBackground: Color {
            background.opacity(0.5)
        }

        // Primary Colors - Using accent color which adapts
        public static var primary: Color { Color.accentColor }
        public static var primaryLight: Color {
            Color.accentColor.opacity(0.8)
        }
        public static var primaryDark: Color {
            Color.accentColor.opacity(0.6)
        }

        // Text Colors - Using system labels that adapt
        public static var primaryText: Color {
            #if os(iOS)
            Color(.label)
            #elseif os(macOS)
            Color(nsColor: .labelColor)
            #endif
        }
        public static var secondaryText: Color {
            #if os(iOS)
            Color(.secondaryLabel)
            #elseif os(macOS)
            Color(nsColor: .secondaryLabelColor)
            #endif
        }
        public static var tertiaryText: Color {
            #if os(iOS)
            Color(.tertiaryLabel)
            #elseif os(macOS)
            Color(nsColor: .tertiaryLabelColor)
            #endif
        }

        // Semantic Colors
        public static var success: Color { Color.green }
        public static var warning: Color { Color.orange }
        public static var error: Color { Color.red }
        public static var info: Color { Color.blue }

        // Border and Divider Colors
        public static var border: Color {
            #if os(iOS)
            Color(.separator)
            #elseif os(macOS)
            Color(nsColor: .separatorColor)
            #endif
        }
        public static var divider: Color {
            #if os(iOS)
            Color(.separator).opacity(0.5)
            #elseif os(macOS)
            Color(nsColor: .separatorColor).opacity(0.5)
            #endif
        }
    }

    // MARK: - Typography (Dynamic Type)
    public enum Typography {
        public static let largeTitle = Font.largeTitle.weight(.semibold)
        public static let title = Font.title.weight(.medium)
        public static let title2 = Font.title2.weight(.medium)
        public static let title3 = Font.title3.weight(.regular)
        public static let headline = Font.headline.weight(.medium)
        public static let body = Font.body
        public static let bodyMedium = Font.body.weight(.regular)
        public static let callout = Font.callout
        public static let subheadline = Font.subheadline
        public static let footnote = Font.footnote
        public static let caption = Font.caption
        public static let caption2 = Font.caption2
    }

    // MARK: - Fonts (Fixed Size Presets)
    public enum Fonts {
        public static let heroTitle = Font.system(size: 24, weight: .semibold)
        public static let pageTitle = Font.system(size: 16, weight: .semibold)
        public static let sectionTitle = Font.system(size: 15, weight: .semibold)
        public static let cardTitle = Font.system(size: 15, weight: .semibold)
        public static let bodyBold = Font.system(size: 13, weight: .medium)
        public static let bodyMedium = Font.system(size: 15, weight: .regular)
        public static let cellTitle = Font.system(size: 14, weight: .medium)
        public static let cellBody = Font.system(size: 14, weight: .regular)
        public static let subtitle = Font.system(size: 13, weight: .regular)
        public static let caption = Font.system(size: 12, weight: .regular)
        public static let captionBold = Font.system(size: 12, weight: .medium)
        public static let badge = Font.system(size: 11, weight: .regular)
        public static let smallIcon = Font.system(size: 18, weight: .regular)
        public static let mediumIcon = Font.system(size: 28, weight: .regular)
    }

    // MARK: - Spacing
    public enum Spacing: Sendable {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    public enum CornerRadius: Sendable {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let icon: CGFloat = 14
        public static let large: CGFloat = 16
        public static let card: CGFloat = 18
        public static let xlarge: CGFloat = 20
        public static let section: CGFloat = 22
        public static let panel: CGFloat = 24
        public static let button: CGFloat = 28
        public static let container: CGFloat = 32
    }

    // MARK: - Layout
    public enum Layout: Sendable {
        public static let screenPadding: CGFloat = 20
        public static let sectionSpacing: CGFloat = 20
        public static let itemSpacing: CGFloat = 14
        public static let innerPaddingH: CGFloat = 20
        public static let innerPaddingV: CGFloat = 16
        public static let buttonPaddingV: CGFloat = 18
        public static let cardPadding: CGFloat = 14
        public static let iconSize: CGFloat = 42
        public static let smallIconSize: CGFloat = 32
    }

    // MARK: - Opacity
    public enum Opacity: Sendable {
        public static let subtle: Double = 0.05
        public static let tint: Double = 0.1
        public static let faded: Double = 0.3
        public static let half: Double = 0.5
        public static let muted: Double = 0.6
        public static let visible: Double = 0.7
    }

    // MARK: - Border
    public enum Border: Sendable {
        public static let thin: CGFloat = 1
        public static let thick: CGFloat = 2.5
    }

    // MARK: - Shadows
    public enum Shadows {
        public static let subtle = Shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        public static let soft = Shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        public static let medium = Shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        public static let strong = Shadow(color: .black.opacity(0.25), radius: 24, y: 12)
    }
}

// MARK: - Shadow Helper
public struct Shadow: Sendable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}
