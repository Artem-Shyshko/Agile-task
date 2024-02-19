//
//  AuthManager.swift
//  Agile Task
//
//  Created by Artur Korol on 09.10.2023.
//

import LocalAuthentication

final class AuthManager: ObservableObject {
    @Published var state: AuthState = .noneAuth
    
    func auth() {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print(error?.localizedDescription ?? "Can't use device Owner Authentication With Biometrics")
            return
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Log in to your account") { success, error in
                Task { @MainActor in
                    self.state = success ? .loggedIn : .noneAuth
                }
            }
    }
}

enum AuthState {
    case loggedIn
    case error
    case noneAuth
}
