//
//  PDFReader.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFReader: View {
    var url: URL?
    
    var body: some View {
        if let url {
            PDFKitView(url: url)
                .ignoresSafeArea()

        } else {
            Text("No document")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Rectangle().foregroundStyle(
                        Color(.secondarySystemBackground)
                    )
                    .ignoresSafeArea()
                }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL // new variable to get the URL of the document
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        // Creating a new PDFVIew and adding a document to it
        let pdfView = PDFView()
        pdfView.scaleFactor = 0.7
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: self.url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
        // we will leave this empty as we don't need to update the PDF
    }
}
