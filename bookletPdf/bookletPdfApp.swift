//
//  bookletPdfApp.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI
import BookletCore
import AppV2
import FirebaseMessaging
import UserNotifications

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
        FirebaseService.configure()
        FirebaseService.registerForPushNotifications()
        FirebaseService.log(.appOpened)
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logging.l(tag: "AppDelegate", "Device token received: \(deviceToken)")
        FirebaseService.setAPNSToken(deviceToken)
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logging.l(tag: "AppDelegate", "Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        Logging.l(tag: "FCM", "Notification received (foreground): \(userInfo)")
        return [.banner, .badge, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        Logging.l(tag: "FCM", "Notification tapped: \(userInfo)")
    }
}
#endif

#if os(iOS)
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseService.configure()
        FirebaseService.registerForPushNotifications()
        FirebaseService.log(.appOpened)
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        AdManager.shared.configure()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FirebaseService.setAPNSToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logging.l(tag: "AppDelegate", "Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        Logging.l(tag: "FCM", "Notification received (foreground): \(userInfo)")
        return [.banner, .badge, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        Logging.l(tag: "FCM", "Notification tapped: \(userInfo)")
    }
}
#endif

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        Logging.l(tag: "FCM", "Token: \(token)")
    }
}

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
        innerBody
    }

    @SceneBuilder
    private var innerBody: some Scene {
        WindowGroup(id: "main-window") {
            MainView()
                .environmentObject(mainViewModel)
                .environmentObject(languageManager)
                .environment(\.locale, Locale(identifier: languageManager.currentLanguage.code))
                #if os(iOS)
                .preferredColorScheme(currentTheme.colorScheme)
                #elseif os(macOS)
                .frame(minWidth: 900, minHeight: 600)
                .background(MacWindowAppearanceView(theme: currentTheme))
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 1280, height: 800)
        #endif
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
