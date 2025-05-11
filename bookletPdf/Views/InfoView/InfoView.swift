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
    private var htmlContent: String = "" // Replace this with your actual HTML string
    
    var body: some View {
        WebViewRepresentable(htmlContent: htmlContent)
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let durl = Bundle.main.url(forResource: "Info", withExtension: "html"),
                   let dstr = try? String.init(contentsOf: durl, encoding: .utf8) {
                    htmlContent = dstr
                }
            }
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
