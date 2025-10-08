//
//  Theme.swift
//  BookletPDFKit
//
//  Created by applebro on 11/05/25.
//

import Foundation
import SwiftUI

public enum Theme {
    // MARK: - Colors
    public enum Colors {
        // Background Colors - Adaptive to light/dark mode
        public static var background: Color { Color(.systemBackground) }
        public static var secondaryBackground: Color { Color(.secondarySystemBackground) }
        public static var tertiaryBackground: Color { Color(.tertiarySystemBackground) }
        
        // Surface Colors with Glassmorphism - Adaptive
        public static var glassSurface: Color {
            Color(.systemBackground).opacity(0.8)
        }
        public static var glassBackground: Color {
            Color(.systemBackground).opacity(0.5)
        }
        
        // Primary Colors - Using accent color which adapts
        public static var primary: Color { Color.accentColor }
        public static var primaryLight: Color {
            Color.accentColor.opacity(0.8)
        }
        public static var primaryDark: Color {
            Color.accentColor.opacity(0.6) // Adjusted for dark mode
        }
        
        // Text Colors - Using system labels that adapt
        public static var primaryText: Color { Color(.label) }
        public static var secondaryText: Color { Color(.secondaryLabel) }
        public static var tertiaryText: Color { Color(.tertiaryLabel) }
        
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
            Color(uiColor: .separatorColor)
            #endif
        }
        public static var divider: Color {
            #if os(iOS)
            Color(.separator).opacity(0.5)
            #elseif os(macOS)
            Color(uiColor: .separatorColor).opacity(0.5)
            #endif
        }
    }
    
    // MARK: - Typography
    public enum Typography {
        public static let largeTitle = Font.largeTitle.weight(.bold)
        public static let title = Font.title.weight(.semibold)
        public static let title2 = Font.title2.weight(.semibold)
        public static let title3 = Font.title3.weight(.medium)
        public static let headline = Font.headline.weight(.semibold)
        public static let body = Font.body
        public static let bodyMedium = Font.body.weight(.medium)
        public static let callout = Font.callout
        public static let subheadline = Font.subheadline
        public static let footnote = Font.footnote
        public static let caption = Font.caption
        public static let caption2 = Font.caption2
    }
    
    // MARK: - Spacing
    public enum Spacing : Sendable {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    public enum CornerRadius : Sendable {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let xlarge: CGFloat = 20
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
public struct Shadow : Sendable {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}
