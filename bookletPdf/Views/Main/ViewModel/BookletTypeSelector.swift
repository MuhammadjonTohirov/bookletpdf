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
        Picker("Booklet Type", selection: $selectedType) {
            Text("2 pages per sheet").tag(BookletType.type2)
            Text("4 pages per sheet").tag(BookletType.type4)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .help("Select how many pages to arrange per sheet")
    }
    
    private var iOSPickerStyle: some View {
        Menu {
            Button(action: { selectedType = .type2 }) {
                HStack {
                    Text("2 pages per sheet")
                    if selectedType == .type2 {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Button(action: { selectedType = .type4 }) {
                HStack {
                    Text("4 pages per sheet")
                    if selectedType == .type4 {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack {
                // Show the currently selected option
                Text(selectedType == .type2 ? "2 pages" : "4 pages")
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
