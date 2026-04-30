#if os(iOS)
import SwiftUI
import BookletCore
import BookletPDFKit

struct IOSPrintAssistantSheet: View {
    enum Step: Int, CaseIterable {
        case front = 0
        case back = 1
        case done = 2
    }

    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .front
    @State private var isPrinting = false
    @State private var split: SplitBookletPDFs?
    @State private var loadError: String?

    let bookletType: BookletType
    let prepareSplit: () async throws -> SplitBookletPDFs

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator
                    .padding(.top, Theme.Layout.screenPadding)
                    .padding(.horizontal, Theme.Layout.screenPadding)

                Spacer(minLength: 24)

                contentCard
                    .padding(.horizontal, Theme.Layout.screenPadding)

                Spacer(minLength: 24)

                actionSection
                    .padding(.horizontal, Theme.Layout.screenPadding)
                    .padding(.bottom, Theme.Layout.screenPadding)
            }
            .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
            .navigationTitle(Text("str.print_assistant_title".localize))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("str.close".localize) { dismiss() }
                        .disabled(isPrinting)
                }
            }
        }
        .interactiveDismissDisabled(isPrinting)
        .task {
            await loadSplitIfNeeded()
        }
        .alert(
            Text("str.print_assistant_error_title".localize),
            isPresented: Binding(
                get: { loadError != nil },
                set: { if !$0 { loadError = nil } }
            )
        ) {
            Button("str.close".localize, role: .cancel) { dismiss() }
        } message: {
            Text(loadError ?? "")
        }
    }

    // MARK: - Step indicator

    private var stepIndicator: some View {
        HStack(spacing: 10) {
            indicatorDot(for: .front, label: "1")
            connector(reached: step.rawValue >= 1)
            indicatorDot(for: .back, label: "2")
            connector(reached: step.rawValue >= 2)
            indicatorDot(for: .done, label: nil)
        }
        .frame(maxWidth: .infinity)
    }

    private func indicatorDot(for target: Step, label: String?) -> some View {
        let isComplete = step.rawValue > target.rawValue
        let isActive = step == target

        let fillColor: Color = {
            if isComplete { return Color.accentColor }
            if isActive { return Color.accentColor.opacity(Theme.Opacity.tint) }
            return Theme.Colors.tertiaryBackground
        }()

        let strokeColor: Color = isActive
            ? Color.accentColor
            : Theme.Colors.border.opacity(Theme.Opacity.half)

        return ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(strokeColor, lineWidth: isActive ? 2 : 1))

            if isComplete || target == .done {
                Image(systemName: isComplete ? "checkmark" : "flag.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isComplete ? .white : Theme.Colors.tertiaryText)
            } else if let label {
                Text(label)
                    .font(Theme.Fonts.captionBold)
                    .foregroundStyle(isActive ? Color.accentColor : Theme.Colors.secondaryText)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)
    }

    private func connector(reached: Bool) -> some View {
        Capsule()
            .fill(reached ? Color.accentColor : Theme.Colors.border.opacity(Theme.Opacity.half))
            .frame(height: 3)
            .frame(maxWidth: 60)
            .animation(.easeInOut(duration: 0.3), value: reached)
    }

    // MARK: - Content

    private var contentCard: some View {
        VStack(spacing: 20) {
            illustration
            VStack(spacing: 10) {
                Text(LocalizedStringKey(titleKey))
                    .font(Theme.Fonts.heroTitle)
                    .foregroundStyle(Theme.Colors.primaryText)
                    .multilineTextAlignment(.center)

                Text(LocalizedStringKey(bodyKey))
                    .font(Theme.Fonts.bodyMedium)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }

            if step == .back {
                flipHint
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, Theme.Layout.innerPaddingH)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
        .id(step)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(step == .done ? Color.green.opacity(Theme.Opacity.tint) : Color.accentColor.opacity(Theme.Opacity.tint))
                .frame(width: 112, height: 112)

            Image(systemName: iconName)
                .font(.system(size: 52, weight: .regular))
                .foregroundStyle(step == .done ? Color.green : Color.accentColor)
        }
    }

    private var flipHint: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.accentColor)

            Text(flipHintKey.localize)
                .font(Theme.Fonts.subtitle)
                .foregroundStyle(Theme.Colors.primaryText)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.accentColor.opacity(Theme.Opacity.tint), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }

    // MARK: - Strings

    private var titleKey: String {
        switch step {
        case .front: return "str.print_assistant_front_title"
        case .back: return "str.print_assistant_back_title"
        case .done: return "str.print_assistant_done_title"
        }
    }

    private var bodyKey: String {
        switch step {
        case .front: return "str.print_assistant_front_body"
        case .back:
            switch bookletType {
            case .type2: return "str.print_assistant_back_body_2in1"
            case .type4: return "str.print_assistant_back_body_4in1"
            }
        case .done:
            switch bookletType {
            case .type2: return "str.print_assistant_done_body"
            case .type4: return "str.print_assistant_done_body_4in1"
            }
        }
    }

    private var flipHintKey: String {
        switch bookletType {
        case .type2: return "str.print_assistant_flip_hint_2in1"
        case .type4: return "str.print_assistant_flip_hint_4in1"
        }
    }

    private var iconName: String {
        switch step {
        case .front: return "doc.text"
        case .back: return "arrow.triangle.2.circlepath"
        case .done: return "checkmark.seal.fill"
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionSection: some View {
        VStack(spacing: 10) {
            Button(action: handlePrimary) {
                HStack(spacing: 10) {
                    if isPrinting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: primaryIcon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(LocalizedStringKey(primaryKey))
                }
                .font(Theme.Fonts.cardTitle)
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundStyle(.white)
                .background(
                    (step == .done ? Color.green : Color.accentColor),
                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button)
                )
                .opacity(isPrinting || split == nil ? 0.6 : 1)
            }
            .buttonStyle(.plain)
            .disabled(isPrinting || split == nil)

            if step != .done {
                Button(action: { dismiss() }) {
                    Text("str.print_assistant_not_now".localize)
                        .font(Theme.Fonts.bodyMedium)
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
                .disabled(isPrinting)
            }
        }
    }

    private var primaryIcon: String {
        switch step {
        case .front, .back: return "printer.fill"
        case .done: return "checkmark"
        }
    }

    private var primaryKey: String {
        switch step {
        case .front: return "str.print_assistant_print_front"
        case .back: return "str.print_assistant_print_back"
        case .done: return "str.print_assistant_done_button"
        }
    }

    private func handlePrimary() {
        switch step {
        case .front:
            guard let url = split?.front else { return }
            Task { await runPrint(url: url, advanceTo: .back) }
        case .back:
            guard let url = split?.back else { return }
            Task { await runPrint(url: url, advanceTo: .done) }
        case .done:
            dismiss()
        }
    }

    // MARK: - Print execution

    private func runPrint(url: URL, advanceTo next: Step) async {
        isPrinting = true
        let completed = await PrinterService.shared.printDocumentAwaitingCompletion(url: url)
        isPrinting = false
        guard completed else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            step = next
        }
    }

    // MARK: - Loading

    private func loadSplitIfNeeded() async {
        guard split == nil else { return }
        do {
            split = try await prepareSplit()
        } catch {
            loadError = error.localizedDescription
        }
    }
}
#endif
