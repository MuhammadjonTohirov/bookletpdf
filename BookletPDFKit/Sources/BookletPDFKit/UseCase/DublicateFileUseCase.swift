//
//  File.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 23/02/25.
//

import Foundation

public protocol DublicateFileUseCase {
    func duplicateFile(at url: URL) throws -> URL
}

public final class DublicateFileUseCaseImpl: DublicateFileUseCase {
    
    public init() {}
    
    /// Creates dublicate file from url and returns dublicat's url
    public func duplicateFile(at url: URL) throws -> URL {
       guard url.startAccessingSecurityScopedResource() else {
            fatalError("No access to \(url)")
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }
                
        let tempDirectoryURL: URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        let targetURL = tempDirectoryURL.appendingPathComponent("Temp_\(url.lastPathComponent)")
        
        do {
            if FileManager.default.fileExists(atPath: targetURL.path()) {
                try? FileManager.default.removeItem(at: targetURL)
            }
            
            try FileManager.default.copyItem(at: url, to: targetURL)
            return targetURL
        } catch {
            print("Error \(error.localizedDescription)")
            return targetURL
        }
    }
}
