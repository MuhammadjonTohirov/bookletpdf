import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import BookletPDFKit

#if os(macOS)
struct MacContentView: View {
    @State private var selectedItem: SidebarItem? = .converter
    @EnvironmentObject private var viewModel: DocumentConvertViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
        } detail: {
            detailView
                .frame(minWidth: 600)
        }
        .navigationSplitViewStyle(.balanced)
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
        .onReceive(NotificationCenter.default.publisher(for: .openHelpView)) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedItem = .help
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .converter:
            convertFlowView
        case .history:
            HistoryView()
        case .help:
            HelpView()
        case .settings:
            SettingsView()
        case .none:
            convertFlowView
        }
    }

    @ViewBuilder
    private var convertFlowView: some View {
        switch viewModel.state {
        case .initial:
            HomeView()
        case .configuringLayout:
            ConfigureLayoutView()
        case .converting:
            ConfigureLayoutView()
                .overlay { LoadingOverlay() }
        case .convertedPdf:
            ExportView()
        case .selectedPdf:
            HomeView()
        }
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
