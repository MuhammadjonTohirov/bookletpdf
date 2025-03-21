//
//  AppCache.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import Foundation

import Foundation

final class AppCache {
    static let shared = AppCache()
    private let version: String = "1"
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.bookletPdf.appCache", attributes: .concurrent)
    
    private lazy var appCacheUrl: URL? = {
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("❌ Error: Could not find cache directory")
            return nil
        }
        
        let cacheURL = cacheDir.appendingPathComponent("AppCache", isDirectory: true)
        
        // Ensure cache directory exists
        if !fileManager.fileExists(atPath: cacheURL.path) {
            do {
                try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true)
                print("✅ Created cache directory at: \(cacheURL.path)")
            } catch {
                print("❌ Error creating cache directory: \(error)")
            }
        }
        
        return cacheURL
    }()
    
    private lazy var versionUrl: URL? = {
        guard let cacheURL = appCacheUrl else { return nil }
        let versionedURL = cacheURL.appendingPathComponent(version, isDirectory: true)
        
        // Ensure versioned cache directory exists
        if !fileManager.fileExists(atPath: versionedURL.path) {
            do {
                try fileManager.createDirectory(at: versionedURL, withIntermediateDirectories: true)
                print("✅ Created versioned cache directory at: \(versionedURL.path)")
            } catch {
                print("❌ Error creating versioned cache directory: \(error)")
            }
        }
        
        return versionedURL
    }()
    
    func save(imageData: Data, key: String) {
        queue.async(flags: .barrier) { // Ensure thread safety
            guard let versionUrl = self.versionUrl else {
                print("❌ Error: versionUrl is nil")
                return
            }

            let url: URL
            if #available(macOS 15.0, iOS 17.0, *) {
                url = versionUrl.appendingPathComponent(key, conformingTo: .image)
            } else {
                url = versionUrl.appendingPathComponent(key) // Fallback for older macOS versions
            }

            do {
                try imageData.write(to: url)
                print("✅ Saved item to \(url.absoluteString)")
            } catch {
                print("❌ Error saving image data: \(error)")
            }
        }
    }
    
    func load(key: String) -> Data? {
        guard let versionUrl = self.versionUrl else {
            print("❌ Error: versionUrl is nil")
            return nil
        }

        let url: URL
        if #available(macOS 15.0, iOS 17.0, *) {
            url = versionUrl.appendingPathComponent(key, conformingTo: .image)
        } else {
            url = versionUrl.appendingPathComponent(key)
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            print("❌ Error loading image data: \(error)")
            return nil
        }
    }
    
    func hasItem(key: String) -> Bool {
        guard let versionUrl = self.versionUrl else {
            print("❌ Error: versionUrl is nil")
            return false
        }

        let url: URL
        if #available(macOS 15.0, iOS 17.0, *) {
            url = versionUrl.appendingPathComponent(key, conformingTo: .image)
        } else {
            url = versionUrl.appendingPathComponent(key)
        }

        let fileExists = fileManager.fileExists(atPath: url.path)
        print("🔍 Checking cache file: \(url.path) -> Exists: \(fileExists)")
        return fileExists
    }
}
