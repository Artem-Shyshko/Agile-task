//
//  SettingsView.swift
//  Master Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var userState: UserState
    @Binding var path: [SettingsNavigationView]
    @State var showMailView = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
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
            .navigationDestination(for: SettingsNavigationView.self) { views in
                switch views {
                case .account:
                    SettingsAccountView()
                case .taskSettings:
                    SettingsTaskView(viewModel: SettingsTaskViewModel())
                case .security:
                    SecurityView(viewModel: SecurityViewModel())
                case .more:
                    MoreOurAppsView()
                case .contactUs:
                    Text("Contact Us")
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
        NavigationLink(value: SettingsNavigationView.account) {
            Text("Subscription")
                .modifier(SectionStyle())
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
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(path: .constant([SettingsNavigationView.account]))
            .environmentObject(UserState())
    }
}
