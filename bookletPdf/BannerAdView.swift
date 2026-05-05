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
        context.coordinator.loadBanner(uiView, adUnitID: adUnitID)
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        private let didChangeLoadState: (Bool) -> Void
        private var isLoading = false
        private var retryAttempt = 0
        private var retryTask: Task<Void, Never>?
        var didStartLoad = false

        init(didChangeLoadState: @escaping (Bool) -> Void) {
            self.didChangeLoadState = didChangeLoadState
        }

        @MainActor
        func loadBanner(_ bannerView: BannerView, adUnitID: String) {
            guard !isLoading else { return }
            isLoading = true
            let currentRetryAttempt = retryAttempt
            AdManager.shared.whenStarted { [weak bannerView] in
                guard let bannerView else { return }
                AdLog.log("Banner: load begin unit=\(adUnitID) adSize=\(bannerView.adSize.size) retry=\(currentRetryAttempt)")
                AdLog.event(
                    AnalyticsEventName.adBannerLoadRequested,
                    parameters: AdLog.parameters(
                        adUnitID: adUnitID,
                        adFormat: "banner",
                        retryAttempt: currentRetryAttempt
                    )
                )
                bannerView.load(Request())
            }
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            AdLog.log("Banner: received ad")
            isLoading = false
            retryTask?.cancel()
            retryAttempt = 0
            DispatchQueue.main.async {
                self.didChangeLoadState(true)
            }
            AdLog.event(
                AnalyticsEventName.adBannerLoaded,
                parameters: AdLog.parameters(
                    adUnitID: bannerView.adUnitID ?? "",
                    adFormat: "banner"
                )
            )
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            let nsError = error as NSError
            AdLog.log("Banner: failed to load code=\(nsError.code) domain=\(nsError.domain) desc=\(error.localizedDescription)")
            isLoading = false
            DispatchQueue.main.async {
                self.didChangeLoadState(false)
            }
            AdLog.event(
                AnalyticsEventName.adBannerLoadFailed,
                parameters: AdLog.errorParameters(
                    error,
                    adUnitID: bannerView.adUnitID,
                    adFormat: "banner",
                    retryAttempt: retryAttempt
                )
            )
            scheduleRetry(for: bannerView)
        }

        private func scheduleRetry(for bannerView: BannerView) {
            guard retryAttempt < 2 else { return }
            retryAttempt += 1
            let delaySeconds = 30 * retryAttempt
            retryTask?.cancel()
            retryTask = Task { @MainActor [weak self, weak bannerView] in
                try? await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
                guard !Task.isCancelled, let self, let bannerView else { return }
                self.loadBanner(bannerView, adUnitID: bannerView.adUnitID ?? "")
            }
        }
    }
}
#endif
