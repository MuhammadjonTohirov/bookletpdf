//
//  SideBarView.swift
//  BookLet
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

struct SidebarView: View {
    @Binding var selectedMenu: MenuOption?

    var body: some View {
        List(selection: $selectedMenu) {
            Section("Main") {
                ForEach([MenuOption.home, MenuOption.projects], id: \.self) { menu in
                    NavigationLink(menu.rawValue, value: menu)
                }
            }
            
            Section("Settings") {
                ForEach([MenuOption.pdfSettings], id: \.self) { menu in
                    NavigationLink(menu.rawValue, value: menu)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Booklet")
    }
}
