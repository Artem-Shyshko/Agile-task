//
//  SubscriptionView.swift
//  Agile Task
//
//  Created by Artur Korol on 26.10.2023.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State var selectedProduct: Product?
    @State private var isPresentedManageSubscription = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 2) {
                planView(
                    title: "Free",
                    price: nil,
                    firstLine: "8 tasks",
                    secondLine: "1 project",
                    isSelected: purchaseManager.selectedSubscriptionID == Constants.shared.freeSubscription && selectedProduct == nil, duration: ""
                )
                
                ForEach(purchaseManager.products) { product in
                    Button {
                        selectedProduct = product
                    } label: {
                        let duration: LocalizedStringKey = product.id == "agile_task_monthly" ? "month" : "year"
                        planView(
                            title: product.displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                            price: product.displayPrice,
                            firstLine: "Unlimited tasks",
                            secondLine: "Unlimited projects",
                            isSelected: selectedProduct?.id == product.id || purchaseManager.selectedSubscriptionID == product.id, duration: duration
                        )
                    }
                    .disabled(purchaseManager.selectedSubscriptionID != Constants.shared.freeSubscription)
                }
                
                VStack {
                    AppFeaturesView()
                        .foregroundColor(themeManager.theme.textColor(colorScheme))
                        .padding(.top, 30)
                        .scaleEffect(0.8)
                    
                    Button {
                        if let selectedProduct {
                            Task {
                                try await purchaseManager.purchase(selectedProduct)
                            }
                        } else if purchaseManager.selectedSubscriptionID != Constants.shared.freeSubscription {
                            isPresentedManageSubscription = true
                        }
                    } label: {
                        Text(purchaseManager.selectedSubscriptionID == Constants.shared.freeSubscription ? "Continue" : "Manage subscription")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    HStack(spacing: 20) {
                        PrivacyPolicyButton()
                            .font(.helveticaRegular(size: 14))
                        TermsOfUseButton()
                            .font(.helveticaRegular(size: 14))
                    }
                    .padding(.top, 10)
                }
                .offset(y: -30)
            }
            .padding(.horizontal, 2)
        }
        .onAppear {
            Task {
                try await purchaseManager.loadProducts()
            }
        }
        .manageSubscriptionsSheet(isPresented: $isPresentedManageSubscription)
    }
}

private extension SubscriptionView {
    func planView(title: String, price: String?, firstLine: LocalizedStringKey, secondLine: LocalizedStringKey, isSelected: Bool, duration: LocalizedStringKey) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image("Check")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .opacity(isSelected ? 1 : 0)
                    .padding(4)
                    .background {
                        if isSelected {
                            Circle()
                                .fill(.green)
                        }
                    }
                    .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
                Text(LocalizedStringKey(title))
                    .font(.helveticaBold(size: 16))
                Spacer()
                if let price {
                    HStack(spacing: 0) {
                        Text("\(price)/")
                        Text(duration)
                    }
                        .font(.helveticaBold(size: 16))
                }
            }
            .hAlign(alignment: .leading)
            Group {
                Text(firstLine)
                
                Text(secondLine)
            }
            .padding(.horizontal, 30)
        }
        .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
        .padding(15)
        .frame(height: 110)
        .frame(maxWidth: .infinity)
        .background(themeManager.theme.sectionColor(colorScheme))
        .cornerRadius(4)
        .overlay {
            if !isSelected && purchaseManager.selectedSubscriptionID != "free" {
                Color.black.opacity(0.1)
            }
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(PurchaseManager())
        .environmentObject(ThemeManager())
}
