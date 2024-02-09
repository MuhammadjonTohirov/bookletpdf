//
//  MainView.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import SwiftUI
import PDFKit

enum ContentViewState {
    case initial
    case selectedPdf
    case convertedPdf
}

struct MainView: View {
    @State private var pdfUrl: URL?
    @State private var showFileImporter = false
    @State private var showFileExporter = false
    @State private var isConverting: Bool = false
    @State private var state: ContentViewState = .initial
    @State private var showInfo = false
    
    private var documentName: String {
        pdfUrl?.lastPathComponent ?? ""
    }
    
    private var document: PDFDocument? {
        if let pdfUrl {
            return PDFDocument(url: pdfUrl)
        }
        
        return nil
    }
    
    var body: some View {
        NavigationStack {
            innerBody
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {showInfo = true}, label: {
                            Image(systemName: "info.circle")
                        })
                        .buttonStyle(BorderedButtonStyle())
                    }
                })
                .sheet(isPresented: $showInfo, content: {
                    NavigationView {
                        InfoView()
                    }
                })
                .navigationTitle(
                    pdfUrl?.lastPathComponent ?? ""
                )
                .navigationBarTitleDisplayMode(.inline)
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.pdf], onCompletion: { result in
            DispatchQueue.global(qos: .background).async {
                do {
                    let _url = AppPDF(url: try result.get()).createTemporaryPdfFromUrl
                    DispatchQueue.main.async {
                        self.pdfUrl = _url
                        self.state = .selectedPdf
                    }
                } catch {
                    print("Error")
                }
            }
        })
        .fileExporter(
            isPresented: $showFileExporter,
            item: document,
            contentTypes: [.pdf],
            onCompletion: { newUrl in
            print("Exported at \(newUrl)")
        })
    }
    
    private var innerBody: some View {
        VStack(alignment: .leading) {

            if let pdfUrl, !isConverting {
                pdfViewer(pdfUrl)
            } else {
                if isConverting {
                    LoadingView(title: "Converting ...", message: documentName)
                } else {
                    Button(action: {
                        openFinder()
                    }, label: {
                        Text("Select pdf file")
                            .font(.system(size: 14))
                    })
                    .buttonStyle(BorderedButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func pdfViewer(_ _url: URL) -> some View {
        if let doc = PDFDocument(url: _url) {
            PDFViewer(document: doc)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
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
                    ToolbarItem(placement: .bottomBar) {
                        bottomActions
                    }
                })
        }
    }
    
    private var bottomActions: some View {
        HStack {
            Button(action: {
                state = .initial
                pdfUrl = nil
            }, label: {
                Text("Clear")
                    .font(.system(size: 14))
            })
            
            Button(action: {
                if state == .convertedPdf {
                    state = .initial
                    pdfUrl = nil
                    return
                }
                
                self.isConverting = true
                AppPDF(url: self.pdfUrl).makeBookletPDF { newPdfUrl in
                    self.pdfUrl = nil
                    self.pdfUrl = newPdfUrl
                    self.state = newPdfUrl != nil ? .convertedPdf : self.state
                    self.isConverting = false
                }
            }, label: {
                Text(state == .convertedPdf ? "Clear" : "Convert to booklet")
                    .font(.system(size: 14))
            })
            .opacity(isConverting || state == .convertedPdf ? 0 : 1)
            Spacer()
            Button(action: {
                self.saveFile()
            }, label: {
                Image(systemName: "square.and.arrow.up")
            })
        }
    }
    
    private func openFinder() {
        showFileImporter = true
    }
    
    private func saveFile() {
        showFileExporter = true
    }
}

#Preview {
    MainView()
}
