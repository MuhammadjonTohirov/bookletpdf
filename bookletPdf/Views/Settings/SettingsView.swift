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
            Section("str.language".localize) {
                NavigationLink(destination: LanguageSelectionView(viewModel: viewModel)) {
                    HStack {
                        Image(systemName: "globe")
                        Text("str.select_language".localize)
                        Spacer()
                        Text(viewModel.selectedLanguage.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("str.cache".localize) {
                Button(action: {
                    viewModel.showClearCacheConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("str.clear_cache".localize)
                    }
                }
                .buttonStyle(.plain)
                
                HStack {
                    Text("str.current_cache_size".localize)
                    Text(viewModel.cacheSize)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("str.refresh".localize) {
                        viewModel.calculateCacheSize()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                }
                
                if viewModel.cacheCleared {
                    Text("str.cache_cleared_success".localize)
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
            
            Section("str.help_support".localize) {
                NavigationLink(destination: InfoView()) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("str.help".localize)
                    }
                }
            }
            
            // App information at the bottom
            Section {
                VStack(alignment: .center, spacing: 4) {
                    Text("str.app_name".localize)
                        .font(.headline)
                    
                    Text("str.version_format".localize.localize(arguments: viewModel.appVersion, viewModel.buildNumber))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("str.powered_by".localize)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("str.settings".localize)
        .alert("str.clear_cache".localize, isPresented: $viewModel.showClearCacheConfirmation) {
            Button("str.cancel".localize, role: .cancel) { }
            Button("str.clear".localize, role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("str.clear_cache_confirmation".localize)
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
                    GroupBox(label: Label("str.language".localize, systemImage: "globe")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("str.language_description".localize)
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
                    GroupBox(label: Label("str.cache_management".localize, systemImage: "folder.badge.gearshape")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("str.cache_description".localize)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 4)
                            
                            Divider()
                            
                            HStack {
                                Text("str.current_cache_size".localize)
                                Text(viewModel.cacheSize)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("str.calculate".localize) {
                                    viewModel.calculateCacheSize()
                                }
                                .buttonStyle(.link)
                            }
                            .padding(.top, 4)
                            
                            HStack {
                                Button(action: {
                                    viewModel.showClearCacheConfirmation = true
                                }) {
                                    Label("str.clear_cache".localize, systemImage: "trash")
                                }
                                .controlSize(.large)
                                
                                Spacer()
                                
                                if viewModel.cacheCleared {
                                    Label("str.cache_cleared_success".localize, systemImage: "checkmark.circle.fill")
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
                    GroupBox(label: Label("str.help_support".localize, systemImage: "questionmark.circle")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("str.help_description".localize)
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
                        Text("str.app_name".localize)
                            .font(.headline)
                        
                        Text("str.version_format".localize.localize(arguments: viewModel.appVersion, viewModel.buildNumber))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("str.powered_by".localize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .alert("str.clear_cache".localize, isPresented: $viewModel.showClearCacheConfirmation) {
            Button("str.cancel".localize, role: .cancel) { }
            Button("str.clear".localize, role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("str.clear_cache_confirmation".localize)
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
