//
//  SettingsAccountView.swift
//  Master Task
//
//  Created by Artur Korol on 25.10.2023.
//

import SwiftUI

struct SettingsAccountView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State var showPurchasesAlert = false
    @State var isRestored = false
    @State var selectedProductName = ""
    
    var body: some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            navigationBar()
            subscriptionView()
            restoreSubscription()
            Spacer()
        }
        .modifier(TabViewChildModifier())
        .task {
            if let product = purchaseManager.products.first(where: { $0.id == purchaseManager.selectedSubscriptionID }) {
                selectedProductName = product.displayName
            }
        }
    }
}

private extension SettingsAccountView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("Account"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    func subscriptionView() -> some View {
        NavigationLink {
            SettingsSubscriptionView()
        } label: {
            HStack {
                Text("Subscription")
                Spacer()
                Text(selectedProductName)
                    .padding(.trailing, 10)
            }
        }
        .modifier(SectionStyle())
    }
    
    func restoreSubscription() -> some View {
        Button {
            Task {
                self.isRestored = await purchaseManager.restore()
                showPurchasesAlert = true
            }
        } label: {
                Text("Restore subscription")
        }
        .modifier(SectionStyle())
    }
}

#Preview {
    SettingsAccountView()
        .environmentObject(PurchaseManager())
}
