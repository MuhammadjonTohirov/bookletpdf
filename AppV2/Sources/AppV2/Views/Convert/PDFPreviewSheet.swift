import SwiftUI
import BookletCore
import PDFKit

struct PDFPreviewSheet: View {
    let document: PDFDocument
    let fileName: String
    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL?

    var body: some View {
        Group {
            #if os(iOS)
            NavigationStack {
                PDFKitView(document: document)
                    .navigationTitle(fileName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("str.close".localize) {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .primaryAction) {
                            shareButton
                        }
                    }
            }
            #else
            VStack(spacing: 0) {
                HStack {
                    Text(fileName)
                        .font(.headline)
                    Spacer()
                    shareButton
                    Button("str.close".localize) {
                        dismiss()
                    }
                }
                .padding()
                Divider()
                PDFKitView(document: document)
            }
            .frame(minWidth: 600, minHeight: 500)
            #endif
        }
        .onAppear {
            if shareURL == nil {
                shareURL = prepareShareURL()
            }
        }
        .onDisappear {
            cleanupTemporaryShareURL()
        }
    }

    @ViewBuilder
    private var shareButton: some View {
        if let shareURL {
            ShareLink(item: shareURL) {
                Image(systemName: "square.and.arrow.up")
            }
        } else {
            Image(systemName: "square.and.arrow.up")
        }
    }

    private func prepareShareURL() -> URL? {
        if let existingURL = document.documentURL,
           FileManager.default.fileExists(atPath: existingURL.path) {
            return existingURL
        }

        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Share_\(UUID().uuidString)_\(fileName)")

        return document.write(to: temporaryURL) ? temporaryURL : nil
    }

    private func cleanupTemporaryShareURL() {
        guard let shareURL else { return }
        guard shareURL != document.documentURL else { return }
        try? FileManager.default.removeItem(at: shareURL)
    }
}

// MARK: - PDFKitView

struct PDFKitView {
    let document: PDFDocument
}

#if os(iOS)
extension PDFKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = document
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = document
    }
}
#elseif os(macOS)
extension PDFKitView: NSViewRepresentable {
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        pdfView.document = document
        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = document
    }
}

#endif
