//
//  AuthView.swift
//  Agile Task
//
//  Created by Artur Korol on 10.10.2023.
//

import SwiftUI
import RealmSwift

struct AuthenticationView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scene
    
    @StateObject var viewModel: AuthenticationViewModel
    @Binding var isShowing: Bool
    @State var recordProtect: SecurityOption? = nil
    
    // MARK: - Body
    var body: some View {
        ZStack {
            themeManager.theme.gradient(colorScheme)
                .ignoresSafeArea()
            securityView()
        }
        .onAppear(perform: {
            viewModel.settings = viewModel.appState.settingsRepository!.get()
        })
        .onAppear(perform: {
            if scene == .active {
                authWithFaceId()
            }
        })
        .onChange(of: scene) { scene in
            if isShowing, scene == .active {
                authWithFaceId()
            }
        }
    }
}

// MARK: - Private setup
private extension AuthenticationView {
    func securityView() -> some View {
        VStack {
            let securityOption = recordProtect == nil ? viewModel.settings.securityOption : recordProtect
            if securityOption == .password {
                PasswordView(viewModel: viewModel)
            }
        }
    }
    
    func authWithFaceId() {
        let securityOption = recordProtect == nil ? viewModel.settings.securityOption : recordProtect
        if securityOption == .faceID {
            authManager.auth()
            isShowing = authManager.state == .loggedIn ? false : true
        }
    }
}
