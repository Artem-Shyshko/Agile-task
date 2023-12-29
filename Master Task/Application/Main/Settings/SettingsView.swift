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
            VStack(spacing: Constants.shared.listRowSpacing) {
                NavigationLink(value: SettingsNavigationView.account) {
                        Text("Account")
                            .modifier(SectionStyle())
                }
                
                SettingsThemeView()
                
                NavigationLink(value: SettingsNavigationView.taskSettings) {
                    Text("Settings")
                        .modifier(SectionStyle())
                }
                
                NavigationLink(value: SettingsNavigationView.security) {
                    Text("Security")
                        .modifier(SectionStyle())
                }
                
                NavigationLink(value: SettingsNavigationView.more) {
                    Text("More Agile App")
                        .modifier(SectionStyle())
                }
                
                Button {
                    showMailView = true
                } label: {
                    Text("Write to us on the email")
                        .modifier(SectionStyle())
                }
                
                Spacer()
            }
            .padding(.top, 25)
            .modifier(TabViewChildModifier())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(path: .constant([SettingsNavigationView.account]))
            .environmentObject(UserState())
    }
}
