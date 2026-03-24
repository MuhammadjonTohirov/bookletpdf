//
//  PurchasePromptView.swift
//  bookletPdf
//
//  Created by applebro on 23/03/26.
//

import SwiftUI

struct PurchasePromptView: View {
    @ObservedObject var storeManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)

            Text("str.unlock_4in1_title")
                .font(.title2.bold())

            Text("str.unlock_4in1_description")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let product = storeManager.fourInOneProduct {
                Button(action: {
                    Task { await purchaseAction() }
                }) {
                    if storeManager.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("\(String(localized: "str.purchase_for")) \(product.displayPrice)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(storeManager.isLoading || storeManager.isRestoring)
            } else if storeManager.productLoadFailed {
                Button(action: {
                    Task { await storeManager.loadProducts() }
                }) {
                    Text("str.retry")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } else {
                ProgressView()
            }

            Button(action: {
                Task { await storeManager.restorePurchases() }
            }) {
                if storeManager.isRestoring {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("str.restore_purchases")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            .buttonStyle(.plain)
            .disabled(storeManager.isLoading || storeManager.isRestoring)
        }
        .padding(32)
        .frame(minWidth: 300, maxWidth: 400)
        .alert(Text("str.error"), isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onChange(of: storeManager.isFourInOnePurchased) { _, purchased in
            if purchased { dismiss() }
        }
    }

    private func purchaseAction() async {
        do {
            _ = try await storeManager.purchase()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
