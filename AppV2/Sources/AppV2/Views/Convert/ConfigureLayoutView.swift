import SwiftUI
import UniformTypeIdentifiers
import BookletPDFKit

struct ConfigureLayoutView: View {
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @ObservedObject private var storeManager = StoreKitManager.shared
    @State private var showCoverImporter = false
    @State private var showPrintingGuide = false
    @State private var showPurchasePrompt = false
    @State private var printingGuideType: BookletType = .type2

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Layout.sectionSpacing) {
                fileInfoSection
                coverImageSection
                layoutSelectionSection
                convertButton
            }
            .padding(Theme.Layout.screenPadding)
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        #if os(iOS)
        .navigationTitle(Text("str.configure_layout"))
        .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { viewModel.clearDocuments() }) {
                    Label("str.back", systemImage: "chevron.left")
                }
                .disabled(viewModel.isConverting)
            }
        }
        #endif
        .overlay {
            if viewModel.isConverting {
                LoadingOverlay()
            }
        }
        .fileImporter(
            isPresented: $showCoverImporter,
            allowedContentTypes: [UTType.image],
            allowsMultipleSelection: false
        ) { result in
            handleCoverImageResult(result)
        }
        .sheet(isPresented: $showPrintingGuide) {
            BookletPrintingGuideSheet(type: printingGuideType)
        }
        .sheet(isPresented: $showPurchasePrompt) {
            PurchasePromptView(storeManager: storeManager)
        }
        #if os(iOS)
        .navigationDestination(isPresented: $viewModel.showExport) {
            ExportView()
        }
        #endif
    }

    private var fileInfoSection: some View {
        FileDetailCard(
            fileName: viewModel.originalDocument?.name ?? "",
            pageCount: viewModel.originalPageCount,
            isAccent: true
        )
    }

    private var coverImageSection: some View {
        CoverImageSection(
            imageData: viewModel.coverImageData,
            onAdd: { showCoverImporter = true },
            onRemove: { viewModel.coverImageData = nil }
        )
    }

    private func handleCoverImageResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            viewModel.coverImageData = try? Data(contentsOf: url)
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
            viewModel.showError = true
        }
    }

    private var layoutSelectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            Text("str.booklet_layout")
                .font(Theme.Fonts.sectionTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            BookletLayoutOption(
                type: .type2,
                isSelected: viewModel.bookletType == .type2,
                action: { viewModel.bookletType = .type2 },
                infoAction: { presentPrintingGuide(for: .type2) }
            )

            BookletLayoutOption(
                type: .type4,
                isSelected: viewModel.bookletType == .type4,
                isLocked: !storeManager.isFourInOnePurchased,
                action: {
                    if storeManager.isFourInOnePurchased {
                        viewModel.bookletType = .type4
                    } else {
                        showPurchasePrompt = true
                    }
                },
                infoAction: { presentPrintingGuide(for: .type4) }
            )
        }
    }

    private var convertButton: some View {
        Button(action: { viewModel.convertToBooklet() }) {
            HStack(spacing: 10) {
                Text("str.reorder_pages")
                    .font(Theme.Fonts.cardTitle)
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Layout.buttonPaddingV)
            .foregroundStyle(.white)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isConverting)
        .padding(.top, 8)
    }

    private func presentPrintingGuide(for type: BookletType) {
        printingGuideType = type
        showPrintingGuide = true
    }
}
