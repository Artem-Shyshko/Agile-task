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
    @StateObject var viewModel: SettingsViewModel
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            VStack(spacing: Constants.shared.listRowSpacing) {
                accountView()
                SettingsThemeView()
                appSettingsView()
                tasksSettingsView()
                securityView()
                moreAppsView()
                emailView()
                versionView()
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
    
    func appSettingsView() -> some View {
        NavigationLink(value: viewModel.settingsGeneral) {
            Text("app_settings_title")
                .modifier(SectionStyle())
        }
    }
    
    func tasksSettingsView() -> some View {
        NavigationLink(value: viewModel.tasksSettings) {
            Text("tasks_settings_title")
                .modifier(SectionStyle())
        }
    }
    
    func securityView() -> some View {
        NavigationLink(value: viewModel.security) {
            Text("Security")
                .modifier(SectionStyle())
        }
    }
    
    func moreAppsView() -> some View {
        NavigationLink(value: viewModel.more) {
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

    func versionView() -> some View {
      Text("Version \(viewModel.getAppVersion())")
        .hAlign(alignment: .trailing)
        .padding(.vertical)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(settingType: .recordsList))
    }
}
