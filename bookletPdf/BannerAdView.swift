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
        let adSize = AdSizeBanner
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator
        bannerView.frame = CGRect(origin: .zero, size: adSize.size)
        AdLog.log("Banner: created adSize=\(adSize.size.width)x\(adSize.size.height)")
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        guard !context.coordinator.didStartLoad else { return }
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController else {
            AdLog.log("Banner: no rootViewController available, will retry on next update")
            return
        }
        context.coordinator.didStartLoad = true
        uiView.rootViewController = rootVC
        let unitID = adUnitID
        AdManager.shared.whenStarted {
            AdLog.log("Banner: load begin unit=\(unitID) adSize=\(uiView.adSize.size)")
            AdLog.event(
                AnalyticsEventName.adBannerLoadRequested,
                parameters: [
                    AnalyticsParamKey.adUnitID: unitID,
                    AnalyticsParamKey.adFormat: "banner"
                ]
            )
            uiView.load(Request())
        }
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        private let didChangeLoadState: (Bool) -> Void
        var didStartLoad = false

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
            let nsError = error as NSError
            AdLog.log("Banner: failed to load code=\(nsError.code) domain=\(nsError.domain) desc=\(error.localizedDescription)")
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
