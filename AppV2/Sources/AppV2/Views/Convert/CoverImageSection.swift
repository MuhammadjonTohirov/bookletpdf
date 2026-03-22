import SwiftUI
import BookletPDFKit

struct CoverImageSection: View {
    let imageData: Data?
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Layout.itemSpacing) {
            Text("str.book_cover")
                .font(Theme.Fonts.sectionTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            if let imageData, let image = imageFromData(imageData) {
                filledState(image: image)
            } else {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        Button(action: onAdd) {
            VStack(spacing: 10) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(Theme.Colors.secondaryText)

                Text("str.add_cover_image")
                    .font(Theme.Fonts.bodyMedium)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text("str.optional_cover_subtitle")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Layout.cardPadding)
            .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                    .strokeBorder(style: StrokeStyle(lineWidth: Theme.Border.thin, dash: [8, 4]))
                    .foregroundStyle(Theme.Colors.border.opacity(Theme.Opacity.half))
            }
        }
        .buttonStyle(.plain)
    }

    private func filledState(image: Image) -> some View {
        HStack(spacing: 14) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 48, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.icon))

            VStack(alignment: .leading, spacing: 4) {
                Text("str.cover_added")
                    .font(Theme.Fonts.bodyBold)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text("str.will_be_first_page")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.Colors.secondaryText)
            }

            Spacer(minLength: 0)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Theme.Layout.innerPaddingH)
        .padding(.vertical, Theme.Layout.innerPaddingV)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.panel)
                .stroke(Color.green.opacity(Theme.Opacity.visible), lineWidth: Theme.Border.thin)
        }
    }

    private func imageFromData(_ data: Data) -> Image? {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #endif
    }
}
