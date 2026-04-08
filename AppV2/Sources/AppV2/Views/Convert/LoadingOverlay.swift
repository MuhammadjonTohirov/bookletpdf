import SwiftUI
import BookletCore
import BookletPDFKit

struct LoadingOverlay: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.black.opacity(Theme.Opacity.faded)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Theme.Colors.border.opacity(Theme.Opacity.faded), lineWidth: 3)
                        .frame(width: 48, height: 48)

                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            AngularGradient(
                                colors: [Color.accentColor.opacity(Theme.Opacity.faded), Color.accentColor],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                }

                VStack(spacing: 6) {
                    Text("str.converting".localize)
                        .font(Theme.Fonts.sectionTitle)
                        .foregroundStyle(Theme.Colors.primaryText)

                    Text("str.converting_message".localize)
                        .font(Theme.Fonts.subtitle)
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
            .padding(32)
            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
        }
        .onAppear { isAnimating = true }
    }
}
