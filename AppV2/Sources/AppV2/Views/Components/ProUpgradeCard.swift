import SwiftUI
import BookletCore
import BookletPDFKit

struct ProUpgradeCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("str.upgrade_to_pro".localize)
                        .font(Theme.Fonts.cellTitle)
                        .foregroundStyle(Theme.Colors.primaryText)

                    Text("str.pro_upgrade_subtitle".localize)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.secondaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, Theme.Layout.innerPaddingH)
            .padding(.vertical, Theme.Layout.innerPaddingV)
            .background(
                LinearGradient(
                    colors: [
                        Color.accentColor.opacity(0.08),
                        Theme.Colors.background
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: Theme.Border.thin)
            }
        }
        .buttonStyle(.plain)
    }
}
