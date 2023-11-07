//
//  OnboardingSubscriptionView.swift
//  Master Task
//
//  Created by Artur Korol on 05.10.2023.
//

import SwiftUI

struct OnboardingSubscriptionView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var theme: AppThemeManager
    @State var showTabbar = false
    
    var body: some View {
        ZStack {
            Group {
                theme.selectedTheme.backgroundColor
                theme.selectedTheme.backgroundGradient
            }
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                SubscriptionView()
                
                Text("Subscriptions will be charged to your credit card through your iTunes account. Your subscription will automatically renew unless cancelled at least 24 hours before the end of your current subscription, and you can cancel a subscription during the active period. You can manage your subscription at any time, either by viewing your account in iTunes from your Mac or PC, or Account Settings on your device after purchase.")
                    .font(.helveticaRegular(size: 8))
                    .foregroundColor(theme.selectedTheme.textColor)
                    .padding(.horizontal, 25)
                
                Button {
                    if !purchaseManager.selectedSubscriptionID.isEmpty {
                        AppHelper.shared.isOnboarding = true
                        showTabbar = true
                    }
                } label: {
                    Text("Continue")
                }
                .padding(.top, 20)
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showTabbar) {
            TabBarView()
        }
    }
}

struct OnboardingSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingSubscriptionView()
            .environmentObject(PurchaseManager())
            .environmentObject(AppThemeManager())
    }
}

extension Array {
    var isNotEmpty: Bool {
        isEmpty == false
    }
}
