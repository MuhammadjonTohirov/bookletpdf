import SwiftUI
import BookletPDFKit

/// Modal sheet that highlights what changed in the latest release.
///
/// Presentation gating lives in `WhatsNewManager`; this view is purely visual.
struct WhatsNewView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    header
                    featureList
                }
                .padding(.horizontal, Theme.Layout.screenPadding)
                .padding(.top, 32)
                .padding(.bottom, 16)
            }

            dismissButton
                .padding(.horizontal, Theme.Layout.screenPadding)
                .padding(.bottom, Theme.Layout.screenPadding)
        }
        .background(Theme.Colors.background)
        #if os(macOS)
        .frame(minWidth: 480, idealWidth: 520, minHeight: 540, idealHeight: 580)
        #endif
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 16) {
            heroBadge

            VStack(spacing: 8) {
                Text("str.whats_new_title")
                    .font(Theme.Fonts.heroTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text("str.whats_new_subtitle")
                    .font(Theme.Fonts.bodyMedium)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }
        }
    }

    private var heroBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.25),
                            Color.accentColor.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 96, height: 96)
                .overlay(
                    Circle().stroke(Color.accentColor.opacity(Theme.Opacity.faded), lineWidth: 1)
                )

            Image(systemName: "sparkles")
                .font(.system(size: 38, weight: .regular))
                .foregroundStyle(Color.accentColor)
        }
    }

    // MARK: - Feature list

    private var featureList: some View {
        VStack(spacing: 12) {
            featureCard(
                icon: "iphone.and.arrow.forward",
                titleKey: "str.whats_new_feature_ios_title",
                descriptionKey: "str.whats_new_feature_ios_desc"
            )
            featureCard(
                icon: "wand.and.stars",
                titleKey: "str.whats_new_feature_simple_title",
                descriptionKey: "str.whats_new_feature_simple_desc"
            )
        }
    }

    private func featureCard(
        icon: String,
        titleKey: LocalizedStringKey,
        descriptionKey: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            iconBubble(systemName: icon)

            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey)
                    .font(Theme.Fonts.cardTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text(descriptionKey)
                    .font(Theme.Fonts.subtitle)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Layout.innerPaddingH)
        .background(
            Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded),
            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        )
    }

    private func iconBubble(systemName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.icon)
                .fill(Color.accentColor.opacity(Theme.Opacity.tint))
                .frame(width: 44, height: 44)

            Image(systemName: systemName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.accentColor)
        }
    }

    // MARK: - CTA

    private var dismissButton: some View {
        Button(action: onDismiss) {
            Text("str.whats_new_dismiss")
                .font(Theme.Fonts.cardTitle)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
        }
        .buttonStyle(.plain)
    }
}

#Preview("What's New") {
    WhatsNewView(onDismiss: {})
}

#Preview("What's New — Dark") {
    WhatsNewView(onDismiss: {})
        .preferredColorScheme(.dark)
}
