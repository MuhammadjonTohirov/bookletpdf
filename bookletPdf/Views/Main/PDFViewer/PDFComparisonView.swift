//
//  PDFComparisonView.swift
//  bookletPdf
//
//  Side-by-side comparison view for original vs converted PDFs
//

import SwiftUI
import PDFKit
import BookletPDFKit
import BookletCore

struct PDFComparisonView: View {
    let originalDocument: PDFDocument
    let convertedDocument: PDFDocument
    let originalTitle: String
    let convertedTitle: String
    @StateObject private var viewModel: PDFComparisonViewModel
    
    init(originalDocument: PDFDocument, convertedDocument: PDFDocument, originalTitle: String, convertedTitle: String) {
        self.originalDocument = originalDocument
        self.convertedDocument = convertedDocument
        self.originalTitle = originalTitle
        self.convertedTitle = convertedTitle
        self._viewModel = StateObject(wrappedValue: PDFComparisonViewModel(
            originalDocument: originalDocument,
            convertedDocument: convertedDocument,
            originalTitle: originalTitle,
            convertedTitle: convertedTitle
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("str.comparison_view".localize)
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button("str.fullscreen".localize) {
                    viewModel.openConvertedFullScreen()
                }
                .padding()
            }
            .background(Theme.Colors.background)
            
            Divider()
            
            // Side-by-side comparison
            HStack(spacing: 1) {
                // Original PDF
                VStack(spacing: 0) {
                    comparisonHeader(
                        title: "str.original_document".localize,
                        subtitle: originalTitle,
                        pageCount: originalDocument.pageCount
                    )
                    
                    Divider()
                    
                    compactPreview(
                        document: originalDocument,
                        title: originalTitle,
                        isOriginal: true
                    )
                }
                .frame(maxWidth: .infinity)
                .background(Theme.Colors.background)
                
                // Divider
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 1)
                
                // Converted PDF
                VStack(spacing: 0) {
                    comparisonHeader(
                        title: "str.converted_booklet".localize,
                        subtitle: convertedTitle,
                        pageCount: convertedDocument.pageCount
                    )
                    
                    Divider()
                    
                    compactPreview(
                        document: convertedDocument,
                        title: convertedTitle,
                        isOriginal: false
                    )
                }
                .frame(maxWidth: .infinity)
                .background(Theme.Colors.background)
            }
        }
        #if os(iOS)
        .sheet(isPresented: $viewModel.showFullScreen) {
            if let document = viewModel.selectedDocument {
                FullScreenPDFView(
                    document: document,
                    initialPage: 0,
                    title: viewModel.selectedTitle
                )
            }
        }
        #endif
    }
    
    private func comparisonHeader(title: String, subtitle: String, pageCount: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text("str.pages_count".localize.localize(arguments: pageCount))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
    
    private func compactPreview(document: PDFDocument, title: String, isOriginal: Bool) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8
            ) {
                ForEach(0..<min(6, document.pageCount), id: \.self) { pageIndex in
                    if let page = document.page(at: pageIndex) {
                        PDFPageView(
                            page: page,
                            pageNumber: pageIndex + 1,
                            key: "\(isOriginal ? "orig" : "conv")_\(pageIndex)_\(title)",
                            size: CGSize(width: 80, height: 100)
                        )
                        .onTapGesture {
                            viewModel.openFullScreen(document: document, title: title)
                        }
                    }
                }
                
                // Show "more pages" indicator if there are more than 6 pages
                if document.pageCount > 6 {
                    VStack {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("+\(document.pageCount - 6)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 80, height: 100)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .onTapGesture {
                        viewModel.openFullScreen(document: document, title: title)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    if let sampleDoc = PDFDocument(url: Bundle.main.url(forResource: "Resume", withExtension: "pdf")!) {
        PDFComparisonView(
            originalDocument: sampleDoc,
            convertedDocument: sampleDoc,
            originalTitle: "Original Document.pdf",
            convertedTitle: "Converted Booklet.pdf"
        )
    } else {
        Text("Preview not available")
    }
}
