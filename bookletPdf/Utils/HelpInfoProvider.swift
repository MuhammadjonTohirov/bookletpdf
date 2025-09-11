//
//  HelpInfoProvider.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 11/09/25.
//

import Foundation
import BookletCore

struct HelpInfoProvider {
    static var helpInfoUrl: URL? {
        switch UserSettings.language {
        case .uzbek:
            return Bundle.main.url(forResource: "Info_uz", withExtension: "html")
        case .france:
            return Bundle.main.url(forResource: "Info_fr", withExtension: "html")
        case .germany:
            return Bundle.main.url(forResource: "Info_de", withExtension: "html")
        default:
            return Bundle.main.url(forResource: "Info", withExtension: "html")
        }
    }
}
