//
//  Langugage.swift
//  YuzPay
//
//  Created by applebro on 11/12/22.
//

import Foundation

public enum Language: Int, Codable {
    case english = 0
    case france
    case germany
    case uzbek
    
    public static func language(_ code: String) -> Language {
        switch code {
        case "uz", "uz-UZ", "UZ":
            return .uzbek
        case "en":
            return .english
        case "de":
            return .germany
        case "fr":
            return .france
        default:
            return .english
        }
    }
    
    public var name: String {
        switch self {
        case .uzbek:
            return "O'zbekcha"
        case .english:
            return "English"
        case .germany:
            return "Deutsch"
        case .france:
            return "Français"
        }
    }

    public var code: String {
        switch self {
        case .uzbek:
            return "uz-UZ"

        case .germany:
            return "de"

        case .english:
            return "en"
        
        case .france:
            return "fr"
        }
    }
}
