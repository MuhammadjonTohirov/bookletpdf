import SwiftUI

public enum AppTheme: Int, Codable, CaseIterable, Sendable {
    case system = 0
    case light
    case dark

    public var name: String {
        switch self {
        case .system: String(localized: "str.theme_system")
        case .light: String(localized: "str.theme_light")
        case .dark: String(localized: "str.theme_dark")
        }
    }

    public var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
