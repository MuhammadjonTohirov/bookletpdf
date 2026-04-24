import SwiftUI
import BookletCore
import PDFKit
import BookletPDFKit

struct ExportView: View {
    @EnvironmentObject private var viewModel: DocumentConvertViewModel
    @State private var showPreview = false
    @State private var showHelp = false
    #if os(iOS)
    @State private var showPrintAssistant = false
    #endif

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Layout.sectionSpacing) {
                successHero
                fileDetailsSection
                actionButtonsSection
                helpButton
                finishButton
            }
            .padding(Theme.Layout.screenPadding)
        }
        .background(Theme.Colors.secondaryBackground.opacity(Theme.Opacity.faded))
        #if os(iOS)
        .navigationTitle(Text("str.booklet_ready".localize))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        #endif
        .sheet(isPresented: $showPreview) {
            if let doc = viewModel.document?.document {
                PDFPreviewSheet(document: doc, fileName: viewModel.convertedFileName)
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showPrintAssistant) {
            IOSPrintAssistantSheet {
                try await viewModel.prepareSplitBookletPDFs()
            }
        }
        #endif
        .alert(Text("str.rate_app_title".localize), isPresented: $viewModel.showRateAppAlert) {
            Button("str.rate_now".localize) {
                RateAppService.requestReview()
            }
            Button("str.no_thanks".localize, role: .cancel) { }
        } message: {
            Text("str.rate_app_message".localize)
        }
        .sheet(isPresented: $showHelp) {
            #if os(iOS)
            NavigationStack {
                HelpView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("str.close".localize) {
                                showHelp = false
                            }
                        }
                    }
            }
            #else
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("str.close".localize) {
                        showHelp = false
                    }
                }
                .padding()
                Divider()
                HelpView()
            }
            .frame(minWidth: 600, minHeight: 500)
            #endif
        }
    }

    private var successHero: some View {
        VStack(spacing: Theme.Layout.itemSpacing) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.08))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.green)
            }

            Text("str.booklet_ready".localize)
                .font(Theme.Fonts.heroTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            Text("str.booklet_ready_subtitle".localize)
                .font(Theme.Fonts.cellBody)
                .foregroundStyle(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Layout.innerPaddingH)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
    }

    private var fileDetailsSection: some View {
        HStack(spacing: Theme.Layout.itemSpacing) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.icon)
                .fill(Color.accentColor.opacity(Theme.Opacity.tint))
                .frame(width: Theme.Layout.iconSize, height: Theme.Layout.iconSize)
                .overlay {
                    Image(systemName: "doc.text")
                        .font(Theme.Fonts.smallIcon)
                        .foregroundStyle(Color.accentColor)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.convertedFileName)
                    .font(Theme.Fonts.cellTitle)
                    .foregroundStyle(Theme.Colors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 6) {
                    Text(viewModel.convertedFileSize)
                    Text("\u{2022}")
                    Text("str.pdf_document".localize)
                }
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.Colors.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.Layout.innerPaddingH)
        .padding(.vertical, Theme.Layout.innerPaddingV)
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.section))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.section)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }

    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button(action: { showPreview = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "eye")
                    Text("str.preview".localize)
                }
                .font(Theme.Fonts.bodyBold)
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(Theme.Colors.primaryText)
                .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.panel)
                        .stroke(Theme.Colors.border.opacity(Theme.Opacity.muted), lineWidth: Theme.Border.thin)
                }
            }
            .buttonStyle(.plain)

            Button(action: printDocument) {
                HStack(spacing: 8) {
                    Image(systemName: "printer")
                    Text("str.print".localize)
                }
                .font(Theme.Fonts.bodyBold)
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(Theme.Colors.primaryText)
                .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.panel)
                        .stroke(Theme.Colors.border.opacity(Theme.Opacity.muted), lineWidth: Theme.Border.thin)
                }
            }
            .buttonStyle(.plain)

            Button(action: {
                viewModel.showFileExporter = true
                AnalyticsReporter.logEvent?(AnalyticsEventName.exportCompleted, nil)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("str.share_pdf".localize)
                }
                .font(Theme.Fonts.bodyBold)
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(.white)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
            }
            .buttonStyle(.plain)
        }
    }

    private func printDocument() {
        #if os(macOS)
        guard let document = viewModel.document?.document,
              let window = NSApp.keyWindow else { return }

        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = true

        guard let printOp = document.printOperation(for: printInfo, scalingMode: .pageScaleToFit, autoRotate: true) else { return }
        printOp.showsPrintPanel = true
        printOp.showsProgressPanel = true
        printOp.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
        #elseif os(iOS)
        // 2-up on iOS is routed through the guided two-step assistant because
        // `UIPrintInteractionController` cannot filter odd/even sheets. 4-up
        // falls back to a single print job (backs aren't required).
        if viewModel.bookletType == .type2 {
            showPrintAssistant = true
        } else if let url = viewModel.pdfUrl {
            let _ = PrinterService.shared.printDocument(url: url)
        }
        #endif
    }

    private var helpButton: some View {
        Button(action: { showHelp = true }) {
            HStack(spacing: 12) {
                Image(systemName: "questionmark.circle")
                    .font(Theme.Fonts.smallIcon)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text("str.need_help_printing".localize)
                        .font(Theme.Fonts.cellTitle)
                        .foregroundStyle(Theme.Colors.primaryText)

                    Text("str.view_printing_instructions".localize)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.Colors.secondaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.Colors.tertiaryText)
            }
            .padding(Theme.Layout.innerPaddingH)
            .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.panel)
                    .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
            }
        }
        .buttonStyle(.plain)
    }

    private var finishButton: some View {
        Button(action: { viewModel.clearDocuments() }) {
            Text("str.finish_return_home".localize)
                .font(Theme.Fonts.cardTitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Layout.buttonPaddingV)
                .foregroundStyle(Theme.Colors.primaryText)
                .background(Theme.Colors.tertiaryBackground, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
        }
        .buttonStyle(.plain)
    }
}
