import SwiftUI
import BookletCore

#if os(macOS)
import AppKit
#endif

public struct MainView: View {
    @EnvironmentObject var mainViewModel: DocumentConvertViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var storeManager = StoreKitManager.shared
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var updateChecker = AppUpdateChecker()
    @State private var showUpdateAlert = false

    public init() {}

    public var body: some View {
        Group {
            #if os(macOS)
            MacContentView()
            #else
            AppTabView()
            #endif
        }
        .environmentObject(networkMonitor)
        .onAppear {
            mainViewModel.onAppear()
            languageManager.onAppear()
        }
        .task {
            await storeManager.refreshStoreState()
            await updateChecker.checkForUpdate()
        }
        .onChange(of: updateChecker.isUpdateRequired) { _, newValue in
            showUpdateAlert = newValue
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            if updateChecker.isUpdateRequired {
                showUpdateAlert = true
            }

            Task {
                await storeManager.refreshStoreState()
            }
        }
        .alert(
            Text("str.update_required".localize),
            isPresented: $showUpdateAlert
        ) {
            Button("str.update_now".localize) {
                openUpdateURL()
            }
        } message: {
            Text("str.update_required_message".localize)
        }
        .overlay {
            if !storeManager.isPro && !networkMonitor.isConnected {
                NoInternetOverlay()
            }
        }
    }

    private func openUpdateURL() {
        guard let url = updateChecker.updateURL else { return }
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
