//
//  SideBarView.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI
import BookletCore

enum MenuOption: String, Identifiable {
    // Main section
    case converter = "converter"
    case help = "help"
    
    // Settings section
    case settings = "settings"
    
    var id: String { self.rawValue }
    
    var localizedTitle: String {
        switch self {
        case .converter:
            return "str.converter".localize
        case .help:
            return "str.help".localize
        case .settings:
            return "str.settings".localize
        }
    }
    
    // Group menu items by section
    static var mainItems: [MenuOption] {
        [.converter, .help]
    }
    
    static var settingsItems: [MenuOption] {
        [.settings]
    }
    
    var icon: String {
        switch self {
        case .converter:
            return "doc.viewfinder"
        case .help:
            return "questionmark.circle"
        case .settings:
            return "gear"
        }
    }
}

struct SidebarView: View {
    @Binding var selectedMenu: MenuOption?

    var body: some View {
        #if os(macOS)
        MacSidebarView(selectedMenu: $selectedMenu)
        #else
        iOSSidebarView(selectedMenu: $selectedMenu)
        #endif
    }
}

#if os(iOS)
// iOS implementation
struct iOSSidebarView: View {
    @Binding var selectedMenu: MenuOption?
    
    var body: some View {
        List(selection: $selectedMenu) {
            Section("str.main".localize) {
                ForEach(MenuOption.mainItems, id: \.id) { menu in
                    NavigationLink(value: menu) {
                        Label(menu.localizedTitle, systemImage: menu.icon)
                    }
                }
            }
            
            Section("str.settings".localize) {
                ForEach(MenuOption.settingsItems, id: \.id) { menu in
                    NavigationLink(value: menu) {
                        Label(menu.localizedTitle, systemImage: menu.icon)
                    }
                }
            }
            
            // Footer section with company info
            Section {
                HStack {
                    Spacer()
                    Text("str.powered_by".localize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("str.app_name".localize)
    }
}
#endif

#if os(macOS)
// macOS implementation with enhanced styling
struct MacSidebarView: View {
    @Binding var selectedMenu: MenuOption?
    @State private var hoverItem: MenuOption? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // App Title
            HStack {
                Image(systemName: "doc.viewfinder")
                    .font(.title2)
                Text("PDF Booklet Maker")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Menu Items
            List(selection: $selectedMenu) {
                Section(header: Text("Main").font(.caption).foregroundColor(.secondary)) {
                    ForEach(MenuOption.mainItems, id: \.id) { menu in
                        menuItem(menu)
                    }
                }
                
                Section(header: Text("Settings").font(.caption).foregroundColor(.secondary)) {
                    ForEach(MenuOption.settingsItems, id: \.id) { menu in
                        menuItem(menu)
                    }
                }
            }
            .listStyle(.sidebar)
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Text("Powered by SBD LLC")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(minWidth: 220)
    }
    
    private func menuItem(_ menu: MenuOption) -> some View {
        NavigationLink(value: menu) {
            HStack(spacing: 12) {
                Image(systemName: menu.icon)
                    .font(.system(size: 14))
                    .foregroundColor(selectedMenu == menu ? .accentColor : .primary)
                    .frame(width: 24, height: 24)
                
                Text(menu.localizedTitle)
                    .font(.body)
                
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
//        .listRowBackground(
//            RoundedRectangle(cornerRadius: 6)
//                .fill(selectedMenu == menu ?
//                      Color.accentColor.opacity(0.15) :
//                      (hoverItem == menu ? Color.gray.opacity(0.1) : Color.clear))
//                .padding(.horizontal, 4)
//        )
        .onHover { hovering in
            hoverItem = hovering ? menu : nil
        }
    }
}
#endif
