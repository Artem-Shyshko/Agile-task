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
        "purchase_unlimited_secured",
        "purchase_advanced_features"
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
                navigationBar()
            if AppHelper.shared.isIPad {
                content()
            } else {
                ScrollView {
                    content()
                }
                .padding(.bottom, 5)
            }
        }
        .onAppear {
            appState.isTabBarHidden = true
            Task {
                try await purchaseManager.loadProducts()
                
                if purchaseManager.selectedSubscriptionID == Constants.shared.freeSubscription,
                   let yearlyPurchaseIndex = purchaseManager.products.firstIndex(where: { $0.id == Constants.shared.monthlySubscriptionID}) {
                    await MainActor.run {
                        selectedProduct = purchaseManager.products[yearlyPurchaseIndex]
                    }
                } else if let subscription = purchaseManager.products.first(where: {$0.id == purchaseManager.selectedSubscriptionID }) {
                    await MainActor.run {
                        selectedProduct = subscription
                    }
                }
            }
        }
        .onDisappear(perform: {
            appState.isTabBarHidden = false
        })
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
        .modifier(TabViewChildModifier())
        .overlay {
            loaderView(show: purchaseManager.showProcessView)
        }
        .foregroundColor(themeManager.theme.textColor(colorScheme))
        .onChange(of: purchaseManager.selectedSubscriptionID) { newValue in
            if newValue == Constants.shared.yearlySubscriptionID
                || newValue == Constants.shared.monthlySubscriptionID {
                dismiss()
            }
        }
    }
}

// MARK: - Private views
private extension SubscriptionView {
    
    func content() -> some View {
        VStack(spacing: 20) {
            title()
            reviews()
            Spacer()
            checkmarksView()
            Spacer()
            VStack(spacing: 12) {
                products()
                Text("Change or cancel plan anytime")
                    .font(.helveticaRegular(size: 16))
                bottomButtons()
            }
        }
        .padding(.horizontal, 2)
    }
    
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
                Text(purchaseManager.selectedSubscriptionID == Constants.shared.freeSubscription ? "Subscribe" : "plane_manage_subscription")
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
        VStack(alignment: .leading, spacing: AppHelper.shared.isIPad ? 25 : 20) {
            ForEach(checkmarkItems, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                    Text(LocalizedStringKey(item))
                        .font(.helveticaRegular(size: AppHelper.shared.isIPad ? 20 : 16))
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
        HStack(spacing: 15) {
            Image(.leftWreath)
            HStack(spacing: 20) {
                ForEach(0..<5) { _ in
                    Image(.star)
                }
            }
            Image(.rightWreath)
        }
    }
    
    func products() -> some View {
        VStack(spacing: 5) {
            ForEach(purchaseManager.products) { product in
                Button {
                    selectedProduct = product
                } label: {
                    if selectedProduct == product {
                        planView(for: product)
                            .background(Color.rubySubscriptionGradient.opacity(0.6))
                            .clipShape(.rect(cornerRadius: 10))
                    } else {
                        planView(for: product)
                            .background(.clear)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .disabled(purchaseManager.selectedSubscriptionID != Constants.shared.freeSubscription)
            }
        }
    }
    
    func planView(for product: Product) -> some View {
        HStack(spacing: 5) {
            Text(product.displayPrice)
                    .font(.helveticaBold(size: 24))
            Text(LocalizedStringKey(product.description))
                .font(.helveticaRegular(size: 14))
        }
        .foregroundColor(themeManager.theme.textColor(colorScheme))
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 4)
                .opacity(selectedProduct == product ? 1 : 0.6)
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
