//
//  DuplicateFileUseCase.swift
//  BookletPDFKit
//
//  Created by Muhammadjon Tohirov on 23/02/25.
//

import Foundation

public protocol DuplicateFileUseCase {
    func duplicateFile(at url: URL) throws -> URL
}

public final class DuplicateFileUseCaseImpl: DuplicateFileUseCase {
    
    public init() {}
    
    /// Creates duplicate file from url and returns duplicate's url
    public func duplicateFile(at url: URL) throws -> URL {
        // Start accessing the security scoped resource.
        // If it fails, we check if we can read it anyway (e.g. it's not security scoped).
        // If it is security scoped and fails, we throw.
        let isSecurityScoped = url.startAccessingSecurityScopedResource()
        
        defer {
            if isSecurityScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
                
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let targetURL = tempDirectoryURL.appendingPathComponent("Temp_\(UUID().uuidString)_\(url.lastPathComponent)")
        
        if FileManager.default.fileExists(atPath: targetURL.path) {
            try FileManager.default.removeItem(at: targetURL)
        }
        
        try FileManager.default.copyItem(at: url, to: targetURL)
        return targetURL
    }
}