//
//  ContentView.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI

struct ContentView: View {
    @State var selectedMenu: MenuOption? = .converter
    @EnvironmentObject var mainViewModel: MainViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        navigationSplitViewLayout
    }
    
    var navigationSplitViewLayout: some View {
        NavigationSplitView {
            SidebarView(selectedMenu: $selectedMenu)
        } detail: {
            switch selectedMenu {
            case .converter:
                MainView()
                    .environmentObject(mainViewModel)
            case .help:
                InfoView()
            case .settings:
                SettingsView()
            default:
                // If no menu is selected, default to converter
                MainView()
                    .environmentObject(mainViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MainViewModel())
}
