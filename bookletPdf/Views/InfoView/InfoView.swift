//
//  InfoView.swift
//  bookletPdf
//
//  Created by applebro on 29/09/23.
//

import SwiftUI
import WebKit

struct InfoView: View {
    @State
    private var isLoading: Bool = true
    
    @State
    private var htmlContent: String = ""
    
    var body: some View {
        WebViewRepresentable(htmlContent: htmlContent)
            .navigationTitle("Info")
            .navigationTitleInline()
            .overlay {
                ProgressView()
                    .opacity(isLoading ? 1 : 0)
            }
            .onAppear {
                if let durl = Bundle.main.url(forResource: "Info", withExtension: "html"),
                   let dstr = try? String.init(contentsOf: durl, encoding: .utf8) {
                    htmlContent = dstr
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
                }
            }
            .animation(.easeInOut, value: isLoading)
    }
}

// WebView wrapper for SwiftUI that works on both platforms
struct WebViewRepresentable: View {
    let htmlContent: String
    
    var body: some View {
        #if os(iOS)
        iOSWebView(htmlContent: htmlContent)
        #elseif os(macOS)
        macOSWebView(htmlContent: htmlContent)
        #endif
    }
}

#if os(iOS)
// iOS implementation
struct iOSWebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#endif

#if os(macOS)
// macOS implementation
struct macOSWebView: NSViewRepresentable {
    let htmlContent: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
#endif

#Preview {
    NavigationStack {
        InfoView()
    }
}
