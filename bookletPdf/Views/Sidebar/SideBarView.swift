//
//  SideBarView.swift
//  bookletPdf
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI
import BookletPDFKit

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
            // App header section
            headerSection
            
            // Main section
            mainSection
            
            // Settings section
            settingsSection
            
            // Footer section
            footerSection
        }
        .listStyle(.sidebar)
        .navigationTitle("PDF Booklet Maker")
        .background(Theme.Colors.background)
        .smoothTransition()
    }
    
    private var headerSection: some View {
        Section {
            HStack(spacing: Theme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .fill(Theme.Colors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("PDF Booklet Maker")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.primaryText)
                    Text("Convert PDFs to booklets")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
                Spacer()
            }
            .padding(.vertical, Theme.Spacing.xs)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
    
    private var mainSection: some View {
        Section {
            ForEach(MenuOption.mainItems, id: \.id) { menu in
                NavigationLink(value: menu) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: menu.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedMenu == menu ? Theme.Colors.primary : Theme.Colors.secondaryText)
                            .frame(width: 24, height: 24)
                        
                        Text(menu.rawValue)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.primaryText)
                    }
                    .padding(.vertical, Theme.Spacing.xs)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .fill(selectedMenu == menu ? Theme.Colors.primary.opacity(0.1) : Color.clear)
                )
            }
        } header: {
            Text("Main")
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)
                .textCase(.uppercase)
        }
    }
    
    private var settingsSection: some View {
        Section(header: Text("Settings")
            .font(Theme.Typography.subheadline)
            .foregroundColor(Theme.Colors.secondaryText)
            .textCase(.uppercase)
        ) {
            ForEach(MenuOption.settingsItems, id: \.id) { menu in
                NavigationLink(value: menu) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: menu.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedMenu == menu ? Theme.Colors.primary : Theme.Colors.secondaryText)
                            .frame(width: 24, height: 24)
                        
                        Text(menu.rawValue)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.primaryText)
                    }
                    .padding(.vertical, Theme.Spacing.xs)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .fill(selectedMenu == menu ? Theme.Colors.primary.opacity(0.1) : Color.clear)
                )
            }
        }
    }
    
    private var footerSection: some View {
        Section {
            HStack {
                Spacer()
                Text("© 2025 SBD LLC")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.tertiaryText)
                Spacer()
            }
            .padding(.vertical, Theme.Spacing.sm)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
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
            // Modern App Header
            HStack(spacing: Theme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .fill(Theme.Colors.primary.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("PDF Booklet")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.primaryText)
                    Text("Maker")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.secondaryText)
                }
                
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
                    Text("Main")
                        .sectionHeader()
                    
                    ForEach(MenuOption.mainItems, id: \.id) { menu in
                        modernMenuItem(menu)
                    }
                }
                
                // Settings section
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Settings")
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
                
                Text("© 2025 SBD LLC")
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedMenu == menu ? Theme.Colors.primary : Theme.Colors.secondaryText)
                    .frame(width: 20, height: 20)
                
                Text(menu.rawValue)
                    .font(selectedMenu == menu ? Theme.Typography.bodyMedium : Theme.Typography.body)
                    .foregroundColor(selectedMenu == menu ? Theme.Colors.primary : Theme.Colors.primaryText)
                
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
                          (hoverItem == menu ? Theme.Colors.secondaryBackground : Color.clear))
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
