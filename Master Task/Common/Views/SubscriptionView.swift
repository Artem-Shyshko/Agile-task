//
//  SubscriptionView.swift
//  Master Task
//
//  Created by Artur Korol on 26.10.2023.
//

import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 2) {
            Button {
                purchaseManager.selectedSubscriptionID = "free"
            } label: {
                planView(
                    title: "Free",
                    price: nil,
                    firstLine: "8 tasks",
                    secondLine: "1 project",
                    isSelected: purchaseManager.selectedSubscriptionID == "free"
                )
            }
            
            ForEach(purchaseManager.products) { product in
                Button {
                    purchaseManager.userSelectSubscription(product: product)
                } label: {
                    planView(
                        title: product.displayName,
                        price: product.displayPrice,
                        firstLine: "Unlimited tasks",
                        secondLine: "Unlimited projects",
                        isSelected: purchaseManager.selectedSubscriptionID == product.id
                    )
                }
            }
            
            AppFeaturesView()
                .foregroundColor(themeManager.theme.textColor(colorScheme))
            .padding(.top, 40)
        }
        .padding(.horizontal, 2)
        .onAppear {
            Task {
                try await purchaseManager.loadProducts()
            }
        }
    }
}


private extension SubscriptionView {
    func planView(title: String, price: String?, firstLine: String, secondLine: String, isSelected: Bool) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image("Check")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .opacity(isSelected ? 1 : 0)
                Text(title)
                    .font(.helveticaBold(size: 16))
                Spacer()
                if let price {
                    Text("\(price)/month")
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
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(PurchaseManager())
        .environmentObject(ThemeManager())
}
