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

    var isPro: Bool {
        #if DEBUG
        return debugIsPro ?? isFourInOnePurchased
        #else
        return isFourInOnePurchased
        #endif
    }

    #if DEBUG
    /// Set to `false` to force free tier in debug builds, `nil` to use real purchase status
    var debugIsPro: Bool? = false
    #endif
    @Published private(set) var isLoading = false
    @Published private(set) var isRestoring = false
    @Published private(set) var productLoadFailed = false

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await refreshStoreState() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        productLoadFailed = false
        do {
            let products = try await Product.products(for: [Self.fourInOneProductID])
            fourInOneProduct = products.first
            if fourInOneProduct == nil {
                productLoadFailed = true
                Logging.l(tag: "StoreKitManager", "Product not found for ID: \(Self.fourInOneProductID)")
            }
        } catch {
            productLoadFailed = true
            Logging.l(tag: "StoreKitManager", "Failed to load products: \(error)")
        }
    }

    func refreshStoreState() async {
        if fourInOneProduct == nil || productLoadFailed {
            await loadProducts()
        }

        _ = await refreshPurchaseStatus()
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
            AnalyticsReporter.logEvent?(AnalyticsEventName.purchaseCompleted, [AnalyticsParamKey.productID: product.id])
            return await refreshPurchaseStatus()
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async throws -> Bool {
        isRestoring = true
        defer { isRestoring = false }

        Logging.l(tag: "StoreKitManager", "Starting restore flow")
        try await AppStore.sync()

        let restored = await refreshPurchaseStatus()
        Logging.l(tag: "StoreKitManager", "Restore flow finished. Restored entitlement: \(restored)")
        if restored {
            AnalyticsReporter.logEvent?(AnalyticsEventName.purchaseRestored, nil)
            return true
        }

        throw StoreError.nothingToRestore
    }

    func refreshPurchaseStatus() async -> Bool {
        let isPurchased = await hasActiveEntitlement()
        isFourInOnePurchased = isPurchased

        Logging.l(
            tag: "StoreKitManager",
            "4-in-1 entitlement status updated. Purchased: \(isPurchased)"
        )

        return isPurchased
    }

    private func hasActiveEntitlement() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.fourInOneProductID,
               isActive(transaction) {
                return true
            }
        }

        if let latest = await Transaction.latest(for: Self.fourInOneProductID),
           case .verified(let transaction) = latest,
           isActive(transaction) {
            return true
        }

        return false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self?.refreshPurchaseStatus()
                    await transaction.finish()
                }
            }
        }
    }

    private func isActive(_ transaction: Transaction) -> Bool {
        transaction.revocationDate == nil
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
    case nothingToRestore

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "str.purchase_verification_failed".localize
        case .nothingToRestore:
            return "No previous 4-in-1 purchase was found for this Apple Account."
        }
    }
}
