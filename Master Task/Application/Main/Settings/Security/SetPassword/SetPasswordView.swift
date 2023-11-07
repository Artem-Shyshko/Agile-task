//
//  SetPasswordView.swift
//  Master Task
//
//  Created by Artur Korol on 09.10.2023.
//

import SwiftUI

struct SetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: SetPasswordViewModel
    private let defaults = UserDefaults.standard
    
    var body: some View {
        VStack(spacing: 1) {
            if let userPassword = defaults.string(forKey: MasterTaskConstants.shared.userPassword) {
                TextField("Enter old password", text: $viewModel.oldPassword.max(viewModel.characterLimit))
                    .keyboardType(.numberPad)
                    .padding(.vertical, 10)
                    .modifier(SectionStyle())
            }
            TextField("Password", text: $viewModel.newPassword.max(viewModel.characterLimit))
                .keyboardType(.numberPad)
                .padding(.vertical, 10)
                .modifier(SectionStyle())
            TextField("Repeat password", text: $viewModel.confirmPassword.max(viewModel.characterLimit))
                .keyboardType(.numberPad)
                .padding(.vertical, 10)
                .modifier(SectionStyle())
            Spacer()
        }
        .padding(.top, 25)
        .modifier(TabViewChildModifier())
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if defaults.value(forKey: MasterTaskConstants.shared.userPassword) == nil {
                        if viewModel.newPassword == viewModel.confirmPassword {
                            defaults.setValue(viewModel.confirmPassword, forKey: MasterTaskConstants.shared.userPassword)
                            dismiss.callAsFunction()
                        }
                    } else {
                        if let password = defaults.value(forKey: MasterTaskConstants.shared.userPassword) as? String,
                           password == viewModel.oldPassword,
                           viewModel.newPassword == viewModel.confirmPassword {
                            defaults.set(viewModel.confirmPassword, forKey: MasterTaskConstants.shared.userPassword)
                            dismiss.callAsFunction()
                        }
                    }
                } label: {
                    Text("Save")
                }
                .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss.callAsFunction()
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.white)
            }
        })
    }
}

struct SetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        SetPasswordView(viewModel: SetPasswordViewModel())
            .environmentObject(AppThemeManager())
    }
}
