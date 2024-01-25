//
//  PurchaseManager.swift
//  Master Task
//
//  Created by Artur Korol on 04.10.2023.
//

import SwiftUI
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @AppStorage("SelectedSubscriptionID") var selectedSubscriptionID = ""
    private let productsID = ["master_task_monthly", "master_task_yearly"]
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    
    var hasUnlockedPro: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    func loadProducts() async throws {
        guard !productsLoaded else { return }
        
        self.products = try await Product.products(for: productsID)
        self.productsLoaded = true
    }
    
    func userSelectSubscription(product: Product) {
        Task {
            do {
                try await purchase(product)
            } catch {
                print(error)
            }
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
                selectedSubscriptionID = ""
            }
        }
    }
    
    func restore() async -> Bool {
        return ((try? await AppStore.sync()) != nil)
    }
}

private extension PurchaseManager {
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
    
    private func purchase(_ product: Product) async throws {
        Task {
            let result = try await product.purchase()
            
            switch result {
            case .success(.verified(let transaction)):
                await transaction.finish()
                await updatePurchasedProducts()
                self.selectedSubscriptionID = product.id 
            case .success(.unverified(_, let error)):
                print(error.localizedDescription)
                break
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        }
    }
}
