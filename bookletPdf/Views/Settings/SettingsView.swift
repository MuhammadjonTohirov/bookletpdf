//
//  SettingsView.swift
//  bookletPdf
//
//  Created on 11/05/25.
//

import SwiftUI
import BookletPDFKit

struct SettingsView: View {
    var body: some View {
        #if os(macOS)
        MacSettingsView()
        #else
        iOSSettingsView()
        #endif
    }
}

#if os(iOS)
struct iOSSettingsView: View {
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
        if AppCache.shared.clearCache() {
            cacheCleared = true
            
            // Hide the success message after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                cacheCleared = false
            }
        }
    }
}
#endif

#if os(macOS)
struct MacSettingsView: View {
    @State private var showClearCacheConfirmation = false
    @State private var cacheCleared = false
    @State private var cacheSize: String = "Calculating..."
    
    // App version information
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "2"
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Cache Management Section
                    GroupBox(label: Label("Cache Management", systemImage: "folder.badge.gearshape")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PDF thumbnails are cached to improve performance. You can clear the cache to free up disk space.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                            
                            HStack {
                                Text("Current cache size:")
                                Text(cacheSize)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Calculate") {
                                    calculateCacheSize()
                                }
                                .buttonStyle(.link)
                            }
                            .padding(.top, 4)
                            
                            HStack {
                                Button(action: {
                                    showClearCacheConfirmation = true
                                }) {
                                    Label("Clear Cache", systemImage: "trash")
                                }
                                .controlSize(.large)
                                
                                Spacer()
                                
                                if cacheCleared {
                                    Label("Cache cleared successfully!", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.callout)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Help & Support Section
                    GroupBox(label: Label("Help & Support", systemImage: "questionmark.circle")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Need help with the app? Check out our help section for guides and troubleshooting tips.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                            
                            Button(action: {
                                openHelp()
                            }) {
                                Label("Open Help", systemImage: "book.pages")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .controlSize(.large)
                            .buttonStyle(.link)
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 24)
            }
            
            // App information footer
            VStack(spacing: 4) {
                Divider()
                
                HStack {
                    Image(systemName: "doc.viewfinder")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PDF Booklet Maker")
                            .font(.headline)
                        
                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("Powered by SBD LLC")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            calculateCacheSize()
        }
        .alert("Clear Cache", isPresented: $showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will clear all cached PDF thumbnails. Are you sure you want to continue?")
        }
    }
    
    private func openHelp() {
        // Navigate to help view - in the macOS version, we could open a separate window or push to the navigation stack
        if (NSApplication.shared.keyWindow?.windowController) != nil {
            // Simulate navigation to Help view (this would be implemented differently in a real app)
            NotificationCenter.default.post(name: NSNotification.Name("OpenHelpView"), object: nil)
        }
    }
    
    private func clearCache() {
        if AppCache.shared.clearCache() {
            cacheCleared = true
            cacheSize = "0 bytes"
            
            // Hide the success message after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                cacheCleared = false
            }
        }
    }
    
    private func calculateCacheSize() {
        cacheSize = "Calculating..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            let size = getCacheFolderSize()
            DispatchQueue.main.async {
                cacheSize = size
            }
        }
    }
    
    private func getCacheFolderSize() -> String {
        guard let versionUrl = AppCache.shared.versionUrl else { return "N/A" }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: versionUrl, includingPropertiesForKeys: [.fileSizeKey])
            
            let size = try contents.reduce(0) { (result, url) -> Int in
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                return result + (resourceValues.fileSize ?? 0)
            }
            
            // Format size to human-readable string
            return formatFileSize(size)
        } catch {
            return "Error calculating size"
        }
    }
    
    private func formatFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}
#endif
