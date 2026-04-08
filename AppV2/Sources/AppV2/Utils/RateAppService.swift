//
//  RateAppService.swift
//  bookletPdf
//

import StoreKit
import SwiftUI
import BookletCore

@MainActor
enum RateAppService {

    static func requestReviewIfNeeded() {
        guard !UserSettings.hasRatedApp else { return }
        requestReview()
    }

    static func requestReview() {
        #if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }
        AppStore.requestReview(in: scene)
        UserSettings.hasRatedApp = true
        #elseif os(macOS)
        if let url = appStoreReviewURL {
            NSWorkspace.shared.open(url)
            UserSettings.hasRatedApp = true
        }
        #endif
    }

    private static var appStoreReviewURL: URL? {
        guard let appID = Bundle.main.object(forInfoDictionaryKey: "APP_STORE_ID") as? String,
              !appID.isEmpty else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review")
    }
}
