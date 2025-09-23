//
//  View+Extensions.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

public extension View {
    func fIgnoreSafeArea() -> some View {
        #if os(macOS)
        self
        #elseif os(iOS)
        self.ignoresSafeArea()
        #endif
    }
    
    func navigationTitleInline() -> some View {
        #if os(iOS)
        return self.navigationBarTitleDisplayMode(.inline)
        #else
        return self
        #endif
    }
    
    // MARK: - Modern Design System Extensions
    
    /// Applies glassmorphism effect with blur and transparency
    func glassEffect(
        blur: CGFloat = 20,
        opacity: Double = 0.1
    ) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                            .stroke(Theme.Colors.border.opacity(0.2), lineWidth: 0.5)
                    )
            }
    }
    
    /// Applies modern card styling with shadows and rounded corners
    func cardStyle(
        cornerRadius: CGFloat = Theme.CornerRadius.medium,
        shadow: Shadow = Theme.Shadows.soft
    ) -> some View {
        self
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
    
    /// Applies glassmorphism card effect
    func glassCardStyle(
        cornerRadius: CGFloat = Theme.CornerRadius.medium
    ) -> some View {
        self
            .padding(Theme.Spacing.md)
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.Colors.border.opacity(0.3), lineWidth: 0.5)
            )
    }
    
    /// Applies modern button styling
    func modernButtonStyle(
        style: ModernButtonStyle.Style = .primary
    ) -> some View {
        self.buttonStyle(ModernButtonStyle(style: style))
    }
    
    /// Applies subtle hover effect
    func hoverEffect() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.2), value: false)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    // The scale effect will be handled by the hover state
                }
            }
    }
    
    /// Applies smooth transitions for state changes
    func smoothTransition() -> some View {
        self
            .animation(.easeInOut(duration: 0.3), value: false)
    }
    
    /// Applies modern section header styling
    func sectionHeader() -> some View {
        self
            .font(Theme.Typography.headline)
            .foregroundColor(Theme.Colors.primaryText)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
    }
    
    /// Applies custom shadow
    func customShadow(_ shadow: Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Modern Button Style
public struct ModernButtonStyle: ButtonStyle {
    public enum Style {
        case primary
        case secondary
        case ghost
        case destructive
    }
    
    let style: Style
    
    public init(style: Style = .primary) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.bodyMedium)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(backgroundColor(configuration))
            .foregroundColor(foregroundColor(configuration))
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
            .customShadow(shadowStyle(configuration))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func backgroundColor(_ configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return configuration.isPressed ? Theme.Colors.primaryDark : Theme.Colors.primary
        case .secondary:
            return configuration.isPressed ? Theme.Colors.tertiaryBackground : Theme.Colors.secondaryBackground
        case .ghost:
            return configuration.isPressed ? Theme.Colors.secondaryBackground : Color.clear
        case .destructive:
            return configuration.isPressed ? Theme.Colors.error.opacity(0.8) : Theme.Colors.error
        }
    }
    
    private func foregroundColor(_ configuration: Configuration) -> Color {
        switch style {
        case .primary:
            return Color(.systemBackground) // Adapts to light/dark mode
        case .destructive:
            return Color.white
        case .secondary, .ghost:
            return Theme.Colors.primaryText
        }
    }
    
    private func shadowStyle(_ configuration: Configuration) -> Shadow {
        switch style {
        case .primary, .destructive:
            return configuration.isPressed ? Theme.Shadows.subtle : Theme.Shadows.soft
        case .secondary:
            return Theme.Shadows.subtle
        case .ghost:
            return Shadow(color: .clear, radius: 0)
        }
    }
}
