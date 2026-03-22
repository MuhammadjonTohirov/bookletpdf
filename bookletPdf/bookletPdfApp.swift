//
//  bookletPdfApp.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI
import BookletCore
import AppV2
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
    @AppStorage(UserSettings.themeStorageKey, store: UserDefaults(suiteName: UserSettings.suiteName))
    private var themeRawValue: Int = AppTheme.system.rawValue

    private var currentTheme: AppTheme {
        AppTheme(rawValue: themeRawValue) ?? .system
    }

    var body: some Scene {
        WindowGroup(id: "main-window") {
            MainView()
                .environmentObject(mainViewModel)
                .environmentObject(languageManager)
                .environment(\.locale, Locale(identifier: languageManager.currentLanguage.code))
                #if os(iOS)
                .preferredColorScheme(currentTheme.colorScheme)
                #elseif os(macOS)
                .background(MacWindowAppearanceView(theme: currentTheme))
                #endif
        }
        .commands {
            AppMenuCommands(viewModel: mainViewModel)
        }
        
        #if os(macOS)
        WindowGroup(Text("str.pdf_viewer"), id: "pdf-viewer") {
            Text("str.pdf_viewer")
                .environment(\.locale, Locale(identifier: languageManager.currentLanguage.code))
                .background(MacWindowAppearanceView(theme: currentTheme))
        }
        .defaultAppStorage(UserDefaults(suiteName: BookletCore.UserSettings.suiteName) ?? .standard)
        #endif
    }
}

#if os(macOS)
private struct MacWindowAppearanceView: NSViewRepresentable {
    let theme: AppTheme

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            applyAppearance(to: view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            applyAppearance(to: nsView.window)
        }
    }

    private func applyAppearance(to window: NSWindow?) {
        let appearance = appAppearance(for: theme)
        NSApp.appearance = appearance
        window?.appearance = appearance
    }

    private func appAppearance(for theme: AppTheme) -> NSAppearance? {
        switch theme {
        case .system:
            nil
        case .light:
            NSAppearance(named: .aqua)
        case .dark:
            NSAppearance(named: .darkAqua)
        }
    }
}
#endif
