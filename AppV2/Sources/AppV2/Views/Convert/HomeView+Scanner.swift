#if os(iOS)
import SwiftUI
import UIKit
import DocumentScannerKit
import BookletCore

extension View {
    func documentScannerHost(viewModel: DocumentConvertViewModel) -> some View {
        modifier(DocumentScannerHostModifier(viewModel: viewModel))
    }

    func scanPreviewDestination(viewModel: DocumentConvertViewModel) -> some View {
        navigationDestination(isPresented: Binding(
            get: { viewModel.showScanPreview },
            set: { viewModel.showScanPreview = $0 }
        )) {
            ScannedDocumentPreviewView()
        }
    }
}

private struct DocumentScannerHostModifier: ViewModifier {
    @ObservedObject var viewModel: DocumentConvertViewModel
    @State private var processingError: String?

    private let scanToPDF: ScanToPDFUseCase = ScanToPDFUseCaseImpl()

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $viewModel.showScanner) {
                VisionKitScannerView(
                    onCancel: { viewModel.showScanner = false },
                    onComplete: handleScanResult
                )
                .ignoresSafeArea()
            }
            .scanPreviewDestination(viewModel: viewModel)
            .alert(
                Text("str.error".localize),
                isPresented: errorBinding,
                presenting: processingError
            ) { _ in
                Button("str.ok".localize, role: .cancel) { processingError = nil }
            } message: { message in
                Text(message)
            }
    }

    private func handleScanResult(_ result: Result<[ScannedPage], Error>) {
        viewModel.showScanner = false
        switch result {
        case .success(let pages):
            guard !pages.isEmpty else { return }
            processScannedPages(pages.map(\.image))
        case .failure(let error):
            processingError = error.localizedDescription
        }
    }

    private func processScannedPages(_ images: [UIImage]) {
        let fileName = "Scan_\(Int(Date().timeIntervalSince1970)).pdf"
        do {
            let url = try scanToPDF.makePDF(from: images, fileName: fileName)
            viewModel.saveScannedDocument(pdfURL: url, pageCount: images.count)
            viewModel.showScanPreview = true
        } catch {
            processingError = error.localizedDescription
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { processingError != nil },
            set: { if !$0 { processingError = nil } }
        )
    }
}
#endif
