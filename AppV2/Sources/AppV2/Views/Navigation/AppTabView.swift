import SwiftUI
import PDFKit
import UniformTypeIdentifiers

#if os(iOS)
enum AppTab: String, CaseIterable {
    case convert
    case history
    case settings

    var title: LocalizedStringKey {
        switch self {
        case .convert: return "str.convert"
        case .history: return "str.history"
        case .settings: return "str.settings"
        }
    }

    var icon: String {
        switch self {
        case .convert: return "doc.viewfinder"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gear"
        }
    }
}

struct AppTabView: View {
    @State private var selectedTab: AppTab = .convert
    @EnvironmentObject private var viewModel: DocumentConvertViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            convertTab
            historyTab
            settingsTab
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
            Text("str.error"),
            isPresented: $viewModel.showError,
            presenting: viewModel.errorMessage
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private var convertTab: some View {
        NavigationStack {
            HomeView()
        }
        .tabItem {
            Label(AppTab.convert.title, systemImage: AppTab.convert.icon)
        }
        .tag(AppTab.convert)
    }

    private var historyTab: some View {
        NavigationStack {
            HistoryView()
                .navigationTitle(Text("str.history"))
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
