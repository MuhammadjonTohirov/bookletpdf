//
//  File.swift
//  BookletPDFKit
//
//  Created by applebro on 11/05/25.
//

import Foundation

public extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
    
    func putIfEmpty(_ string: String) -> String {
        isEmpty ? string : self
    }
}
