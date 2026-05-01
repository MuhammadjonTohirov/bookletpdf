#if os(iOS)
import SwiftUI
import UIKit
import Network
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
    private var isStarted = false
    private var pendingReadyActions: [() -> Void] = []
    private let networkMonitor = NWPathMonitor()
    private var hasAttemptedStart = false
    private var stabilityTask: Task<Void, Never>?

    /// Runs `action` once the Google Mobile Ads SDK has finished initialization.
    /// If the SDK is already started the action runs immediately; otherwise it is
    /// queued and flushed inside the `MobileAds.shared.start` completion handler.
    func whenStarted(_ action: @escaping () -> Void) {
        if isStarted {
            action()
        } else {
            pendingReadyActions.append(action)
        }
    }

    private override init() {
        super.init()
    }

    func configure() {
        let appID = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String ?? "<missing>"
        AdLog.log("configure begin build=\(Self.buildConfiguration) appID=\(appID) banner=\(Self.bannerAdUnitID) interstitial=\(Self.interstitialAdUnitID)")

        #if DEBUG
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "GADSimulatorID"
        ]
        AdLog.log("Test device identifiers set: \(MobileAds.shared.requestConfiguration.testDeviceIdentifiers ?? [])")
        #endif

        wireAdService()
        AdLog.log("AdService wired bannerSet=\(AdService.bannerView != nil) interstitialSet=\(AdService.showInterstitial != nil)")
        awaitStableNetworkThenStart()
    }

    /// `MobileAds.shared.start()` caches an unsuccessful initialization for the
    /// remainder of the process, so a launch with no network poisons every
    /// subsequent ad request. Wait for the network path to be `.satisfied` and
    /// remain so for one second (riding out wifi/cellular handoff flicker)
    /// before triggering the single allowed `start()` call.
    private func awaitStableNetworkThenStart() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self, !self.hasAttemptedStart else { return }
                self.stabilityTask?.cancel()
                guard path.status == .satisfied else {
                    AdLog.log("Network unavailable, holding MobileAds.start")
                    return
                }
                self.stabilityTask = Task { @MainActor [weak self] in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    guard !Task.isCancelled, let self, !self.hasAttemptedStart else { return }
                    self.hasAttemptedStart = true
                    self.networkMonitor.cancel()
                    AdLog.log("Network stable, calling MobileAds.start")
                    self.startMobileAds()
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global(qos: .utility))
    }

    private func startMobileAds() {
        MobileAds.shared.start { [weak self] status in
            let adapters = status.adapterStatusesByClassName
            let allReady = !adapters.isEmpty && adapters.values.allSatisfy { $0.state == .ready }
            AdLog.log("MobileAds.start completed adapters=\(adapters.count) allReady=\(allReady)")
            for (name, adapter) in adapters {
                AdLog.log("  adapter=\(name) state=\(adapter.state.rawValue) latency=\(adapter.latency) desc=\(adapter.description)")
            }
            AdLog.event(AnalyticsEventName.adSdkConfigured)
            Task { @MainActor [weak self] in
                guard let self else { return }
                if allReady {
                    self.flushPendingReadyActions()
                    self.loadInterstitial()
                } else {
                    AdLog.log("MobileAds returned not-ready despite stable network. SDK is poisoned for this session — relaunch required.")
                }
            }
        }
    }

    private func flushPendingReadyActions() {
        isStarted = true
        let actions = pendingReadyActions
        pendingReadyActions.removeAll()
        AdLog.log("SDK ready, flushing \(actions.count) pending action(s)")
        actions.forEach { $0() }
    }

    private static var buildConfiguration: String {
        #if DEBUG
        return "DEBUG"
        #else
        return "RELEASE"
        #endif
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
        InterstitialAd.load(with: interstitialAdUnitID, request: Request()) { [weak self] ad, error in
            if let error {
                let nsError = error as NSError
                AdLog.log("Failed to load interstitial code=\(nsError.code) domain=\(nsError.domain) desc=\(error.localizedDescription)")
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
            NotificationCenter.default.post(name: AdService.interstitialDismissedNotification, object: nil)
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
