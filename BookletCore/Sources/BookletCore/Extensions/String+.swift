//
//  File.swift
//  Core
//
//  Created by Muhammadjon Tohirov on 11/09/25.
//

import Foundation

public extension String {
    var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
    
    
    // as json object
    func asObject<T: Decodable>() -> T? {
        guard let data = self.asData else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // convert json string to json object
    var asJson: Any? {
        guard let data = self.asData else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    // convert json string to dict
    var asDict: [String: Any]? {
        guard let data = self.asData else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
    
    func localize(language: Language, bundle: Bundle = .main) -> String {
        let path = bundle.path(forResource: language.code, ofType: "lproj")
        guard path != nil else {
            return self
        }
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: self, comment: self)
    }
    
    var localize: String {
        return localize(language: UserSettings.language ?? .english)
    }
    
    func placeholder(_ text: String) -> String {
        return self.nilIfEmpty == nil ? text : self
    }

    func localize(arguments: CVarArg...) -> String {
        String.init(format: self.localize, arguments: arguments)
    }
}

public extension Encodable {
    /// Turns json into a Dictionary
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
    
    /// Turn json into a string
    var asString: String {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return ""
        }
        
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
    
    var asData: Data? {
        try? JSONEncoder().encode(self)
    }
}

public extension Substring {
    var asString: String {
        String(self)
    }
    
    var asData: Data? {
        self.asString.data(using: .utf8)
    }
}
