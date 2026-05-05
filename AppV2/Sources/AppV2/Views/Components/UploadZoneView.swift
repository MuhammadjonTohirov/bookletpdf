import SwiftUI
import BookletCore
import BookletPDFKit

struct UploadZoneView: View {
    let onPickPDF: () -> Void
    var onScanDocument: (() -> Void)? = nil

    init(action: @escaping () -> Void) {
        self.onPickPDF = action
        self.onScanDocument = nil
    }

    init(onPickPDF: @escaping () -> Void, onScanDocument: (() -> Void)?) {
        self.onPickPDF = onPickPDF
        self.onScanDocument = onScanDocument
    }

    var body: some View {
        VStack(spacing: 14) {
            pickPDFRow

            if onScanDocument != nil {
                orDivider
                scanRow
            }
        }
        .padding(Theme.Layout.cardPadding)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.container))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.container)
                .strokeBorder(style: StrokeStyle(lineWidth: Theme.Border.thin, dash: [12, 8]))
                .foregroundStyle(Theme.Colors.border)
        }
    }

    private var pickPDFRow: some View {
        Button(action: onPickPDF) {
            UploadActionRow(
                title: "str.tap_to_select_pdf".localize,
                subtitle: "str.tap_to_select_pdf_subtitle".localize,
                systemImage: "doc.badge.arrow.up",
                style: .secondary
            )
        }
        .buttonStyle(.plain)
    }

    private var scanRow: some View {
        Button(action: { onScanDocument?() }) {
            UploadActionRow(
                title: "str.scan_document".localize,
                subtitle: "str.scan_document_subtitle".localize,
                systemImage: "camera.viewfinder",
                style: .primary
            )
        }
        .buttonStyle(.plain)
    }

    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Theme.Colors.border.opacity(Theme.Opacity.half))
                .frame(height: 1)
            Text("str.or".localize)
                .font(Theme.Fonts.badge)
                .foregroundStyle(Theme.Colors.tertiaryText)
            Rectangle()
                .fill(Theme.Colors.border.opacity(Theme.Opacity.half))
                .frame(height: 1)
        }
    }
}

private struct UploadActionRow: View {
    enum Style { case primary, secondary }

    let title: String
    let subtitle: String
    let systemImage: String
    let style: Style

    var body: some View {
        HStack(spacing: 14) {
            iconBadge
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Fonts.cardTitle)
                    .foregroundStyle(titleColor)
                Text(subtitle)
                    .font(Theme.Fonts.cellBody)
                    .foregroundStyle(subtitleColor)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            if style == .primary {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
    }

    private var iconBadge: some View {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
            .fill(iconBadgeFill)
            .frame(width: 56, height: 56)
            .overlay {
                Image(systemName: systemImage)
                    .font(Theme.Fonts.mediumIcon)
                    .foregroundStyle(iconColor)
            }
    }

    private var rowBackground: Color {
        switch style {
        case .primary: return Color.accentColor
        case .secondary: return Theme.Colors.secondaryBackground.opacity(Theme.Opacity.muted)
        }
    }

    private var titleColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return Theme.Colors.primaryText
        }
    }

    private var subtitleColor: Color {
        switch style {
        case .primary: return .white.opacity(0.85)
        case .secondary: return Theme.Colors.secondaryText
        }
    }

    private var iconBadgeFill: Color {
        switch style {
        case .primary: return .white.opacity(0.18)
        case .secondary: return Color.accentColor.opacity(Theme.Opacity.tint)
        }
    }

    private var iconColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return Color.accentColor
        }
    }
}
