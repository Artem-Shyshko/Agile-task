//
//  NewRecordView.swift
//  Agile Task
//
//  Created by USER on 09.04.2024.
//

import SwiftUI
import RealmSwift

struct NewRecordView: View {
    enum Field: Hashable {
        case title
        case description
        case password
    }
    
    // MARK: - Properties
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: NewRecordViewModel
    @FocusState private var isFocusedField: Field?
    
    @State var isShowingBulletView: Bool = false
    @State private var showPasswordView = false
    @State private var showAuthView = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            returnMainView()
        }
        .fullScreenCover(isPresented: $isShowingBulletView, content: {
            BulletView(
                viewModel: BulletViewModel(appState: appState),
                taskBulletArray: $viewModel.bulletInfo,
                isShowing: $isShowingBulletView
            )
        })
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
        .onChange(of: viewModel.isScreenClose) { _ in
            dismiss.callAsFunction()
        }
        .onReceive(authManager.$state) { newValue in
            if newValue == .loggedIn {
                showAuthView = false
            }
        }
        .fullScreenCover(isPresented: $showPasswordView) {
            AuthView(vm: AuthViewModel(appState: appState),
                     isShowing: $showPasswordView,
                     recordPrptect: viewModel.protectWith.securityOption)
        }
        .modifier(TabViewChildModifier())
        .alert(LocalizedStringKey("alert_wrong_fields_requirements"),
               isPresented: $viewModel.showErrorAlert) {
            Button("alert_ok") {
                viewModel.showErrorAlert = false
            }
        }
    }
}

