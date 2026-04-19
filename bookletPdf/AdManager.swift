#if os(iOS)
import SwiftUI
import UIKit
import AppTrackingTransparency
import GoogleMobileAds
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
        wireAdService()
        Task { @MainActor in
            await requestTrackingAuthorization()
            MobileAds.shared.start { _ in }
            loadInterstitial()
        }
    }

    private func requestTrackingAuthorization() async {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        try? await Task.sleep(nanoseconds: 400_000_000)
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    private func wireAdService() {
        AdService.showInterstitial = { [weak self] completion in
            self?.showInterstitial(completion: completion)
        }

        AdService.loadInterstitial = { [weak self] in
            self?.loadInterstitial()
        }

        AdService.bannerView = {
            AnyView(BannerAdView(adUnitID: AdManager.bannerAdUnitID))
        }
    }

    private func loadInterstitial() {
        AdLog.log("loadInterstitial begin unit=\(Self.interstitialAdUnitID)")
        InterstitialAd.load(with: Self.interstitialAdUnitID) { [weak self] ad, error in
            if let error {
                AdLog.log("Failed to load interstitial: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                AdLog.log("Interstitial loaded successfully")
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
            }
        }
    }

    private func showInterstitial(completion: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            AdLog.log("showInterstitial: no ad loaded, firing completion immediately; triggering reload")
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
        interstitialCompletion = completion
        ad.present(from: rootVC)
    }
}

extension AdManager: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor [weak self] in
            self?.interstitialCompletion?()
            self?.interstitialCompletion = nil
            self?.interstitialAd = nil
            self?.loadInterstitial()
        }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor [weak self] in
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
}
#endif
