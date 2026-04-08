import Foundation
import BookletCore

protocol AppCacheProtocol: Sendable {
    func save(imageData: Data, key: String)
    func load(key: String) -> Data?
    func hasItem(key: String) -> Bool
    func clearCache() -> Bool
    func cacheFolderSize() -> String
    func moveFileToCache(from sourceURL: URL, fileName: String) -> URL?
}

final class AppCache: AppCacheProtocol, @unchecked Sendable {
    static let shared = AppCache()
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.bookletPdf.appCacheV2", attributes: .concurrent)

    private let appCacheUrl: URL?
    let versionUrl: URL?

    private init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let baseUrl = cacheDir?.appendingPathComponent("AppCacheV2", isDirectory: true)
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
        } catch {
            Logging.l(tag: "AppCache", "Error creating directory: \(error)")
        }
    }

    private func fileUrl(for key: String) -> URL? {
        versionUrl?.appendingPathComponent(key)
    }

    func save(imageData: Data, key: String) {
        queue.async(flags: .barrier) {
            guard let url = self.fileUrl(for: key) else { return }
            try? imageData.write(to: url)
        }
    }

    func load(key: String) -> Data? {
        queue.sync {
            guard let url = self.fileUrl(for: key) else { return nil }
            return try? Data(contentsOf: url)
        }
    }

    func hasItem(key: String) -> Bool {
        queue.sync {
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
                return false
            }
        }
    }

    func moveFileToCache(from sourceURL: URL, fileName: String) -> URL? {
        guard let versionUrl else { return nil }
        let destURL = versionUrl.appendingPathComponent(fileName)
        do {
            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.moveItem(at: sourceURL, to: destURL)
            return destURL
        } catch {
            Logging.l(tag: "AppCache", "Error moving file to cache: \(error)")
            return nil
        }
    }

    func cacheFolderSize() -> String {
        guard let versionUrl else { return "str.cache_not_available".localize }
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: versionUrl, includingPropertiesForKeys: [.fileSizeKey])
            let size = try contents.reduce(0) { result, url in
                let values = try url.resourceValues(forKeys: [.fileSizeKey])
                return result + (values.fileSize ?? 0)
            }
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: Int64(size))
        } catch {
            return "str.cache_size_error".localize
        }
    }
}
