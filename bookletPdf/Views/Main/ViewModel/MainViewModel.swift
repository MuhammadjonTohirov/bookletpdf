//
//  MainViewModel.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 23/02/25.
//

import Foundation
import Combine
import PDFKit
import BookletPDFKit

struct PDFDocumentObject {
    var document: PDFDocument
    var name: String
    var url: URL?
}

final class MainViewModel: ObservableObject {
    @Published var pdfUrl: URL?
    @Published var showFileImporter = false
    @Published var showFileExporter = false
    @Published var isConverting: Bool = false
    @Published var state: ContentViewState = .initial
    
    @Published var document: PDFDocumentObject?
    
    func setImportedDocument(_ url: URL) {
        DispatchQueue.global(qos: .background).async {
            guard let _url = try? DublicateFileUseCaseImpl().duplicateFile(at: url) else {
                 return
            }
            
            DispatchQueue.main.async {
                self.pdfUrl = _url
                self.state = .selectedPdf
            }
        }
    }
    
    private func setDocument(_ url: URL) {
        guard let doc = PDFDocument(url: url) else { return }
        
        self.document = .init(
            document: doc,
            name: url.lastPathComponent,
            url: url
        )
    }
}
