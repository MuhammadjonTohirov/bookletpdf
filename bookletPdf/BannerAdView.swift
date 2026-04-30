#if os(iOS)
import SwiftUI
import GoogleMobileAds
import AppV2

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    let didChangeLoadState: (Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(didChangeLoadState: didChangeLoadState)
    }

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        DispatchQueue.main.async {
            guard let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)?
                .rootViewController else {
                AdLog.log("Banner: no rootViewController available")
                return
            }
            bannerView.rootViewController = rootVC
            AdLog.log("Banner: load begin unit=\(adUnitID)")
            AdLog.event(
                AnalyticsEventName.adBannerLoadRequested,
                parameters: [
                    AnalyticsParamKey.adUnitID: adUnitID,
                    AnalyticsParamKey.adFormat: "banner"
                ]
            )
            bannerView.load(Request())
        }

        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    final class Coordinator: NSObject, BannerViewDelegate {
        private let didChangeLoadState: (Bool) -> Void

        init(didChangeLoadState: @escaping (Bool) -> Void) {
            self.didChangeLoadState = didChangeLoadState
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            AdLog.log("Banner: received ad")
            DispatchQueue.main.async {
                self.didChangeLoadState(true)
            }
            AdLog.event(
                AnalyticsEventName.adBannerLoaded,
                parameters: [
                    AnalyticsParamKey.adUnitID: bannerView.adUnitID ?? "",
                    AnalyticsParamKey.adFormat: "banner"
                ]
            )
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            AdLog.log("Banner: failed to load - \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.didChangeLoadState(false)
            }
            AdLog.event(
                AnalyticsEventName.adBannerLoadFailed,
                parameters: AdLog.errorParameters(
                    error,
                    adUnitID: bannerView.adUnitID,
                    adFormat: "banner"
                )
            )
        }
    }
}
#endif
