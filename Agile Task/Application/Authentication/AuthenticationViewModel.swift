//
//  AuthViewModel.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import SwiftUI

final class AuthenticationViewModel: ObservableObject {
    @Published var password: String = ""
    @Published var passwordCount: Int = 6
    @Published var showAlert: Bool = false
    @Published var settings: SettingsDTO
    @Published var isRightPassword: Bool = false
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        settings = appState.settingsRepository!.get()
        getPasswordCount()
    }
    
    func getPasswordCount() {
        guard let userPassword = UserDefaults.standard.string(forKey: Constants.shared.userPassword) else { return }
        
        passwordCount = userPassword.count
    }
    
    func checkPassword() {
        let userPassword = UserDefaults.standard.string(forKey: Constants.shared.userPassword)
        if password.count == userPassword?.count {
            if userPassword == password {
                isRightPassword = true
            } else {
                showAlert = true
            }
        }
    }
}
