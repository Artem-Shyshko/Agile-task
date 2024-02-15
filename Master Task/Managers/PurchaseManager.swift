//
//  PurchaseManager.swift
//  Master Task
//
//  Created by Artur Korol on 04.10.2023.
//

import SwiftUI
import StoreKit

@MainActor
final class PurchaseManager: NSObject, ObservableObject {
    @AppStorage(Constants.shared.selectedSubscriptionID) var selectedSubscriptionID = Constants.shared.freeSubscription
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
        updates = observeTransactionUpdates()
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
        
        self.products = try await Product.products(for: productsID)
        self.productsLoaded = true
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
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        
        if purchasedProductIDs.isEmpty {
            selectedSubscriptionID = Constants.shared.freeSubscription
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
                showProcessView = false
            case .success(.unverified(_, let error)):
                print(error.localizedDescription)
                print("success unverified break")
                showProcessView = false
                break
            default:
                print("Default break")
                showProcessView = false
                break
            }
        }
    }
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {}

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
