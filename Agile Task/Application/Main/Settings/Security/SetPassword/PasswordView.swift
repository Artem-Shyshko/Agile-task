//
//  PasswordView.swift
//  Agile Task
//
//  Created by Artur Korol on 15.04.2024.
//

import SwiftUI

struct PasswordView: View {
    // MARK: - Properties
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var vm: AuthViewModel
    @FocusState private var keyboardFocused: Bool
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                themeManager.theme.gradient(colorScheme)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    ZStack {
                        TextField("", text: $vm.password)
                            .keyboardType(.alphabet)
                            .disableAutocorrection(true)
                            .foregroundColor(.clear)
                            .accentColor(.clear)
                            .focused($keyboardFocused)
                            .onAppear {
                                keyboardFocused = true
                            }
                        
                        HStack {
                            ForEach(0..<(vm.passwordCount), id: \.self) { index in
                                PasswordCircleView(index: index,
                                                   geometry: geometry,
                                                   password: $vm.password,
                                                   passwordCount: $vm.passwordCount)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .modifier(TabViewChildModifier())
        }
        .onChange(of: vm.password) { newValue in
            vm.checkPassword()
            if vm.isRightPassword {
                authManager.state = .loggedIn
            }
        }
        .alert("alert_wrong_password", isPresented: $vm.showAlert) {
            Button {
                vm.showAlert = false
            } label: {
                Text("alert_ok")
            }
        }
    }
}

// MARK: - PasswordCircleView
struct PasswordCircleView: View {
    var index: Int
    var geometry: GeometryProxy
    @Binding var password: String
    @Binding var passwordCount: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white, lineWidth: 2)
                .frame(width: calculateCircleSize(geometry: geometry),
                       height: calculateCircleSize(geometry: geometry))
            
            if password.count > index {
                Circle()
                    .fill(.white)
                    .frame(width: calculateCircleSize(geometry: geometry),
                           height: calculateCircleSize(geometry: geometry))
            }
            
        }
    }
    
    private func calculateCircleSize(geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let numberOfCircles = CGFloat(passwordCount)
        let totalSpacing = screenWidth - 10 * numberOfCircles
        let circleSize = totalSpacing / numberOfCircles
        
        return min(circleSize, 30)
    }
}


#Preview {
    PasswordView(vm: AuthViewModel(appState: AppState()))
}
