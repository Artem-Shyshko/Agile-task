//
//  SettingsSubscriptionView.swift
//  Master Task
//
//  Created by Artur Korol on 25.10.2023.
//

import SwiftUI

struct SettingsSubscriptionView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        
        VStack {
            SubscriptionView()
            
            Spacer()
        }
        .navigationTitle("Subscription")
        .padding(.top, 25)
        .modifier(TabViewChildModifier())
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    SettingsSubscriptionView()
        .environmentObject(AppThemeManager())
        .environmentObject(PurchaseManager())
}
