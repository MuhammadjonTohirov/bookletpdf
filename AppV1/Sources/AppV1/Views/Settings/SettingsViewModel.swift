//
//  SettingsViewModel.swift
//  bookletPdf
//
//  Created on 11/05/25.
//

import Foundation
import SwiftUI
import Combine
import BookletPDFKit
import BookletCore

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var cacheSize: String = String(localized: "str.calculating")
    @Published var showClearCacheConfirmation = false
    @Published var cacheCleared = false
    @Published var selectedLanguage: Language = UserSettings.language ?? .english

    let appVersion = Bundle.main.appVersion
    let buildNumber = Bundle.main.buildNumber

    private let cache: AppCacheProtocol
    private var cancellables = Set<AnyCancellable>()

    init(cache: AppCacheProtocol = AppCache.shared) {
        self.cache = cache
        calculateCacheSize()

        $selectedLanguage
            .dropFirst()
            .sink { newLanguage in
                UserSettings.language = newLanguage
            }
            .store(in: &cancellables)

        $cacheCleared
            .filter { $0 == true }
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .seconds(3))
                    self?.cacheCleared = false
                }
            }
            .store(in: &cancellables)
    }

    func calculateCacheSize() {
        cacheSize = String(localized: "str.calculating")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let size = self.cache.cacheFolderSize()
            DispatchQueue.main.async {
                self.cacheSize = size
            }
        }
    }

    func clearCache() {
        if cache.clearCache() {
            cacheCleared = true
            cacheSize = String(localized: "str.zero_bytes")
        }
    }

    var availableLanguages: [Language] {
        [.english, .france, .germany, .uzbek]
    }
}
