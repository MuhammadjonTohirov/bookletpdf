import Foundation

/// Source of `HouseAd` items. Today: a local mock. Tomorrow: a remote
/// implementation that fetches from the publisher's server. The same call site
/// keeps working because both implementations satisfy this contract.
public protocol HouseAdGateway: Sendable {
    func fetchHouseAds() async throws -> [HouseAd]
}

/// Returns a hard-coded list of house ads. Use this until a real backend is
/// available; swap with `RemoteHouseAdGateway` (future) without touching the
/// UseCase or UI.
public struct MockHouseAdGateway: HouseAdGateway {
    public init() {}

    public func fetchHouseAds() async throws -> [HouseAd] {
        guard let alifSafariURL = URL(string: "https://apps.apple.com/us/app/alifsafari/id6762508577") else {
            return []
        }
        return [
            HouseAd(
                id: "alifsafari_v1",
                source: .asset(name: "img_banner_example"),
                targetURL: alifSafariURL,
                analyticsName: "alifsafari_v1"
            ),
            HouseAd(
                id: "alifsafari_v2",
                source: .asset(name: "img_banner_example_2"),
                targetURL: alifSafariURL,
                analyticsName: "alifsafari_v2"
            )
        ]
    }
}
