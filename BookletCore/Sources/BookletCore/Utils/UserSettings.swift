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
}
