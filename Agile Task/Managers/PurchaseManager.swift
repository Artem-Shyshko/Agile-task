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
    private let productsID = ["agile_task_monthly", "agile_task_yearly"]
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil
    private let taskRepository: TaskRepository = TaskRepositoryImpl()
    private let projectRepository: ProjectRepository = ProjectRepositoryImpl()
    private let maxFreeTasks = 8
    private let maxFreeProjects = 1
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    
    var hasUnlockedPro: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    override init() {
        super.init()
        updates = newTransactionListenerTask()
    }
    
    deinit {
        updates?.cancel()
    }
    
    func canCreateTask() -> Bool {
        guard hasUnlockedPro == false else { return  true }
        
        let allTasks = taskRepository.getTaskList()
        
        return maxFreeTasks <= allTasks.count ? false : true
    }
    
    func canCreateProject() -> Bool {
        guard hasUnlockedPro == false else { return  true }
        
        let allProjects = projectRepository.getProjects()
        
        return maxFreeProjects <= allProjects.count ? false : true
    }
    
    func loadProducts() async throws {
        guard !productsLoaded else { return }
        showProcessView = true
        
        self.products = try await Product.products(for: productsID)
            .sorted(by: { $0.price < $1.price })
        self.productsLoaded = true
        showProcessView = false
    }
    
    func userSelectSubscription(product: Product) {
        showProcessView = true
        
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
            guard case .verified(let transaction) = result else {
                selectedSubscriptionID = Constants.shared.freeSubscription
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
            
            selectedSubscriptionID = purchasedProductIDs.first ?? Constants.shared.freeSubscription
        }
    }
    
    func restore() async -> Bool {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            return true
        } catch {
            return false
        }
    }
}

private extension PurchaseManager {
    func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                //                await self.updatePurchasedProducts()
                guard case .verified(let transaction) = verificationResult else {
                    return
                }
                
                if transaction.revocationDate != nil {
                    selectedSubscriptionID = Constants.shared.freeSubscription
                } else if let expirationDate = transaction.expirationDate,
                          expirationDate < Date() {
                    selectedSubscriptionID = Constants.shared.freeSubscription
                    return
                } else if transaction.isUpgraded {
                    return
                } else {
                    selectedSubscriptionID = transaction.productID
                }
            }
        }
    }
    
    private func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(.verified(let transaction)):
            self.selectedSubscriptionID = product.id
            showProcessView = false
            await updatePurchasedProducts()
            await transaction.finish()
        case .success(.unverified(_, let error)):
            print(error.localizedDescription)
            showProcessView = false
            break
        default:
            showProcessView = false
            break
        }
    }
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {}
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
