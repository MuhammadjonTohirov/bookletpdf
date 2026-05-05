import Foundation
import Combine
import PDFKit
import BookletPDFKit
import BookletCore

extension BookletType {
    var analyticsName: String {
        switch self {
        case .type2: "2-up"
        case .type4: "4-up"
        }
    }
}

@MainActor
public final class DocumentConvertViewModel: ObservableObject {
    @Published public var pdfUrl: URL?
    @Published public var showFileImporter = false
    @Published public var showFileExporter = false
    @Published public var isConverting: Bool = false
    @Published public var state: ContentViewState = .initial
    @Published public var bookletType: BookletType = .type2
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false

    @Published public var document: PDFDocumentObject?
    @Published public var originalDocument: PDFDocumentObject?
    @Published var coverImageData: Data?

    @Published var showConfigureLayout = false
    @Published var showExport = false
    @Published var showRateAppAlert = false
    @Published var recentConversions: [RecentConversion] = []

    @Published var showScanner: Bool = false
    @Published var showScanPreview: Bool = false
    @Published var scannedPDFURL: URL?
    @Published var scannedFileName: String = ""
    @Published var scannedPageCount: Int = 0

    private var cachedSplitBookletPDFs: SplitBookletPDFs?
    private var cachedSplitSourceURL: URL?
    private var scanOriginPending: Bool = false

    private let generatorFactory: BookletGeneratorFactory
    private let duplicateFileUseCase: DuplicateFileUseCase
    private let prepareBookletInputUseCase: PrepareBookletInputUseCase
    private let brandingUseCase: PDFBrandingUseCase
    private let recentStore: RecentConversionsStore
    private let cache: AppCacheProtocol

    public init(
        generatorFactory: BookletGeneratorFactory = BookletGeneratorFactoryImpl(),
        duplicateFileUseCase: DuplicateFileUseCase = DuplicateFileUseCaseImpl(),
        prepareBookletInputUseCase: PrepareBookletInputUseCase = PrepareBookletInputUseCaseImpl(),
        brandingUseCase: PDFBrandingUseCase = PDFBrandingUseCaseImpl()
    ) {
        self.generatorFactory = generatorFactory
        self.duplicateFileUseCase = duplicateFileUseCase
        self.prepareBookletInputUseCase = prepareBookletInputUseCase
        self.brandingUseCase = brandingUseCase
        self.recentStore = RecentConversionsStore.shared
        self.cache = AppCache.shared
    }

    public func onAppear() {
        if recentConversions.isEmpty {
            recentConversions = recentStore.load()
        }
    }

    func setImportedDocument(_ url: URL, origin: RecentItemOrigin = .pdfImport) {
        scanOriginPending = origin == .scan
        Task { @MainActor in
            do {
                let duplicateURL = try duplicateFileUseCase.duplicateFile(at: url)

                guard let doc = PDFDocument(url: duplicateURL) else {
                    throw BookletError.invalidDocument
                }

                self.pdfUrl = duplicateURL
                self.state = .configuringLayout
                self.showConfigureLayout = true

                let pdfDoc = PDFDocumentObject(
                    document: doc,
                    name: duplicateURL.lastPathComponent,
                    url: duplicateURL
                )
                self.document = pdfDoc
                self.originalDocument = pdfDoc
                AnalyticsReporter.logEvent?(AnalyticsEventName.documentImported, [AnalyticsParamKey.pageCount: doc.pageCount])
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    func convertToBooklet() {
        guard let pdf = pdfUrl else { return }

        isConverting = true
        state = .converting
        AnalyticsReporter.logEvent?(AnalyticsEventName.conversionStarted, [AnalyticsParamKey.bookletType: bookletType.analyticsName])

        let generator = generatorFactory.makeGenerator(for: bookletType)
        let cache = self.cache
        let coverData = self.coverImageData
        let prepareBookletInputUseCase = self.prepareBookletInputUseCase
        let brandingUseCase = self.brandingUseCase
        let shouldBrand = !StoreKitManager.shared.isPro

        Task {
            do {
                let preparedInputURL = try prepareBookletInputUseCase.prepareInputPDF(
                    at: pdf,
                    coverImageData: coverData
                )
                var tempUrl = try await generator.makeBookletPDF(url: preparedInputURL)

                if shouldBrand {
                    tempUrl = try brandingUseCase.applyBranding(to: tempUrl)
                }

                let cachedUrl = cache.moveFileToCache(
                    from: tempUrl,
                    fileName: tempUrl.lastPathComponent
                ) ?? tempUrl

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.setDocument(cachedUrl)
                    self.pdfUrl = cachedUrl
                    self.state = .convertedPdf
                    self.isConverting = false
                    self.showExport = true
                    self.saveRecentConversion()
                    AnalyticsReporter.logEvent?(AnalyticsEventName.conversionCompleted, [
                        AnalyticsParamKey.bookletType: self.bookletType.analyticsName,
                        AnalyticsParamKey.pageCount: self.document?.document.pageCount ?? 0
                    ])
                    if !UserSettings.hasRatedApp && ConversionLimitManager.shared.totalConversions == 2 {
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(1))
                            self.showRateAppAlert = true
                            AnalyticsReporter.logEvent?(AnalyticsEventName.rateAppShown, nil)
                        }
                    }
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isConverting = false
                    self.state = .configuringLayout
                    AnalyticsReporter.logEvent?(AnalyticsEventName.conversionFailed, [AnalyticsParamKey.error: error.localizedDescription])
                    AnalyticsReporter.recordError?(error, "convertToBooklet")
                }
            }
        }
    }

