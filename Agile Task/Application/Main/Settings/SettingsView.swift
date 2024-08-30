//
//  SettingsView.swift
//  Agile Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    @State var showMailView = false
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            VStack(spacing: Constants.shared.listRowSpacing) {
                accountView()
                SettingsThemeView()
                settingsView()
                securityView()
                moreAppsView()
                emailView()
                Spacer()
            }
        }
        .modifier(TabViewChildModifier())
        .sheet(isPresented: $showMailView, content: {
            MailView()
                .tint(.blue)
        })
    }
}

private extension SettingsView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("Settings"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss()
        }
    }
    
    func accountView () -> some View {
        NavigationLink(value: TaskListNavigationView.subscription) {
            HStack {
                Text("settings_subscription_title")
                Spacer()
                Text(selectedSubscriptionTitle())
            }
            .modifier(SectionStyle())
        }
    }
    
    func selectedSubscriptionTitle() -> LocalizedStringKey {
        if purchaseManager.selectedSubscriptionID == Constants.shared.monthlySubscriptionID {
            return "monthly_title"
        } else if purchaseManager.selectedSubscriptionID == Constants.shared.yearlySubscriptionID {
            return "yearly_title"
        } else {
            return "free_plane_title"
        }
    }
    
    func settingsView() -> some View {
        NavigationLink(value: TaskListNavigationView.taskSettings) {
            Text("Settings")
                .modifier(SectionStyle())
        }
    }
    
    func securityView() -> some View {
        NavigationLink(value: TaskListNavigationView.security) {
            Text("Security")
                .modifier(SectionStyle())
        }
    }
    
    func moreAppsView() -> some View {
        NavigationLink(value: TaskListNavigationView.more) {
            Text("App credentials")
                .modifier(SectionStyle())
        }
    }
    
    func emailView() -> some View {
        Button {
            showMailView = true
        } label: {
            Text("Email us")
                .modifier(SectionStyle())
        }
    }
    
    func backupView() -> some View {
        NavigationLink(value: TaskListNavigationView.backup) {
            Text("backup_title")
                .modifier(SectionStyle())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
