import SwiftUI

public struct MainView: View {
    @EnvironmentObject var mainViewModel: DocumentConvertViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var storeManager = StoreKitManager.shared
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var updateChecker = AppUpdateChecker()

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
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            Task {
                await storeManager.refreshStoreState()
            }
        }
        .overlay {
            if updateChecker.isUpdateRequired {
                ForceUpdateOverlay(updateURL: updateChecker.updateURL)
            } else if !storeManager.isPro && !networkMonitor.isConnected {
                NoInternetOverlay()
            }
        }
    }
}
