//
//  SecurityView.swift
//  Master Task
//
//  Created by Artur Korol on 03.10.2023.
//

import SwiftUI
import RealmSwift

struct SecurityView: View {
    
    @StateObject var viewModel: SecurityViewModel
    @Environment(\.realm) var realm
    @State private var showPasswordView = false
    
    var settings: TaskSettings {
        realm.objects(TaskSettings.self).first!
    }
    var isUserPassword: Bool {
        UserDefaults.standard.string(forKey: MasterTaskConstants.shared.userPassword) != nil
    }
    
    var body: some View {
        VStack(spacing: 3) {
            securitySection()
            changePasswordView()
            Spacer()
        }
        .padding(.top, 25)
        .modifier(TabViewChildModifier())
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Security")
        .onAppear {
            viewModel.selectedSecurityOption = settings.securityOption
        }
        .navigationDestination(isPresented: $showPasswordView) {
            SetPasswordView(viewModel: SetPasswordViewModel())
        }
        .onChange(of: viewModel.selectedSecurityOption) { newValue in
            if newValue == .password, !isUserPassword {
                showPasswordView = true
            }
        }
    }
}

// MARK: - Private Views

private extension SecurityView {
    func securitySection() -> some View {
        HStack {
            Text("Security")
            Spacer()
            
            Picker("", selection: $viewModel.selectedSecurityOption) {
                ForEach(SecurityOption.allCases, id: \.self) {
                    Text($0.rawValue)
                        .tag($0.rawValue)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.selectedSecurityOption) { newValue in
                settings.saveSettings {
                    settings.securityOption = newValue
                }
            }
        }
        .modifier(SectionStyle())
    }
    
    func changePasswordView() -> some View {
        Button {
            showPasswordView = true
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
    
    var checkMark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.green)
    }
}

// MARK: - SecurityView_Previews

struct SecurityView_Previews: PreviewProvider {
    static var previews: some View {
        SecurityView(viewModel: SecurityViewModel())
    }
}
