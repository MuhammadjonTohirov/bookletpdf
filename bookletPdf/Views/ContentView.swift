//
//  ContentView.swift
//  bookletPdf
//
//  Created by applebro on 27/09/23.
//

import SwiftUI

struct ContentView: View {
    @State var selectedMenu: MenuOption? = .converter
    @EnvironmentObject var mainViewModel: DocumentConvertViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        #if os(macOS)
        macNavigationView
        #else
        iosNavigationView
        #endif
    }
    
    // iOS-specific navigation
    var iosNavigationView: some View {
        NavigationSplitView {
            SidebarView(selectedMenu: $selectedMenu)
        } detail: {
            detailView
        }
    }
    
    // macOS-specific navigation with improved styling
    var macNavigationView: some View {
        NavigationSplitView {
            SidebarView(selectedMenu: $selectedMenu)
        } detail: {
            detailView
                .frame(minWidth: 600)
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    // Common detail view for both platforms
    @ViewBuilder
    var detailView: some View {
        switch selectedMenu {
        case .converter:
            DocumentConvertView()
                .environmentObject(mainViewModel)
        case .help:
            InfoView()
        case .settings:
            SettingsView()
        default:
            // If no menu is selected, default to converter
            DocumentConvertView()
                .environmentObject(mainViewModel)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DocumentConvertViewModel())
}
