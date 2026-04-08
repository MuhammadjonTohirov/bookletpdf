import SwiftUI
import BookletCore
import BookletPDFKit

struct UploadZoneView: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.xlarge)
                        .fill(Color.accentColor.opacity(Theme.Opacity.tint))
                        .frame(width: 72, height: 72)
                        .overlay {
                            Image(systemName: "doc.badge.arrow.up")
                                .font(Theme.Fonts.mediumIcon)
                                .foregroundStyle(Color.accentColor)
                        }

                    Circle()
                        .fill(Theme.Colors.background)
                        .frame(width: 28, height: 28)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.accentColor)
                        }
                        .offset(x: 4, y: 4)
                }
                .padding(.bottom, Theme.Layout.innerPaddingH)

                Text("str.tap_to_select_pdf".localize)
                    .font(Theme.Fonts.pageTitle)
                    .foregroundStyle(Theme.Colors.primaryText)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Theme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.container))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.container)
                    .strokeBorder(style: StrokeStyle(lineWidth: Theme.Border.thin, dash: [12, 8]))
                    .foregroundStyle(Theme.Colors.border)
            }
        }
        .buttonStyle(.plain)
    }
}
