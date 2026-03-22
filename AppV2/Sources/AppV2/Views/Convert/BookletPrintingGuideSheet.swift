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

    @ViewBuilder
    private var printingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch type {
            case .type2:
                numberedStep(1, text: "str.help_print2_step1")
                numberedStep(2, text: "str.help_print2_step2")
                numberedStep(3, text: "str.help_print2_step3")
                numberedStep(4, text: "str.help_print2_step4")

                bulletGroup {
                    bulletItem("str.help_print2_step4a")
                    bulletItem("str.help_print2_step4b")
                }

                subsectionHeader("str.help_print2_manual_title")

                numberedStep(5, text: "str.help_print2_step5")

                bulletGroup {
                    bulletItem("str.help_print2_step5a")
                    bulletItem("str.help_print2_step5b")
                }

                numberedStep(6, text: "str.help_print2_step6")

                bulletGroup {
                    bulletItem("str.help_print2_step6a")
                    bulletItem("str.help_print2_step6b")
                    bulletItem("str.help_print2_step6c")
                    bulletItem("str.help_print2_step6d")
                }
            case .type4:
                numberedStep(1, text: "str.help_print4_step1")
                numberedStep(2, text: "str.help_print4_step2")
                numberedStep(3, text: "str.help_print4_step3")
                numberedStep(4, text: "str.help_print4_step4")

                bulletGroup {
                    bulletItem("str.help_print4_step4a")
                    bulletItem("str.help_print4_step4b")
                }

                subsectionHeader("str.help_print4_manual_title")

                numberedStep(5, text: "str.help_print4_step5")

                bulletGroup {
                    bulletItem("str.help_print4_manual_a")
                    bulletItem("str.help_print4_manual_b")
                    bulletItem("str.help_print4_manual_c")
                    bulletItem("str.help_print4_manual_d")
                }

                numberedStep(6, text: "str.help_print4_step6")

                bulletGroup {
                    bulletItem("str.help_print4_step6a")
                    bulletItem("str.help_print4_step6b")
                    bulletItem("str.help_print4_step6c")
                    bulletItem("str.help_print4_step6d")
                }

                numberedStep(7, text: "str.help_print4_step7")
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

    private func subsectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(Theme.Fonts.bodyMedium)
            .foregroundStyle(Theme.Colors.primaryText)
            .padding(.top, 2)
    }

    private func numberedStep(_ number: Int, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(Theme.Fonts.captionBold)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24, height: 24)
                .background(Color.accentColor.opacity(Theme.Opacity.tint), in: Circle())

            Text(text)
                .font(Theme.Fonts.subtitle)
                .foregroundStyle(Theme.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func bulletGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            content()
        }
        .padding(.leading, 36)
    }

    private func bulletItem(_ key: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Theme.Colors.tertiaryText)
                .frame(width: 5, height: 5)
                .padding(.top, 6)

            Text(key)
                .font(Theme.Fonts.subtitle)
                .foregroundStyle(Theme.Colors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
