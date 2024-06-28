//
//  SettingsView.swift
//  Agile Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    @Binding var path: [SettingsNavigationView]
    @State var showMailView = false
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var appState: AppState
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Constants.shared.viewSectionSpacing) {
                navigationBar()
                VStack(spacing: Constants.shared.listRowSpacing) {
                    accountView()
                    SettingsThemeView()
                    settingsView()
                    securityView()
//                    backupView()
                    moreAppsView()
                    emailView()
                    Spacer()
                }
            }
            .modifier(TabViewChildModifier())
            .navigationDestination(for: SettingsNavigationView.self) { views in
                switch views {
                case .subscription:
                    SubscriptionView()
                case .taskSettings:
                    SettingsTaskView(viewModel: SettingsTaskViewModel(appState: appState))
                case .security:
                    SecurityView(viewModel: SecurityViewModel(appState: appState))
                case .more:
                    MoreOurAppsView()
                case .contactUs:
                    Text("Contact Us")
                case .backup:
                    BackupView(viewModel: BackupViewModel(appState: appState))
                case .backupDetail(storage: let storage):
                    BackupDetailView(viewModel: BackupViewModel(appState: appState), backupStorage: storage)
                case .backupList(storage: let storage):
                    BackupListView(viewModel: BackupViewModel(appState: appState), backupStorage: storage)
                }
            }
            .sheet(isPresented: $showMailView, content: {
                MailView()
                    .tint(.blue)
            })
        }
    }
}

private extension SettingsView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: EmptyView(),
            header: NavigationTitle("Settings"),
            rightItem: EmptyView()
        )
    }
    
    func accountView () -> some View {
        NavigationLink(value: SettingsNavigationView.subscription) {
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
        NavigationLink(value: SettingsNavigationView.taskSettings) {
            Text("Settings")
                .modifier(SectionStyle())
        }
    }
    
    func securityView() -> some View {
        NavigationLink(value: SettingsNavigationView.security) {
            Text("Security")
                .modifier(SectionStyle())
        }
    }
    
    func moreAppsView() -> some View {
        NavigationLink(value: SettingsNavigationView.more) {
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
        NavigationLink(value: SettingsNavigationView.backup) {
            Text("backup_title")
                .modifier(SectionStyle())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(path: .constant([SettingsNavigationView.subscription]))
    }
}
