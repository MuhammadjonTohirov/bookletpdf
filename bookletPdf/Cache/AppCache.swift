//
//  AppCache.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import Foundation

final class AppCache {
    static let shared = AppCache()
    private let version: String = "1"
    private let appCacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    private lazy var versionUrl: URL? = {
        return appCacheUrl?.appending(path: version)
    }()
    
    func save(imageData: Data, key: String) {
        guard let versionUrl else {
            return
        }
        
        let url = versionUrl.appendingPathComponent(key, conformingTo: .image)
        
        do {
            try imageData.write(to: url)
            debugPrint("Save item to \(url.absoluteString)")
        } catch {
            debugPrint("error saving image data: \(error)")
        }
    }
    
    func load(key: String) -> Data? {
        guard let versionUrl else {
            return nil
        }
        
        let url = versionUrl.appendingPathComponent(key, conformingTo: .image)
        
        do {
            return try Data(contentsOf: url)
        } catch {
            print("error loading image data: \(error)")
            return nil
        }
    }
    
    func hasItem(key: String) -> Bool {
        guard let versionUrl else {
            return false
        }
        
        let url = versionUrl.appendingPathComponent(key, conformingTo: .image)
        
        return FileManager.default.fileExists(atPath: url.path)
    }
}
