//
//  PDFPageView.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFPageView: View {
    var page: PDFPage
    var pageNumber: Int
    var key: String
    var size: CGSize = .init(width: 100, height: 200)
    
    var body: some View {
        VStack {
            PDFPageThumbnail(
                viewModel: .init(page: page, key: key, size: size)
            )
            .padding(.bottom, 4)
            Text("\(pageNumber)")
                .font(.system(size: 12))
                .foregroundStyle(Color.init(uiColor: .secondaryLabel))
        }
    }
}

#Preview {
    let doc = PDFDocument(url: Bundle.main.url(forResource: "Resume", withExtension: "pdf")!)!
    PDFPageView(
        page: doc.page(at: 0)!,
        pageNumber: 1,
        key: "pdf"
    )
}
