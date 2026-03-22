import SwiftUI
import BookletPDFKit

#if os(macOS)
enum SidebarItem: String, Identifiable, CaseIterable {
    case converter
    case history
    case help
    case settings

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .converter: return "str.converter"
        case .history: return "str.history"
        case .help: return "str.help"
        case .settings: return "str.settings"
        }
    }

    var icon: String {
        switch self {
        case .converter: return "doc.viewfinder"
        case .history: return "clock.arrow.circlepath"
        case .help: return "questionmark.circle"
        case .settings: return "gear"
        }
    }

    static var mainItems: [SidebarItem] { [.converter, .history, .help] }
    static var settingsItems: [SidebarItem] { [.settings] }
}

struct SidebarView: View {
    @Binding var selectedItem: SidebarItem?
    @State private var hoverItem: SidebarItem?

    var body: some View {
        VStack(spacing: 0) {
            // App Header
            HStack {
                Image("img_logo_white")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("Booklet PDF")
                    .font(.headline)
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)

            // Menu Items
            VStack(spacing: Theme.Spacing.sm) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("str.main")
                        .sectionHeader()

                    ForEach(SidebarItem.mainItems) { item in
                        sidebarButton(item)
                    }
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("str.settings")
                        .sectionHeader()

                    ForEach(SidebarItem.settingsItems) { item in
                        sidebarButton(item)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.lg)

            Spacer()

            VStack(spacing: Theme.Spacing.xs) {
                Rectangle()
                    .fill(Theme.Colors.divider)
                    .frame(height: 0.5)
                    .padding(.horizontal, Theme.Spacing.md)

                Text("str.powered_by")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.tertiaryText)
                    .padding(.vertical, Theme.Spacing.sm)
            }
        }
        .frame(minWidth: 240)
        .background(Theme.Colors.background)
    }

    private func sidebarButton(_ item: SidebarItem) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedItem = item
            }
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
                    .frame(width: 24, height: 24)

                Text(item.title)
                    .font(.body)

                Spacer()

                if selectedItem == item {
                    Circle()
                        .fill(Theme.Colors.primary)
                        .frame(width: 4, height: 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .fill(
                        selectedItem == item
                            ? Theme.Colors.primary.opacity(0.1)
                            : (hoverItem == item ? Theme.Colors.secondaryBackground.opacity(0.5) : Color.clear)
                    )
            )
            .scaleEffect(hoverItem == item ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: hoverItem)
            .animation(.easeInOut(duration: 0.2), value: selectedItem)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                hoverItem = hovering ? item : nil
            }
        }
    }
}
#endif
