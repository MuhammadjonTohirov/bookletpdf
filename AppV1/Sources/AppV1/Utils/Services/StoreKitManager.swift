//
//  StoreKitManager.swift
//  bookletPdf
//
//  Created by applebro on 23/03/26.
//

import Foundation
import StoreKit
import BookletCore

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    static let fourInOneProductID = "uz.tox.bookletPdf.fourinone"

    @Published private(set) var fourInOneProduct: Product?
    @Published private(set) var isFourInOnePurchased = false
    @Published private(set) var isLoading = false

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchaseStatus() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.fourInOneProductID])
            fourInOneProduct = products.first
        } catch {
            Logging.l(tag: "StoreKitManager", "Failed to load products: \(error)")
        }
    }

    func purchase() async throws -> Bool {
        guard let product = fourInOneProduct else { return false }

        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchaseStatus()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchaseStatus()
    }

    private func updatePurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.fourInOneProductID {
                isFourInOnePurchased = true
                return
            }
        }
        isFourInOnePurchased = false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.updatePurchaseStatus()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return String(localized: "str.purchase_verification_failed")
        }
    }
}
