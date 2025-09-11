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

final class DocumentConvertViewModel: ObservableObject {
    @Published var pdfUrl: URL?
    @Published var showFileImporter = false
    @Published var showFileExporter = false
    @Published var isConverting: Bool = false
    @Published var state: ContentViewState = .initial
    @Published var bookletType: BookletType = .type2  // Add this line
    
    @Published var document: PDFDocumentObject?
    @Published var originalDocument: PDFDocumentObject? // Store original for comparison
    
    var generator: (any BookletPDFGeneratorUseCase)?
    
    func setupGenerator() {
        switch bookletType {
        case .type2:
            self.generator = TwoInOnePdfGeneratorUseCaseImpl()
        case .type4:
            self.generator = FourInOneGeneratorUseCaseImpl()
        }
    }
    
    func setImportedDocument(_ url: URL) {
        DispatchQueue.global(qos: .background).async {
            guard let _url = try? DublicateFileUseCaseImpl().duplicateFile(at: url) else {
                return
            }
            
            DispatchQueue.main.async {
                self.pdfUrl = _url
                self.state = .selectedPdf
                let pdfDoc = PDFDocumentObject(
                    document: .init(url: _url)!,
                    name: _url.lastPathComponent,
                    url: _url
                )
                self.document = pdfDoc
                self.originalDocument = pdfDoc // Store original for comparison
            }
        }
    }
    
    func set(generator: any BookletPDFGeneratorUseCase) {
        self.generator = generator
    }
    
    private func setDocument(_ url: URL) {
        guard let doc = PDFDocument(url: url) else { return }
        
        self.document = .init(
            document: doc,
            name: url.lastPathComponent,
            url: url
        )
    }
    
    @MainActor
    func convertToBooklet() {
        guard let pdf = self.pdfUrl else {
            return
        }
        
        self.isConverting = true
        
        if state == .convertedPdf {
            state = .initial
            pdfUrl = nil
            return
        }
        
        // Make sure the appropriate generator is configured
        setupGenerator()
        
        generator?.makeBookletPDF(url: pdf) { newPdfUrl in
            Task { @MainActor in
                if let newPdfUrl {
                    self.setDocument(newPdfUrl)
                }
                
                self.pdfUrl = newPdfUrl
                self.state = newPdfUrl != nil ? .convertedPdf : self.state
                self.isConverting = false
            }
        }
    }
    
    func clearDocuments() {
        self.document = nil
        self.originalDocument = nil
        self.pdfUrl = nil
        self.state = .initial
    }
}
