//
//  AppCache.swift
//  bookletPdf
//

import Foundation
import BookletCore

protocol AppCacheProtocol: Sendable {
    func save(imageData: Data, key: String)
    func load(key: String) -> Data?
    func hasItem(key: String) -> Bool
    func clearCache() -> Bool
    func cacheFolderSize() -> String
    var versionUrl: URL? { get }
}

final class AppCache: AppCacheProtocol, @unchecked Sendable {
    static let shared = AppCache()
    private let version: String = "1"
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.bookletPdf.appCache", attributes: .concurrent)

    private let appCacheUrl: URL?
    let versionUrl: URL?

    private init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let baseUrl = cacheDir?.appendingPathComponent("AppCache", isDirectory: true)
        let versionedUrl = baseUrl?.appendingPathComponent("1", isDirectory: true)

        if let baseUrl {
            Self.ensureDirectoryExists(at: baseUrl)
        }
        if let versionedUrl {
            Self.ensureDirectoryExists(at: versionedUrl)
        }

        self.appCacheUrl = baseUrl
        self.versionUrl = versionedUrl
    }

    private static func ensureDirectoryExists(at url: URL) {
        guard !FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            Logging.l(tag: "AppCache", "Created directory at: \(url.path)")
        } catch {
            Logging.l(tag: "AppCache", "Error creating directory: \(error)")
        }
    }

    private func fileUrl(for key: String) -> URL? {
        guard let versionUrl else {
            Logging.l(tag: "AppCache", "versionUrl is nil")
            return nil
        }

        if #available(macOS 15.0, iOS 17.0, *) {
            return versionUrl.appendingPathComponent(key, conformingTo: .image)
        } else {
            return versionUrl.appendingPathComponent(key)
        }
    }

    func save(imageData: Data, key: String) {
        queue.async(flags: .barrier) {
            guard let url = self.fileUrl(for: key) else { return }

            do {
                try imageData.write(to: url)
                Logging.l(tag: "AppCache", "Saved item to \(url.absoluteString)")
            } catch {
                Logging.l(tag: "AppCache", "Error saving image data: \(error)")
            }
        }
    }

    func load(key: String) -> Data? {
        return queue.sync {
            guard let url = self.fileUrl(for: key) else { return nil }

            do {
                return try Data(contentsOf: url)
            } catch {
                Logging.l(tag: "AppCache", "Error loading image data: \(error)")
                return nil
            }
        }
    }

    func hasItem(key: String) -> Bool {
        return queue.sync {
            guard let url = self.fileUrl(for: key) else { return false }
            return fileManager.fileExists(atPath: url.path)
        }
    }

    func clearCache() -> Bool {
        guard let versionUrl else { return false }

        return queue.sync(flags: .barrier) {
            do {
                let contents = try fileManager.contentsOfDirectory(at: versionUrl, includingPropertiesForKeys: nil)
                for fileURL in contents {
                    try fileManager.removeItem(at: fileURL)
                }
                return true
            } catch {
                Logging.l(tag: "AppCache", "Error clearing cache: \(error)")
                return false
            }
        }
    }

    func cacheFolderSize() -> String {
        guard let versionUrl else { return String(localized: "str.cache_not_available") }

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: versionUrl, includingPropertiesForKeys: [.fileSizeKey])
            let size = try contents.reduce(0) { (result, url) -> Int in
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                return result + (resourceValues.fileSize ?? 0)
            }
            return Self.formatFileSize(size)
        } catch {
            return String(localized: "str.cache_size_error")
        }
    }

    private static func formatFileSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}
