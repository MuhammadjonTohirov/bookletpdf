import Foundation
import SwiftUI
import BookletCore

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var cacheSize: String = String(localized: "str.calculating")
    @Published var showClearCacheConfirmation = false
    @Published var cacheCleared = false
    @Published var selectedLanguage: Language = UserSettings.language ?? .english {
        didSet {
            guard selectedLanguage != oldValue else { return }
            DispatchQueue.main.async {
                UserSettings.language = self.selectedLanguage
            }
        }
    }

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    private let cache: AppCacheProtocol

    init(cache: AppCacheProtocol = AppCache.shared) {
        self.cache = cache
    }

    func onAppear() {
        calculateCacheSize()
    }

    func calculateCacheSize() {
        cacheSize = String(localized: "str.calculating")
        let cache = self.cache
        Task.detached {
            let size = cache.cacheFolderSize()
            await MainActor.run { [weak self] in
                self?.cacheSize = size
            }
        }
    }

    func clearCache() {
        if cache.clearCache() {
            RecentConversionsStore.shared.clear()
            cacheCleared = true
            cacheSize = String(localized: "str.zero_bytes")

            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(3))
                self?.cacheCleared = false
            }
        }
    }

    var availableLanguages: [Language] {
        [.english, .france, .germany, .uzbek]
    }
}