// MARK: - Subviews
private extension NewRecordView {
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: cancelButton(),
            header: CustomSegmentedControl(
                options: TaskType.allCases,
                selection: $viewModel.taskType,
                textColor: themeManager.theme.sectionTextColor(colorScheme)
            ).padding(.horizontal, viewModel.settings.appLanguage == .ukrainian ? 35 : 15),
            rightItem: saveButton()
        )
    }
    
    func sectionTitle(title: String) -> some View {
        HStack {
            Spacer()
            Text(LocalizedStringKey(title))
                .font(.helveticaBold(size: 15))
                .foregroundStyle(.white)
            Spacer()
        }
    }
    
    @ViewBuilder
    func returnMainView() -> some View {
        if viewModel.protectWith != .none {
            VStack(spacing: 80) {
                Spacer()
                lockSceen()
            }
        } else {
            mainListOfFields()
        }
    }
    
    func recordTitle() -> some View {
        HStack {
            if viewModel.isEditing {
                Text("record_title")
                    .foregroundColor(viewModel.password.isEmpty ? .gray : .primary)
                    .onTapGesture {
                        isFocusedField = .title
                    }
                Spacer()
            }
            
            TextField("", text: $viewModel.title.max(Constants.shared.charactersLimit),
                      prompt: Text("record_title")
                .foregroundColor(.secondary))
            .accentColor(.primary)
            .multilineTextAlignment(viewModel.isEditing ? .trailing : .leading)
            .focused($isFocusedField, equals: .title)
            .onAppear {
                if viewModel.editedRecord == nil {
                    isFocusedField = .title
                }
            }
        }
    }
    
    func userNameView() -> some View {
        HStack {
            if viewModel.isEditing {
                Text("account_userName")
                    .font(.helveticaLight(size: 16))
                    .foregroundColor(viewModel.password.isEmpty ? .gray : .primary)
                    .onTapGesture {
                        isFocusedField = .password
                    }
                Spacer()
            }
            TextField("", text: $viewModel.account.max(Constants.shared.charactersLimit),
                      prompt: Text("account_userName")
            .foregroundColor(.secondary))
            .multilineTextAlignment(viewModel.isEditing ? .trailing : .leading)
            .accentColor(.primary)
        }
    }
    
    func passwordView() -> some View {
        HStack {
            if viewModel.isEditing {
                Text("password_title")
                    .font(.helveticaLight(size: 16))
                    .foregroundColor(viewModel.password.isEmpty ? .gray : .primary)
                    .onTapGesture {
                        isFocusedField = .password
                    }
                Spacer()
            }
            TextField("", text: $viewModel.password.max(Constants.shared.charactersLimit),
                      prompt: Text("password_title")
            .foregroundColor(.secondary))
            .multilineTextAlignment(viewModel.isEditing ? .trailing : .leading)
            .focused($isFocusedField, equals: .password)
            .accentColor(.primary)
        }
    }
    
    func protectionSelector() -> some View {
        CustomPickerView(
            image: nil,
            title: "protect_with",
            options: Protection.allCases,
            selection: $viewModel.protection,
            isSelected: false
        )
    }
    
    func autoCloseSelector() -> some View {
        CustomPickerView(
            image: nil,
            title: "auto_close",
            options: AutoClose.allCases,
            selection: $viewModel.autoClose,
            isSelected: false
        )
    }
    
    @ViewBuilder
    func mainListOfFields() -> some View {
        if viewModel.taskType == .advanced {
            advancedListOfFields()
        } else {
            simpleListOfFields()
        }
    }
    
    func advancedListOfFields() -> some View {
        List {
            Section() {
                recordTitle()
                descriptionView()
                bulletListView()
            }
            .padding(.horizontal, -5)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(themeManager.theme.sectionColor(colorScheme).name))
            )
            
            Section(header: sectionTitle(title: "record_details")) {
                userNameView()
                passwordView()
                
                FieldsInfoView(viewModel: viewModel.fieldsInfoModel,
                               isEditing: viewModel.isEditing)
            }
            .padding(.horizontal, -5)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(themeManager.theme.sectionColor(colorScheme).name))
            )
            
            Section(header: sectionTitle(title:"settings_title")) {
                protectionSelector()
                autoCloseSelector()
            }
            .padding(.horizontal, -5)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(themeManager.theme.sectionColor(colorScheme).name))
            )
        }
        .scrollContentBackground(.hidden)
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .listRowSpacing(Constants.shared.listRowSpacing)
        .padding(.bottom, 10)
    }
    
    func simpleListOfFields() -> some View {
        List {
            Section() {
                recordTitle()
            }
            .padding(.horizontal, -5)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(themeManager.theme.sectionColor(colorScheme).name))
            )
            
            Section(header: sectionTitle(title: "record_details")) {
                userNameView()
                passwordView()
            }
            .padding(.horizontal, -5)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(themeManager.theme.sectionColor(colorScheme).name))
            )
        }
        .scrollContentBackground(.hidden)
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .listRowSpacing(Constants.shared.listRowSpacing)
        .padding(.bottom, 10)
    }
    
    func descriptionView() -> some View {
        TextFieldWithEnterButton(placeholder: "description", text: $viewModel.description.max(200)) {
        }
        .focused($isFocusedField, equals: .description)
        .tint(themeManager.theme.sectionTextColor(colorScheme))
        .onTapGesture {
            isFocusedField = .description
        }
    }
    
    func bulletListView() -> some View {
        Button {
            isShowingBulletView = true
        } label: {
            HStack(spacing: 5) {
                Text("info_bulletlist")
                Spacer()
                Text(viewModel.bulletInfo.isEmpty ? "add" : "edit")
            }
        }
        .tint(viewModel.bulletInfo.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
        .foregroundColor(viewModel.bulletInfo.isEmpty ? .gray : themeManager.theme.sectionTextColor(colorScheme))
    }
    
    @ViewBuilder
    func saveButton() -> some View {
        switch viewModel.protectWith {
        case .none:
            Button {
                if viewModel.taskType == .advanced {
                    guard purchaseManager.hasUnlockedPro == true else {
                        appState.securedNavigationStack.append(.purchase)
                        return
                    }
                }
                viewModel.saveRecord()
                if viewModel.showErrorAlert != true {
                    dismiss.callAsFunction()
                }
            } label: {
                Text("save_button")
            }
        default: Color.clear.frame(size: Constants.shared.imagesSize)
        }
    }
    
    func cancelButton() -> some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("cancel_button")
        }
        .foregroundColor(.white)
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
                switch viewModel.editedRecord?.settingsRecordInfo.protectWith {
                case .faceID:
                    showAuthView = true
                case .password:
                    showPasswordView = true
                default: break
                }
            } label: {
                Text("view_record")
                    .font(.helveticaBold(size: 16))
                    .foregroundColor(Color.black)
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
}

// MARK: - FieldsType
enum FieldsType: String, PersistableEnum, CaseIterable, CustomStringConvertible, Equatable {
    case title = "title_field"
    case password = "password_field"
    case email = "e-mail_field"
    case url = "URL_field"
    case number = "number_field"
    case date = "date_field"
    case bulletList = "bullet_list_field"
    case address = "address_field"
    case phone = "phone_field"
    
    var description: String {
        self.rawValue
    }
    
    var keyboard: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .url:
            return .URL
        case .number:
            return .decimalPad
        case .phone:
            return .phonePad
        default: return .alphabet
        }
    }
}
