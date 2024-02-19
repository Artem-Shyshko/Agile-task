//
//  SetPasswordView.swift
//  Agile Task
//
//  Created by Artur Korol on 09.10.2023.
//

import SwiftUI

struct SetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SetPasswordViewModel
    private let defaults = UserDefaults.standard
    
    var body: some View {
        VStack {
            navigationBar()
            VStack(spacing: 1) {
                oldPasswordFieldView()
                passwordFieldView()
                repeatPasswordFieldView()
                Spacer()
            }
        }
        .modifier(TabViewChildModifier())
    }
}

private extension SetPasswordView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: cancelButton(),
            header: NavigationTitle("Password"),
            rightItem: saveButton()
        )
    }
    
    func saveButton() -> some View {
        Button {
            if defaults.value(forKey: Constants.shared.userPassword) == nil {
                if viewModel.newPassword == viewModel.confirmPassword {
                    defaults.setValue(viewModel.confirmPassword, forKey: Constants.shared.userPassword)
                    dismiss.callAsFunction()
                }
            } else {
                if let password = defaults.value(forKey: Constants.shared.userPassword) as? String,
                   password == viewModel.oldPassword,
                   viewModel.newPassword == viewModel.confirmPassword {
                    defaults.set(viewModel.confirmPassword, forKey: Constants.shared.userPassword)
                    dismiss.callAsFunction()
                }
            }
        } label: {
            Text("Save")
        }
    }
    
    func cancelButton() -> some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("Cancel")
        }
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    func oldPasswordFieldView() -> some View {
        if let userPassword = defaults.string(forKey: Constants.shared.userPassword) {
            TextField("Enter old password", text: $viewModel.oldPassword.max(viewModel.characterLimit))
                .keyboardType(.numberPad)
                .padding(.vertical, 10)
                .modifier(SectionStyle())
        }
    }
    
    func passwordFieldView() -> some View {
        TextField("Password", text: $viewModel.newPassword.max(viewModel.characterLimit))
            .keyboardType(.numberPad)
            .padding(.vertical, 10)
            .modifier(SectionStyle())
    }
    
    func repeatPasswordFieldView() -> some View {
        TextField("Repeat password", text: $viewModel.confirmPassword.max(viewModel.characterLimit))
            .keyboardType(.numberPad)
            .padding(.vertical, 10)
            .modifier(SectionStyle())
    }
}

struct SetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        SetPasswordView(viewModel: SetPasswordViewModel())
    }
}
