//
//  SettingsView.swift
//  bookletPdf
//
//  Created on 11/05/25.
//

import SwiftUI
import BookletPDFKit

struct SettingsView: View {
    @State private var showClearCacheConfirmation = false
    @State private var cacheCleared = false
    
    // App version information
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        Form {
            Section("Cache") {
                Button(action: {
                    showClearCacheConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Clear Cache")
                    }
                }
                .buttonStyle(.plain)
                
                if cacheCleared {
                    Text("Cache cleared successfully!")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
            
            Section("Help & Support") {
                NavigationLink(destination: InfoView()) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("Help")
                    }
                }
            }
            
            // App information at the bottom
            Section {
                VStack(alignment: .center, spacing: 4) {
                    Text("PDF Booklet Maker")
                        .font(.headline)
                    
                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Powered by SBD LLC")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Settings")
        .alert("Clear Cache", isPresented: $showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will clear all cached PDF thumbnails. Are you sure you want to continue?")
        }
    }
    
    private func clearCache() {
        // Access the app cache and clear it
        let cacheURL = AppCache.shared.versionUrl
        
        do {
            if let cacheURL = cacheURL, FileManager.default.fileExists(atPath: cacheURL.path) {
                let contents = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
                for fileURL in contents {
                    try FileManager.default.removeItem(at: fileURL)
                }
                
                cacheCleared = true
                
                // Hide the success message after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    cacheCleared = false
                }
            }
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView()
    }
}
#endif
