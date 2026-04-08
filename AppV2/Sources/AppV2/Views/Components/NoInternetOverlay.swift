import SwiftUI
import BookletCore
import BookletPDFKit

struct NoInternetOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: Theme.Layout.sectionSpacing) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.Colors.secondaryText)

                Text("str.internet_required".localize)
                    .font(Theme.Fonts.heroTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                Text("str.internet_required_message".localize)
                    .font(Theme.Fonts.cellBody)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(Theme.Layout.screenPadding)
            .frame(maxWidth: 400)
            .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section))
            .shadow(color: .black.opacity(0.15), radius: 20)
        }
    }
}
