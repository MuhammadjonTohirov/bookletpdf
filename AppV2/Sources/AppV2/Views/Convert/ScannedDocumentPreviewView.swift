#if os(iOS)
import SwiftUI
import PDFKit
import BookletCore
import BookletPDFKit

struct ScannedDocumentPreviewView: View {
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @State private var showShareSheet = false

    var body: some View {
        Group {
            if let url = viewModel.scannedPDFURL, let document = PDFDocument(url: url) {
                content(document: document, url: url)
            } else {
                emptyState
            }
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        .navigationTitle(Text("str.scan_preview_title".localize))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(document: PDFDocument, url: URL) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 140), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(0..<document.pageCount, id: \.self) { index in
                        if let page = document.page(at: index) {
                            ThumbnailCell(page: page, index: index)
                        }
                    }
                }
                .padding(Theme.Layout.screenPadding)
            }

            actionBar(url: url)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [url])
        }
    }

    private func actionBar(url: URL) -> some View {
        HStack(spacing: 12) {
            Button(action: { showShareSheet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("str.share".localize)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Layout.buttonPaddingV)
                .foregroundStyle(Color.accentColor)
                .background(Color.accentColor.opacity(Theme.Opacity.tint), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
            }
            .buttonStyle(.plain)

            Button(action: { viewModel.startBookletFromScan() }) {
                HStack(spacing: 8) {
                    Text("str.make_booklet".localize)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Layout.buttonPaddingV)
                .foregroundStyle(.white)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.Layout.screenPadding)
        .background(.ultraThinMaterial)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.questionmark")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.Colors.tertiaryText)
            Text("str.file_not_found".localize)
                .font(Theme.Fonts.sectionTitle)
                .foregroundStyle(Theme.Colors.primaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ThumbnailCell: View {
    let page: PDFPage
    let index: Int

    var body: some View {
        VStack(spacing: 6) {
            Image(uiImage: render())
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
                }

            Text("\(index + 1)")
                .font(Theme.Fonts.badge)
                .foregroundStyle(Theme.Colors.tertiaryText)
        }
    }

    private func render() -> UIImage {
        let bounds = page.bounds(for: .mediaBox)
        let scale = max(1, 240 / max(bounds.width, bounds.height))
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: bounds.width * scale, height: bounds.height * scale))
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: renderer.format.bounds.size))
            ctx.cgContext.translateBy(x: 0, y: renderer.format.bounds.height)
            ctx.cgContext.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
#endif
