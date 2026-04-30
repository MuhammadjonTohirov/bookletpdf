#if os(iOS)
import SwiftUI
import UIKit
import GoogleMobileAds
import FirebaseAnalytics
import AppV2

@MainActor
final class AdManager: NSObject {
    static let shared = AdManager()

    #if DEBUG
    private static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    private static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    private static let bannerAdUnitID = "ca-app-pub-3869807878238093/8930697948"
    private static let interstitialAdUnitID = "ca-app-pub-3869807878238093/7617616279"
    #endif

    private var interstitialAd: InterstitialAd?
    private var interstitialCompletion: (() -> Void)?

    private override init() {
        super.init()
    }

    func configure() {
        #if DEBUG
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "GADSimulatorID"
        ]
        #endif
        MobileAds.shared.start { _ in
            AdLog.event(AnalyticsEventName.adSdkConfigured)
        }
        wireAdService()
        loadInterstitial()
    }

    private func wireAdService() {
        AdService.showInterstitial = { [weak self] completion in
            self?.showInterstitial(completion: completion)
        }

        AdService.loadInterstitial = { [weak self] in
            self?.loadInterstitial()
        }

        AdService.bannerView = { didChangeLoadState in
            AnyView(
                BannerAdView(
                    adUnitID: AdManager.bannerAdUnitID,
                    didChangeLoadState: didChangeLoadState
                )
            )
        }
    }

    private func loadInterstitial() {
        let interstitialAdUnitID = Self.interstitialAdUnitID
        AdLog.log("loadInterstitial begin unit=\(interstitialAdUnitID)")
        AdLog.event(
            AnalyticsEventName.adInterstitialLoadRequested,
            parameters: [
                AnalyticsParamKey.adUnitID: interstitialAdUnitID,
                AnalyticsParamKey.adFormat: "interstitial"
            ]
        )
        InterstitialAd.load(with: interstitialAdUnitID) { [weak self] ad, error in
            if let error {
                AdLog.log("Failed to load interstitial: \(error.localizedDescription)")
                AdLog.event(
                    AnalyticsEventName.adInterstitialLoadFailed,
                    parameters: AdLog.errorParameters(
                        error,
                        adUnitID: interstitialAdUnitID,
                        adFormat: "interstitial"
                    )
                )
                return
            }

            DispatchQueue.main.async {
                AdLog.log("Interstitial loaded successfully")
                AdLog.event(
                    AnalyticsEventName.adInterstitialLoaded,
                    parameters: [
                        AnalyticsParamKey.adUnitID: Self.interstitialAdUnitID,
                        AnalyticsParamKey.adFormat: "interstitial"
                    ]
                )
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
            }
        }
    }

    private func showInterstitial(completion: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            AdLog.log("showInterstitial: no ad loaded, firing completion immediately; triggering reload")
            AdLog.event(
                AnalyticsEventName.adInterstitialUnavailable,
                parameters: [
                    AnalyticsParamKey.adUnitID: Self.interstitialAdUnitID,
                    AnalyticsParamKey.adFormat: "interstitial"
                ]
            )
            loadInterstitial()
            completion()
            return
        }
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController else {
            AdLog.log("showInterstitial: no rootViewController, firing completion immediately")
            completion()
            return
        }

        AdLog.log("Presenting interstitial")
        AdLog.event(
            AnalyticsEventName.adInterstitialPresented,
            parameters: [
                AnalyticsParamKey.adUnitID: Self.interstitialAdUnitID,
                AnalyticsParamKey.adFormat: "interstitial"
            ]
        )
        interstitialCompletion = completion
        ad.present(from: rootVC)
    }
}

extension AdManager: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor [weak self] in
            AdLog.event(AnalyticsEventName.adInterstitialDismissed)
            self?.interstitialCompletion?()
            self?.interstitialCompletion = nil
            self?.interstitialAd = nil
            self?.loadInterstitial()
        }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor [weak self] in
            AdLog.event(
                AnalyticsEventName.adInterstitialPresentationFailed,
                parameters: AdLog.errorParameters(error, adFormat: "interstitial")
            )
            self?.interstitialCompletion?()
            self?.interstitialCompletion = nil
            self?.loadInterstitial()
        }
    }
}

enum AdLog {
    static func log(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("[Ads] \(message())")
        #endif
    }

    static func event(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    static func errorParameters(_ error: Error, adUnitID: String? = nil, adFormat: String) -> [String: Any] {
        let nsError = error as NSError
        var parameters: [String: Any] = [
            AnalyticsParamKey.adFormat: adFormat,
            AnalyticsParamKey.error: error.localizedDescription,
            AnalyticsParamKey.errorCode: nsError.code,
            AnalyticsParamKey.errorDomain: nsError.domain
        ]
        if let adUnitID {
            parameters[AnalyticsParamKey.adUnitID] = adUnitID
        }
        return parameters
    }
}
#endif
