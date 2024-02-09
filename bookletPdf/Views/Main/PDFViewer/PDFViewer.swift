//
//  PDFViewer.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI
import PDFKit

struct PDFViewer: View {
    var document: PDFDocument
    @State private var screenSize: CGRect = .zero
    var body: some View {
        VStack {
            gridView
                .opacity(screenSize.width == 0 ? 0 : 1)
                .background {
                    GeometryReader(content: { geometry in
                        Color.clear
                            .onAppear {
                                screenSize = geometry.frame(in: .global)
                            }
                    })
                }
        }.onAppear {
            
        }
    }
    
    var horizontalListView: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 20) {
                ForEach(0..<document.pageCount, id: \.self) { page in
                    PDFPageView(
                        page: document.page(at: page)!,
                        pageNumber: page + 1,
                        key: "\(page + 1)_\(document.documentURL!.lastPathComponent)"
                    )
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 240)
        }
        .background {
            Rectangle()
                .foregroundStyle(Color.init(uiColor: .secondarySystemBackground))
                .ignoresSafeArea()
        }
    }
    
    var gridView: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 120, maximum: 200))
                ],
                spacing: 20) {
                ForEach(0..<document.pageCount, id: \.self) { page in
                    PDFPageView(
                        page: document.page(at: page)!,
                        pageNumber: page + 1,
                        key: "\(page + 1)_\(document.documentURL!.lastPathComponent)",
                        size: .init(width: 150, height: 230)
                    )
                    .frame(width: 100, height: 180)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background {
            Rectangle()
                .foregroundStyle(Color.init(uiColor: .secondarySystemBackground))
                .ignoresSafeArea()
        }
    }
}



#Preview {
    PDFViewer(document: PDFDocument(url: Bundle.main.url(forResource: "Resume", withExtension: "pdf")!)!)
}
