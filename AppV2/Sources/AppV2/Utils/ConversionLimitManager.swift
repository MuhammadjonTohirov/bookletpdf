import Foundation

@MainActor
public final class ConversionLimitManager: ObservableObject {
    public static let shared = ConversionLimitManager()

    private static let totalConversionCountKey = "bookletpdf.totalConversionCount"
    private static let lastConversionDateKey = "bookletpdf.lastConversionDate"
    private static let dailyConversionCountKey = "bookletpdf.dailyConversionCount"

    /// Number of free conversions before restrictions kick in
    private static let freeConversionLimit = 3
    /// Daily limit for macOS after free conversions are used
    private static let macOSDailyLimit = 3
    /// Show an interstitial once every N eligible conversions (post free limit)
    private static let interstitialCadence = 2

    @Published public private(set) var totalConversions: Int

    private init() {
        totalConversions = UserDefaults.standard.integer(forKey: Self.totalConversionCountKey)
    }

    /// Whether the user has exceeded the free conversion threshold
    var hasReachedFreeLimit: Bool {
        totalConversions >= Self.freeConversionLimit
    }

    /// Whether the user should see an interstitial ad (iOS).
    /// After the free limit, shows once every `interstitialCadence` conversions
    /// so users aren't hit with a full-screen ad on every single conversion.
    var shouldShowAd: Bool {
        #if DEBUG
        return true
        #else
        guard hasReachedFreeLimit else { return false }
        let postFreeCount = totalConversions - Self.freeConversionLimit
        return postFreeCount % Self.interstitialCadence == 0
        #endif
    }

    /// Whether the user can convert on macOS (3/day after free limit)
    var canConvertOnMacOS: Bool {
        guard hasReachedFreeLimit else { return true }
        return dailyConversionCount < Self.macOSDailyLimit || isNewDay
    }

    func recordConversion() {
        totalConversions += 1
        UserDefaults.standard.set(totalConversions, forKey: Self.totalConversionCountKey)

        let today = Self.todayString
        if UserDefaults.standard.string(forKey: Self.lastConversionDateKey) == today {
            let count = UserDefaults.standard.integer(forKey: Self.dailyConversionCountKey) + 1
            UserDefaults.standard.set(count, forKey: Self.dailyConversionCountKey)
        } else {
            UserDefaults.standard.set(today, forKey: Self.lastConversionDateKey)
            UserDefaults.standard.set(1, forKey: Self.dailyConversionCountKey)
        }
    }

    private var dailyConversionCount: Int {
        guard !isNewDay else { return 0 }
        return UserDefaults.standard.integer(forKey: Self.dailyConversionCountKey)
    }

    private var isNewDay: Bool {
        guard let storedDate = UserDefaults.standard.string(forKey: Self.lastConversionDateKey) else {
            return true
        }
        return storedDate != Self.todayString
    }

    private static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
