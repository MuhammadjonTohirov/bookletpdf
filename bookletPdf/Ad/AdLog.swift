//
//  AdLog.swift
//  bookletPdf
//
//  Created by applebro on 06/05/26.
//

import Foundation

#if os(iOS)
import UIKit
import Network
import GoogleMobileAds
import FirebaseAnalytics
import AppV2

enum AdLog {
    static var sessionParameters: [String: Any] {
        [
            AnalyticsParamKey.adServingMode: servingMode,
            AnalyticsParamKey.buildConfiguration: buildConfiguration
        ]
    }

    static func log(_ message: @autoclosure () -> String) {
        #if DEBUG
        print("[Ads] \(message())")
        #endif
    }

    static func event(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    static func parameters(adUnitID: String? = nil, adFormat: String, retryAttempt: Int? = nil) -> [String: Any] {
        var parameters: [String: Any] = [
            AnalyticsParamKey.adFormat: adFormat,
            AnalyticsParamKey.adServingMode: servingMode,
            AnalyticsParamKey.buildConfiguration: buildConfiguration
        ]
        if let adUnitID {
            parameters[AnalyticsParamKey.adUnitID] = adUnitID
        }
        if let retryAttempt {
            parameters[AnalyticsParamKey.retryAttempt] = retryAttempt
        }
        return parameters
    }

    static func errorParameters(_ error: Error, adUnitID: String? = nil, adFormat: String, retryAttempt: Int? = nil) -> [String: Any] {
        let nsError = error as NSError
        var parameters = parameters(
            adUnitID: adUnitID,
            adFormat: adFormat,
            retryAttempt: retryAttempt
        )
        parameters.merge([
            AnalyticsParamKey.error: error.localizedDescription,
            AnalyticsParamKey.errorCode: nsError.code,
            AnalyticsParamKey.errorDomain: nsError.domain
        ]) { _, new in new }
        return parameters
    }

    private static var servingMode: String {
        #if DEBUG
        return "test"
        #else
        return "live"
        #endif
    }

    private static var buildConfiguration: String {
        #if DEBUG
        return "DEBUG"
        #else
        return "RELEASE"
        #endif
    }
}
#endif
