import SwiftUI
import BookletCore

struct LanguageSelectionView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        #if os(iOS)
        iOSLanguageSelection
        #else
        macOSLanguageSelection
        #endif
    }

    private func languageDescription(for language: Language) -> LocalizedStringKey {
        switch language {
        case .english: return "str.lang_english"
        case .france: return "str.lang_french"
        case .germany: return "str.lang_german"
        case .uzbek: return "str.lang_uzbek"
        }
    }
}

// MARK: - iOS

#if os(iOS)
extension LanguageSelectionView {
    var iOSLanguageSelection: some View {
        List {
            ForEach(viewModel.availableLanguages, id: \.self) { language in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.name)
                        Text(languageDescription(for: language))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if language == viewModel.selectedLanguage {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
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
        .navigationTitle(Text("str.select_language"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif

// MARK: - macOS

#if os(macOS)
extension LanguageSelectionView {
    var macOSLanguageSelection: some View {
        HStack {
            Text("str.current_language")
            Spacer()
            Picker("", selection: $viewModel.selectedLanguage) {
                ForEach(viewModel.availableLanguages, id: \.self) { language in
                    Text(language.name).tag(language)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
        }
    }
}
#endif
