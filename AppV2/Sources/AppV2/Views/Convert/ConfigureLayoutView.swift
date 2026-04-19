import SwiftUI
import UniformTypeIdentifiers
import BookletCore
import BookletPDFKit

private enum ConfigureLayoutSheet: Identifiable {
    case printingGuide
    case purchase

    var id: Int {
        switch self {
        case .printingGuide: 0
        case .purchase: 1
        }
    }
}

struct ConfigureLayoutView: View {
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @ObservedObject private var storeManager = StoreKitManager.shared
    @State private var showCoverImporter = false
    @State private var activeSheet: ConfigureLayoutSheet?
    @State private var printingGuideType: BookletType = .type2
    @State private var showDailyLimitAlert = false
    @ObservedObject private var conversionLimit = ConversionLimitManager.shared

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
        .navigationTitle(Text("str.configure_layout".localize))
        .navigationBarTitleDisplayMode(.inline)
        #endif
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: { viewModel.clearDocuments() }) {
                    Label("str.back".localize, systemImage: "chevron.left")
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .printingGuide:
                BookletPrintingGuideSheet(type: printingGuideType)
            case .purchase:
                PurchasePromptView(storeManager: storeManager)
                    #if os(iOS)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
                    #endif
            }
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
            if viewModel.coverImageData != nil {
                AnalyticsReporter.logEvent?(AnalyticsEventName.coverImageAdded, nil)
            }
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
            viewModel.showError = true
        }
    }

    private var layoutSelectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            Text("str.booklet_layout".localize)
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
                isLocked: !storeManager.isPro,
                action: {
                    if storeManager.isPro {
                        viewModel.bookletType = .type4
                    } else {
                        activeSheet = .purchase
                    }
                },
                infoAction: { presentPrintingGuide(for: .type4) }
            )
        }
    }

    private var convertButton: some View {
        Button(action: handleConvert) {
            HStack(spacing: 10) {
                Text("str.reorder_pages".localize)
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
        .alert(Text("str.daily_limit_reached".localize), isPresented: $showDailyLimitAlert) {
            Button("str.upgrade_to_pro".localize) {
                activeSheet = .purchase
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("str.daily_limit_message".localize)
        }
    }

    private func handleConvert() {
        Logging.l(tag: "Ads", "handleConvert isPro=\(storeManager.isPro) shouldShowAd=\(conversionLimit.shouldShowAd) interstitialWired=\(AdService.showInterstitial != nil)")
        guard !storeManager.isPro else {
            Logging.l(tag: "Ads", "Skipping ad: user is pro")
            viewModel.convertToBooklet()
            return
        }

        #if os(macOS)
        guard conversionLimit.canConvertOnMacOS else {
            showDailyLimitAlert = true
            return
        }
        conversionLimit.recordConversion()
        viewModel.convertToBooklet()
        #else
        if conversionLimit.shouldShowAd, let showAd = AdService.showInterstitial {
            Logging.l(tag: "Ads", "Requesting interstitial presentation")
            conversionLimit.recordConversion()
            showAd {
                Logging.l(tag: "Ads", "Interstitial completion fired, starting conversion")
                viewModel.convertToBooklet()
            }
        } else {
            Logging.l(tag: "Ads", "No interstitial path: shouldShowAd=\(conversionLimit.shouldShowAd) wired=\(AdService.showInterstitial != nil)")
            conversionLimit.recordConversion()
            viewModel.convertToBooklet()
        }
        #endif
    }

    private func presentPrintingGuide(for type: BookletType) {
        printingGuideType = type
        activeSheet = .printingGuide
    }
}
