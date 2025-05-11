//
//  SettingsView.swift
//  bookletPdf
//
//  Created on 11/05/25.
//

import SwiftUI
import BookletPDFKit

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        #if os(macOS)
        MacSettingsView(viewModel: viewModel)
        #else
        iOSSettingsView(viewModel: viewModel)
        #endif
    }
}

#if os(iOS)
struct iOSSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section("Cache") {
                Button(action: {
                    viewModel.showClearCacheConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Clear Cache")
                    }
                }
                .buttonStyle(.plain)
                
                HStack {
                    Text("Current cache size:")
                    Text(viewModel.cacheSize)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Refresh") {
                        viewModel.calculateCacheSize()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
                
                if viewModel.cacheCleared {
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
                    
                    Text("Version \(viewModel.appVersion) (\(viewModel.buildNumber))")
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
        .alert("Clear Cache", isPresented: $viewModel.showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("This will clear all cached PDF thumbnails. Are you sure you want to continue?")
        }
    }
}
#endif

#if os(macOS)
struct MacSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
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
                                Text(viewModel.cacheSize)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Calculate") {
                                    viewModel.calculateCacheSize()
                                }
                                .buttonStyle(.link)
                            }
                            .padding(.top, 4)
                            
                            HStack {
                                Button(action: {
                                    viewModel.showClearCacheConfirmation = true
                                }) {
                                    Label("Clear Cache", systemImage: "trash")
                                }
                                .controlSize(.large)
                                
                                Spacer()
                                
                                if viewModel.cacheCleared {
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
                                viewModel.openHelp()
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
                        
                        Text("Version \(viewModel.appVersion) (\(viewModel.buildNumber))")
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
        .alert("Clear Cache", isPresented: $viewModel.showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("This will clear all cached PDF thumbnails. Are you sure you want to continue?")
        }
    }
}
#endif

#if os(iOS)
#Preview("iOS Settings View") {
    NavigationStack {
        iOSSettingsView(viewModel: SettingsViewModel())
    }
}
#endif

#if os(macOS)
#Preview("macOS Settings View") {
    MacSettingsView(viewModel: SettingsViewModel())
}
#endif
