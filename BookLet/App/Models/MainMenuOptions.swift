//
//  MainMenuOptions.swift
//  BookLet
//
//  Created by Muhammadjon Tohirov on 06/01/25.
//

import Foundation

enum MenuOption: String, CaseIterable, Identifiable {
    case home = "Home"
    case projects = "Projects"
    case layoutOptions = "Layout Options"
    case pdfSettings = "PDF Settings"
    case previewAndAdjust = "Preview & Adjust"
    case printing = "Printing"
    case templates = "Templates"
    case exportOptions = "Export Options"
    case helpAndSettings = "Help & Settings"

    var id: String { self.rawValue }
    
    static var standardCases: [MenuOption] {
        [
            .home,
            .projects,
            .pdfSettings
        ]
    }
}
