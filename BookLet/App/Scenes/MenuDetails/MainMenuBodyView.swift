//
//  MainMenuBodyView.swift
//  BookLet
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation
import SwiftUI

struct MainMenuBodyView: View {
    let selectedMenu: MenuOption?

    var body: some View {
        Group {
            if let menu = selectedMenu {
                switch menu {
                case .home:
                    HomeView()
                case .projects:
                    Text("Projects View Content")
                case .layoutOptions:
                    Text("Layout Options Content")
                case .pdfSettings:
                    Text("PDF Settings Content")
                case .previewAndAdjust:
                    Text("Preview and Adjust Content")
                case .printing:
                    Text("Printing Content")
                case .templates:
                    Text("Templates Content")
                case .exportOptions:
                    Text("Export Options Content")
                case .helpAndSettings:
                    Text("Help & Settings Content")
                }
            } else {
                Text("Select a menu option")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(selectedMenu?.rawValue ?? "Detail")
    }
}
