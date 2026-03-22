import SwiftUI
import PDFKit
import BookletPDFKit

struct HistoryView: View {
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @State private var selectedItem: RecentConversion?

    var body: some View {
        Group {
            if viewModel.recentConversions.isEmpty {
                emptyState
            } else {
                historyList
            }
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
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.Colors.tertiaryText)

            Text("str.no_history")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.Colors.primaryText)

            Text("str.no_history_subtitle")
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
                ForEach(viewModel.recentConversions) { item in
                    Button(action: { selectedItem = item }) {
                        historyRow(item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Theme.Layout.screenPadding)
        }
    }

    private func historyRow(_ item: RecentConversion) -> some View {
        HStack(spacing: Theme.Layout.itemSpacing) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.muted))
                .frame(width: Theme.Layout.iconSize, height: Theme.Layout.iconSize)
                .overlay {
                    Image(systemName: "doc.text")
                        .font(Theme.Fonts.smallIcon)
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

                    Text("\(item.pageCount) " + String(localized: "str.pages_suffix"))
                        .font(Theme.Fonts.badge)
                        .foregroundStyle(Theme.Colors.tertiaryText)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Text(item.formattedDate)
                    .font(Theme.Fonts.badge)
                    .foregroundStyle(Theme.Colors.tertiaryText)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.Colors.tertiaryText)
            }
        }
        .padding(Theme.Layout.cardPadding)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }

    private func fileNotFoundView(_ item: RecentConversion) -> some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "str.close")) {
                        selectedItem = nil
                    }
                }
            }
        }
    }
}
