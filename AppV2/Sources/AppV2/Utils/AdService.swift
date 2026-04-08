import SwiftUI

@MainActor
public enum AdService {
    /// Shows a full-screen interstitial ad, calls completion when dismissed.
    /// Set by the main target on iOS. Nil on macOS.
    public static var showInterstitial: ((@escaping () -> Void) -> Void)?

    /// Preloads the next interstitial ad.
    public static var loadInterstitial: (() -> Void)?

    /// Returns a banner ad view. Set by the main target on iOS. Nil on macOS.
    public static var bannerView: (() -> AnyView)?
}
