import SwiftUI
import BookletCore
import BookletPDFKit

struct ForceUpdateOverlay: View {
    let updateURL: URL?

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: Theme.Layout.sectionSpacing) {
                Image(systemName: "arrow.down.app.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.accentColor)

                Text("str.update_required".localize)
                    .font(Theme.Fonts.heroTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text("str.update_required_message".localize)
                    .font(Theme.Fonts.cellBody)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button(action: openAppStore) {
                    Text("str.update_now".localize)
                        .font(Theme.Fonts.cardTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Layout.buttonPaddingV)
                        .foregroundStyle(.white)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
            }
            .padding(Theme.Layout.screenPadding)
            .frame(maxWidth: 400)
            .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section))
            .shadow(color: .black.opacity(0.15), radius: 20)
        }
    }

    private func openAppStore() {
        guard let url = updateURL else { return }
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
