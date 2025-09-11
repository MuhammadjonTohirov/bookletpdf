//
//  LanguageSelectionView.swift
//  bookletPdf
//
//  Created on 11/09/25.
//

import SwiftUI
import BookletCore

struct LanguageSelectionView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        #if os(iOS)
        iOSLanguageSelectionView(viewModel: viewModel)
        #else
        macOSLanguageSelectionView(viewModel: viewModel)
        #endif
    }
}

#if os(iOS)
struct iOSLanguageSelectionView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(viewModel.availableLanguages, id: \.self) { language in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.name)
                            .font(.body)
                        Text(getLanguageDescription(for: language))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if language == viewModel.selectedLanguage {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .font(.body.weight(.semibold))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedLanguage = language
                    dismiss()
                }
            }
        }
        .navigationTitle("str.select_language".localize)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getLanguageDescription(for language: Language) -> String {
        switch language {
        case .english:
            return "str.lang_english".localize
        case .france:
            return "str.lang_french".localize
        case .germany:
            return "str.lang_german".localize
        case .uzbek:
            return "str.lang_uzbek".localize
        }
    }
}
#endif

#if os(macOS)
struct macOSLanguageSelectionView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingLanguagePopover = false
    
    var body: some View {
        HStack {
            Text("str.current_language".localize)
            Spacer()
            Button(viewModel.selectedLanguage.name) {
                showingLanguagePopover.toggle()
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showingLanguagePopover, arrowEdge: .trailing) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("str.select_language".localize)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.availableLanguages, id: \.self) { language in
                            Button(action: {
                                viewModel.selectedLanguage = language
                                showingLanguagePopover = false
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(language.name)
                                            .font(.body)
                                        Text(getLanguageDescription(for: language))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if language == viewModel.selectedLanguage {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.caption.weight(.semibold))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(
                                Color.clear
                                    .onHover { hovering in
                                        // Add hover effect if needed
                                    }
                            )
                            
                            if language != viewModel.availableLanguages.last {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                .frame(minWidth: 200, maxWidth: 250)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
    }
    
    private func getLanguageDescription(for language: Language) -> String {
        switch language {
        case .english:
            return "str.lang_english".localize
        case .france:
            return "str.lang_french".localize
        case .germany:
            return "str.lang_german".localize
        case .uzbek:
            return "str.lang_uzbek".localize
        }
    }
}
#endif

#if os(iOS)
#Preview("iOS Language Selection") {
    NavigationStack {
        iOSLanguageSelectionView(viewModel: SettingsViewModel())
    }
}
#endif

#if os(macOS)
#Preview("macOS Language Selection") {
    macOSLanguageSelectionView(viewModel: SettingsViewModel())
        .padding()
}
#endif