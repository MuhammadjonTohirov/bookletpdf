//
//  SideBarView.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

enum MenuOption: String, CaseIterable, Identifiable {
    case home = "Home"
    case help
    case settings
    
    var id: String { self.rawValue }
}

struct SidebarView: View {
    @Binding var selectedMenu: MenuOption?

    var body: some View {
        List(selection: $selectedMenu) { 
            Section("Menu") {
                ForEach(MenuOption.allCases) { menu in
                    NavigationLink(menu.rawValue.capitalized, value: menu)
                }
            }
        }
        .frame(minWidth: 200)
        .listStyle(.sidebar)
        .navigationTitle("PDF Booklet Maker")
    }
}
