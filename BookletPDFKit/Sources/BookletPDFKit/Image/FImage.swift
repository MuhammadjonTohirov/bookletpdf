//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation

public struct FImage {
    private var _imageData: Data?
    
    public init?(data: Data? = nil) {
        guard let data = data else { return nil }
        self._imageData = data
    }
}

public protocol FImageProtocol {
    
}

#if canImport(UIKit)
import UIKit
public extension FImage {
    var image: UIImage? {
        guard let imageData = self._imageData else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
}
#endif

#if canImport(AppKit)
import AppKit
public extension FImage {
    var image: NSImage? {
        guard let imageData = self._imageData else {
            return nil
        }
        
        return NSImage(data: imageData)
    }
}

public extension NSImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
        return jpegData
    }
}

#endif
