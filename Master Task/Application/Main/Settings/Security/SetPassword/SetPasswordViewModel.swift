//
//  SetPasswordViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 09.10.2023.
//

import Foundation

final class SetPasswordViewModel: ObservableObject {
    let characterLimit = 6
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
}
