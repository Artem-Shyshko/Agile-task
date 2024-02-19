//
//  AuthView.swift
//  Agile Task
//
//  Created by Artur Korol on 10.10.2023.
//

import SwiftUI
import RealmSwift

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scene
    
    @StateObject var vm: AuthViewModel
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            themeManager.theme.gradient(colorScheme)
                .ignoresSafeArea()
            securityView()
        }
        .onAppear(perform: {
            vm.settings = vm.settingsRepository.get()
            authWithFaceId()
        })
        .onChange(of: scene) { scene in
            if isShowing, scene == .active {
                authWithFaceId()
            }
        }
        .onChange(of: vm.password) { newValue in
            if vm.password.count == 6,
                let userPassword = UserDefaults.standard.string(forKey: Constants.shared.userPassword) {
                if userPassword == vm.password {
                    isShowing = false
                    authManager.state = .loggedIn
                } else {
                    vm.showAlert = true
                }
            }
        }
        .alert("Wrong password", isPresented: $vm.showAlert) {
            Button {
                vm.showAlert = false
            } label: {
                Text("OK")
            }
        }
    }
}

private extension AuthView {
    
    func securityView() -> some View {
        VStack {
            if vm.settings.securityOption == .password {
                passwordView()
            }
        }
    }
    
    func passwordView() -> some View {
        VStack {
            Spacer()
            HStack {
                ForEach(0..<6, id: \.self) { index in
                    PasswordView(index: index, password: $vm.password)
                }
            }
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(1...9, id: \.self) { value in
                    PasswordButton(value: "\(value)", password: $vm.password)
                }
                PasswordButton(value: "", password: $vm.password)
                PasswordButton(value: "0", password: $vm.password)
                PasswordButton(value: "delete.fill", password: $vm.password)
            }
            .padding(.bottom, 15)
        }
    }
    
    func authWithFaceId() {
        if vm.settings.securityOption == .faceID {
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
