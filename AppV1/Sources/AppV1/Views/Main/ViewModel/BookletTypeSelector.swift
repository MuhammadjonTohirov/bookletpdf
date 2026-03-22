//
//  BookletTypeSelector.swift
//  bookletPdf
//
//  Created by applebro on 11/05/25.
//

import SwiftUI
import BookletPDFKit
import BookletCore

struct BookletTypeSelector: View {
    @Binding var selectedType: BookletType
    @ObservedObject var storeManager: StoreKitManager
    var onLockedTap: () -> Void

    private var isFourInOneLocked: Bool {
        !storeManager.isFourInOnePurchased
    }

    var body: some View {
#if os(iOS)
        iOSPickerStyle
#else
        macOSPickerStyle
#endif
    }

    private var macOSPickerStyle: some View {
        HStack(spacing: 4) {
            Picker("str.booklet_type", selection: $selectedType) {
                Text("str.pages_per_sheet_2").tag(BookletType.type2)
                Label {
                    Text("str.pages_per_sheet_4")
                } icon: {
                    if isFourInOneLocked {
                        Image(systemName: "lock.fill")
                    }
                }
                .tag(BookletType.type4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .help(Text("str.pages_arrangement_help"))
            .onChange(of: selectedType) { _, newValue in
                if newValue == .type4 && isFourInOneLocked {
                    selectedType = .type2
                    onLockedTap()
                }
            }
        }
    }

    private var iOSPickerStyle: some View {
        Menu {
            Button(action: { selectedType = .type2 }) {
                HStack {
                    Text("str.pages_per_sheet_2")
                    if selectedType == .type2 {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Button(action: {
                if isFourInOneLocked {
                    onLockedTap()
                } else {
                    selectedType = .type4
                }
            }) {
                HStack {
                    Text("str.pages_per_sheet_4")
                    if isFourInOneLocked {
                        Image(systemName: "lock.fill")
                    } else if selectedType == .type4 {
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedType == .type2 ? "str.pages_2" : "str.pages_4")
                    .font(.system(size: 14))

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
