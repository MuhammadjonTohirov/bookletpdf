import Foundation

/// Decides whether to present the What's New sheet on launch.
///
/// Gating is per-release: the marketing version (`CFBundleShortVersionString`)
/// drives the key. Bumping the marketing version on a release that ships new
/// What's New copy triggers the sheet for active users on first launch after
/// update. Build-number-only resubmissions (same marketing version) do not
/// re-show. Brand-new installs never see the sheet for the version they
/// install on, since the new features are already their baseline.
@MainActor
public final class WhatsNewManager: ObservableObject {
    public static let shared = WhatsNewManager()

    /// Tied to `CFBundleShortVersionString`. Prefixed so the stored value is
    /// distinguishable from a bare version string anywhere it gets logged.
    static let currentReleaseKey: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return "whatsnew.\(version)"
    }()

    private static let lastSeenReleaseKey = "WhatsNew.lastSeenRelease"

    /// MIRRORS `ConversionLimitManager.totalConversionCountKey`. Re-declared
    /// here only to avoid widening that type's API. If that key ever moves,
    /// move this with it — there is no compile-time link.
    private static let totalConversionsKey = "bookletpdf.totalConversionCount"

    @Published public private(set) var shouldPresent: Bool = false

    private init() {
        shouldPresent = Self.evaluateOnLaunch()
    }

    /// Mark the current release as seen, suppressing re-presentation on
    /// subsequent launches until `currentReleaseKey` changes.
    ///
    /// In DEBUG builds we still flip `shouldPresent` to `false` so the dismiss
    /// works for the current session, but we skip persisting it so the sheet
    /// shows again on the next launch.
    public func markSeen() {
        #if !DEBUG
        UserDefaults.standard.set(Self.currentReleaseKey, forKey: Self.lastSeenReleaseKey)
        #endif
        shouldPresent = false
    }

    /// Suppressed for the 1.2.2 ad-bugfix release: the existing sheet copy
    /// describes the 1.2.1 iOS print flow and would re-show stale content to
    /// upgraders. Restore the version-gated logic (DEBUG always-show, Release
    /// compare `currentReleaseKey` to `lastSeenReleaseKey`) when shipping new
    /// What's New content alongside a marketing-version bump.
    private static func evaluateOnLaunch() -> Bool {
        return false
    }
}
