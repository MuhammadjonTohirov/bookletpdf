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
}
