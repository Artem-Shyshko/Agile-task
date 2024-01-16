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
            SubscriptionView()
            
            Spacer()
        }
        .navigationTitle("Subscription")
        .padding(.top, 25)
        .modifier(TabViewChildModifier())
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            backButton {
              dismiss.callAsFunction()
            }
          }
        }
    }
}

#Preview {
    SettingsSubscriptionView()
        .environmentObject(AppThemeManager())
        .environmentObject(PurchaseManager())
}
