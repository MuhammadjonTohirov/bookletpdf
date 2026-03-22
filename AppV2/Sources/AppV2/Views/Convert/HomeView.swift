import SwiftUI
import PDFKit
import BookletPDFKit

struct HomeView: View {
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @State private var selectedItem: RecentConversion?

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                UploadZoneView(action: { viewModel.showFileImporter = true })
                recentConversionsSection
            }
            .padding(Theme.Layout.screenPadding)
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        #if os(iOS)
        .navigationTitle(Text("str.convert_to_booklet"))
        #endif
        .sheet(item: $selectedItem) { item in
            if let url = item.fileURL, item.fileExists, let doc = PDFDocument(url: url) {
                PDFPreviewSheet(document: doc, fileName: item.fileName)
            } else {
                fileNotFoundView(item)
            }
        }
        #if os(iOS)
        .navigationDestination(isPresented: $viewModel.showConfigureLayout) {
            ConfigureLayoutView()
        }
        #endif
    }

    @ViewBuilder
    private var recentConversionsSection: some View {
        if !viewModel.recentConversions.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
                Text("str.recent_conversions")
                    .font(Theme.Fonts.sectionTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                ForEach(viewModel.recentConversions.prefix(5)) { item in
                    Button(action: { selectedItem = item }) {
                        recentConversionRow(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func recentConversionRow(_ item: RecentConversion) -> some View {
        HStack(spacing: Theme.Layout.itemSpacing) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.muted))
                .frame(width: Theme.Layout.smallIconSize, height: Theme.Layout.smallIconSize)
                .overlay {
                    Image(systemName: "doc.text")
                        .font(Theme.Fonts.sectionTitle)
                        .foregroundStyle(Theme.Colors.secondaryText)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.fileName)
                    .font(Theme.Fonts.cellTitle)
                    .foregroundStyle(Theme.Colors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 8) {
                    Text(item.bookletType)
                        .font(Theme.Fonts.badge)
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(Theme.Opacity.tint), in: Capsule())

                    Text(item.formattedDate)
                        .font(Theme.Fonts.badge)
                        .foregroundStyle(Theme.Colors.tertiaryText)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.Colors.tertiaryText)
        }
        .padding(Theme.Layout.cardPadding)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }

    private func fileNotFoundView(_ item: RecentConversion) -> some View {
        #if os(iOS)
        NavigationStack {
            fileNotFoundContent
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "str.close")) {
                            selectedItem = nil
                        }
                    }
                }
        }
        #else
        VStack {
            HStack {
                Spacer()
                Button(String(localized: "str.close")) {
                    selectedItem = nil
                }
            }
            .padding()
            fileNotFoundContent
        }
        .frame(minWidth: 400, minHeight: 300)
        #endif
    }

    private var fileNotFoundContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.questionmark")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.Colors.tertiaryText)

            Text("str.file_not_found")
                .font(Theme.Fonts.sectionTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            Text("str.file_not_found_subtitle")
                .font(Theme.Fonts.subtitle)
                .foregroundStyle(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}
