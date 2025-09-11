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

enum ContentViewState {
    case initial
    case selectedPdf
    case convertedPdf
}

struct DocumentConvertView: View {
    @EnvironmentObject var viewModel: DocumentConvertViewModel
    @State private var showConvertConfirmation = false
    @State private var tempBookletType: BookletType = .type2
    @State private var showComparison = false

    private var documentName: String {
        (viewModel.document?.name)?.putIfEmpty(viewModel.document?.url?.lastPathComponent ?? "str.unknown_document".localize) ?? ""
    }
    
    private var documentInfo: String {
        [
            documentName,
            "str.pages_count".localize.localize(arguments: document?.pageCount ?? 0)
        ].joined(separator: ", ")
    }
    
    private var document: PDFDocument? {
        viewModel.document?.document
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background
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
        .alert("str.confirm_conversion".localize, isPresented: $showConvertConfirmation) {
            Button("str.cancel".localize, role: .cancel) { }
            Button("str.convert_to".localize.localize(arguments: tempBookletType == .type2 ? "str.format_2in1".localize : "str.format_4in1".localize)) {
                viewModel.bookletType = tempBookletType
                viewModel.convertToBooklet()
            }
        } message: {
            Text("str.convert_confirmation_message".localize.localize(arguments: tempBookletType == .type2 ? "str.format_2in1".localize : "str.format_4in1".localize))
        }
    }
    
    private var innerBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let pdfUrl = viewModel.pdfUrl, !viewModel.isConverting {
                HStack {
                    Text(documentInfo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .background(Theme.Colors.background)
                
                Divider()
                    .padding(.vertical, 4)
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
                    LoadingView(title: "str.converting".localize, message: documentName)
                } else {
                    openFinderView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var openFinderView: some View {
        Button(action: {
            openFinder()
        }, label: {
            Text("str.select_pdf_file".localize)
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
        Text("str.clear".localize)
            .font(.system(size: 14))
        #else
        Image(systemName: "trash")
            .font(.system(size: 14))
        #endif
    }
    
    private var bottomActions: some View {
        HStack {
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
                        Text("str.show_comparison".localize)
                            .font(.system(size: 14))
                        #endif
                    }
                })
                .buttonStyle(.bordered)
                
                Divider()
            }
            
            if !viewModel.isConverting && viewModel.state != .convertedPdf {
                #if os(macOS)
                BookletTypeSelector(selectedType: $viewModel.bookletType)
                    .frame(maxWidth: 250)
                    .padding(.horizontal)
                #endif
                
                Button(action: {
                    tempBookletType = viewModel.bookletType
                    showConvertConfirmation = true
                }, label: {
                    Text("str.convert".localize)
                        .font(.system(size: 14))
                })
            }
            
            Spacer()
            
            // Add print button here when document is loaded
            if viewModel.state == .convertedPdf || viewModel.state == .selectedPdf {
                printToolbarButton
            }
            
            Button(action: {
                self.saveFile()
            }, label: {
                Image(systemName: "square.and.arrow.up")
            })
        }
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
                .help("str.show_comparison".localize)
            } else if viewModel.state != .convertedPdf {
                BookletTypeSelector(selectedType: $viewModel.bookletType)
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
