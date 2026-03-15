import Combine
import Foundation
import StoreKit

@MainActor
final class PurchaseStore: ObservableObject {
    static let lifetimeProductID = "com.snake.PortraitCutout.lifetime"

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published var noticeMessage: String?
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?
    private var prepared = false

    init() {
        updatesTask = observeTransactionUpdates()
    }

    deinit {
        updatesTask?.cancel()
    }

    var lifetimeProduct: Product? {
        products.first(where: { $0.id == Self.lifetimeProductID })
    }

    var hasLifetimeAccess: Bool {
        purchasedProductIDs.contains(Self.lifetimeProductID)
    }

    var currentTierTitle: String {
        hasLifetimeAccess
            ? NSLocalizedString("purchase.tier.lifetime", comment: "")
            : NSLocalizedString("purchase.tier.free", comment: "")
    }

    var unlockModelTitle: String {
        hasLifetimeAccess
            ? NSLocalizedString("purchase.model.unlocked", comment: "")
            : NSLocalizedString("purchase.model.buy_once", comment: "")
    }

    var lifetimePriceText: String {
        lifetimeProduct?.displayPrice ?? "$3.99"
    }

    func prepare() async {
        guard !prepared else {
            return
        }
        prepared = true
        await refreshStoreState()
    }

    func refreshStoreState() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            products = try await Product.products(for: [Self.lifetimeProductID])
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchaseLifetime() async {
        guard !hasLifetimeAccess else {
            noticeMessage = NSLocalizedString("purchase.notice.already_unlocked", comment: "")
            return
        }

        if lifetimeProduct == nil {
            await refreshStoreState()
        }

        guard let product = lifetimeProduct else {
            errorMessage = NSLocalizedString("purchase.error.product_load_failed", comment: "")
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await apply(transaction: transaction)
                await transaction.finish()
                noticeMessage = NSLocalizedString("purchase.notice.unlocked", comment: "")
            case .userCancelled:
                noticeMessage = NSLocalizedString("purchase.notice.cancelled", comment: "")
            case .pending:
                noticeMessage = NSLocalizedString("purchase.notice.pending", comment: "")
            @unknown default:
                noticeMessage = NSLocalizedString("purchase.notice.updated", comment: "")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            noticeMessage = hasLifetimeAccess
                ? NSLocalizedString("purchase.notice.restored", comment: "")
                : NSLocalizedString("purchase.notice.not_found", comment: "")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshEntitlements() async {
        var activeProducts: Set<String> = []

        for await entitlement in Transaction.currentEntitlements {
            guard let transaction = try? Self.checkVerified(entitlement) else {
                continue
            }

            if transaction.revocationDate == nil {
                activeProducts.insert(transaction.productID)
            }
        }

        purchasedProductIDs = activeProducts
    }

    private func apply(transaction: Transaction) async {
        if transaction.revocationDate == nil {
            purchasedProductIDs.insert(transaction.productID)
        } else {
            purchasedProductIDs.remove(transaction.productID)
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                guard let self else {
                    break
                }

                guard let transaction = try? Self.checkVerified(update) else {
                    continue
                }

                await self.apply(transaction: transaction)
                await transaction.finish()
            }
        }
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}

private enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return NSLocalizedString("purchase.error.verification_failed", comment: "")
        }
    }
}
