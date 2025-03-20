//
//  ContentView.swift
//  BookLet
//
//  Created by Muhammadjon Tohirov on 05/01/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedMenu: MenuOption? = .home
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedMenu: $selectedMenu)
        } detail: {
            MainMenuBodyView(selectedMenu: selectedMenu)
        }
    }
}

#Preview {
    MainView()
}
