import SwiftUI
import StoreKit
import BookletPDFKit
import BookletCore

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @ObservedObject private var storeManager = StoreKitManager.shared
    @State private var showPurchase = false
    @AppStorage(UserSettings.themeStorageKey, store: UserDefaults(suiteName: UserSettings.suiteName))
    private var themeRawValue: Int = AppTheme.system.rawValue

    var body: some View {
        Group {
            #if os(macOS)
            macOSSettings
            #else
            iOSSettings
            #endif
        }
        .onAppear {
            viewModel.onAppear()
            AnalyticsReporter.logEvent?(AnalyticsEventName.settingsOpened, nil)
        }
    }

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: themeRawValue) ?? .system
    }

    private var selectedThemeBinding: Binding<AppTheme> {
        Binding(
            get: { selectedTheme },
            set: { newTheme in
                themeRawValue = newTheme.rawValue
            }
        )
    }
}

// MARK: - iOS

#if os(iOS)
extension SettingsView {
    var iOSSettings: some View {
        ScrollView {
            VStack(spacing: Theme.Layout.sectionSpacing) {
                if !storeManager.isPro {
                    proSection
                }
                themeSection
                languageSection
                cacheSection
                helpSection
                appInfoSection
            }
            .padding(Theme.Layout.screenPadding)
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        .navigationTitle(Text("str.settings".localize))
        .alert(Text("str.clear_cache".localize), isPresented: $viewModel.showClearCacheConfirmation) {
            Button("str.cancel".localize, role: .cancel) {}
            Button("str.clear".localize, role: .destructive) { viewModel.clearCache() }
        } message: {
            Text("str.clear_cache_confirmation".localize)
        }
        .sheet(isPresented: $showPurchase) {
            PurchasePromptView(storeManager: storeManager)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    private var proSection: some View {
        ProUpgradeCard(action: { showPurchase = true })
    }

    private var themeSection: some View {
        iosSection(
            title: "str.appearance",
            description: "str.appearance_description"
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("str.theme".localize)
                    .font(Theme.Fonts.cellBody)
                    .foregroundStyle(Theme.Colors.primaryText)

                Picker("str.theme".localize, selection: selectedThemeBinding) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.name)
                            .tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
    }

    private var languageSection: some View {
        iosSection(
            title: "str.language",
            description: "str.language_description"
        ) {
            NavigationLink {
                LanguageSelectionView(viewModel: viewModel)
            } label: {
                HStack(spacing: 12) {
                    Text("str.current_language".localize)
                        .font(Theme.Fonts.cellBody)
                        .foregroundStyle(Theme.Colors.primaryText)

                    Spacer()

                    Text(viewModel.selectedLanguage.name)
                        .font(Theme.Fonts.subtitle)
                        .foregroundStyle(Theme.Colors.secondaryText)

                    Image(systemName: "chevron.right".localize)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.Colors.tertiaryText)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
    }

    private var cacheSection: some View {
        iosSection(
            title: "str.cache_management",
            description: "str.cache_description"
        ) {
            VStack(alignment: .leading, spacing: Theme.Layout.innerPaddingV) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("str.current_cache_size".localize)
                            .font(Theme.Fonts.cellBody)
                            .foregroundStyle(Theme.Colors.primaryText)

                        Text(viewModel.cacheSize)
                            .font(Theme.Fonts.subtitle)
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }

                    Spacer()

                    Button("str.calculate".localize) {
                        viewModel.calculateCacheSize()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Theme.Colors.secondaryBackground,
                        in: Capsule()
                    )
                    .overlay {
                        Capsule()
                            .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
                    }
                }

                Button(action: { viewModel.showClearCacheConfirmation = true }) {
                    Label("str.clear_cache".localize, systemImage: "trash")
                        .font(Theme.Fonts.cellBody)
                        .foregroundStyle(Theme.Colors.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Theme.Colors.secondaryBackground,
                            in: Capsule()
                        )
                        .overlay {
                            Capsule()
                                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
                        }
                }
                .buttonStyle(.plain)

                if viewModel.cacheCleared {
                    Label("str.cache_cleared_success".localize, systemImage: "checkmark.circle.fill")
                        .font(Theme.Fonts.captionBold)
                        .foregroundStyle(Theme.Colors.success)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Theme.Colors.success.opacity(Theme.Opacity.tint),
                            in: Capsule()
                        )
                }
            }
        }
    }

    private var helpSection: some View {
        iosSection(
            title: "str.help_support",
            description: "str.help_description"
        ) {
            NavigationLink {
                HelpView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "book.pages")
                        .font(Theme.Fonts.smallIcon)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 40, height: 40)
                        .background(
                            Color.accentColor.opacity(Theme.Opacity.tint),
                            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text("str.open_help".localize)
                            .font(Theme.Fonts.cellTitle)
                            .foregroundStyle(Theme.Colors.primaryText)

                        Text("str.help".localize)
                            .font(Theme.Fonts.subtitle)
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.Colors.tertiaryText)
                }
                .padding(Theme.Layout.cardPadding)
                .background(
                    Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded),
                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                )
            }
            .buttonStyle(.plain)

            Button(action: { RateAppService.requestReview() }) {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(Theme.Fonts.smallIcon)
                        .foregroundStyle(.yellow)
                        .frame(width: 40, height: 40)
                        .background(
                            Color.yellow.opacity(Theme.Opacity.tint),
                            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text("str.rate_app".localize)
                            .font(Theme.Fonts.cellTitle)
                            .foregroundStyle(Theme.Colors.primaryText)

                        Text("str.rate_app_subtitle".localize)
                            .font(Theme.Fonts.subtitle)
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.Colors.tertiaryText)
                }
                .padding(Theme.Layout.cardPadding)
                .background(
                    Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded),
                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func iosSection<Content: View>(
        title: LocalizedStringKey,
        description: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            Text(title)
                .font(Theme.Fonts.sectionTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            VStack(alignment: .leading, spacing: Theme.Layout.innerPaddingV) {
                Text(description)
                    .font(Theme.Fonts.cellBody)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .overlay(Theme.Colors.divider)

                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Layout.innerPaddingH)
            .padding(.vertical, Theme.Layout.innerPaddingV)
            .background(
                Theme.Colors.background,
                in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                    .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
            }
        }
    }

    private var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("str.app_name".localize)
                .font(Theme.Fonts.cellTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            Text(String(format: String("str.version_format".localize), viewModel.appVersion, viewModel.buildNumber))
                .font(Theme.Fonts.badge)
                .foregroundStyle(Theme.Colors.secondaryText)

            Text("str.powered_by".localize)
                .font(Theme.Fonts.badge)
                .foregroundStyle(Theme.Colors.tertiaryText)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Layout.innerPaddingV)
        .padding(.horizontal, Theme.Layout.innerPaddingH)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }
}
#endif

