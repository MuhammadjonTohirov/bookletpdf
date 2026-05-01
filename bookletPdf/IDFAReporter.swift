#if os(iOS)
import Foundation
import AppTrackingTransparency
import UIKit

#if DEBUG
import AdSupport
import CryptoKit
import OSLog
#endif

/// Coordinates App Tracking Transparency authorization with the launch of any
/// IDFA-dependent SDK (Google Mobile Ads, Firebase Analytics, …). Apple
/// requires the ATT prompt to be presented while the app is in the foreground,
/// so each entry point waits for the first scene to become active before
/// requesting authorization. The completion runs once the user has resolved
/// the prompt (or the system has answered immediately on a previously
/// determined status), giving the caller the right moment to start ad SDKs.
enum IDFAReporter {

    /// Production entry point. Requests ATT and chains the completion. No
    /// device identifiers are read or logged.
    static func requestPermission(then completion: (@MainActor () -> Void)? = nil) {
        Task { @MainActor in
            await waitForForeground()
            _ = await ATTrackingManager.requestTrackingAuthorization()
            completion?()
        }
    }

    #if DEBUG
    /// Debug-only entry point. Requests ATT, then logs the ATT status, the
    /// IDFA, and its md5 hash so a physical device can be registered as a
    /// test device in the AdMob console (Settings → Test devices →
    /// MD5 of advertising ID). Stripped from Release builds at compile time.
    static func requestPermissionAndLog(then completion: (@MainActor () -> Void)? = nil) {
        Task { @MainActor in
            await waitForForeground()
            let status = await ATTrackingManager.requestTrackingAuthorization()
            report(status: status)
            completion?()
        }
    }
    #endif

    @MainActor
    private static func waitForForeground() async {
        guard UIApplication.shared.applicationState != .active else { return }
        for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
            return
        }
    }

    #if DEBUG
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "bookletPdf", category: "IDFA")

    private static func report(status: ATTrackingManager.AuthorizationStatus) {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let hash = adMobTestDeviceHash(for: idfa)

        logger.notice("ATT status: \(statusDescription(status), privacy: .public)")
        logger.notice("IDFA: \(idfa, privacy: .public)")
        logger.notice("AdMob test-device hash (md5 IDFA): \(hash, privacy: .public)")
        logger.notice("Register the hash above in AdMob console → Settings → Test devices to force test ads on this build.")
        print("[IDFA] status=\(statusDescription(status)) idfa=\(idfa) hash=\(hash)")
    }

    private static func statusDescription(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorized: return "authorized"
        @unknown default: return "unknown"
        }
    }

    private static func adMobTestDeviceHash(for idfa: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(idfa.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    #endif
}
#endif
