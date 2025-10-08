//
//  PDFPreviewView.swift
//  bookletPdf
//
//  Enhanced PDF preview with full-screen and zoom capabilities
//

import SwiftUI
import PDFKit
import BookletCore
import BookletPDFKit

struct PDFPreviewView: View {
    let document: PDFDocument
    let title: String
    let isConverted: Bool
    @StateObject private var viewModel: PDFPreviewViewModel
    
    init(document: PDFDocument, title: String, isConverted: Bool) {
        self.document = document
        self.title = title
        self.isConverted = isConverted
        self._viewModel = StateObject(wrappedValue: PDFPreviewViewModel(document: document, title: title))
    }
    
    var body: some View {
        gridPreview
            .background(Theme.Colors.background)
            #if os(iOS)
            .sheet(isPresented: $viewModel.showFullScreen) {
                NavigationStack {
                    FullScreenPDFView(
                        document: document,
                        initialPage: viewModel.selectedPageIndex,
                        title: title
                    )
                }
            }
            #endif
    }
    
    
    private var gridPreview: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: viewModel.adaptiveColumnCount),
                spacing: 12
            ) {
                ForEach(0..<document.pageCount, id: \.self) { pageIndex in
                    PDFPageThumbnailView(
                        page: document.page(at: pageIndex)!,
                        pageNumber: pageIndex + 1,
                        isSelected: pageIndex == viewModel.selectedPageIndex,
                        size: CGSize(width: 120, height: 160),
                        key: (document.documentURL?.absoluteString ?? "") + "_\(pageIndex)"
                    )
                    .onTapGesture {
                        viewModel.selectPage(pageIndex)
                    }
                    .frame(width: 120)
                    .frame(minHeight: 160)
                }
            }
            .padding()
        }
    }
}

struct PDFPageThumbnailView: View {
    let page: PDFPage
    let pageNumber: Int
    let isSelected: Bool
    let size: CGSize
    var key: String? = nil
    
    var body: some View {
        PDFPageView(
            page: page,
            pageNumber: pageNumber,
            key: key ?? "thumb_\(pageNumber)",
            size: size
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

struct FullScreenPDFView: View {
    let document: PDFDocument
    @State var currentPage: Int
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var zoomScale: CGFloat = 1.0
    @State private var showControls = true
    
    init(document: PDFDocument, initialPage: Int, title: String) {
        self.document = document
        self._currentPage = State(initialValue: initialPage)
        self.title = title
    }
    
    var body: some View {
        ZStack {
            // PDF Content
            if let page = document.page(at: currentPage) {
                PDFPageScrollView(page: page, zoomScale: $zoomScale)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showControls.toggle()
                        }
                    }
            }
            
            // Controls overlay
            if showControls {
                controlsView
                .transition(.opacity)
            }
        }
        #if os(iOS)
        .navigationTitle(title)
        .navigationTitleInline()
        #endif
        .onAppear {
            // Auto-hide controls after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showControls = false
                }
            }
        }
    }
    
    private var controlsView: some View {
        VStack {
            // Top bar
            HStack {
                #if os(iOS)
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5), in: Circle())
                }
                #endif
                
                Spacer()
                
                // Zoom controls
                HStack(spacing: 8) {
                    Button(action: zoomOut) {
                        Image(systemName: "minus.magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .disabled(zoomScale <= 0.5)
                    
                    Button(action: resetZoom) {
                        Image(systemName: "1.magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    
                    Button(action: zoomIn) {
                        Image(systemName: "plus.magnifyingglass")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .disabled(zoomScale >= 3.0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding()
            
            Spacer()
            
            // Bottom navigation
            HStack {
                Button(action: previousPage) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5), in: Circle())
                }
                .disabled(currentPage == 0)
                
                Spacer()
                
                Text("\(currentPage + 1) / \(document.pageCount)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                Button(action: nextPage) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5), in: Circle())
                }
                .disabled(currentPage >= document.pageCount - 1)
            }
            .padding()
        }
    }
    
    private func nextPage() {
        if currentPage < document.pageCount - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentPage += 1
                zoomScale = 1.0
            }
        }
    }
    
    private func previousPage() {
        if currentPage > 0 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentPage -= 1
                zoomScale = 1.0
            }
        }
    }
    
    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomScale = min(zoomScale * 1.5, 3.0)
        }
    }
    
    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomScale = max(zoomScale / 1.5, 0.5)
        }
    }
    
    private func resetZoom() {
        withAnimation(.easeInOut(duration: 0.2)) {
            zoomScale = 1.0
        }
    }
}

struct PDFPageScrollView: View {
    let page: PDFPage
    @Binding var zoomScale: CGFloat
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @ViewBuilder
    private func image(_ img: FImage?) -> some View {
        if let _img = img?.image {
            #if os(macOS)
            Image(nsImage: _img)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #else
            Image(uiImage: _img)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #endif
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let pageImage = page.thumbnail(of: CGSize(width: 400 * zoomScale, height: 600 * zoomScale), for: .mediaBox)
            image(.init(data: pageImage.jpegData(compressionQuality: 1)))
                .scaleEffect(zoomScale)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                            
                            // Limit offset to keep image within bounds
                            let maxOffsetX = max(0, (geometry.size.width * zoomScale - geometry.size.width) / 2)
                            let maxOffsetY = max(0, (geometry.size.height * zoomScale - geometry.size.height) / 2)
                            
                            offset = CGSize(
                                width: min(maxOffsetX, max(-maxOffsetX, newOffset.width)),
                                height: min(maxOffsetY, max(-maxOffsetY, newOffset.height))
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onChange(of: zoomScale) { _, _ in
                    // Reset offset when zoom changes
                    offset = .zero
                    lastOffset = .zero
                }
            
        }
    }
}

#Preview {
    PDFPreviewView(
        document: PDFDocument(url: Bundle.main.url(forResource: "Resume", withExtension: "pdf")!)!,
        title: "Sample Document.pdf",
        isConverted: false
    )
}
