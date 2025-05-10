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
        viewModel.document?.name ?? ""
    }
    
    private var document: PDFDocument? {
        viewModel.document?.document
    }
    
    var body: some View {
        NavigationStack {
            innerBody
                .navigationTitle(
                    viewModel.pdfUrl?.lastPathComponent ?? ""
                )
                .navigationTitleInline()
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
        VStack(alignment: .leading) {
            if let pdfUrl = viewModel.pdfUrl, !viewModel.isConverting {
                pdfViewer(pdfUrl)
            } else {
                if viewModel.isConverting {
                    LoadingView(title: "Converting ...", message: documentName)
                } else {
                    initialView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var initialView: some View {
        VStack {
            #if os(macOS)
            Image(systemName: "square.and.arrow.down")
                .font(.system(
                    size: 32,
                    weight: .ultraLight,
                    design: .rounded
                ))
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            Text("Drag and drop pdf file here")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            #endif
            
            Button(action: {
                openFinder()
            }, label: {
                Text("Select pdf file")
                    .font(.system(size: 14))
            })
            .buttonStyle(BorderedButtonStyle())
        }
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
                    Button(action: {
                        openFinder()
                    }, label: {
                        Image(systemName: "folder")
                            .font(.system(size: 14))
                    })
                    .buttonStyle(BorderedButtonStyle())
                }
            })
            .toolbar(content: {
                ToolbarItem(placement: .buttomBarOrPrimary) {
                    bottomActions
                }
            })
        }
    }
    
    // Add this to the bottomActions in MainView.swift
    private var bottomActions: some View {
        HStack {
            if viewModel.state == .convertedPdf || viewModel.state == .selectedPdf {
                Button(action: {
                    viewModel.state = .initial
                    viewModel.pdfUrl = nil
                }, label: {
                    Text("Clear")
                        .font(.system(size: 14))
                })
            }
            
            if !viewModel.isConverting && viewModel.state != .convertedPdf {
                Button(action: {
                    self.viewModel.convertToBooklet()
                }, label: {
                    Text("Convert to booklet")
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
        self.viewModel.pdfUrl = Bundle.main.url(forResource: "Resume", withExtension: "pdf")
        self.viewModel.state = .selectedPdf
    }
}

#Preview {
    MainView()
}
