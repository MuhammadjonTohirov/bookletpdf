//
//  PDFViewerView.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 23/02/25.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFViewerView: View {
    var pdfDocument: PDFDocument

    var body: some View {
        #if os(macOS)
        PDFKitView(pdfDocument: pdfDocument)
            .frame(minWidth: 800, minHeight: 600)
        #else
        NavigationView {
            PDFKitView(pdfDocument: pdfDocument)
                .navigationBarTitle("PDF Viewer", displayMode: .inline)
        }
        #endif
    }
}

struct PDFKitView: View {
    let pdfDocument: PDFDocument

    var body: some View {
        #if os(macOS)
        PDFKitMacView(pdfDocument: pdfDocument)
        #else
        PDFKitIOSView(pdfDocument: pdfDocument)
        #endif
    }
}

#if os(macOS)
struct PDFKitMacView: NSViewRepresentable {
    let pdfDocument: PDFDocument

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {}
}
#else
struct PDFKitIOSView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
#endif
