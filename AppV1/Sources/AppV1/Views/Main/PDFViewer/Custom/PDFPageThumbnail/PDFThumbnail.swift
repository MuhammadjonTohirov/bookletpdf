//
//  PDFPageThumbnail.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import Foundation
import SwiftUI
import PDFKit
import BookletPDFKit

struct PDFThumbnail: View {
    @StateObject var viewModel: PDFThumbnailViewModel
    @State private var image: FImage? = nil

    var body: some View {
        imageView
    }
    
    private var imageView: some View {
        imageui
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
    }
    
    @ViewBuilder
    private var imageui: some View {
        if let image = viewModel.image {
            Image(fImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .shadow(radius: 3, x: 0, y: 1)

            .frame(
                width: viewModel.size.width,
                height: viewModel.size.height
            )
                
        } else {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(
                    .clear
                )
                .overlay {
                    ProgressView()
                }
        }
    }
}
