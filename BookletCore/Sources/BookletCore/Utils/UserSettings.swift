//
//  File.swift
//  Core
//
//  Created by Muhammadjon Tohirov on 11/09/25.
//

import Foundation
@preconcurrency import Combine

public actor UserSettings {

    // Language change notification
    public static let languageDidChange = PassthroughSubject<Language, Never>()

    public static let themeStorageKey = "appTheme"
    public static let suiteName = "uz.sbd.bookletPdf"

    static public var language: Language? {
        get {
            @codableWrapper(key: "language", Language.english)
            var language: Language?

            return language
        }

        set {
            @codableWrapper(key: "language", Language.english)
            var language: Language?

            language = newValue

            // Notify observers of language change
            if let newValue = newValue {
                languageDidChange.send(newValue)
            }
        }
    }

    static public var theme: AppTheme {
        get {
            let raw = UserDefaults(suiteName: suiteName)?.integer(forKey: themeStorageKey) ?? 0
            return AppTheme(rawValue: raw) ?? .system
        }

        set {
            UserDefaults(suiteName: suiteName)?.set(newValue.rawValue, forKey: themeStorageKey)
        }
    }
}
