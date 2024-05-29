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
    
    private var isPurchaseCompleted: Bool {
        purchaseManager.selectedSubscriptionID == Constants.shared.yearlySubscriptionID
        && !purchaseManager.showProcessView
        || purchaseManager.selectedSubscriptionID == Constants.shared.monthlySubscriptionID
        && !purchaseManager.showProcessView
    }
    private let checkmarkItems = [
            "purchase_unlimited_tasks",
            "purchase_unlimited_projects",
            "purchase_statuses",
            "purchase_checklists_bullets",
            "purchase_notification_reminders",
            "purchase_recurring",
            "purchase_faceid",
            "purchase_data_backup"
        ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
                navigationBar()
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 20) {
                        title()
                        descriptionView()
                        Spacer()
                        checkmarksView()
                        Spacer()
                        products()
                    }
                    bottomButtons()
                }
                .padding(.horizontal, 2)
            }
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
                appState.selectedTab = .taskList
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
    
    func descriptionView() -> some View {
        Text("subscription_description")
            .font(.helveticaRegular(size: 16))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
    
    func bottomButtons() -> some View {
        VStack(spacing: 10) {
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
                    .font(.helveticaRegular(size: 13))
                TermsOfUseButton()
                    .font(.helveticaRegular(size: 13))
            }
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
        VStack(spacing: 10) {
            Text("subscription_title")
            Text("subscription_subtitle")
        }
        .font(.helveticaRegular(size: 32))
        .multilineTextAlignment(.center)
        .padding(.top, 15)
    }
    
    func products() -> some View {
        VStack(spacing: 5) {
            ForEach(purchaseManager.products) { product in
                Button {
                    selectedProduct = product
                } label: {
                    planView(
                        title: LocalizedStringKey(product.displayName.trimmingCharacters(in: .whitespacesAndNewlines)),
                        description: product.description,
                        price: product.displayPrice,
                        isSelected: selectedProduct?.id == product.id || purchaseManager.selectedSubscriptionID == product.id
                    )
                }
                .disabled(purchaseManager.selectedSubscriptionID != Constants.shared.freeSubscription)
            }
        }
    }
    
    func planView(
        title: LocalizedStringKey,
        description: String,
        price: String?,
        isSelected: Bool
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image("SubscribtionCheckmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .opacity(isSelected ? 1 : 0)
                HStack {
                    Text(title)
                        .font(.helveticaBold(size: 16))
                    Text(LocalizedStringKey(description))
                        .font(.helveticaRegular(size: 14))
                }
                Spacer()
                if let price {
                    HStack(spacing: 0) {
                        Text("\(price)")
                    }
                    .font(.helveticaBold(size: 16))
                }
            }
            .hAlign(alignment: .leading)
        }
        .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
        .padding(15)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background(themeManager.theme.sectionColor(colorScheme))
        .cornerRadius(Layout.cornerRadius)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(lineWidth: 3)
                    .fill(Color.orangeGradient)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SubscriptionView()
}
