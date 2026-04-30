//
//  FirebaseService.swift
//  bookletPdf
//

import Foundation
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseMessaging
import AppV2
import BookletCore
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private let tag = "Firebase"

enum FirebaseService {

    // MARK: - Configuration

    static func configure() {
        Logging.l(tag: tag, "Configuring Firebase...")
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)

        #if os(iOS)
        Crashlytics.crashlytics().setCustomValue("iOS", forKey: "platform")
        Logging.l(tag: tag, "Platform: iOS")
        #elseif os(macOS)
        Crashlytics.crashlytics().setCustomValue("macOS", forKey: "platform")
        Logging.l(tag: tag, "Platform: macOS")
        #endif

        wireAnalyticsReporter()
        Logging.l(tag: tag, "Firebase configured successfully")
    }

    // MARK: - Push Notifications

    static func registerForPushNotifications() {
        Messaging.messaging().isAutoInitEnabled = true

        Logging.l(tag: tag, "Requesting push notification authorization...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            Logging.l(tag: tag, "Push authorization granted: \(granted)")
            if let error { Logging.l(tag: tag, "Push authorization error: \(error)") }
        }

        #if os(iOS)
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            Logging.l(tag: tag, "Registered for remote notifications (iOS)")
        }
        #elseif os(macOS)
        NSApplication.shared.registerForRemoteNotifications()
        Logging.l(tag: tag, "Registered for remote notifications (macOS)")
        #endif
    }

    static func setAPNSToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Logging.l(tag: tag, "APNs token set: \(tokenString)")
    }

    // MARK: - Analytics

    static func log(_ event: AnalyticsEvent) {
        Logging.l(tag: tag, "Event: \(event.name) \(event.parameters ?? [:])")
        Analytics.logEvent(event.name, parameters: event.parameters)
    }

    // MARK: - Crashlytics

    static func recordError(_ error: Error, context: String? = nil) {
        Logging.l(tag: tag, "Recording error: \(error.localizedDescription), context: \(context ?? "none")")
        var userInfo: [String: Any] = [:]
        if let context { userInfo["context"] = context }
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }

    // MARK: - Private

    private static func wireAnalyticsReporter() {
        Task { @MainActor in
            AnalyticsReporter.logEvent = { name, parameters in
                Analytics.logEvent(name, parameters: parameters)
            }
            AnalyticsReporter.recordError = { error, context in
                FirebaseService.recordError(error, context: context)
            }
        }
    }
}

// MARK: - Analytics Events

enum AnalyticsEvent {
    case appOpened
    case documentImported(pageCount: Int)
    case conversionStarted(bookletType: String)
    case conversionCompleted(bookletType: String, pageCount: Int)
    case conversionFailed(error: String)
    case exportCompleted
    case purchaseScreenViewed
    case purchaseCompleted(productID: String)
    case purchaseRestored
    case coverImageAdded
    case rateAppShown
    case settingsOpened

    var name: String {
        switch self {
        case .appOpened: AnalyticsEventName.appOpened
        case .documentImported: AnalyticsEventName.documentImported
        case .conversionStarted: AnalyticsEventName.conversionStarted
        case .conversionCompleted: AnalyticsEventName.conversionCompleted
        case .conversionFailed: AnalyticsEventName.conversionFailed
        case .exportCompleted: AnalyticsEventName.exportCompleted
        case .purchaseScreenViewed: AnalyticsEventName.purchaseScreenViewed
        case .purchaseCompleted: AnalyticsEventName.purchaseCompleted
        case .purchaseRestored: AnalyticsEventName.purchaseRestored
        case .coverImageAdded: AnalyticsEventName.coverImageAdded
        case .rateAppShown: AnalyticsEventName.rateAppShown
        case .settingsOpened: AnalyticsEventName.settingsOpened
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .documentImported(let pageCount):
            [AnalyticsParamKey.pageCount: pageCount]
        case .conversionStarted(let bookletType):
            [AnalyticsParamKey.bookletType: bookletType]
        case .conversionCompleted(let bookletType, let pageCount):
            [AnalyticsParamKey.bookletType: bookletType, AnalyticsParamKey.pageCount: pageCount]
        case .conversionFailed(let error):
            [AnalyticsParamKey.error: error]
        case .purchaseCompleted(let productID):
            [AnalyticsParamKey.productID: productID]
        default:
            nil
        }
    }
}
