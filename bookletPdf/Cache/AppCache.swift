//
//  AppCache.swift
//  bookletPdf
//

import Foundation

final class AppCache {
    static let shared = AppCache()
    private let version: String = "1"
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.bookletPdf.appCache", attributes: .concurrent)
    
    // Use a lazily initialized constant for the cache directory to ensure it's only created once
    private let appCacheUrl: URL? = {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("❌ Error: Could not find cache directory")
            return nil
        }
        
        let cacheURL = cacheDir.appendingPathComponent("AppCache", isDirectory: true)
        
        // Ensure cache directory exists
        if !FileManager.default.fileExists(atPath: cacheURL.path) {
            do {
                try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)
                print("✅ Created cache directory at: \(cacheURL.path)")
            } catch {
                print("❌ Error creating cache directory: \(error)")
            }
        }
        
        return cacheURL
    }()
    
    // Create the version URL only once, not every time it's accessed
    // Make this public to allow cache clearing from settings
    let versionUrl: URL? = {
        guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let cacheURL = cacheDir.appendingPathComponent("AppCache", isDirectory: true)
        let versionedURL = cacheURL.appendingPathComponent("1", isDirectory: true)
        
        // Ensure versioned cache directory exists
        if !FileManager.default.fileExists(atPath: versionedURL.path) {
            do {
                try FileManager.default.createDirectory(at: versionedURL, withIntermediateDirectories: true)
                print("✅ Created versioned cache directory at: \(versionedURL.path)")
            } catch {
                print("❌ Error creating versioned cache directory: \(error)")
            }
        }
        
        return versionedURL
    }()
    
    // Helper method to safely get the file URL for a key
    private func fileUrl(for key: String) -> URL? {
        guard let versionUrl = self.versionUrl else {
            print("❌ Error: versionUrl is nil")
            return nil
        }
        
        if #available(macOS 15.0, iOS 17.0, *) {
            return versionUrl.appendingPathComponent(key, conformingTo: .image)
        } else {
            return versionUrl.appendingPathComponent(key)
        }
    }
    
    func save(imageData: Data, key: String) {
        queue.async(flags: .barrier) { // Ensure thread safety
            guard let url = self.fileUrl(for: key) else { return }
            
            do {
                try imageData.write(to: url)
                print("✅ Saved item to \(url.absoluteString)")
            } catch {
                print("❌ Error saving image data: \(error)")
            }
        }
    }
    
    func load(key: String) -> Data? {
        // Using sync because we need to return the result
        return queue.sync {
            guard let url = self.fileUrl(for: key) else { return nil }
            
            do {
                return try Data(contentsOf: url)
            } catch {
                print("❌ Error loading image data: \(error)")
                return nil
            }
        }
    }
    
    func hasItem(key: String) -> Bool {
        // Using sync because we need to return the result
        return queue.sync {
            guard let url = self.fileUrl(for: key) else { return false }
            
            let fileExists = fileManager.fileExists(atPath: url.path)
            print("🔍 Checking cache file: \(url.path) -> Exists: \(fileExists)")
            return fileExists
        }
    }
    
    // Added method for clearing cache from settings
    func clearCache() -> Bool {
        guard let versionUrl = self.versionUrl else { return false }
        
        return queue.sync(flags: .barrier) {
            do {
                let contents = try fileManager.contentsOfDirectory(at: versionUrl, includingPropertiesForKeys: nil)
                for fileURL in contents {
                    try fileManager.removeItem(at: fileURL)
                }
                return true
            } catch {
                print("❌ Error clearing cache: \(error)")
                return false
            }
        }
    }
}
