//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

public extension View {
    func fIgnoreSafeArea() -> some View {
        #if os(macOS)
        self
        #elseif os(iOS)
        self.ignoresSafeArea()
        #endif
    }
    
    func navigationTitleInline() -> some View {
        #if os(iOS)
        return self.navigationBarTitleDisplayMode(.inline)
        #endif
        
        return self
    }
}
