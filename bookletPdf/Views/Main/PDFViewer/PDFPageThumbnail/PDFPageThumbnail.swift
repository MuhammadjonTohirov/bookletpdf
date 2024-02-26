//
//  PDFPageThumbnail.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFPageThumbnail: View {
    @StateObject var viewModel: PDFThumbnailViewModel
    @State private var image: UIImage? = nil

    var body: some View {
        imageView
    }
    
    private var imageView: some View {
        imageui
            .cornerRadius(10)
            .shadow(radius: 3, x: 0, y: 1)
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
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
        } else {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.init(uiColor: .secondarySystemBackground))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    ProgressView()
                }
        }
    }
}
