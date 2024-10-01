//
//  RecordInfoView.swift
//  Agile Task
//
//  Created by USER on 15.04.2024.
//

import SwiftUI
import RealmSwift

struct RecordInfoView: View {
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: RecordInfoViewModel
    @FocusState var isFocused: Bool
    
    @State var isShowingBulletView: Bool = false
    @State var isSharePresented = false
    @State var textToCopy = "hello"
    @State var isTextCopied = false
    @State private var showPasswordView = false
    @State private var showAuthView = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
           navigationBar()
            if viewModel.protectWith == .none {
                mainInfoView()
            } else {
                VStack(spacing: 80) {
                    Spacer()
                    lockSceen()
                }
            }
        }
        .modifier(TabViewChildModifier())
        .onAppear {
            viewModel.startTimer()
            isFocused = true
        }
        
        .onChange(of: viewModel.isScreenClose) { _ in
            dismiss.callAsFunction()
        }
        .onChange(of: isTextCopied) { isTextCopied in
            if isTextCopied {
                viewModel.copy(text: textToCopy)
            }
        }
        .onChange(of: showPasswordView) { new in
            if new == false {
                viewModel.protectWith = .none
            }
        }
        .onChange(of: showAuthView) { newValue in
            if newValue {
                authManager.auth()
            } else {
                viewModel.protectWith = .none
            }
        }
        .onReceive(authManager.$state) { newValue in
            if newValue == .loggedIn {
                showAuthView = false
            }
        }
        .fullScreenCover(isPresented: $showPasswordView) {
            AuthenticationView(viewModel: AuthenticationViewModel(appState: viewModel.appState),
                     isShowing: $showPasswordView,
                     recordProtect: viewModel.protectWith.securityOption)
        }
        .alert(LocalizedStringKey("data_is_copied"),
               isPresented: $viewModel.showCopyAlert) {
            Button("alert_ok") {
                viewModel.showCopyAlert = false
            }
        }
    }
}

// MARK: - Subviews
private extension RecordInfoView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: backButton(),
            header: NavigationTitle(LocalizedStringKey(viewModel.record.openRecordInfo.title)),
            rightItem: Color(.clear).frame(width: Constants.shared.imagesSize)
        )
    }
    
    func backButton() -> some View {
        backButton {
            dismiss.callAsFunction()
        }
    }
    
    func lockSceen() -> some View {
        VStack(alignment: .center, spacing: 20) {
            Text("record_locked")
                .font(.helveticaRegular(size: 16))
                .foregroundColor(.white)
            Image(.lock)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 60)
            Button {
                switch viewModel.record.settingsRecordInfo.protectWith {
                case .faceID:
                    showAuthView = true
                case .password:
                    showPasswordView = true
                case .none:
                    break
                }
            } label: {
                Text("view_record")
                    .font(.helveticaBold(size: 16))
                    .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(themeManager.theme.sectionColor(colorScheme))
                    .cornerRadius(3)
                    .padding(.horizontal, 50)
                    .preferredColorScheme(themeManager.theme.colorScheme)
            }
            Spacer()
        }
    }
    
    func mainInfoView() -> some View {
        List {
            Section() {
                HStack {
                    Text("account_userName")
                        .font(.helveticaLight(size: 16))
                    Spacer()
                    Text(viewModel.record.protectedRecordInfo.userName)
                    Button {
                        textToCopy = "Account: \(viewModel.record.protectedRecordInfo.userName)"
                        isSharePresented = true
                    } label: {
                        Image(.shareRecord)
                    }
                    .buttonStyle(.borderless)
                    
                    Button {
                        textToCopy = "Account: \(viewModel.record.protectedRecordInfo.userName)"
                        viewModel.copy(text: textToCopy)
                    } label: {
                        Image(.copyRecord)
                    }
                    .buttonStyle(.borderless)
                }
                
                HStack {
                    Text("password_title")
                        .font(.helveticaLight(size: 16))
                        .foregroundColor(viewModel.password.isEmpty ? .gray : .primary)
                    Spacer()
                    Text(viewModel.password)
                    
                    Button {
                        textToCopy = "Password: \(viewModel.password)"
                        isSharePresented = true
                    } label: {
                        Image(.shareRecord)
                    }
                    .buttonStyle(.borderless)
                    
                    Button {
                        textToCopy = "Password: \(viewModel.password)"
                        viewModel.copy(text: textToCopy)
                    } label: {
                        Image(.copyRecord)
                    }
                    .buttonStyle(.borderless)
                }
                
                InfoView(viewModel: viewModel.fieldsInfoModel,
                         copyText: $textToCopy,
                         isSharePresented: $isSharePresented,
                         isTextCopied: $isTextCopied)
            }
            .padding(.horizontal, -7)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(themeManager.theme.sectionColor(colorScheme).name))
            )
        }
        .sheet(isPresented: $isSharePresented) {
            ShareViewController(textToCopy: $textToCopy)
        }
        .scrollContentBackground(.hidden)
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .listRowSpacing(Constants.shared.listRowSpacing)
    }
}
