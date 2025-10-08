//
//  SideBarView.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI
import BookletCore
import BookletPDFKit

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
// iOS implementation with modern design
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
                Image("img_logo_white")
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("Booklet PDF")
                    .font(.headline)
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)
            
            // Menu Items with modern styling
            VStack(spacing: Theme.Spacing.sm) {
                // Main section
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("str.main".localize)
                        .sectionHeader()
                    
                    ForEach(MenuOption.mainItems, id: \.id) { menu in
                        modernMenuItem(menu)
                    }
                }
                
                // Settings section
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("str.settings".localize)
                        .sectionHeader()
                    
                    ForEach(MenuOption.settingsItems, id: \.id) { menu in
                        modernMenuItem(menu)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.lg)
            
            Spacer()
            
            // Modern Footer
            VStack(spacing: Theme.Spacing.xs) {
                Rectangle()
                    .fill(Theme.Colors.divider)
                    .frame(height: 0.5)
                    .padding(.horizontal, Theme.Spacing.md)
                
                Text("str.powered_by".localize)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.tertiaryText)
                    .padding(.vertical, Theme.Spacing.sm)
            }
        }
        .frame(minWidth: 240)
        .background(Theme.Colors.background)
    }
    
    private func modernMenuItem(_ menu: MenuOption) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMenu = menu
            }
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: menu.icon)

                    .font(.system(size: 14))
                    .foregroundColor(selectedMenu == menu ? .white : .primary)
                    .frame(width: 24, height: 24)
                
                Text(menu.localizedTitle)
                    .font(.body)
                
                Spacer()
                
                if selectedMenu == menu {
                    Circle()
                        .fill(Theme.Colors.primary)
                        .frame(width: 4, height: 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .fill(selectedMenu == menu ? 
                          Theme.Colors.primary.opacity(0.1) :
                            (hoverItem == menu ? Theme.Colors.secondaryBackground.opacity(0.5) : Color.clear))
            )
            .scaleEffect(hoverItem == menu ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: hoverItem)
            .animation(.easeInOut(duration: 0.2), value: selectedMenu)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                hoverItem = hovering ? menu : nil
            }
        }
    }
}
#endif

#Preview {
    SidebarView(selectedMenu: .init(get: {nil}, set: {_ in }))
}
