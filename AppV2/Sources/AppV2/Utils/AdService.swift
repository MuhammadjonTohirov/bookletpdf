import SwiftUI

@MainActor
public enum AdService {
    /// Shows a full-screen interstitial ad, calls completion when dismissed.
    /// Set by the main target on iOS. Nil on macOS.
    public static var showInterstitial: ((@escaping () -> Void) -> Void)?

    /// Preloads the next interstitial ad.
    public static var loadInterstitial: (() -> Void)?

    /// Returns a banner ad view. Set by the main target on iOS. Nil on macOS.
    /// The callback reports whether an ad creative is actually available.
    public static var bannerView: ((_ didChangeLoadState: @escaping (Bool) -> Void) -> AnyView)?

    /// Posted by the main target when an interstitial ad has been dismissed.
    /// Observers (e.g. the tab view) can use this to refresh ad UI such as
    /// re-showing a previously dismissed banner.
    public static let interstitialDismissedNotification = Notification.Name("bookletpdf.ads.interstitialDismissed")
}
