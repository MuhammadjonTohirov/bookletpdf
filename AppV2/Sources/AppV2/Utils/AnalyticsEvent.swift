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
}

public enum AnalyticsParamKey {
    public static let pageCount = "page_count"
    public static let bookletType = "booklet_type"
    public static let error = "error"
    public static let productID = "product_id"
}
