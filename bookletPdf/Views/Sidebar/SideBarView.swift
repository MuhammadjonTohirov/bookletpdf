//
//  SideBarView.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

enum MenuOption: String, Identifiable {
    // Main section
    case converter = "Converter"
    case help = "Help"
    
    // Settings section
    case settings = "Settings"
    
    var id: String { self.rawValue }
    
    // Group menu items by section
    static var mainItems: [MenuOption] {
        [.converter, .help]
    }
    
    static var settingsItems: [MenuOption] {
        [.settings]
    }
}

struct SidebarView: View {
    @Binding var selectedMenu: MenuOption?

    var body: some View {
        List(selection: $selectedMenu) {
            Section("Main") {
                ForEach(MenuOption.mainItems, id: \.id) { menu in
                    NavigationLink(value: menu) {
                        Label(menu.rawValue, systemImage: iconFor(menu))
                    }
                }
            }
            
            Section("Settings") {
                ForEach(MenuOption.settingsItems, id: \.id) { menu in
                    NavigationLink(value: menu) {
                        Label(menu.rawValue, systemImage: iconFor(menu))
                    }
                }
            }
            
            // Footer section with company info
            Section {
                HStack {
                    Spacer()
                    Text("Powered by SBD LLC")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .frame(minWidth: 200)
        .listStyle(.sidebar)
        .navigationTitle("PDF Booklet Maker")
    }
    
    // Return appropriate icon for each menu option
    private func iconFor(_ menu: MenuOption) -> String {
        switch menu {
        case .converter:
            return "doc.text"
        case .help:
            return "questionmark.circle"
        case .settings:
            return "gear"
        }
    }
}

#if DEBUG
#Preview {
    NavigationSplitView {
        SidebarView(selectedMenu: .constant(.converter))
    } detail: {
        Text("Selected menu item will appear here")
    }
}
#endif
