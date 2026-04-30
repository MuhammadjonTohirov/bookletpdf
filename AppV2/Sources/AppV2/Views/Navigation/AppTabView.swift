import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import BookletCore

#if os(iOS)
enum AppTab: String, CaseIterable {
    case convert
    case history
    case settings

    var title: String {
        switch self {
        case .convert: return "str.convert".localize
        case .history: return "str.history".localize
        case .settings: return "str.settings".localize
        }
    }

    var icon: String {
        switch self {
        case .convert: return "doc.on.doc"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gear"
        }
    }
}

struct AppTabView: View {
    @State private var selectedTab: AppTab = .convert
    @State private var isBannerDismissed = false
    @State private var isBannerLoaded = false
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @ObservedObject private var storeManager = StoreKitManager.shared

    var body: some View {
        VStack(spacing: 0) {
            if !storeManager.isPro && !isBannerDismissed,
               let banner = AdService.bannerView {
                bannerSection(banner: banner)
            }

            TabView(selection: $selectedTab) {
                convertTab
                historyTab
                settingsTab
            }
            .id(languageManager.currentLanguage)
        }
        .fileImporter(
            isPresented: $viewModel.showFileImporter,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .fileExporter(
            isPresented: $viewModel.showFileExporter,
            item: viewModel.document?.document,
            contentTypes: [.pdf],
            defaultFilename: viewModel.convertedFileName
        ) { _ in }
        .alert(
            Text("str.error".localize),
            isPresented: $viewModel.showError,
            presenting: viewModel.errorMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private func bannerSection(banner: @escaping (@escaping (Bool) -> Void) -> AnyView) -> some View {
        ZStack(alignment: .topTrailing) {
            banner { isLoaded in
                isBannerLoaded = isLoaded
            }
                .frame(height: isBannerLoaded ? 50 : 0)
                .opacity(isBannerLoaded ? 1 : 0)
                .clipped()

            if isBannerLoaded {
                Button {
                    isBannerDismissed = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(.systemGray), Color(.systemBackground))
                }
                .accessibilityLabel(Text("str.close".localize))
                .padding(4)
            }
        }
    }

    private var convertTab: some View {
        NavigationStack {
            HomeView()
                .toolbar {
                    if storeManager.isPro {
                        ToolbarItem(placement: .topBarLeading) {
                            ProBadgeView()
                        }
                    }
                }
        }
        .tabItem {
            Label(AppTab.convert.title, systemImage: AppTab.convert.icon)
        }
        .tag(AppTab.convert)
    }

    private var historyTab: some View {
        NavigationStack {
            HistoryView()
                .navigationTitle(Text("str.history".localize))
        }
        .tabItem {
            Label(AppTab.history.title, systemImage: AppTab.history.icon)
        }
        .tag(AppTab.history)
    }

    private var settingsTab: some View {
        NavigationStack {
            SettingsView()
        }
        .tabItem {
            Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
        }
        .tag(AppTab.settings)
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            if url.startAccessingSecurityScopedResource() {
                viewModel.setImportedDocument(url)
                url.stopAccessingSecurityScopedResource()
            }
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
            viewModel.showError = true
        }
    }
}
#endif
