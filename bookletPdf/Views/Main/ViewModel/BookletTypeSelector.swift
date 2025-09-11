//
//  BookletTypeSelector.swift
//  bookletPdf
//
//  Created by applebro on 11/05/25.
//
// First, let's add a BookletTypeSelector component
// This will be a new Swift file: bookletPdf/Views/Main/BookletTypeSelector.swift

import SwiftUI
import BookletPDFKit
import BookletCore

struct BookletTypeSelector: View {
    @Binding var selectedType: BookletType
    
    var body: some View {
#if os(iOS)
        iOSPickerStyle
#else
        macOSPickerStyle
#endif
    }
    
    private var macOSPickerStyle: some View {
        Picker("str.booklet_type".localize, selection: $selectedType) {
            Text("str.pages_per_sheet_2".localize).tag(BookletType.type2)
            Text("str.pages_per_sheet_4".localize).tag(BookletType.type4)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .help("str.pages_arrangement_help".localize)
    }
    
    private var iOSPickerStyle: some View {
        Menu {
            Button(action: { selectedType = .type2 }) {
                HStack {
                    Text("str.pages_per_sheet_2".localize)
                    if selectedType == .type2 {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button(action: { selectedType = .type4 }) {
                HStack {
                    Text("str.pages_per_sheet_4".localize)
                    if selectedType == .type4 {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack {
                // Show the currently selected option
                Text(selectedType == .type2 ? "str.pages_2".localize : "str.pages_4".localize)
                    .font(.system(size: 14))
                
                // Use a more appropriate icon for format selection
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color.gray.opacity(0.1).cornerRadius(6))
            )
        }
    }
}
