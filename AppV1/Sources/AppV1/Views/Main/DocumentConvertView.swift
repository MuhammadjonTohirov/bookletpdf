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
import BookletCore

public enum ContentViewState {
    case initial
    case selectedPdf
    case convertedPdf
}

struct DocumentConvertView: View {
    @EnvironmentObject var viewModel: DocumentConvertViewModel
    @ObservedObject private var storeManager = StoreKitManager.shared
    @State private var showConvertConfirmation = false
    @State private var showPurchasePrompt = false
    @State private var tempBookletType: BookletType = .type2
    @State private var showComparison = false

    private var documentName: String {
        let name = (viewModel.document?.name)?.nilIfEmpty ?? String(localized: "str.unknown_document")
        return name.isEmpty ? "Untitled.pdf" : name
    }
    
    private var documentInfo: String {
        [
            documentName,
            String(format: String(localized: "str.pages_count"), document?.pageCount ?? 0)
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
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
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
            defaultFilename: documentName,
            onCompletion: { newUrl in
            Logging.l(tag: "DocumentConvertView", "Exported at \(newUrl)")
        })
        .alert(Text("str.confirm_conversion"), isPresented: $showConvertConfirmation) {
            Button(role: .cancel) { } label: { Text("str.cancel") }
            Button {
                viewModel.bookletType = tempBookletType
                viewModel.convertToBooklet()
            } label: {
                let format = tempBookletType == .type2 ? String(localized: "str.format_2in1") : String(localized: "str.format_4in1")
                Text("\(String(localized: "str.convert_to")) \(format)")
            }
        } message: {
            let format = tempBookletType == .type2 ? String(localized: "str.format_2in1") : String(localized: "str.format_4in1")
            Text("\(String(localized: "str.convert_confirmation_message")) \(format)")
        }
        .sheet(isPresented: $showPurchasePrompt) {
            PurchasePromptView(storeManager: storeManager)
        }
    }
    
    private var innerBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let _ = viewModel.pdfUrl, !viewModel.isConverting {
                documentInfoView
                
                Divider()
                    .background(Theme.Colors.background)
                
                previewContent
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
            } else {
                if viewModel.isConverting {
                    LoadingView(title: String(localized: "str.converting"), message: documentName)
                } else {
                    openFinderView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var documentInfoView: some View {
        HStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Text(documentInfo)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.secondaryText)
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
                .background(Theme.Colors.secondaryBackground, in: Circle())
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
        .background(Theme.Colors.glassSurface)
    }
    
    @ViewBuilder
    private func pdfViewer(_ url: URL) -> some View {
        if let document: PDFDocument = .init(url: url) {
            PDFPreviewView(document: document, title: "", isConverted: false)
        }
    }
    
    private var openFinderView: some View {
        Button(action: {
            openFinder()
        }, label: {
            Text("str.select_pdf_file")
                .font(.system(size: 14))
        })
        .buttonStyle(BorderedButtonStyle())
    }
    
    @ViewBuilder
    private var previewContent: some View {
        if showComparison && viewModel.state == .convertedPdf,
           let original = viewModel.originalDocument,
           let converted = viewModel.document {
            PDFComparisonView(
                originalDocument: original.document,
                convertedDocument: converted.document,
                originalTitle: original.name,
                convertedTitle: converted.name
            )
        } else if let doc = document {
            PDFPreviewView(
                document: doc,
                title: documentName,
                isConverted: viewModel.state == .convertedPdf
            )
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
        Text("str.clear")
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
                    viewModel.clearDocuments()
                }, label: {
                    clearButton
                })
            }
            
            Divider()
            
            // Comparison toggle for converted documents
            if viewModel.state == .convertedPdf && viewModel.originalDocument != nil {
                Button(action: {
                    showComparison.toggle()
                }, label: {
                    HStack(spacing: 4) {
                        Image(systemName: showComparison ? "rectangle.split.2x1" : "rectangle.split.2x1.fill")
                        #if os(macOS)
                        Text("str.show_comparison")
                            .font(.system(size: 14))
                        #endif
                    }
                })
                .buttonStyle(.bordered)
                
                Divider()
            }
            
            if !viewModel.isConverting && viewModel.state != .convertedPdf {
                
                BookletTypeSelector(
                        selectedType: $viewModel.bookletType,
                        storeManager: storeManager,
                        onLockedTap: { showPurchasePrompt = true }
                    )
            }
            
            if #available(iOS 26.0, *) {
                Spacer()
            }
            
            // Convert button
            if !viewModel.isConverting && viewModel.state != .convertedPdf {
                Button(action: {
                    if viewModel.bookletType == .type4 && !storeManager.isFourInOnePurchased {
                        showPurchasePrompt = true
                    } else {
                        tempBookletType = viewModel.bookletType
                        showConvertConfirmation = true
                    }
                }, label: {
                    Text("str.convert")
                        .font(.system(size: 14))
                })
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
            }
        }
        .padding(.horizontal, 10)
    }
    
    private var topBarTrailingActions: some View {
        #if os(iOS)
        HStack {
            if viewModel.state == .convertedPdf && viewModel.originalDocument != nil {
                Button(action: {
                    showComparison.toggle()
                }, label: {
                    Image(systemName: showComparison ? "rectangle.split.2x1.fill" : "rectangle.split.2x1")
                })
                .help("str.show_comparison")
            } else if viewModel.state != .convertedPdf {
                BookletTypeSelector(
                        selectedType: $viewModel.bookletType,
                        storeManager: storeManager,
                        onLockedTap: { showPurchasePrompt = true }
                    )
            }
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