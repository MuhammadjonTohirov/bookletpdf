import SwiftUI
import BookletCore
import BookletPDFKit

struct FileDetailCard: View {
    let fileName: String
    let pageCount: Int
    var isAccent: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.icon)
                .fill(isAccent ? Color.accentColor.opacity(Theme.Opacity.tint) : Theme.Colors.secondaryBackground.opacity(Theme.Opacity.muted))
                .frame(width: Theme.Layout.iconSize, height: Theme.Layout.iconSize)
                .overlay {
                    Image(systemName: "doc.text")
                        .font(Theme.Fonts.smallIcon)
                        .foregroundStyle(isAccent ? Color.accentColor : Theme.Colors.secondaryText)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(fileName)
                    .font(Theme.Fonts.bodyBold)
                    .foregroundStyle(Theme.Colors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 6) {
                    Image(systemName: "square.stack.3d.up")
                        .font(Theme.Fonts.badge)
                    Text("str.original_pages \(pageCount)".localize)
                        .font(Theme.Fonts.caption)
                }
                .foregroundStyle(Theme.Colors.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.Layout.innerPaddingH)
        .padding(.vertical, Theme.Layout.innerPaddingV)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.panel)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.visible), lineWidth: Theme.Border.thin)
        }
    }
}
