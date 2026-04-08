import Foundation
import BookletCore

@MainActor
public final class AppUpdateChecker: ObservableObject {
    @Published public private(set) var isUpdateRequired: Bool = false
    @Published public private(set) var updateURL: URL?

    private let bundleId: String
    private let currentVersion: String

    public init() {
        self.bundleId = Bundle.main.bundleIdentifier ?? ""
        self.currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    public func checkForUpdate() async {
        guard !bundleId.isEmpty else { return }

        let lookupURLString: String
        #if os(macOS)
        lookupURLString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)&entity=macSoftware"
        #else
        lookupURLString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        #endif

        guard let url = URL(string: lookupURLString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AppStoreLookupResponse.self, from: data)

            guard let result = response.results.first else { return }

            let storeVersion = result.version
            if isVersion(storeVersion, newerThan: currentVersion) {
                isUpdateRequired = true
                updateURL = storeURL(for: result.trackId)
            }
        } catch {
            Logging.l(tag: "AppUpdateChecker", "Failed to check for update: \(error)")
        }
    }

    private func storeURL(for trackId: Int) -> URL? {
        #if os(macOS)
        URL(string: "macappstore://apps.apple.com/app/id\(trackId)")
        #else
        URL(string: "https://apps.apple.com/app/id\(trackId)")
        #endif
    }

    private func isVersion(_ remote: String, newerThan local: String) -> Bool {
        let remoteParts = remote.split(separator: ".").compactMap { Int($0) }
        let localParts = local.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(remoteParts.count, localParts.count)
        for i in 0..<maxCount {
            let r = i < remoteParts.count ? remoteParts[i] : 0
            let l = i < localParts.count ? localParts[i] : 0
            if r > l { return true }
            if r < l { return false }
        }
        return false
    }
}

private struct AppStoreLookupResponse: Decodable {
    let results: [AppStoreResult]
}

private struct AppStoreResult: Decodable {
    let version: String
    let trackId: Int
}
