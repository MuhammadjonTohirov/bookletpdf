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
    @ObservedObject private var whatsNewManager = WhatsNewManager.shared
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var updateChecker = AppUpdateChecker()
    @State private var showUpdateAlert = false
    @State private var showNoInternetAlert = false

    public init() {}
    
    public var body: some View {
        innerBody
    }

    public var innerBody: some View {
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

            if shouldRequireInternet {
                showNoInternetAlert = true
            }

            Task {
                await storeManager.refreshStoreState()
            }
        }
        .onChange(of: networkMonitor.isConnected) { _, _ in
            if shouldRequireInternet {
                showNoInternetAlert = true
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
        .alert(
            Text("str.internet_required".localize),
            isPresented: $showNoInternetAlert
        ) {
            Button("str.ok".localize, role: .cancel) {}
        } message: {
            Text("str.internet_required_message".localize)
        }
        .sheet(isPresented: whatsNewBinding) {
            WhatsNewView(onDismiss: { whatsNewManager.markSeen() })
                #if os(iOS)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                #endif
        }
    }

    private var shouldRequireInternet: Bool {
        !storeManager.isPro && !networkMonitor.isConnected
    }

    private var whatsNewBinding: Binding<Bool> {
        Binding(
            get: { whatsNewManager.shouldPresent },
            set: { newValue in
                if !newValue { whatsNewManager.markSeen() }
            }
        )
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
