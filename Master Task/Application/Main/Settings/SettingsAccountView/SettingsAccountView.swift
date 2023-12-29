//
//  SettingsAccountView.swift
//  Master Task
//
//  Created by Artur Korol on 25.10.2023.
//

import SwiftUI

struct SettingsAccountView: View {
    @EnvironmentObject var theme: AppThemeManager
    
    var body: some View {
            VStack {
                NavigationLink {
                    SettingsSubscriptionView()
                } label: {
                    HStack {
                        Text("Subscription")
                        Spacer()
                        Text("Selected plane")
                    }
                    .padding(.horizontal, 5)
                }
                .buttonStyle(SettingsButtonStyle())
                .padding(.horizontal, 5)
                Spacer()
            }
            .navigationTitle("Account")
            .padding(.top, 25)
            .modifier(TabViewChildModifier())
            .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    ProjectsView(vm: ProjectsViewModel())
        .environmentObject(AppThemeManager())
}
