//
//  SettingsView.swift
//  bookletPdf
//
//  Created on 11/05/25.
//

import SwiftUI
import BookletPDFKit
import BookletCore

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
            Section("str.language") {
                NavigationLink(destination: LanguageSelectionView(viewModel: viewModel)) {
                    HStack {
                        Image(systemName: "globe")
                        Text("str.select_language")
                        Spacer()
                        Text(viewModel.selectedLanguage.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("str.cache") {
                Button(action: {
                    viewModel.showClearCacheConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("str.clear_cache")
                    }
                }
                .buttonStyle(.plain)
                
                HStack {
                    Text("str.current_cache_size")
                    Text(viewModel.cacheSize)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("str.refresh") {
                        viewModel.calculateCacheSize()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
                
                if viewModel.cacheCleared {
                    Text("str.cache_cleared_success")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
            
            Section("str.help_support") {
                NavigationLink(destination: InfoView()) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("str.help")
                    }
                }
            }
            
            // App information at the bottom
            Section {
                VStack(alignment: .center, spacing: 4) {
                    Text("str.app_name")
                        .font(.headline)
                    
                    Text(String(format: String(localized: "str.version_format"), viewModel.appVersion, viewModel.buildNumber))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("str.powered_by")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(Text("str.settings"))
        .alert(Text("str.clear_cache"), isPresented: $viewModel.showClearCacheConfirmation) {
            Button("str.cancel", role: .cancel) { }
            Button("str.clear", role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("str.clear_cache_confirmation")
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
                    // Language Selection Section
                    GroupBox(label: Label("str.language", systemImage: "globe")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("str.language_description")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                            
                            LanguageSelectionView(viewModel: viewModel)
                            .padding(.top, 4)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Cache Management Section
                    GroupBox(label: Label("str.cache_management", systemImage: "folder.badge.gearshape")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("str.cache_description")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                            
                            HStack {
                                Text("str.current_cache_size")
                                Text(viewModel.cacheSize)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("str.calculate") {
                                    viewModel.calculateCacheSize()
                                }
                                .buttonStyle(.link)
                            }
                            .padding(.top, 4)
                            
                            HStack {
                                Button(action: {
                                    viewModel.showClearCacheConfirmation = true
                                }) {
                                    Label("str.clear_cache", systemImage: "trash")
                                }
                                .controlSize(.large)
                                
                                Spacer()
                                
                                if viewModel.cacheCleared {
                                    Label("str.cache_cleared_success", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.callout)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    // Help & Support Section
                    GroupBox(label: Label("str.help_support", systemImage: "questionmark.circle")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("str.help_description")
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                            
                            Button(action: {
                                #if os(macOS)
                                NotificationCenter.default.post(name: NSNotification.Name("OpenHelpView"), object: nil)
                                #endif
                            }) {
                                Label("open.help".localize, systemImage: "book.pages")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .controlSize(.large)
                            .buttonStyle(.link)
                            .padding(.top, 4)
                        }
                        .padding()
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
                        Text("str.app_name")
                            .font(.headline)
                        
                        Text(String(format: String(localized: "str.version_format"), viewModel.appVersion, viewModel.buildNumber))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("str.powered_by")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .alert(Text("str.clear_cache"), isPresented: $viewModel.showClearCacheConfirmation) {
            Button("str.cancel", role: .cancel) { }
            Button("str.clear", role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("str.clear_cache_confirmation")
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
