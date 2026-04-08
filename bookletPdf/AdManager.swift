#if os(iOS)
import SwiftUI
import UIKit
import GoogleMobileAds
import AppV2

@MainActor
final class AdManager: NSObject {
    static let shared = AdManager()

    private static let bannerAdUnitID = "ca-app-pub-3869807878238093/8930697948"
    private static let interstitialAdUnitID = "ca-app-pub-3869807878238093/7617616279"

    private var interstitialAd: InterstitialAd?
    private var interstitialCompletion: (() -> Void)?

    private override init() {
        super.init()
    }

    func configure() {
        MobileAds.shared.start { _ in }
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

        AdService.bannerView = {
            AnyView(BannerAdView(adUnitID: AdManager.bannerAdUnitID))
        }
    }

    private func loadInterstitial() {
        InterstitialAd.load(with: Self.interstitialAdUnitID) { [weak self] ad, error in
            if let error {
                print("Failed to load interstitial: \(error.localizedDescription)")
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    private func showInterstitial(completion: @escaping () -> Void) {
        guard let ad = interstitialAd,
              let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)?
                .rootViewController else {
            completion()
            return
        }

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
#endif
