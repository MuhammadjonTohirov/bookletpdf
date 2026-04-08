//
//  PurchasePromptView.swift
//  bookletPdf
//
//  Created by applebro on 23/03/26.
//

import SwiftUI
import BookletCore
import BookletPDFKit

struct PurchasePromptView: View {
    @ObservedObject var storeManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                header
                heroCard
                copyBlock
                benefitsList
                actionSection
            }
            .padding(Theme.Layout.screenPadding)
        }
        .background(sheetBackground)
        .frame(minWidth: 320, idealWidth: 420, maxWidth: 460)
        .alert(Text("str.error".localize), isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            AnalyticsReporter.logEvent?(AnalyticsEventName.purchaseScreenViewed, nil)
            _ = await storeManager.refreshPurchaseStatus()
        }
        .onChange(of: storeManager.isPro) { _, purchased in
            if purchased { dismiss() }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("str.pro".localize)
                .font(Theme.Fonts.captionBold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.75)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .frame(width: 32, height: 32)
                    .background(Theme.Colors.background, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
                    }
            }
            .buttonStyle(.plain)
        }
    }

    private var heroCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.container)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.18),
                            Theme.Colors.background
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: Theme.CornerRadius.container)
                .stroke(Color.accentColor.opacity(0.18), lineWidth: Theme.Border.thin)

            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 170, height: 170)
                .blur(radius: 10)
                .offset(x: 120, y: -70)

            Circle()
                .fill(Color.accentColor.opacity(0.08))
                .frame(width: 120, height: 120)
                .blur(radius: 8)
                .offset(x: -120, y: 70)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.14))
                        .frame(width: 56, height: 56)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }

                fourUpPreview
            }
            .padding(20)
        }
    }

    private var fourUpPreview: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.background)
                .frame(height: 8)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(Color.accentColor.opacity(0.85))
                        .frame(width: 88, height: 8)
                }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(1...4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.Colors.background)
                        .frame(height: 48)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
                        }
                        .overlay(alignment: .topLeading) {
                            Text(index.description)
                                .font(Theme.Fonts.captionBold)
                                .foregroundStyle(Theme.Colors.secondaryText)
                                .padding(8)
                        }
                }
            }
        }
        .padding(14)
        .background(Theme.Colors.secondaryBackground.opacity(0.85), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.card)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }

    private var copyBlock: some View {
        VStack(spacing: 8) {
            Text("str.upgrade_to_pro_title".localize)
                .font(Theme.Fonts.heroTitle)
                .foregroundStyle(Theme.Colors.primaryText)
                .multilineTextAlignment(.center)

            Text("str.upgrade_to_pro_description".localize)
                .font(Theme.Fonts.bodyMedium)
                .foregroundStyle(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 8)
    }

    private var benefitsList: some View {
        VStack(spacing: 0) {
            benefitRow(icon: "square.grid.2x2.fill", title: "str.pro_benefit_4in1".localize)
            #if os(iOS)
            Divider().padding(.horizontal, Theme.Layout.innerPaddingH)
            benefitRow(icon: "eye.slash.fill", title: "str.pro_benefit_no_ads".localize)
            #endif
            Divider().padding(.horizontal, Theme.Layout.innerPaddingH)
            benefitRow(icon: "doc.text.fill", title: "str.pro_benefit_no_label".localize)
            Divider().padding(.horizontal, Theme.Layout.innerPaddingH)
            benefitRow(icon: "infinity", title: "str.pro_benefit_unlimited".localize)
        }
        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.panel))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.panel)
                .stroke(Theme.Colors.border.opacity(Theme.Opacity.half), lineWidth: Theme.Border.thin)
        }
    }

    private func benefitRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Color.accentColor.opacity(Theme.Opacity.tint))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.accentColor)
                }

            Text(title)
                .font(Theme.Fonts.cellTitle)
                .foregroundStyle(Theme.Colors.primaryText)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.green)
        }
        .padding(.horizontal, Theme.Layout.innerPaddingH)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var actionSection: some View {
        VStack(spacing: 12) {
            if storeManager.fourInOneProduct != nil {
                Button(action: {
                    Task { await purchaseAction() }
                }) {
                    HStack(spacing: 10) {
                        if storeManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14, weight: .semibold))

                            Text("str.upgrade_to_pro".localize)
                                .font(Theme.Fonts.cardTitle)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color.accentColor.opacity(0.85)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button)
                    )
                    .shadow(
                        color: Color.accentColor.opacity(0.22),
                        radius: Theme.Shadows.medium.radius,
                        y: Theme.Shadows.medium.y
                    )
                }
                .buttonStyle(.plain)
                .disabled(storeManager.isLoading || storeManager.isRestoring)
            } else if storeManager.productLoadFailed {
                Button(action: {
                    Task { await storeManager.loadProducts() }
                }) {
                    Text("str.retry".localize)
                        .font(Theme.Fonts.cardTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(Theme.Colors.primaryText)
                        .background(Theme.Colors.background, in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
                        .overlay {
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.button)
                                .stroke(Theme.Colors.border.opacity(Theme.Opacity.visible), lineWidth: Theme.Border.thin)
                        }
                }
                .buttonStyle(.plain)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }

            Button(action: {
                Task { await restoreAction() }
            }) {
                HStack(spacing: 8) {
                    if storeManager.isRestoring {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .semibold))
                    }

                    Text("str.restore_purchases".localize)
                        .font(Theme.Fonts.bodyMedium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(Color.accentColor)
                .background(Color.accentColor.opacity(Theme.Opacity.tint), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.button))
            }
            .buttonStyle(.plain)
            .disabled(storeManager.isLoading || storeManager.isRestoring)
        }
    }

    private var sheetBackground: some View {
        LinearGradient(
            colors: [
                Theme.Colors.secondaryBackground.opacity(0.95),
                Theme.Colors.background
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func purchaseAction() async {
        do {
            _ = try await storeManager.purchase()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func restoreAction() async {
        do {
            _ = try await storeManager.restorePurchases()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    PurchasePromptView(storeManager: .shared)
}
