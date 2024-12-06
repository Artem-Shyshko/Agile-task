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
    private let iconSize: CGFloat = 15
    
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
                backupView()
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
        NavigationLink(value: TasksNavigation.subscription) {
            HStack {
                HStack(spacing: 6) {
                    setupIcon(with: .settingsSubscription, size: iconSize)
                    Text("settings_subscription_title")
                }
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
            HStack(spacing: 6) {
                setupIcon(with: .settingsApp, size: iconSize)
                Text("app_settings_title")
            }
            .modifier(SectionStyle())
        }
    }
    
    func tasksSettingsView() -> some View {
        NavigationLink(value: viewModel.tasksSettings) {
            HStack(spacing: 6) {
                setupIcon(with: .settingsTasks, size: iconSize)
                Text("tasks_settings_title")
            }
            .modifier(SectionStyle())
        }
    }
    
    func backupView() -> some View {
        NavigationLink(value: TasksNavigation.backup) {
            HStack(spacing: 6) {
                setupIcon(with: .settingsBackup, size: iconSize)
                Text("backup_title")
            }
            .modifier(SectionStyle())
        }
    }
    
    func securityView() -> some View {
        NavigationLink(value: viewModel.security) {
            HStack(spacing: 6) {
                setupIcon(with: .settingsSecurity, size: iconSize)
                Text("Security")
            }
            .modifier(SectionStyle())
        }
    }
    
    func moreAppsView() -> some View {
        NavigationLink(value: viewModel.more) {
            HStack(spacing: 6) {
                setupIcon(with: .settingsCredentials, size: iconSize)
                Text("App credentials")
            }
            .modifier(SectionStyle())
        }
    }
    
    func emailView() -> some View {
        HStack(spacing: 6) {
            setupIcon(with: .settingsWrite, size: iconSize)
            Button {
                showMailView = true
            } label: {
                Text("Email us")
            }
        }
        .modifier(SectionStyle())
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
