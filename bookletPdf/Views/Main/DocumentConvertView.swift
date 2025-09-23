//
//  MainView.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

// Modified version of MainView.swift with confirmation alert
import SwiftUI
import PDFKit
import BookletPDFKit

enum ContentViewState {
    case initial
    case selectedPdf
    case convertedPdf
}

struct DocumentConvertView: View {
    @EnvironmentObject var viewModel: DocumentConvertViewModel
    @State private var showConvertConfirmation = false
    @State private var tempBookletType: BookletType = .type2

    private var documentName: String {
        (viewModel.document?.name.nilIfEmpty ?? "").putIfEmpty(viewModel.document?.url?.lastPathComponent ?? "Unknown document")
    }
    
    private var documentInfo: String {
        [
            documentName,
            "\(document?.pageCount ?? 0) pages"
        ].joined(separator: ", ")
    }
    
    private var document: PDFDocument? {
        viewModel.document?.document
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Theme.Colors.background,
                        Theme.Colors.secondaryBackground.opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                innerBody
                    .navigationTitleInline()
            }
        }
        .fileImporter(
            isPresented: $viewModel.showFileImporter,
            allowedContentTypes: [.pdf],
            onCompletion: { result in
                if let url = try? result.get() {
                    viewModel.setImportedDocument(url)
                }
            }
        )
        .fileExporter(
            isPresented: $viewModel.showFileExporter,
            item: document,
            contentTypes: [.pdf],
            onCompletion: { newUrl in
            print("Exported at \(newUrl)")
        })
        .alert("Confirm Conversion", isPresented: $showConvertConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Convert to \(tempBookletType == .type2 ? "2-in-1" : "4-in-1")") {
                viewModel.bookletType = tempBookletType
                viewModel.convertToBooklet()
            }
        } message: {
            Text("Do you want to convert this PDF to \(tempBookletType == .type2 ? "2-in-1" : "4-in-1") booklet format?")
        }
    }
    
    private var innerBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let pdfUrl = viewModel.pdfUrl, !viewModel.isConverting {
                VStack(spacing: 0) {
                    // Enhanced document info header
                    HStack(spacing: Theme.Spacing.md) {
                        // Document icon
                        ZStack {
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .fill(Theme.Colors.primary.opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        
                        // Document info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(documentName)
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.primaryText)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            HStack(spacing: Theme.Spacing.sm) {
                                Text("\(document?.pageCount ?? 0) pages")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                
                                Text("•")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                
                                HStack(spacing: Theme.Spacing.xs) {
                                    Circle()
                                        .fill(Theme.Colors.success)
                                        .frame(width: 6, height: 6)
                                    Text("Ready to convert")
                                        .font(Theme.Typography.subheadline)
                                        .foregroundColor(Theme.Colors.success)
                                }
                            }
                        }
                        
                        Spacer(minLength: 0)
                        
                        // Quick action buttons
                        HStack(spacing: Theme.Spacing.xs) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.state = .initial
                                    viewModel.pdfUrl = nil
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                            .buttonStyle(.borderless)
                            .frame(width: 24, height: 24)
                            .background(Theme.Colors.tertiaryBackground, in: Circle())
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.md)
                    .background {
                        Rectangle()
                            .fill(.regularMaterial)
                            .overlay(
                                Rectangle()
                                    .fill(Theme.Colors.divider)
                                    .frame(height: 0.5),
                                alignment: .bottom
                            )
                    }
                    
                    pdfViewer(pdfUrl)
                }
            } else {
                if viewModel.isConverting {
                    LoadingView(title: "Converting ...", message: documentName)
                } else {
                    openFinderView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var openFinderView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Modern empty state illustration
            ZStack {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(.regularMaterial)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 48))
                            .foregroundColor(Theme.Colors.primary.opacity(0.8))
                    )
            }
            
            VStack(spacing: Theme.Spacing.sm) {
                Text("Select PDF File")
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Choose a PDF document to convert into a booklet format")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.lg)
            }
            
            Button(action: {
                openFinder()
            }) {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 16, weight: .medium))
                    Text("Browse Files")
                        .font(Theme.Typography.bodyMedium)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
            }
            .modernButtonStyle(style: .primary)
            .hoverEffect()
        }
        .padding(Theme.Spacing.xl)
        .smoothTransition()
    }
    
    @ViewBuilder
    private func pdfViewer(_ _url: URL) -> some View {
        if let doc = PDFDocument(url: _url) {
            PDFViewer(
                document: doc,
                onClickPage: { pageIndex in
                    
                }
            )
            .toolbar(content: {
                ToolbarItem(placement: .automaticOrTopLeading) {
                    openFolderToolbar
                }
            })
            .toolbar(content: {
                ToolbarItem(placement: .buttomBarOrPrimary) {
                    bottomActions
                }
                
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    topBarTrailingActions
                }
                #endif
            })
        }
    }
    
    private var openFolderToolbar: some View {
        Button(action: {
            openFinder()
        }, label: {
            Image(systemName: "folder")
                .font(.system(size: 14))
        })
        .buttonStyle(BorderedButtonStyle())
    }
    
    private var clearButton: some View {
        #if os(macOS)
        Text("Clear")
            .font(.system(size: 14))
        #else
        Image(systemName: "trash")
            .font(.system(size: 14))
        #endif
    }
    
    private var bottomActions: some View {
        HStack(spacing: Theme.Spacing.xs) {
            // Clear/Reset button
            if viewModel.state == .convertedPdf || viewModel.state == .selectedPdf {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.state = .initial
                        viewModel.pdfUrl = nil
                    }
                }) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                        #if os(macOS)
                        Text("Clear")
                            .font(Theme.Typography.callout)
                        #endif
                    }
                }
            }
            
            // Booklet type selector (macOS)
            #if os(macOS)
            if !viewModel.isConverting && viewModel.state != .convertedPdf {
                
                BookletTypeSelector(selectedType: $viewModel.bookletType)
            }
            #endif
            
            // Convert button
            if !viewModel.isConverting && viewModel.state != .convertedPdf {
                Button(action: {
                    tempBookletType = viewModel.bookletType
                    showConvertConfirmation = true
                }) {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 14, weight: .medium))
                        Text("Convert to Booklet")
                            .font(Theme.Typography.bodyMedium)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                }
            }
            
            // Action buttons group
            HStack(spacing: Theme.Spacing.sm) {
                // Print button
                if viewModel.state == .convertedPdf || viewModel.state == .selectedPdf {
                    printToolbarButton
                }
                
                // Export button
                Button(action: {
                    self.saveFile()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                }
                .modernButtonStyle(style: .secondary)
            }
        }
    }
    
    private var topBarTrailingActions: some View {
        #if os(iOS)
        HStack {
            BookletTypeSelector(selectedType: $viewModel.bookletType)
        }
        #else
        EmptyView()
        #endif
    }
    
    private func openFinder() {
        if ProcessInfo.isPreviewing {
            openDefaultDocument()
            return
        }
        viewModel.showFileImporter = true
    }
    
    private func saveFile() {
        viewModel.showFileExporter = true
    }
    
    private func openDefaultDocument() {
        self.viewModel.setImportedDocument(Bundle.main.url(forResource: "Resume", withExtension: "pdf")!)
        self.viewModel.state = .selectedPdf
    }
}

#Preview {
    DocumentConvertView()
        .environmentObject(DocumentConvertViewModel())
}
