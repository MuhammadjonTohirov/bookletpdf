//
//  bookletPdfApp.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

final class AppDelegate: NSObject {
}

#if os(macOS)
extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
    }
}
#endif

#if os(iOS)
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
#endif

@main
struct bookletPdfApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    
    @State private var menuBarExtraShown: Bool = true
    @StateObject private var mainViewModel = MainViewModel()

    var body: some Scene {
        WindowGroup("Main Window", id: "main-window") {
            ContentView()
                .environmentObject(mainViewModel)
        }
        .commands {
            AppMenuCommands(viewModel: mainViewModel)
        }
        
        #if os(macOS)
        WindowGroup("PDF Viewer", id: "pdf-viewer") {
            Text("PDF Viewer")
        }
        #endif
    }
}
