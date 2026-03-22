import SwiftUI

public struct MainView: View {
    @EnvironmentObject var mainViewModel: DocumentConvertViewModel
    @EnvironmentObject var languageManager: LanguageManager

    public init() {}

    public var body: some View {
        Group {
            #if os(macOS)
            MacContentView()
            #else
            AppTabView()
            #endif
        }
        .onAppear {
            mainViewModel.onAppear()
            languageManager.onAppear()
        }
    }
}
