//
//  bookletPdfApp.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI

@main
struct bookletPdfApp: App {
    @State private var menuBarExtraShown: Bool = true
    var body: some Scene {
        WindowGroup("Main Window", id: "main-window") {
            ContentView()
        }
        
        #if os(macOS)
        WindowGroup("PDF Viewer", id: "pdf-viewer") {
            Text("PDF Viewer")
        }
        #endif
    }
}
