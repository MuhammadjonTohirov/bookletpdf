//
//  LanguageManager.swift
//  bookletPdf
//
//  Created on 11/09/25.
//

import SwiftUI
import Combine
import BookletCore

class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with stored language or default to English
        self.currentLanguage = UserSettings.language ?? .english
        
        // Listen for language changes
        UserSettings.languageDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLanguage in
                self?.currentLanguage = newLanguage
            }
            .store(in: &cancellables)
    }
    
    func changeLanguage(_ language: Language) {
        UserSettings.language = language
    }
}