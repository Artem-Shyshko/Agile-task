//
//  SettingsSubscriptionView.swift
//  Agile Task
//
//  Created by Artur Korol on 25.10.2023.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    enum Layout {
        static let cornerRadius: CGFloat = 4
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State var selectedProduct: Product?
    @State private var isPresentedManageSubscription = false
    @State var showPurchasesAlert = false
    @State var isRestored = false
    
    private let checkmarkItems = [
        "purchase_unlimited_tasks",
        "purchase_unlimited_lists",
        "purchase_unlimited_checklists",
        "purchase_unlimited_to_do_lists",
        "purchase_unlimited_secured",
        "purchase_advanced_features"
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
                VStack(spacing: 20) {
                    VStack {
                        title()
                        subtitle()
                        Spacer()
                        checkmarksView()
                        Spacer()
                        reviews()
                        products()
                    }
                    bottomButtons()
                }
                .padding(.horizontal, 2)
        }
        .onAppear {
            Task {
                try await purchaseManager.loadProducts()
                
                if purchaseManager.selectedSubscriptionID == Constants.shared.freeSubscription,
                   let yearlyPurchaseIndex = purchaseManager.products.firstIndex(where: { $0.id == Constants.shared.yearlySubscriptionID}) {
                    await MainActor.run {
                        selectedProduct = purchaseManager.products[yearlyPurchaseIndex]
                    }
                }
            }
        }
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
        .toolbar(.hidden, for: .tabBar)
        .modifier(TabViewChildModifier())
        .overlay {
            loaderView(show: purchaseManager.showProcessView)
        }
        .foregroundColor(themeManager.theme.textColor(colorScheme))
        .onChange(of: purchaseManager.selectedSubscriptionID) { newValue in
            if newValue == Constants.shared.yearlySubscriptionID
                || newValue == Constants.shared.monthlySubscriptionID {
                dismiss()
                appState.projectsNavigationStack = []
                appState.taskListNavigationStack = []
            }
        }
    }
}

// MARK: - Private views

private extension SubscriptionView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: EmptyView(),
            rightItem: restoreSubscription()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    func bottomButtons() -> some View {
        VStack(spacing: 20) {
            Button {
                if let selectedProduct {
                    Task {
                        try await purchaseManager.purchase(selectedProduct)
                    }
                } else if purchaseManager.selectedSubscriptionID != Constants.shared.freeSubscription {
                    isPresentedManageSubscription = true
                }
            } label: {
                Text(purchaseManager.selectedSubscriptionID == Constants.shared.freeSubscription ? "plane_continue_title" : "plane_manage_subscription")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            HStack(spacing: 30) {
                    PrivacyPolicyButton()
                        .font(.helveticaRegular(size: 15))
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .frame(height: 0.5)
                        }
                TermsOfUseButton()
                    .font(.helveticaRegular(size: 15))
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: 0.5)
                    }
            }
            .opacity(0.8)
        }
    }
    
    func checkmarksView() -> some View {
        VStack(alignment: .leading) {
            ForEach(checkmarkItems, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                    Text(LocalizedStringKey(item))
                }
            }
        }
    }
    
    func restoreSubscription() -> some View {
        Button {
            Task {
                self.isRestored = await purchaseManager.restore()
                showPurchasesAlert = true
            }
        } label: {
            Text("restore_subscription_title")
                .font(.helveticaRegular(size: 15))
        }
    }
    
    func title() -> some View {
        Text("subscription_title")
            .font(.helveticaBold(size: 28))
            .multilineTextAlignment(.center)
            .padding(.top, 15)
    }
    
    func subtitle() -> some View {
        Text("purchase_welcome_offer")
            .font(.helveticaRegular(size: 12))
            .padding(10)
            .overlay {
                Capsule()
                    .foregroundStyle(.white.opacity(0.2))
            }
    }
    
    
    func sum<T: AdditiveArithmetic>(firsValue: T, secondValue: T) -> T {
        firsValue + secondValue
    }
    
    func reviews() -> some View {
        HStack {
            Image(.leftWreath)
            ForEach(0..<5) { _ in
                Image(.star)
            }
            Image(.rightWreath)
        }
        .overlay(alignment: .center) {
            Text("purchase_reviews")
                .font(.helveticaRegular(size: 15))
                .offset(y: 25)
        }
    }
    
    func products() -> some View {
        VStack(spacing: 5) {
            ForEach(purchaseManager.products) { product in
                if product.id == Constants.shared.yearlySubscriptionID {
                    planView(
                        title: LocalizedStringKey(product.displayName.trimmingCharacters(in: .whitespacesAndNewlines)),
                        description: product.description,
                        price: product.displayPrice
                    )
                }
            }
        }
    }
    
    func planView(
        title: LocalizedStringKey,
        description: String,
        price: String?
    ) -> some View {
        VStack(alignment: .center, spacing: 12) {
            if let price {
                HStack(spacing: 10) {
                    Text("$49.99 ")
                        .font(.helveticaBold(size: 20))
                        .opacity(0.5)
                        .strikethrough()
                    Text(price)
                        .font(.helveticaBold(size: 30))
                    Text("Save 80%")
                        .font(.helveticaBold(size: 16))
                }
                .font(.helveticaBold(size: 16))
            }
            
            HStack {
                Text(title)
                    .font(.helveticaBold(size: 16))
                Text(LocalizedStringKey(description))
                    .font(.helveticaRegular(size: 14))
            }
        }
        .foregroundColor(themeManager.theme.textColor(colorScheme))
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.3))
        .clipShape(.rect(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(lineWidth: 1)
                .opacity(0.6)
        }
    }
}

// MARK: - Preview

#Preview {
    SubscriptionView()
        .environmentObject(PurchaseManager())
        .environmentObject(ThemeManager())
        .environmentObject(AppState())
}
