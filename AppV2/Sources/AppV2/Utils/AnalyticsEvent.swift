//
//  AnalyticsEvent.swift
//  bookletPdf
//

import Foundation

public enum AnalyticsEventName {
    public static let appOpened = "app_opened"
    public static let documentImported = "document_imported"
    public static let conversionStarted = "conversion_started"
    public static let conversionCompleted = "conversion_completed"
    public static let conversionFailed = "conversion_failed"
    public static let exportCompleted = "export_completed"
    public static let purchaseScreenViewed = "purchase_screen_viewed"
    public static let purchaseCompleted = "purchase_completed"
    public static let purchaseRestored = "purchase_restored"
    public static let coverImageAdded = "cover_image_added"
    public static let rateAppShown = "rate_app_shown"
    public static let settingsOpened = "settings_opened"
    public static let adSdkConfigured = "ad_sdk_configured"
    public static let adBannerLoadRequested = "ad_banner_load_requested"
    public static let adBannerLoaded = "ad_banner_loaded"
    public static let adBannerLoadFailed = "ad_banner_load_failed"
    public static let adInterstitialLoadRequested = "ad_interstitial_load_requested"
    public static let adInterstitialLoaded = "ad_interstitial_loaded"
    public static let adInterstitialLoadFailed = "ad_interstitial_load_failed"
    public static let adInterstitialUnavailable = "ad_interstitial_unavailable"
    public static let adInterstitialPresented = "ad_interstitial_presented"
    public static let adInterstitialDismissed = "ad_interstitial_dismissed"
    public static let adInterstitialPresentationFailed = "ad_interstitial_presentation_failed"
}

public enum AnalyticsParamKey {
    public static let pageCount = "page_count"
    public static let bookletType = "booklet_type"
    public static let error = "error"
    public static let productID = "product_id"
    public static let adUnitID = "ad_unit_id"
    public static let adFormat = "ad_format"
    public static let adServingMode = "ad_serving_mode"
    public static let buildConfiguration = "build_configuration"
    public static let retryAttempt = "retry_attempt"
    public static let errorCode = "error_code"
    public static let errorDomain = "error_domain"
}
