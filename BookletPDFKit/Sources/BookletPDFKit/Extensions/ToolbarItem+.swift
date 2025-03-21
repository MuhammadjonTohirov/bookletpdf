//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 23/02/25.
//

import Foundation
import SwiftUI

public extension ToolbarItemPlacement {
    static var automaticOrTopLeading: Self {
#if os(iOS)
        return .topBarLeading
#else
        return .automatic
#endif
    }
    
    static var buttomBarOrPrimary: Self {
#if os(iOS)
        return .bottomBar
#else
        return .primaryAction
#endif
    }
}
