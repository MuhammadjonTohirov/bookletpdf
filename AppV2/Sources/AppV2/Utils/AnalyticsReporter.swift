//
//  AnalyticsReporter.swift
//  bookletPdf
//

import Foundation

@MainActor
public enum AnalyticsReporter {
    public static var logEvent: ((_ name: String, _ parameters: [String: Any]?) -> Void)?
    public static var recordError: ((_ error: Error, _ context: String?) -> Void)?
}
