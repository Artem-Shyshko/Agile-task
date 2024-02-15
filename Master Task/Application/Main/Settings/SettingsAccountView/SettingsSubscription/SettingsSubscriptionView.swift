//
//  SettingsSubscriptionView.swift
//  Master Task
//
//  Created by Artur Korol on 25.10.2023.
//

import SwiftUI

struct SettingsSubscriptionView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            VStack {
                navigationBar()
                SubscriptionView()
                Spacer()
            }
            .modifier(TabViewChildModifier())
            .overlay {
                if purchaseManager.showProcessView {
                    ZStack {
                        Color.black.opacity(0.2)
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .ignoresSafeArea()
                }
            }
    }
}

private extension SettingsSubscriptionView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("Subscription"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
}

#Preview {
    SettingsSubscriptionView()
}
