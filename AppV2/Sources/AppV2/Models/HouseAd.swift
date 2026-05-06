import Foundation

/// A self-promoted ad slot rendered when the AdMob banner fails to fill.
/// Initially served from a local mock; the same model serves remote ads later
/// via a different gateway.
public struct HouseAd: Identifiable, Equatable, Sendable {
    public let id: String
    public let source: HouseAdImageSource
    public let targetURL: URL
    public let analyticsName: String

    public init(
        id: String,
        source: HouseAdImageSource,
        targetURL: URL,
        analyticsName: String
    ) {
        self.id = id
        self.source = source
        self.targetURL = targetURL
        self.analyticsName = analyticsName
    }
}

public enum HouseAdImageSource: Equatable, Sendable {
    /// Image stored in the main app's asset catalog.
    case asset(name: String)
    /// Remote image fetched at runtime (server-served ads).
    case remote(URL)
}
