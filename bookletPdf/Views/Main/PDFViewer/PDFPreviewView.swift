//
//  PDFPreviewView.swift
//  bookletPdf
//
//  Enhanced PDF preview with full-screen and zoom capabilities
//

import SwiftUI
import PDFKit
import BookletCore

struct PDFPreviewView: View {
    let document: PDFDocument
    let title: String
    let isConverted: Bool
    @State private var selectedPageIndex: Int = 0
    @State private var showFullScreen = false
    @State private var previewMode: PreviewMode = .grid
    
    enum PreviewMode: CaseIterable {
        case grid
        case single
        case continuous
        
        var icon: String {
            switch self {
            case .grid: return "rectangle.grid.2x2"
            case .single: return "doc"
            case .continuous: return "doc.plaintext"
            }
        }
        
        var title: String {
            switch self {
            case .grid: return "str.grid_view".localize
            case .single: return "str.single_view".localize
            case .continuous: return "str.continuous_view".localize
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with document info and controls
            previewHeader
            
            Divider()
            
            // Main preview area
            previewContent
                .background(Color(NSColor.controlBackgroundColor))
        }
        .sheet(isPresented: $showFullScreen) {
            FullScreenPDFView(
                document: document,
                initialPage: selectedPageIndex,
                title: title
            )
        }
    }
    
    private var previewHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if isConverted {
                        Label("str.converted_booklet".localize, systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    Text("str.pages_count".localize.localize(arguments: document.pageCount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // View mode selector
            Picker("str.view_mode".localize, selection: $previewMode) {
                ForEach(PreviewMode.allCases, id: \.self) { mode in
                    Label(mode.title, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: 200)
            
            Button(action: { showFullScreen = true }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
            }
            .help("str.fullscreen".localize)
        }
        .padding()
    }
    
    @ViewBuilder
    private var previewContent: some View {
        switch previewMode {
        case .grid:
            gridPreview
        case .single:
            singlePagePreview
        case .continuous:
            continuousPreview
        }
    }
    
    private var gridPreview: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: adaptiveColumnCount),
                spacing: 12
            ) {
                ForEach(0..<document.pageCount, id: \.self) { pageIndex in
                    PDFPageThumbnail(
                        page: document.page(at: pageIndex)!,
                        pageNumber: pageIndex + 1,
                        isSelected: pageIndex == selectedPageIndex,
                        size: CGSize(width: 120, height: 160)
                    )
                    .onTapGesture {
                        selectedPageIndex = pageIndex
                        showFullScreen = true
                    }
                }
            }
            .padding()
        }
    }
    
    private var singlePagePreview: some View {
        VStack {
            if let currentPage = document.page(at: selectedPageIndex) {
                PDFPageView(
                    page: currentPage,
                    pageNumber: selectedPageIndex + 1,
                    key: "single_\(selectedPageIndex)",
                    size: CGSize(width: 300, height: 400)
                )
                .onTapGesture {
                    showFullScreen = true
                }
            }
            
            // Page navigation
            HStack {
                Button(action: previousPage) {
                    Image(systemName: "chevron.left")
                }
                .disabled(selectedPageIndex == 0)
                
                Text("\(selectedPageIndex + 1) / \(document.pageCount)")
                    .font(.caption)
                    .monospacedDigit()
                    .frame(minWidth: 60)
                
                Button(action: nextPage) {
                    Image(systemName: "chevron.right")
                }
                .disabled(selectedPageIndex >= document.pageCount - 1)
            }
            .padding()
        }
    }
    
    private var continuousPreview: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(0..<document.pageCount, id: \.self) { pageIndex in
                    VStack(spacing: 8) {
                        PDFPageView(
                            page: document.page(at: pageIndex)!,
                            pageNumber: pageIndex + 1,
                            key: "continuous_\(pageIndex)",
                            size: CGSize(width: 250, height: 320)
                        )
                        .onTapGesture {
                            selectedPageIndex = pageIndex
                            showFullScreen = true
                        }
                        
                        Text("str.page_number".localize.localize(arguments: pageIndex + 1))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
    }
    
    private var adaptiveColumnCount: Int {
        #if os(macOS)
        return 4
        #else
        return 2
        #endif
    }
    
    private func nextPage() {
        if selectedPageIndex < document.pageCount - 1 {
            selectedPageIndex += 1
        }
    }
    
    private func previousPage() {
        if selectedPageIndex > 0 {
            selectedPageIndex -= 1
        }
    }
}

struct PDFPageThumbnail: View {
    let page: PDFPage
    let pageNumber: Int
    let isSelected: Bool
    let size: CGSize
    
    var body: some View {
        VStack(spacing: 4) {
            PDFPageView(
                page: page,
                pageNumber: pageNumber,
                key: "thumb_\(pageNumber)",
                size: size
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            
            Text("str.page_number".localize.localize(arguments: pageNumber))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
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
            Color.black.ignoresSafeArea()
            
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
                VStack {
                    // Top bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5), in: Circle())
                        }
                        
                        Spacer()
                        
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
                        
                        Spacer()
                        
                        // Zoom controls
                        HStack(spacing: 8) {
                            Button(action: zoomOut) {
                                Image(systemName: "minus.magnifyingglass")
                                    .foregroundColor(.white)
                            }
                            .disabled(zoomScale <= 0.5)
                            
                            Button(action: resetZoom) {
                                Image(systemName: "1.magnifyingglass")
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: zoomIn) {
                                Image(systemName: "plus.magnifyingglass")
                                    .foregroundColor(.white)
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
                                .font(.title2)
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
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5), in: Circle())
                        }
                        .disabled(currentPage >= document.pageCount - 1)
                    }
                    .padding()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Auto-hide controls after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showControls = false
                }
            }
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
    
    var body: some View {
        GeometryReader { geometry in
            if let pageImage = page.thumbnail(of: CGSize(width: 400 * zoomScale, height: 600 * zoomScale), for: .mediaBox) {
                Image(nsImage: pageImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
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
}

#Preview {
    PDFPreviewView(
        document: PDFDocument(url: Bundle.main.url(forResource: "Resume", withExtension: "pdf")!)!,
        title: "Sample Document.pdf",
        isConverted: false
    )
}