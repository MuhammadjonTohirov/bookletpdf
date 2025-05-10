//
//  BooketUtils.swift
//  bookletPdf
//
//  Created by applebro on 14/10/23.
//

import Foundation

public enum BookletType {
    case type2        // 2 pages per sheet (traditional booklet)
    case type4Grid    // 4 pages per sheet in grid layout (not booklet)
    case type4Booklet // 4 pages per sheet arranged for booklet folding
}
