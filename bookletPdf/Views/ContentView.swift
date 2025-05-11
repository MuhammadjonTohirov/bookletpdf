//
//  ContentView.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI

struct ContentView: View {
    @State var selectedMenu: MenuOption? = .home
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
            case .home:
                MainView()
                    .environmentObject(mainViewModel)
            case .help:
                InfoView()
            case .settings:
                Text("Settings")
            default:
                EmptyView()
            }
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(MainViewModel())
}
