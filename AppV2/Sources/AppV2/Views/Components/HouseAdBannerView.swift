#if os(iOS)
import SwiftUI
import UIKit
import BookletCore

/// Renders a `HouseAd` to fill the banner slot when AdMob doesn't deliver.
/// Tap opens the ad's target URL.
struct HouseAdBannerView: View {
    let ad: HouseAd

    var body: some View {
        Button(action: openTarget) {
            adImage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .overlay(alignment: .topTrailing) { adBadge }
                .overlay {
                    Rectangle()
                        .stroke(Color(.separator), lineWidth: 0.5)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var adBadge: some View {
        Text("str.ad_badge".localize)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 3))
            .padding(4)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var adImage: some View {
        switch ad.source {
        case .asset(let name):
            Image(name, bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .remote(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .empty, .failure:
                    Color.clear
                @unknown default:
                    Color.clear
                }
            }
        }
    }

    private func openTarget() {
        UIApplication.shared.open(ad.targetURL)
    }
}
#endif
