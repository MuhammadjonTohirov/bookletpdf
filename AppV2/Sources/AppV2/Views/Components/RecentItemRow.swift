import SwiftUI
import BookletCore
import BookletPDFKit

struct RecentItemRow: View {
    let item: RecentConversion
    var iconSize: CGFloat = Theme.Layout.iconSize

    var body: some View {
        HStack(spacing: Theme.Layout.itemSpacing) {
            iconBadge

            VStack(alignment: .leading, spacing: 3) {
                Text(item.fileName)
                    .font(Theme.Fonts.cellTitle)
                    .foregroundStyle(Theme.Colors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 8) {
                    if let bookletType = item.bookletType, item.kind == .booklet {
                        Text(bookletType)
                            .font(Theme.Fonts.badge)
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(Theme.Opacity.tint), in: Capsule())
                    } else if item.kind == .scan {
                        Text("str.scanned_badge".localize)
                            .font(Theme.Fonts.badge)
                            .foregroundStyle(scanTint)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(scanTint.opacity(Theme.Opacity.tint), in: Capsule())
                    }

                    Text("\(item.pageCount) " + "str.pages_suffix".localize)
                        .font(Theme.Fonts.badge)
                        .foregroundStyle(Theme.Colors.tertiaryText)

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

    private var iconBadge: some View {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
            .fill(badgeBackground)
            .frame(width: iconSize, height: iconSize)
            .overlay {
                Image(systemName: badgeSymbol)
                    .font(Theme.Fonts.smallIcon)
                    .foregroundStyle(badgeForeground)
            }
    }

    private var badgeSymbol: String {
        item.origin == .scan ? "viewfinder" : "doc.text"
    }

    private var badgeBackground: Color {
        item.origin == .scan
            ? scanTint.opacity(Theme.Opacity.tint)
            : Theme.Colors.secondaryBackground.opacity(Theme.Opacity.muted)
    }

    private var badgeForeground: Color {
        item.origin == .scan ? scanTint : Theme.Colors.secondaryText
    }

    private var scanTint: Color { .green }
}
