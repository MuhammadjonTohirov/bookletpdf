//
//  InfoView.swift
//  bookletPdf
//
//  Created by applebro on 29/09/23.
//

import SwiftUI
import WebKit
import BookletCore

struct InfoView: View {
    var body: some View {
        #if os(macOS)
        MacInfoView()
        #else
        iOSInfoView()
        #endif
    }
}

#if os(iOS)
struct iOSInfoView: View {
    @State private var isLoading: Bool = true
    @State private var htmlContent: String = ""
    
    var body: some View {
        WebViewRepresentable(htmlContent: htmlContent)
            .navigationTitle("str.help".localize)
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ProgressView()
                    .opacity(isLoading ? 1 : 0)
            }
            .onAppear {
                if let durl = HelpInfoProvider.helpInfoUrl,
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
#endif

#if os(macOS)
struct MacInfoView: View {
    @State private var isLoading: Bool = true
    @State private var htmlContent: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title
            HStack {
                Text("str.app_help_title".localize)
                    .font(.title)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content area
            ZStack {
                WebViewRepresentable(htmlContent: htmlContent)
                    .overlay {
                        if isLoading {
                            VStack {
                                ProgressView()
                                    .controlSize(.large)
                                    .scaleEffect(1.2)
                                
                                Text("str.loading_help_content".localize)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 12)
                            }
                            .frame(width: 200, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(NSColor.controlBackgroundColor))
                                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                            )
                        }
                    }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            if let durl = HelpInfoProvider.helpInfoUrl,
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
#endif

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
        
        // Configure for macOS styling
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Add some CSS to match macOS styling
        let styledHtml = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                    line-height: 1.5;
                    color: #333;
                    margin: 0;
                    padding: 20px;
                }
                h1, h2, h3 {
                    font-weight: 500;
                }
                h1 {
                    color: #333;
                    font-size: 24px;
                }
                h2 {
                    color: #444;
                    font-size: 20px;
                    margin-top: 25px;
                }
                p {
                    margin: 12px 0;
                }
                ul, ol {
                    margin: 12px 0;
                    padding-left: 24px;
                }
                code {
                    font-family: SF Mono, Menlo, monospace;
                    background-color: #f5f5f5;
                    padding: 2px 4px;
                    border-radius: 3px;
                    font-size: 0.9em;
                }
                .note {
                    background-color: #f0f7ff;
                    border-left: 4px solid #0070e0;
                    padding: 12px;
                    margin: 16px 0;
                    border-radius: 4px;
                }
                img {
                    max-width: 100%;
                    border-radius: 6px;
                    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
        
        webView.loadHTMLString(styledHtml, baseURL: nil)
    }
}
#endif

#if os(iOS)
#Preview("iOS Info View") {
    NavigationStack {
        iOSInfoView()
    }
}
#endif

#if os(macOS)
#Preview("macOS Info View") {
    MacInfoView()
}
#endif
