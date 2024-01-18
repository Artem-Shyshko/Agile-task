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
            navigationBar()
            subscriptionView()
            Spacer()
        }
        .modifier(TabViewChildModifier())
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
                Text("Selected plane")
            }
            .padding(.horizontal, 5)
        }
        .buttonStyle(SettingsButtonStyle())
        .padding(.horizontal, 5)
    }
}

#Preview {
    ProjectsView(vm: ProjectsViewModel())
        .environmentObject(AppThemeManager())
}
