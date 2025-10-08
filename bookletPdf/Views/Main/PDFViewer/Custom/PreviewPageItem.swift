//
//  PreviewPageItem.swift
//  bookletPdf
//
//  Created by rakhmatillo on 23/02/24.
//


import Foundation
import SwiftUI
import PDFKit

struct PreviewPageItem: View {
    var page: PDFPage
    var pageNumber: Int
    var key: String
    var size: CGSize = .init(width: 100, height: 200)
    @Binding var selectedPage : Int
    var body: some View {
        VStack {
            if selectedPage == pageNumber - 1 {
                PDFThumbnail(viewModel: .init(page: page, key: key, size: size))
                    .padding(.bottom, 4)
                    .border(.blue, width: 2)
            }else{
                PDFThumbnail(viewModel: .init(page: page, key: key, size: size))
            }
            Text("\(pageNumber)")
                .font(.system(size: 12))
                .foregroundStyle(Color.init(uiColor: .secondaryLabel))
        }
        
    }
}
