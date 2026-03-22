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

public struct PDFDocumentObject {
    public var document: PDFDocument
    public var name: String
    public var url: URL?
}

@MainActor
public final class DocumentConvertViewModel: ObservableObject {
    @Published public var pdfUrl: URL?
    @Published public var showFileImporter = false
    @Published public var showFileExporter = false
    @Published public var isConverting: Bool = false
    @Published public var state: ContentViewState = .initial
    @Published public var bookletType: BookletType = .type2
    @Published public var errorMessage: String?
    @Published public var showError: Bool = false

    @Published public var document: PDFDocumentObject?
    @Published public var originalDocument: PDFDocumentObject? // Store original for comparison

    private let generatorFactory: BookletGeneratorFactory
    private let duplicateFileUseCase: DuplicateFileUseCase

    public init(
        generatorFactory: BookletGeneratorFactory = BookletGeneratorFactoryImpl(),
        duplicateFileUseCase: DuplicateFileUseCase = DuplicateFileUseCaseImpl()
    ) {
        self.generatorFactory = generatorFactory
        self.duplicateFileUseCase = duplicateFileUseCase
    }
    
    func setImportedDocument(_ url: URL) {
        Task { @MainActor in
            do {
                let duplicateURL = try duplicateFileUseCase.duplicateFile(at: url)
                
                guard let doc = PDFDocument(url: duplicateURL) else {
                    throw BookletError.invalidDocument
                }
                
                self.pdfUrl = duplicateURL
                self.state = .selectedPdf
                
                let pdfDoc = PDFDocumentObject(
                    document: doc,
                    name: duplicateURL.lastPathComponent,
                    url: duplicateURL
                )
                self.document = pdfDoc
                self.originalDocument = pdfDoc
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
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
        
        let generator = generatorFactory.makeGenerator(for: bookletType)
        
        Task {
            do {
                let newPdfUrl = try await generator.makeBookletPDF(url: pdf)
                
                // Back to Main Actor for UI updates
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.setDocument(newPdfUrl)
                    self.pdfUrl = newPdfUrl
                    self.state = .convertedPdf
                    self.isConverting = false
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isConverting = false
                }
            }
        }
    }
    
    func clearDocuments() {
        self.document = nil
        self.originalDocument = nil
        self.pdfUrl = nil
        self.state = .initial
        self.errorMessage = nil
        self.showError = false
    }
}
