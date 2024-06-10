//
//  AuthView.swift
//  Agile Task
//
//  Created by Artur Korol on 10.10.2023.
//

import SwiftUI
import RealmSwift

struct AuthView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scene
    
    @StateObject var vm: AuthViewModel
    @Binding var isShowing: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            themeManager.theme.gradient(colorScheme)
                .ignoresSafeArea()
            securityView()
        }
        .onAppear(perform: {
            vm.settings = vm.appState.settingsRepository!.get()
            authWithFaceId()
        })
        .onChange(of: scene) { scene in
            if isShowing, scene == .active {
                authWithFaceId()
            }
        }
    }
}

// MARK: - Private setup
private extension AuthView {
    func securityView() -> some View {
        VStack {
            if vm.settings.securityOption == .password {
                PasswordView(vm: vm)
            }
        }
    }
    
    func authWithFaceId() {
        if vm.settings.securityOption == .faceID {
            authManager.auth()
            isShowing = authManager.state == .loggedIn ? false : true
        }
    }
}
