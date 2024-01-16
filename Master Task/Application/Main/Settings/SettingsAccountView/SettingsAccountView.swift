//
//  SettingsAccountView.swift
//  Master Task
//
//  Created by Artur Korol on 25.10.2023.
//

import SwiftUI

struct SettingsAccountView: View {
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss
    
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
            .toolbar {
              ToolbarItem(placement: .topBarLeading) {
                backButton {
                  dismiss.callAsFunction()
                }
              }
            }
            .padding(.top, 25)
            .modifier(TabViewChildModifier())
    }
}

#Preview {
    ProjectsView(vm: ProjectsViewModel())
        .environmentObject(AppThemeManager())
}
