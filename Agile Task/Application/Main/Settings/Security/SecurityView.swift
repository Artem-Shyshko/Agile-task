//
//  SecurityView.swift
//  Agile Task
//
//  Created by Artur Korol on 03.10.2023.
//

import SwiftUI
import RealmSwift

struct SecurityView: View {
    
    @StateObject var viewModel: SecurityViewModel
    @Environment(\.realm) var realm
    @Environment(\.dismiss) var dismiss
    
    var isUserPassword: Bool {
        UserDefaults.standard.string(forKey: Constants.shared.userPassword) != nil
    }
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            
            VStack(spacing: Constants.shared.listRowSpacing) {
                securitySection()
                changePasswordView()
                Spacer()
            }
        }
        .modifier(TabViewChildModifier())
        .navigationDestination(isPresented: $viewModel.showPasswordView) {
            SetPasswordView(viewModel: SetPasswordViewModel(appState: viewModel.appState), isFirstSetup: false)
        }
        .onChange(of: viewModel.settings.securityOption) { newValue in
            if newValue == .password, !isUserPassword {
                viewModel.showPasswordView = true
            }
        }
        .onChange(of: viewModel.settings) { _ in
            viewModel.appState.settingsRepository!.save(viewModel.settings)
        }
    }
}

// MARK: - Private Views

private extension SecurityView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle("Security"),
            rightItem: EmptyView()
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    func securitySection() -> some View {
        HStack {
            Text("Security")
            Spacer()
            
            Picker("", selection: $viewModel.settings.securityOption) {
                ForEach(SecurityOption.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0.rawValue)
                }
            }
            .pickerStyle(.menu)
        }
        .modifier(SectionStyle())
    }
    
    func changePasswordView() -> some View {
        Button {
            viewModel.showPasswordView = true
        } label: {
            HStack {
                Text("Password")
                Spacer()
                Text(isUserPassword ? "Change" : "Set")
                    .padding(.trailing, 13)
            }
        }
        .padding(.vertical, 10)
        .modifier(SectionStyle())
    }
}

// MARK: - SecurityView_Previews

struct SecurityView_Previews: PreviewProvider {
    static var previews: some View {
        SecurityView(viewModel: SecurityViewModel(appState: AppState()))
    }
}
