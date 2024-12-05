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
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AuthenticationViewModel
    @FocusState private var keyboardFocused: Bool
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack {
                navigationBar
                ZStack {
                    TextField("", text: $viewModel.password)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .foregroundColor(.clear)
                        .accentColor(.clear)
                        .focused($keyboardFocused)
                        .onAppear {
                            keyboardFocused = true
                        }
                    
                    HStack {
                        ForEach(0..<(viewModel.passwordCount), id: \.self) { index in
                            PasswordCircleView(index: index,
                                               geometry: geometry,
                                               password: $viewModel.password,
                                               passwordCount: $viewModel.passwordCount)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .modifier(TabViewChildModifier())
        }
        .onChange(of: viewModel.password) { newValue in
            viewModel.checkPassword()
            if viewModel.isRightPassword {
                authManager.state = .loggedIn
            }
        }
        .alert("alert_wrong_password", isPresented: $viewModel.showAlert) {
            Button {
                viewModel.showAlert = false
            } label: {
                Text("alert_ok")
            }
        }
    }
}

private extension PasswordView {
    var navigationBar: some View {
        NavigationBarView(
            leftItem: cancelButton,
            header: EmptyView(),
            rightItem: EmptyView()
        )
    }
    
    var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("cancel_button")
                .font(.helveticaRegular(size: 16))
        }
        .foregroundColor(.white)
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
    PasswordView(viewModel: AuthenticationViewModel(appState: AppState()))
}