    #if os(iOS)
    func saveScannedDocument(pdfURL: URL, pageCount: Int) {
        let cachedURL = cache.moveFileToCache(
            from: pdfURL,
            fileName: pdfURL.lastPathComponent
        ) ?? pdfURL
        scannedPDFURL = cachedURL
        scannedFileName = cachedURL.lastPathComponent
        scannedPageCount = pageCount

        let item = RecentConversion(
            fileName: scanDisplayName(),
            pageCount: pageCount,
            bookletType: nil,
            fileURL: cachedURL,
            kind: .scan,
            origin: .scan
        )
        recentStore.add(item)
        recentConversions = recentStore.load()
        AnalyticsReporter.logEvent?(AnalyticsEventName.documentImported, [AnalyticsParamKey.pageCount: pageCount])
    }

    func startBookletFromScan() {
        guard let url = scannedPDFURL else { return }
        showScanPreview = false
        setImportedDocument(url, origin: .scan)
    }

    private func scanDisplayName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        return "str.scan_default_name".localize + " " + formatter.string(from: .now)
    }
    #endif

    func clearDocuments() {
        showExport = false
        showConfigureLayout = false
        document = nil
        originalDocument = nil
        pdfUrl = nil
        state = .initial
        errorMessage = nil
        showError = false
        bookletType = .type2
        coverImageData = nil
        cachedSplitBookletPDFs = nil
        cachedSplitSourceURL = nil
        scanOriginPending = false
        scannedPDFURL = nil
        scannedFileName = ""
        scannedPageCount = 0
        showScanner = false
        showScanPreview = false
    }

    /// Splits the current merged booklet into front/back PDFs for the iOS
    /// two-step print flow. Cached per merged URL so reopening the print
    /// assistant doesn't re-split.
    func prepareSplitBookletPDFs() async throws -> SplitBookletPDFs {
        guard let url = pdfUrl else { throw BookletError.invalidDocument }
        if let cached = cachedSplitBookletPDFs, cachedSplitSourceURL == url {
            return cached
        }
        let split = try await MergedPDFSplitter().split(mergedURL: url)
        cachedSplitBookletPDFs = split
        cachedSplitSourceURL = url
        return split
    }

    func refreshRecentConversions() {
        recentConversions = recentStore.load()
    }

    var originalPageCount: Int {
        originalDocument?.document.pageCount ?? 0
    }

    var convertedPageCount: Int {
        document?.document.pageCount ?? 0
    }

    var bookletTypeName: String {
        switch bookletType {
        case .type2: return "str.standard_booklet".localize
        case .type4: return "str.pocket_booklet".localize
        }
    }

    var convertedFileName: String {
        guard let name = originalDocument?.name else { return "" }
        let base = (name as NSString).deletingPathExtension
        return "\(base)_Booklet.pdf"
    }

    var convertedFileSize: String {
        guard let url = pdfUrl else { return "" }
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return "" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    private func setDocument(_ url: URL) {
        guard let doc = PDFDocument(url: url) else { return }
        self.document = .init(document: doc, name: url.lastPathComponent, url: url)
    }

    private func saveRecentConversion() {
        guard let original = originalDocument else { return }
        let item = RecentConversion(
            fileName: original.name,
            pageCount: original.document.pageCount,
            bookletType: bookletType == .type2 ? "2-up" : "4-up",
            fileURL: pdfUrl,
            kind: .booklet,
            origin: scanOriginPending ? .scan : .pdfImport
        )
        recentStore.add(item)
        recentConversions = recentStore.load()
        scanOriginPending = false
    }
}
