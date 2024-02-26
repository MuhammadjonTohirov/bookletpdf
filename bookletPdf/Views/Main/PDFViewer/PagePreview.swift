//
//  PagePreview.swift
//  bookletPdf
//
//  Created by rakhmatillo on 17/02/24.
//

import SwiftUI
import PDFKit
import AppKit

struct PagePreview: View {
    var document : PDFDocument
    @Binding var pageNumber : Int
    @Binding var show : Bool
    @State private var screenSize: CGRect = .zero
    @State var mainPage : UIImage!
    @State var scrollViewProxy : ScrollViewProxy!
    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                show.toggle()
            }, label: {
                Image(systemName: "xmark")
            })
            
            .padding(16)
            HStack(alignment: .center){
                Button {
                    if pageNumber > 0 {
                        pageNumber -= 1
                        self.scrollViewProxy.scrollTo(pageNumber, anchor: .center)
                    }
                    
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxHeight: .infinity)
                .frame(width: 100)
                .background(
                    Rectangle()
                        .foregroundStyle(Color.init(uiColor: .secondarySystemBackground.withAlphaComponent(0.1)))
                    .ignoresSafeArea())
                Spacer()
                mainImage
                Spacer()
                
                Button {
                    if pageNumber < document.pageCount - 1 {
                        withAnimation {
                            pageNumber += 1
                            self.scrollViewProxy.scrollTo(pageNumber, anchor: .center)
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxHeight: .infinity)
                .frame(width: 100)
                .background(
                    Rectangle()
                        .foregroundStyle(Color.init(uiColor: .secondarySystemBackground.withAlphaComponent(0.1)))
                    .ignoresSafeArea())
                
            }

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
        }

    }
 
    @ViewBuilder
    private var mainImage: some View {
        GeometryReader { proxy in
            if let imageData = self.document.page(at: pageNumber)!.thumbnail(of: .init(width: proxy.size.width - 200, height: proxy.size.height), for: .trimBox).jpegData(compressionQuality: 1) {
                let uiImage = UIImage(data: imageData)
                if let image = uiImage{
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fit).frame(maxWidth: .infinity, alignment: .center)
                }
            }else{
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.init(uiColor: .secondarySystemBackground))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        
    }
    
    var gridView: some View {
        ScrollViewReader { value in
            
            ScrollView(.horizontal) {
                LazyHGrid(
                    rows: [
                        GridItem(.adaptive(minimum: 120, maximum: 200))
                    ],
                    spacing: 20) {
                    ForEach(0..<document.pageCount, id: \.self) { page in
                        PreviewPageItem(
                            page: document.page(at: page)!,
                            pageNumber: page + 1,
                            key: "\(page + 1)_\(document.documentURL!.lastPathComponent)",
                            size: .init(width: 100, height: 200),
                            selectedPage: $pageNumber
                        )
                        .frame(width: 100, height: 200)
                        .onTapGesture {
                            withAnimation {
                                pageNumber = page
                                self.scrollViewProxy.scrollTo(pageNumber, anchor: .center)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .frame(height: 230)
            .background {
                Rectangle()
                    .foregroundStyle(Color.init(uiColor: .secondarySystemBackground))
                    .ignoresSafeArea()
            }.onAppear {
                withAnimation {
                    self.scrollViewProxy = value
                    self.scrollViewProxy.scrollTo(pageNumber, anchor: .center)
                }
            }
        }
    }
}




