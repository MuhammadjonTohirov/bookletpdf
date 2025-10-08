//
//  bookletPdfApp.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI
import BookletCore
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
    @StateObject private var mainViewModel = DocumentConvertViewModel()
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup(id: "main-window") {
            ContentView()
                .environmentObject(mainViewModel)
                .environmentObject(languageManager)
        }
        .commands {
            AppMenuCommands(viewModel: mainViewModel)
        }
        
        #if os(macOS)
        WindowGroup("str.pdf_viewer".localize, id: "pdf-viewer") {
            Text("str.pdf_viewer".localize)
        }
        #endif
    }
}
