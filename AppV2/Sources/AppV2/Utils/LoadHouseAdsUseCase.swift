import Foundation

/// Loads the available house ads. Hides the gateway choice from callers; the
/// manager only has to depend on this use case, not on the gateway directly.
public protocol LoadHouseAdsUseCase: Sendable {
    func loadAds() async throws -> [HouseAd]
}

public struct LoadHouseAdsUseCaseImpl: LoadHouseAdsUseCase {
    private let gateway: HouseAdGateway

    public init(gateway: HouseAdGateway = MockHouseAdGateway()) {
        self.gateway = gateway
    }

    public func loadAds() async throws -> [HouseAd] {
        try await gateway.fetchHouseAds()
    }
}
