import SwiftUI
import BookletCore
import PDFKit
import BookletPDFKit

enum HistoryFilter: Hashable, CaseIterable {
    case all, scanned, booklets

    var titleKey: String {
        switch self {
        case .all: return "str.history_filter_all"
        case .scanned: return "str.history_filter_scanned"
        case .booklets: return "str.history_filter_booklets"
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @State private var selectedItem: RecentConversion?
    @State private var filter: HistoryFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            filterPicker
            content
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        .onAppear { viewModel.refreshRecentConversions() }
        .sheet(item: $selectedItem) { item in
            if let url = item.fileURL, item.fileExists, let doc = PDFDocument(url: url) {
                PDFPreviewSheet(document: doc, fileName: item.fileName)
            } else {
                fileNotFoundView(item)
            }
        }
        #if os(iOS)
        .scanPreviewDestination(viewModel: viewModel)
        #endif
    }

    private var filterPicker: some View {
        Picker("", selection: $filter) {
            ForEach(HistoryFilter.allCases, id: \.self) { option in
                Text(option.titleKey.localize).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Theme.Layout.screenPadding)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var content: some View {
        if filteredItems.isEmpty {
            emptyState
        } else {
            historyList
        }
    }

    private var filteredItems: [RecentConversion] {
        switch filter {
        case .all: return viewModel.recentConversions
        case .scanned: return viewModel.recentConversions.filter { $0.kind == .scan || $0.origin == .scan }
        case .booklets: return viewModel.recentConversions.filter { $0.kind == .booklet }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.Colors.tertiaryText)

            Text("str.no_history".localize)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.Colors.primaryText)

            Text("str.no_history_subtitle".localize)
                .font(Theme.Fonts.cellBody)
                .foregroundStyle(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.Layout.screenPadding)
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredItems) { item in
                    Button(action: { handleTap(item) }) {
                        historyRow(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Theme.Layout.screenPadding)
        }
    }

    private func handleTap(_ item: RecentConversion) {
        #if os(iOS)
        if item.kind == .scan, let url = item.fileURL, item.fileExists {
            viewModel.scannedPDFURL = url
            viewModel.scannedFileName = item.fileName
            viewModel.scannedPageCount = item.pageCount
            viewModel.showScanPreview = true
            return
        }
        #endif
        selectedItem = item
    }

    private func historyRow(_ item: RecentConversion) -> some View {
        RecentItemRow(item: item)
    }

    private func fileNotFoundView(_ item: RecentConversion) -> some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "doc.questionmark")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Theme.Colors.tertiaryText)

                Text("str.file_not_found".localize)
                    .font(Theme.Fonts.sectionTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text("str.file_not_found_subtitle".localize)
                    .font(Theme.Fonts.subtitle)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("str.close".localize) {
                        selectedItem = nil
                    }
                }
            }
        }
    }
}
