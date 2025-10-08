//
//  CodableWrapper.swift
//  YuzPay
//
//  Created by applebro on 11/12/22.
//

import Foundation

@propertyWrapper public struct codableWrapper<Value: Codable> {
    public let key: String
    public var storage: UserDefaults {
        UserDefaults(suiteName: "uz.sbd.bookletPdf") ?? .standard
    }
    
    public init(key: String, _ default: Value? = nil) {
        self.key = key
        if wrappedValue == nil {
            self.wrappedValue = `default`
        }
    }
    
    public var wrappedValue: Value? {
        get {
            guard let data = self.storage.value(forKey: key) as? Data else {
                return nil
            }
            
            return try? JSONDecoder().decode(Value.self, from: data)
        }
        
        set {
            guard let value = newValue else {
                storage.setValue(nil, forKey: key)
                return
            }
            
            guard let data = try? JSONEncoder().encode(value) else {
                return
            }
            
            storage.setValue(data, forKey: key)
        }
    }
}


