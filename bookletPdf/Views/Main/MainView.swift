//
//  MainView.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import SwiftUI
import PDFKit
import BookletPDFKit

enum ContentViewState {
    case initial
    case selectedPdf
    case convertedPdf
}

struct MainView: View {
    @EnvironmentObject var viewModel: MainViewModel

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
                
                pdfViewer(pdfUrl)
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
        Button(action: {
            openFinder()
        }, label: {
            Text("Select pdf file")
                .font(.system(size: 14))
        })
        .buttonStyle(BorderedButtonStyle())
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
        HStack {
            if viewModel.state == .convertedPdf || viewModel.state == .selectedPdf {
                Button(action: {
                    viewModel.state = .initial
                    viewModel.pdfUrl = nil
                }, label: {
                    clearButton
                })
            }
            
            Divider()
            
            if !viewModel.isConverting && viewModel.state != .convertedPdf {
                #if os(macOS)
                BookletTypeSelector(selectedType: $viewModel.bookletType)
                    .frame(maxWidth: 250)
                    .padding(.horizontal)
                #endif
                
                Button(action: {
                    self.viewModel.convertToBooklet()
                }, label: {
                    Text("Convert")
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
    MainView()
        .environmentObject(MainViewModel())
}
