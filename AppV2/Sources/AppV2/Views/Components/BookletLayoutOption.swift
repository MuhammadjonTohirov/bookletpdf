import SwiftUI
import BookletPDFKit

struct BookletLayoutOption: View {
    let type: BookletType
    let isSelected: Bool
    var isLocked: Bool = false
    let action: () -> Void
    let infoAction: () -> Void

    private var title: String {
        switch type {
        case .type2: return String(localized: "str.standard_booklet_2up")
        case .type4: return String(localized: "str.pocket_booklet_4up")
        }
    }

    private var subtitle: String {
        switch type {
        case .type2: return String(localized: "str.folds_in_half")
        case .type4: return String(localized: "str.folds_into_quarters")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Button(action: action) {
                HStack(spacing: 20) {
                    layoutThumbnail
                        .frame(width: 80, height: 56)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(title)
                                .font(Theme.Fonts.cardTitle)
                                .foregroundStyle(Theme.Colors.primaryText)

                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                        }

                        Text(subtitle)
                            .font(Theme.Fonts.subtitle)
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Layout.screenPadding)
                .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.background.opacity(0.01)))
            }
            .buttonStyle(.plain)

            Button(action: infoAction) {
                Image(systemName: "info.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 36, height: 36)
                    .background(Color.accentColor.opacity(Theme.Opacity.tint), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("str.view_printing_instructions"))
            .padding(Theme.Layout.screenPadding)
        }
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                    .fill(Color.accentColor.opacity(Theme.Opacity.subtle))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                            .stroke(Color.accentColor, lineWidth: Theme.Border.thin)
                    }
            } else {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                    .fill(Theme.Colors.background)
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                            .stroke(Theme.Colors.border.opacity(Theme.Opacity.visible), lineWidth: Theme.Border.thin)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var layoutThumbnail: some View {
        switch type {
        case .type2:
            twoUpThumbnail
        case .type4:
            fourUpThumbnail
        }
    }

    private var twoUpThumbnail: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 4) {
                pagePlaceholder("1")
                pagePlaceholder("2")
            }
            .padding(4)
            .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(isSelected ? Color.accentColor.opacity(0.2) : Theme.Colors.border.opacity(0.4), lineWidth: Theme.Border.thin)
            }

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.accentColor)
                    .offset(x: 2, y: -2)
            }
        }
    }

    private var fourUpThumbnail: some View {
        ZStack(alignment: .topTrailing) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 3), GridItem(.flexible(), spacing: 3)], spacing: 3) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Colors.background)
                        .frame(height: 20)
                        .overlay {
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Theme.Colors.border.opacity(0.4), lineWidth: Theme.Border.thin)
                        }
                        .overlay {
                            Text((index + 1).description)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                }
            }
            .padding(4)
            .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(isSelected ? Color.accentColor.opacity(0.2) : Theme.Colors.border.opacity(0.4), lineWidth: Theme.Border.thin)
            }
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.accentColor)
                    .offset(x: 2, y: -2)
            }
        }
    }

    private func pagePlaceholder(_ number: String) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
            .frame(width: 28, height: 40)
            .overlay {
                Text(number)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Theme.Colors.border.opacity(Theme.Opacity.muted), lineWidth: Theme.Border.thin)
            }
    }
}
