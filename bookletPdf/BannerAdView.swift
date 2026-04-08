#if os(iOS)
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView()
        bannerView.adUnitID = adUnitID
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
               let rootVC = windowScene.windows.first?.rootViewController {
                bannerView.rootViewController = rootVC
                bannerView.load(Request())
            }
        }

        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
#endif
