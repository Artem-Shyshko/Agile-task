//
//  PurchaseManager.swift
//  Agile Task
//
//  Created by Artur Korol on 04.10.2023.
//

import SwiftUI
import StoreKit

@MainActor
final class PurchaseManager: NSObject, ObservableObject {
    @Published var selectedSubscriptionID = Constants.shared.freeSubscription
    @Published var showProcessView = false
    private let productsID = [
        Constants.shared.oneTimeSubscriptionID,
        Constants.shared.monthlySubscriptionID,
        Constants.shared.yearlySubscriptionID
    ]
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil
    private let maxFreeProjects = 2
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var activeTransactions = Set<StoreKit.Transaction>()
    
    
    var hasUnlockedPro: Bool {
        if !activeTransactions.isEmpty, let active = activeTransactions.first {
            selectedSubscriptionID = active.productID
        } else {
            selectedSubscriptionID = Constants.shared.freeSubscription
        }
        
        return !activeTransactions.isEmpty
    }
    
    override init() {
        super.init()
        updates = Task {
            for await update in StoreKit.Transaction.updates {
                if let transaction = try? update.payloadValue {
                    await fetchActiveTransactions()
                    await transaction.finish()
                }
            }
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    func canCreateTask(taskCount: Int) -> Bool {
        guard hasUnlockedPro == false else { return  true }
        
        return taskCount >= 3 ? false : true
    }
    
    func canCreateProject(projectCount: Int) -> Bool {
        guard hasUnlockedPro == false else { return  true }
        
        return maxFreeProjects <= projectCount ? false : true
    }
    
    func loadProducts() async throws {
        guard !productsLoaded else { return }
        showProcessView = true
        
        self.products = try await Product.products(for: productsID)
            .sorted(by: { $0.productOrder < $1.productOrder })
        self.productsLoaded = true
        showProcessView = false
    }
    
    func purchase(_ product: Product) async throws {
        showProcessView = true
        let result = try await product.purchase()
        switch result {
        case .success(let verificationResult):
            if let transaction = try? verificationResult.payloadValue {
                activeTransactions.insert(transaction)
                await transaction.finish()
                _ = hasUnlockedPro
                showProcessView = false
            }
        case .userCancelled, .pending:
            showProcessView = false
            break
        @unknown default:
            showProcessView = false
            break
        }
    }
    
    func restore() async -> Bool {
        showProcessView = true
        do {
            try await AppStore.sync()
            await fetchActiveTransactions()
            showProcessView = false
            return activeTransactions.isEmpty ? false : true
        } catch {
            print("Can't restore")
            showProcessView = false
            return false
        }
    }
    
    func fetchActiveTransactions() async {
        var activeTransactions: Set<StoreKit.Transaction> = []
        
        for await entitlement in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                activeTransactions.insert(transaction)
            }
        }
        
        self.activeTransactions = activeTransactions
        _ = hasUnlockedPro
    }
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {}
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}

extension Product {
    var productOrder: Int {
        switch self.type {
        case .autoRenewable:
            if self.price < 1 {
                return 1
            }
            return 2
        case .nonRenewable:
            return 0
        default:
            return 3
        }
    }
}
