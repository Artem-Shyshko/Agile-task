//
//  AuthView.swift
//  Master Task
//
//  Created by Artur Korol on 10.10.2023.
//

import SwiftUI
import RealmSwift

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.scenePhase) var scene
    
    @Binding var isShowing: Bool
    @State var password: String = ""
    
    var body: some View {
        ZStack {
            theme.selectedTheme.backgroundColor
                .ignoresSafeArea()
            theme.selectedTheme.backgroundGradient
                .ignoresSafeArea()
            securityView()
        }
        .onAppear(perform: {
            authWithFaceId()
        })
        .onChange(of: scene) { scene in
            if isShowing, scene == .active {
                authWithFaceId()
            }
        }
        .onChange(of: password) { newValue in
            if password.count == 6 {
                if let userPassword = UserDefaults.standard.string(forKey: MasterTaskConstants.shared.userPassword),
                userPassword == password {
                    isShowing = false
                    authManager.state = .loggedIn
                }
            }
        }
    }
}

private extension AuthView {
    
    func securityView() -> some View {
        VStack {
            if let settings = RealmManager.shared.settings {
            
                switch settings.securityOption {
                case .password:
                    passwordView()
                case .faceID:
                    EmptyView()
                case .none:
                    EmptyView()
                }
            }
        }
    }
    
    func passwordView() -> some View {
        VStack {
            Spacer()
            HStack {
                ForEach(0..<6, id: \.self) { index in
                    PasswordView(index: index, password: $password)
                }
            }
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(1...9, id: \.self) { value in
                    PasswordButton(value: "\(value)", password: $password)
                }
                PasswordButton(value: "", password: $password)
                PasswordButton(value: "0", password: $password)
                PasswordButton(value: "delete.fill", password: $password)
            }
            .padding(.bottom, 15)
        }
    }
    
    func authWithFaceId() {
        guard let settings = RealmManager.shared.settings else {
            isShowing = false
            return
        }
        
        if settings.securityOption == .faceID {
            authManager.auth()
            isShowing = authManager.state == .loggedIn ? false : true
        }
    }
}

fileprivate struct PasswordView: View {
    var index: Int
    @Binding var password: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 30, height: 30)
            
            if password.count > index {
                Circle()
                    .fill(.white)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

fileprivate struct PasswordButton: View {
    var value: String
    @Binding var password: String
    
    var body: some View {
        Button(action: {
            setPassword()
        }, label: {
            VStack {
                if value.count > 1 {
                    Image(systemName: "delete.left")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                } else {
                    Text(value)
                        .font(.helveticaRegular(size: 16))
                        .foregroundStyle(.white)
                }
            }
            .padding()
        })
    }
    
    func setPassword() {
        if value.count > 1 {
            if password.count != 0 {
                password.removeLast()
            }
        } else {
            if password.count != 6 {
                password.append(value)
            }
        }
    }
}
