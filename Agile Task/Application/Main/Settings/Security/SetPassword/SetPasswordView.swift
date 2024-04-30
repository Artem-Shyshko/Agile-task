//
//  SetPasswordView.swift
//  Agile Task
//
//  Created by Artur Korol on 09.10.2023.
//

import SwiftUI


struct SetPasswordView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: SetPasswordViewModel
    
    @State private var showAuthView = false
    @State var showPasswordView = false
    
    var isFirstSetup: Bool
    private let defaults = UserDefaults.standard
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            
            VStack(alignment: .leading, spacing: 3) {
                oldPasswordFieldView()
                passwordFieldView()
                CheckingPasswordView(viewModel: viewModel, password: viewModel.newPassword)
                repeatPasswordFieldView()
                if isFirstSetup { secureWithFieldView() }
                Spacer()
            }
        }
        .navigationDestination(isPresented: $showPasswordView) {
            PasswordView(vm: AuthViewModel())
        }
        .modifier(TabViewChildModifier())
        .onChange(of: viewModel.settings) { _ in
            viewModel.settingsRepository.save(viewModel.settings)
        }
    }
}

private extension SetPasswordView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: cancelButton(),
            header: NavigationTitle("password_navigation_title"),
            rightItem: saveButton()
        )
    }
    
    func saveButton() -> some View {
        Button {
            if defaults.value(forKey: Constants.shared.userPassword) == nil {
                if viewModel.newPassword == viewModel.confirmPassword &&
                    viewModel.allRequirementsMet == true {
                    defaults.setValue(viewModel.confirmPassword, forKey: Constants.shared.userPassword)
                    showPasswordView = true
                    AppHelper.shared.isOnboarding = true
                }
            } else {
                if let password = defaults.value(forKey: Constants.shared.userPassword) as? String,
                   password == viewModel.oldPassword,
                   viewModel.newPassword == viewModel.confirmPassword,
                   viewModel.allRequirementsMet == true {
                    defaults.set(viewModel.confirmPassword, forKey: Constants.shared.userPassword)
                    dismiss.callAsFunction()
                }
            }
        } label: {
            Text("save_button")
        }
    }
    
    func cancelButton() -> some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("cancel_button")
        }
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    func oldPasswordFieldView() -> some View {
        if let userPassword = defaults.string(forKey: Constants.shared.userPassword) {
            TextField("enter_old_password_title", text: $viewModel.oldPassword.max(viewModel.characterLimit))
                .keyboardType(.alphabet)
                .padding(.vertical, 10)
                .modifier(SectionStyle())
        }
    }
    
    func passwordFieldView() -> some View {
        TextField("password_title",
                  text: $viewModel.newPassword.max(viewModel.characterLimit))
        .keyboardType(.alphabet)
        .padding(.vertical, 10)
        .modifier(SectionStyle())
    }
    
    func repeatPasswordFieldView() -> some View {
        TextField("repeat_password_title", text: $viewModel.confirmPassword.max(viewModel.characterLimit))
            .keyboardType(.alphabet)
            .padding(.vertical, 10)
            .modifier(SectionStyle())
    }
    
    func secureWithFieldView() -> some View {
        HStack {
            Text("secure_app_with")
            Spacer()
            
            Picker("", selection: $viewModel.settings.securityOption) {
                ForEach(SecurityOption.allCases, id: \.self) {
                    Text(LocalizedStringKey($0.description))
                        .tag($0.rawValue)
                }
            }
            .pickerStyle(.menu)
        }
        .modifier(SectionStyle())
    }
}

struct SetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        SetPasswordView(viewModel: SetPasswordViewModel(), isFirstSetup: true)
    }
}

