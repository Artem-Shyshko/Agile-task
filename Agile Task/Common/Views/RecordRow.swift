//
//  RecordRow.swift
//  Agile Task
//
//  Created by USER on 08.04.2024.
//

import SwiftUI

struct RecordRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var vm: RecordListViewModel
    
    @State private var isShowingDeleteAlert = false
    @State private var isContentExpanded = false
    @State private var isSharePresented = false
    @State private var showAuthView = false
    @State private var showPasswordView = false
    @State private var isDeleting = false
    @State private var copyRecord = false
    @State private var shareRecord = false
    @State private var textToCopy = ""
    
    @Binding var path: [SecuredNavigationView]
    
    var record: RecordDTO
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 7) {
                if !record.openRecordInfo.bulletInfo.isEmpty || !record.openRecordInfo.recordDescription.isEmpty { chevronButton() }
                Text(record.openRecordInfo.title)
                    .font(.helveticaRegular(size: 16))
                    .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
                Spacer()
                actionButtons()
            }
            .onAppear(perform: {
                textToCopy = CopyRecordHelper(record: record).copiedText
            })
            .sheet(isPresented: $isSharePresented) {
                ShareViewController(textToCopy: $textToCopy)
            }
            .padding(.horizontal, -7)
            .contentShape(Rectangle())
            .onTapGesture {
                    path.append(.recordInfo(record: record))
            }
            .frame(height: 22)
            
            if isContentExpanded {
                VStack(spacing: 3) {
                    Divider()
                        .modifier(TabViewChildModifier())
                        .background(.clear)
                        .frame(height: 2)
                        .padding(.vertical, 3)
                    if !record.openRecordInfo.recordDescription.isEmpty {
                        Text(record.openRecordInfo.recordDescription)
                            .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
                            .font(.helveticaRegular(size: 14))
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    bulletList()
                }
                .padding(.horizontal, -7)
            }
        }
        .fullScreenCover(isPresented: $showPasswordView) {
            AuthView(vm: AuthViewModel(appState: vm.appState),
                     isShowing: $showPasswordView,
                     recordPrptect: record.settingsRecordInfo.protectWith.securityOption)
        }
        .onChange(of: showPasswordView) { newValue in
            if newValue == false {
                performActionAfterAuth()
            }
        }
        .onChange(of: isDeleting) { newValue in
            if newValue == false {
                performActionAfterAuth()
            }
        }
        .onChange(of: showAuthView) { newValue in
            if newValue {
                authManager.auth()
            } else {
                performActionAfterAuth()
            }
        }
        .onReceive(authManager.$state) { newValue in
            if newValue == .loggedIn {
                showAuthView = false
            }
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(themeManager.theme.sectionColor(colorScheme))
                .padding(.trailing, 12)
                .overlay(alignment: .trailing, content: {
                    Image(.swipes)
                        .padding(.trailing, 2)
                })
        )
        .padding(.trailing, 12)
        .swipeActions {
            Button {
                switch record.settingsRecordInfo.protectWith {
                case .faceID:
                    showAuthView = true
                    isDeleting = true
                case .password:
                    showPasswordView = true
                    isDeleting = true
                case .none:
                    isShowingDeleteAlert = true
                }
            } label: {
                Image("trash")
            }
            .tint(Color.red)
            
            Button {
                path.append(.createRecord(record: record))
            } label: {
                Image(.edit)
            }
            .tint(Color.editButtonColor)
        }
        .alert("are_you_sure_you_want_to_delete", isPresented: $isShowingDeleteAlert) {
            Button("cancel_button", role: .cancel) { }
            
            Button("delete") {
                vm.deleteRecord(record)
            }
        }
    }
    
    private func performActionAfterAuth() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if shareRecord {
                isSharePresented = true
                shareRecord = false
            } else if copyRecord {
                vm.copy(record: record)
                copyRecord = false
            } else if isDeleting {
                isShowingDeleteAlert = true
            } else {
                path.append(.recordInfo(record: record))
            }
        }
    }
}

// MARK: - Private Views
private extension RecordRow {
    func actionButtons() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Button {
                switch record.settingsRecordInfo.protectWith {
                case .faceID:
                    showAuthView = true
                    shareRecord = true
                case .password:
                    showPasswordView = true
                    shareRecord = true
                case .none:
                    isSharePresented = true
                }
            } label: {
                Image(.shareRecord)
            }
            .buttonStyle(.borderless)
            
            Button {
                switch record.settingsRecordInfo.protectWith {
                case .faceID:
                    showAuthView = true
                    copyRecord = true
                case .password:
                    showPasswordView = true
                    copyRecord = true
                case .none:
                    vm.copy(record: record)
                }
            } label: {
                Image(.copyRecord)
            }
            .buttonStyle(.borderless)
        }
    }
    
    func chevronButton() -> some View {
        Button {
            isContentExpanded.toggle()
        } label: {
            Image(systemName: isContentExpanded ? "chevron.down" : "chevron.right")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
                .frame(width: 10, height: 10)
                .padding(.vertical, 5)
        }
        .buttonStyle(.borderedProminent)
        .tint(.clear)
        .frame(width: 10)
    }
    
    func bulletList() -> some View {
        ForEach(record.openRecordInfo.bulletInfo , id: \.self) { bullet in
            HStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
                Text(bullet.title)
                    .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
                    .font(.helveticaRegular(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
            }
        }
    }
}
