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

class PDFThumbnailViewModel: ObservableObject {
    var page: PDFPage
    var key: String
    var size: CGSize = .init(width: 100, height: 200)
    var isLoaded: Bool = false
    @Published var image: FImage?
    var isAppeard: Bool = false
    init(page: PDFPage, key: String, size: CGSize) {
        self.page = page
        self.key = key
        self.size = size
    }
    
    lazy var imageLoaderItem: DispatchWorkItem = {
        let item = DispatchWorkItem(qos: .utility, flags: .barrier) {
            if AppCache.shared.hasItem(key: self.key) {
                self.loadImageFromCache()
                return
            }
            
            self.loadImageFromPageAndStore()
        }
        
        return item
    }()
    
    private func loadImageFromCache() {
        guard isAppeard else {
            return
        }
        
        if let d = AppCache.shared.load(key: self.key) {
            DispatchQueue.main.async {
                self.isLoaded = true
                withAnimation {
                    self.image = FImage(data: d)
                }
            }
        }
    }
    
    private func loadImageFromPageAndStore() {
        guard isAppeard else {
            return
        }
        
        if let imageData = self.page.thumbnail(of: self.size, for: .trimBox).jpegData(compressionQuality: 0.1) {
            AppCache.shared.save(imageData: imageData, key: self.key)
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
        debugPrint("On appear \(key)")
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: DispatchTime.now() + 0.5, execute: self.imageLoaderItem)
    }
    
    func onDisappear() {
        isAppeard = false
    }
}

