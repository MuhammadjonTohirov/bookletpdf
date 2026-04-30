import SwiftUI
import BookletPDFKit

struct BookletPrintingGuideSheet: View {
    let type: BookletType
    @Environment(\.dismiss) private var dismiss

    private var title: LocalizedStringKey {
        switch type {
        case .type2: return "str.help_print_2in1_title"
        case .type4: return "str.help_print_4in1_title"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                    printingCard
                }
                .padding(Theme.Layout.screenPadding)
            }
            .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("str.close") {
                        dismiss()
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 560, minHeight: 480)
        #endif
    }

    private var printingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(type.printingSteps.enumerated()), id: \.offset) { pair in
                numberedStep(pair.offset + 1, key: pair.element)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Layout.innerPaddingH)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }

    private func numberedStep(_ number: Int, key: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(Theme.Fonts.captionBold)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24, height: 24)
                .background(Color.accentColor.opacity(Theme.Opacity.tint), in: Circle())

            Text(LocalizedStringKey(key))
                .font(Theme.Fonts.subtitle)
                .foregroundStyle(Theme.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

