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

    private static let bannerAdUnitID = "ca-app-pub-3869807878238093/8930697948"
    private static let interstitialAdUnitID = "ca-app-pub-3869807878238093/7617616279"

//    #if DEBUG
//    private static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
//    private static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
//    #else
//    private static let bannerAdUnitID = "ca-app-pub-3869807878238093/8930697948"
//    private static let interstitialAdUnitID = "ca-app-pub-3869807878238093/7617616279"
//    #endif

    private var interstitialAd: InterstitialAd?
    private var interstitialCompletion: (() -> Void)?
    private var isInterstitialLoading = false
    private var interstitialRetryAttempt = 0
    private var interstitialRetryTask: Task<Void, Never>?
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

        configureTestDevices()
        wireAdService()
        AdLog.log("AdService wired bannerSet=\(AdService.bannerView != nil) interstitialSet=\(AdService.showInterstitial != nil)")
        awaitStableNetworkThenStart()
    }

    /// Marks debug builds as test devices so live ad units serve real-rendered
    /// ads flagged as test by Google — no policy risk from self-impressions/taps.
    /// On first run, the SDK prints a line like:
    /// `<Google> To get test ads on this device, set: testDeviceIdentifiers = @[ @"abc123..." ];`
    /// Paste each device hash into `ids` below.
    private func configureTestDevices() {
        #if DEBUG
        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        AdLog.log("DEVICE IDFV=\(idfv)")
        let ids: [String] = [
            "00008120-000270902E39A01E",
            "13D25292-5F86-4D79-8ED7-6B39F2860A31",
            idfv
        ]
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ids
        AdLog.log("Test device identifiers set count=\(ids.count)")
        #endif
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
            let readyAdapters = adapters.values.filter { $0.state == .ready }.count
            AdLog.log("MobileAds.start completed adapters=\(adapters.count) ready=\(readyAdapters)")
            for (name, adapter) in adapters {
                AdLog.log("  adapter=\(name) state=\(adapter.state.rawValue) latency=\(adapter.latency) desc=\(adapter.description)")
            }
            AdLog.event(AnalyticsEventName.adSdkConfigured, parameters: AdLog.sessionParameters)
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.flushPendingReadyActions()
                self.loadInterstitial()
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
        guard isStarted else {
            AdLog.log("loadInterstitial queued until SDK start completes")
            whenStarted { [weak self] in
                self?.loadInterstitial()
            }
            return
        }
        guard interstitialAd == nil else {
            AdLog.log("loadInterstitial skipped: ad already loaded")
            return
        }
        guard !isInterstitialLoading else {
            AdLog.log("loadInterstitial skipped: load already in progress")
            return
        }

        isInterstitialLoading = true
        interstitialRetryTask?.cancel()
        let retryAttempt = interstitialRetryAttempt
        let interstitialAdUnitID = Self.interstitialAdUnitID
        AdLog.log("loadInterstitial begin unit=\(interstitialAdUnitID) retry=\(retryAttempt)")
        AdLog.event(
            AnalyticsEventName.adInterstitialLoadRequested,
            parameters: AdLog.parameters(
                adUnitID: interstitialAdUnitID,
                adFormat: "interstitial",
                retryAttempt: retryAttempt
            )
        )
        InterstitialAd.load(with: interstitialAdUnitID, request: Request()) { [weak self] ad, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isInterstitialLoading = false

                if let error {
                    let nsError = error as NSError
                    AdLog.log("Failed to load interstitial code=\(nsError.code) domain=\(nsError.domain) desc=\(error.localizedDescription)")
                    AdLog.event(
                        AnalyticsEventName.adInterstitialLoadFailed,
                        parameters: AdLog.errorParameters(
                            error,
                            adUnitID: interstitialAdUnitID,
                            adFormat: "interstitial",
                            retryAttempt: retryAttempt
                        )
                    )
                    self.scheduleInterstitialRetry()
                    return
                }

                AdLog.log("Interstitial loaded successfully")
                self.interstitialRetryTask?.cancel()
                self.interstitialRetryAttempt = 0
                AdLog.event(
                    AnalyticsEventName.adInterstitialLoaded,
                    parameters: AdLog.parameters(
                        adUnitID: Self.interstitialAdUnitID,
                        adFormat: "interstitial"
                    )
                )
                self.interstitialAd = ad
                self.interstitialAd?.fullScreenContentDelegate = self
            }
        }
    }

    private func scheduleInterstitialRetry() {
        guard interstitialRetryAttempt < 3 else {
            AdLog.log("Interstitial retry limit reached")
            return
        }

        interstitialRetryAttempt += 1
        let delaySeconds = min(30 * interstitialRetryAttempt, 120)
        AdLog.log("Scheduling interstitial retry attempt=\(interstitialRetryAttempt) delay=\(delaySeconds)s")
        interstitialRetryTask?.cancel()
        interstitialRetryTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
            guard !Task.isCancelled else { return }
            self?.loadInterstitial()
        }
    }

    private func showInterstitial(completion: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            AdLog.log("showInterstitial: no ad loaded, firing completion immediately; triggering reload")
            AdLog.event(
                AnalyticsEventName.adInterstitialUnavailable,
                parameters: AdLog.parameters(
                    adUnitID: Self.interstitialAdUnitID,
                    adFormat: "interstitial"
                )
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
            parameters: AdLog.parameters(
                adUnitID: Self.interstitialAdUnitID,
                adFormat: "interstitial"
            )
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
            self?.interstitialAd = nil
            self?.loadInterstitial()
        }
    }
}
#endif
