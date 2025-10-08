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

class SettingsViewModel: ObservableObject {
    // UI state
    @Published var cacheSize: String = "str.calculating".localize
    @Published var showClearCacheConfirmation = false
    @Published var cacheCleared = false
    @Published var selectedLanguage: Language = UserSettings.language ?? .english
    
    // App version information
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        calculateCacheSize()
        
        // Listen to language changes
        $selectedLanguage
            .dropFirst() // Skip the initial value
            .sink { newLanguage in
                UserSettings.language = newLanguage
            }
            .store(in: &cancellables)
        
        // Reset the cacheCleared flag after 3 seconds once it becomes true
        $cacheCleared
            .filter { $0 == true }
            .sink { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.cacheCleared = false
                }
            }
            .store(in: &cancellables)
    }
    
    func calculateCacheSize() {
        cacheSize = "str.calculating".localize
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let size = self?.getCacheFolderSize() ?? "str.cache_error".localize
            DispatchQueue.main.async {
                self?.cacheSize = size
            }
        }
    }
    
    func clearCache() {
        if AppCache.shared.clearCache() {
            cacheCleared = true
            cacheSize = "str.zero_bytes".localize
        }
    }
    
    private func getCacheFolderSize() -> String {
        guard let versionUrl = AppCache.shared.versionUrl else { return "str.cache_not_available".localize }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: versionUrl, includingPropertiesForKeys: [.fileSizeKey])
            
            let size = try contents.reduce(0) { (result, url) -> Int in
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                return result + (resourceValues.fileSize ?? 0)
            }
            
            // Format size to human-readable string
            return formatFileSize(size)
        } catch {
            return "str.cache_size_error".localize
        }
    }
    
    private func formatFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
    
    // Language management
    var availableLanguages: [Language] {
        [.english, .france, .germany, .uzbek]
    }
    
    // Helper method to open Help view
    func openHelp() {
        #if os(macOS)
        // Notify the app to open the help view
        NotificationCenter.default.post(name: NSNotification.Name("OpenHelpView"), object: nil)
        #endif
        // For iOS, this is handled through navigation
    }
}
