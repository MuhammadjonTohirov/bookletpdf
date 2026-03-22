//
//  PDFPageThumbnailViewModel.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import Foundation
import SwiftUI
import PDFKit
import BookletPDFKit
import BookletCore

@MainActor
class PDFThumbnailViewModel: ObservableObject {
    private static let thumbnailCompressionQuality: CGFloat = 0.1

    var page: PDFPage
    var key: String
    var size: CGSize = .init(width: 100, height: 200)
    var isLoaded: Bool = false
    @Published var image: FImage?
    var isAppeard: Bool = false
    private let cache: AppCacheProtocol

    init(page: PDFPage, key: String, size: CGSize, cache: AppCacheProtocol = AppCache.shared) {
        self.page = page
        self.key = key
        self.size = size
        self.cache = cache
    }

    lazy var imageLoaderItem: DispatchWorkItem = {
        let item = DispatchWorkItem(qos: .utility, flags: .barrier) {
            if self.cache.hasItem(key: self.key) {
                self.loadImageFromCache()
                return
            }

            self.loadImageFromPageAndStore()
        }

        return item
    }()

    private func loadImageFromCache() {
        guard isAppeard else { return }

        if let d = cache.load(key: self.key) {
            DispatchQueue.main.async {
                self.isLoaded = true
                withAnimation {
                    self.image = FImage(data: d)
                }
            }
        }
    }

    private func loadImageFromPageAndStore() {
        guard isAppeard else { return }

        if let imageData = self.page.thumbnail(of: self.size, for: .trimBox).jpegData(compressionQuality: Self.thumbnailCompressionQuality) {
            cache.save(imageData: imageData, key: self.key)
            DispatchQueue.main.async {
                self.isLoaded = true
                withAnimation {
                    self.image = FImage(data: imageData)
                }
            }
        }
    }

    func onAppear() {
        isAppeard = true
        Logging.l(tag: "PDFThumbnailVM", "On appear \(key)")
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: DispatchTime.now() + 0.5, execute: self.imageLoaderItem)
    }

    func onDisappear() {
        isAppeard = false
    }
}

