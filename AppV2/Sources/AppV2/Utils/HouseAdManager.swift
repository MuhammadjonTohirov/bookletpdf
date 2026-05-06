import Foundation
import SwiftUI

/// Holds the currently displayed house ad and exposes it to the UI.
/// Loads ads once via `LoadHouseAdsUseCase`, picks one to show, and rotates on
/// demand. Designed so the gateway can later be a real network call without
/// touching call sites.
@MainActor
public final class HouseAdManager: ObservableObject {
    public static let shared = HouseAdManager()

    @Published public private(set) var currentAd: HouseAd?

    private let useCase: LoadHouseAdsUseCase
    private var ads: [HouseAd] = []
    private var loadTask: Task<Void, Never>?

    public init(useCase: LoadHouseAdsUseCase = LoadHouseAdsUseCaseImpl()) {
        self.useCase = useCase
    }

    /// Triggers an initial load. Idempotent: subsequent calls while a load is
    /// in flight are coalesced; once ads exist, calling again is a no-op.
    public func start() {
        guard loadTask == nil, ads.isEmpty else { return }
        loadTask = Task { @MainActor [weak self] in
            await self?.load()
            self?.loadTask = nil
        }
    }

    /// Picks a different ad from the loaded set. Useful between sessions or
    /// after a full-screen ad dismisses, to avoid showing the same creative
    /// over and over.
    public func rotate() {
        guard ads.count > 1 else { return }
        let pool = ads.filter { $0.id != currentAd?.id }
        currentAd = pool.randomElement() ?? ads.randomElement()
    }

    private func load() async {
        do {
            ads = try await useCase.loadAds()
            currentAd = ads.randomElement()
        } catch {
            ads = []
            currentAd = nil
        }
    }
}
