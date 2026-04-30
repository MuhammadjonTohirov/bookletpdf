import SwiftUI
import BookletCore
import BookletPDFKit

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Layout.sectionSpacing) {
                aboutSection
                featuresSection
                howToUseSection
                printingSection2in1
                printingSection4in1
                tipsSection
                footerSection
            }
            .padding(Theme.Layout.screenPadding)
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        #if os(iOS)
        .navigationTitle(Text("str.help".localize))
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - About

    private var aboutSection: some View {
        helpCard {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("str.help_about_title")

                Text("str.help_about_body".localize)
                    .font(Theme.Fonts.subtitle)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        helpCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("str.help_features_title")

                featureRow(icon: "rectangle.split.2x1", title: "str.help_feature_2in1_title", desc: "str.help_feature_2in1_desc")
                featureRow(icon: "rectangle.split.2x2", title: "str.help_feature_4in1_title", desc: "str.help_feature_4in1_desc")
                featureRow(icon: "slider.horizontal.3", title: "str.help_feature_simple_title", desc: "str.help_feature_simple_desc")
                featureRow(icon: "eye", title: "str.help_feature_preview_title", desc: "str.help_feature_preview_desc")
                featureRow(icon: "printer", title: "str.help_feature_print_title", desc: "str.help_feature_print_desc")
            }
        }
    }

    // MARK: - How to Use

    private var howToUseSection: some View {
        helpCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("str.help_howto_title")

                Text("str.help_howto_generate_title".localize)
                    .font(Theme.Fonts.cellTitle)
                    .foregroundStyle(Theme.Colors.primaryText)

                numberedStep(1, text: "str.help_generate_step1")
                numberedStep(2, text: "str.help_generate_step2")
                numberedStep(3, text: "str.help_generate_step3")
                numberedStep(4, text: "str.help_generate_step4")
                numberedStep(5, text: "str.help_generate_step5")
                numberedStep(6, text: "str.help_generate_step6")
            }
        }
    }

    // MARK: - Printing 2-in-1

    private var printingSection2in1: some View {
        printingSection(title: "str.help_print_2in1_title", type: .type2)
    }

    // MARK: - Printing 4-in-1

    private var printingSection4in1: some View {
        printingSection(title: "str.help_print_4in1_title", type: .type4)
    }

    private func printingSection(title: LocalizedStringKey, type: BookletType) -> some View {
        helpCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(title)

                ForEach(Array(type.printingSteps.enumerated()), id: \.offset) { pair in
                    numberedStep(pair.offset + 1, text: LocalizedStringKey(pair.element))
                }
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        helpCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("str.help_tips_title")

                bulletItem("str.help_tip_1")
                bulletItem("str.help_tip_2")
                bulletItem("str.help_tip_3")
                bulletItem("str.help_tip_4")
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        Text("str.help_footer".localize)
            .font(Theme.Fonts.subtitle)
            .italic()
            .foregroundStyle(Theme.Colors.tertiaryText)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    // MARK: - Reusable Components

    private func helpCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Layout.innerPaddingH)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        HStack(spacing: 10) {
            Text(key)
                .font(Theme.Fonts.cardTitle)
                .foregroundStyle(Theme.Colors.primaryText)
        }
        .padding(.bottom, 4)
    }

    private func featureRow(icon: String, title: LocalizedStringKey, desc: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.opacity(Theme.Opacity.tint), in: RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Fonts.cellTitle)
                    .foregroundStyle(Theme.Colors.primaryText)
                Text(desc)
                    .font(Theme.Fonts.subtitle)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func numberedStep(_ number: Int, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(verbatim: number.description)
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
