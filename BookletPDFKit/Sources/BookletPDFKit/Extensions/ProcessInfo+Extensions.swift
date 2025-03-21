//
//  ProcessInfo+Extensions.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation

public extension ProcessInfo {
    static var isPreviewing: Bool {
        let previews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] ?? "0"
        
        return (Int(previews) ?? 0) >= 1
    }
}
