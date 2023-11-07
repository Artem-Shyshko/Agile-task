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
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 5) {
                NavigationView(title: "Settings")
                
                NavigationLink(value: SettingsNavigationView.account) {
                    Text("Account")
                }
                NavigationLink(value: SettingsNavigationView.theme) {
                    Text("Theme")
                }
                NavigationLink(value: SettingsNavigationView.taskSettings) {
                    Text("Task settings")
                }
                NavigationLink(value: SettingsNavigationView.security) {
                    Text("Security")
                }
                NavigationLink(value: SettingsNavigationView.more) {
                    Text("More our apps")
                }
                NavigationLink(value: SettingsNavigationView.contactUs) {
                    Text("Contact us")
                }
                Spacer()
            }
            .buttonStyle(SettingsButtonStyle())
            .modifier(TabViewChildModifier())
            .navigationDestination(for: SettingsNavigationView.self) { views in
                switch views {
                case .account:
                    SettingsAccountView()
                case .theme:
                    SettingsThemeView()
                case .taskSettings:
                    SettingsTaskView(viewModel: SettingsTaskViewModel())
                case .security:
                    SecurityView(viewModel: SecurityViewModel())
                case .more:
                    Text("More")
                case .contactUs:
                    Text("Contact Us")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(path: .constant([SettingsNavigationView.account]))
            .environmentObject(UserState())
    }
}