// MARK: - macOS

#if os(macOS)
extension SettingsView {
    var macOSSettings: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                if !storeManager.isPro {
                    macProSection
                }

                macSection(
                    title: "str.appearance",
                    systemImage: "circle.lefthalf.filled",
                    description: "str.appearance_description"
                ) {
                    macSettingsRow(title: "str.theme") {
                        Picker("str.theme", selection: selectedThemeBinding) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Text(theme.name)
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 260)
                    }
                }

                macSection(
                    title: "str.language",
                    systemImage: "globe",
                    description: "str.language_description"
                ) {
                    macSettingsRow(title: "str.current_language") {
                        Picker("str.current_language", selection: $viewModel.selectedLanguage) {
                            ForEach(viewModel.availableLanguages, id: \.self) { language in
                                Text(language.name)
                                    .tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 180)
                    }
                }

                macSection(
                    title: "str.cache_management",
                    systemImage: "folder.badge.gearshape",
                    description: "str.cache_description"
                ) {
                    macSettingsRow(
                        title: "str.current_cache_size",
                        value: viewModel.cacheSize
                    ) {
                        Button("str.calculate") {
                            viewModel.calculateCacheSize()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Theme.Colors.secondaryBackground,
                            in: Capsule()
                        )
                        .overlay {
                            Capsule()
                                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
                        }
                    }

                    HStack(spacing: 14) {
                        Button(action: { viewModel.showClearCacheConfirmation = true }) {
                            Label("str.clear_cache", systemImage: "trash")
                                .font(Theme.Fonts.cellBody)
                                .foregroundStyle(Theme.Colors.primaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Theme.Colors.secondaryBackground,
                                    in: Capsule()
                                )
                                .overlay {
                                    Capsule()
                                        .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
                                }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        if viewModel.cacheCleared {
                            Label("str.cache_cleared_success", systemImage: "checkmark.circle.fill")
                                .font(Theme.Fonts.captionBold)
                                .foregroundStyle(Theme.Colors.success)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Theme.Colors.success.opacity(Theme.Opacity.tint),
                                    in: Capsule()
                                )
                        }
                    }
                }

                macSection(
                    title: "str.help_support",
                    systemImage: "questionmark.circle",
                    description: "str.help_description"
                ) {
                    Button(action: {
                        NotificationCenter.default.post(name: .openHelpView, object: nil)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "book.pages")
                                .font(Theme.Fonts.smallIcon)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 40, height: 40)
                                .background(
                                    Color.accentColor.opacity(Theme.Opacity.tint),
                                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text("str.open_help".localize)
                                    .font(Theme.Fonts.cellTitle)
                                    .foregroundStyle(Theme.Colors.primaryText)

                                Text("str.help".localize)
                                    .font(Theme.Fonts.subtitle)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.Colors.tertiaryText)
                        }
                        .background(
                            Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded),
                            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                        )
                    }
                    .buttonStyle(.plain)

                    Button(action: { RateAppService.requestReview() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(Theme.Fonts.smallIcon)
                                .foregroundStyle(.yellow)
                                .frame(width: 40, height: 40)
                                .background(
                                    Color.yellow.opacity(Theme.Opacity.tint),
                                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text("str.rate_app".localize)
                                    .font(Theme.Fonts.cellTitle)
                                    .foregroundStyle(Theme.Colors.primaryText)

                                Text("str.rate_app_subtitle".localize)
                                    .font(Theme.Fonts.subtitle)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.Colors.tertiaryText)
                        }
                        .background(
                            Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded),
                            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                        )
                    }
                    .buttonStyle(.plain)
                }

                macAppInfoSection
            }
            .padding(Theme.Layout.screenPadding)
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        .frame(minWidth: 620, minHeight: 520)
        .alert(Text("str.clear_cache".localize), isPresented: $viewModel.showClearCacheConfirmation) {
            Button("str.cancel", role: .cancel) {}
            Button("str.clear", role: .destructive) { viewModel.clearCache() }
        } message: {
            Text("str.clear_cache_confirmation".localize)
        }
        .sheet(isPresented: $showPurchase) {
            PurchasePromptView(storeManager: storeManager)
                .frame(minWidth: 420, minHeight: 520)
        }
    }

    private var macProSection: some View {
        ProUpgradeCard(action: { showPurchase = true })
    }

    private func macSection<Content: View>(
        title: LocalizedStringKey,
        systemImage: String,
        description: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            HStack(spacing: 10) {
//                Image(systemName: systemImage)
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundStyle(Theme.Colors.primaryText)

                Text(title)
                    .font(Theme.Fonts.sectionTitle)
                    .foregroundStyle(Theme.Colors.primaryText)
            }

            VStack(alignment: .leading, spacing: Theme.Layout.innerPaddingV) {
                Text(description)
                    .font(Theme.Fonts.cellBody)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .overlay(Theme.Colors.divider)

                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Layout.innerPaddingH)
            .padding(.vertical, Theme.Layout.innerPaddingV)
            .background(
                Theme.Colors.background,
                in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                    .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
            }
        }
    }

    private func macSettingsRow<Trailing: View>(
        title: LocalizedStringKey,
        value: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            HStack(spacing: 6) {
                Text(title)
                    .font(Theme.Fonts.cellBody)
                    .foregroundStyle(Theme.Colors.primaryText)

                if let value {
                    Text(value)
                        .font(Theme.Fonts.cellBody)
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }

            Spacer(minLength: 16)

            trailing()
        }
    }

    private var macAppInfoSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("str.app_name".localize)
                    .font(Theme.Fonts.cellTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text(String(format: "str.version_format".localize, viewModel.appVersion, viewModel.buildNumber))
                    .font(Theme.Fonts.badge)
                    .foregroundStyle(Theme.Colors.secondaryText)
            }

            Spacer()

            Text("str.powered_by".localize)
                .font(Theme.Fonts.badge)
                .foregroundStyle(Theme.Colors.tertiaryText)
        }
        .padding(.horizontal, Theme.Layout.innerPaddingH)
        .padding(.vertical, Theme.Layout.innerPaddingV)
        .background(
            Theme.Colors.background,
            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
        )
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }
}

extension Notification.Name {
    static let openHelpView = Notification.Name("OpenHelpView")
}
#endif
