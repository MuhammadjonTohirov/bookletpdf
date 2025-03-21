//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

public extension Image {
    init(fImage: FImage) {
        #if os(macOS)
        self.init(nsImage: fImage.image ?? NSImage.init())
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        self.init(uiImage: fImage.image ?? UIImage())
        #endif
    }
}
