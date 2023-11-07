//
//  AccountView.swift
//  Master Task
//
//  Created by Artur Korol on 07.09.2023.
//

import SwiftUI
import RealmSwift

struct ProjectsView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var theme: AppThemeManager
    @ObservedResults(Account.self) var savedAccounts
    @State var isAlert = false
    @State var isSearchBarHidden: Bool = true
    @State var searchText: String = ""
    
    private var accounts: [Account] {
      let accounts = Array(savedAccounts)
      if !searchText.isEmpty {
        return accounts
              .filter({$0.name.contains(searchText)})
      } else {
        return accounts
      }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                topView()
                if !isSearchBarHidden {
                    SearchableView(searchText: $searchText, isSearchBarHidden: $isSearchBarHidden)
                        .foregroundColor(theme.selectedTheme.textColor)
                }
                accountsList()
                Spacer()
            }
            .modifier(TabViewChildModifier())
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView()
            .environmentObject(UserState())
            .environmentObject(AppThemeManager())
    }
}

private extension ProjectsView {
    func accountsList() -> some View {
        List {
            ForEach(accounts) { account in
                AccountRow(account: account)
                    .foregroundColor(theme.selectedTheme.sectionTextColor)
                    .swipeActions {
                        NavigationLink {
                            NewProjectView(account: account, editMode: true)
                        } label: {
                            Image("done-checkbox")
                        }
                        .tint(Color.editButtonColor)
                        
                        if account.name != userState.selectedAccount {
                            Button {
                                isAlert = true
                            } label: {
                                Image("trash")
                            }
                            .tint(Color.red)
                        }
                    }
                    .alert("Are you sure you want to delete", isPresented: $isAlert) {
                        Button("Cancel", role: .cancel) {
                            isAlert = false
                        }
                        
                        Button("Delete") {
                            $savedAccounts.remove(account)
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.selectedTheme.sectionColor)
                            .padding(.top, 1)
                    )
            }
            .listRowSeparator(.hidden)
            .scrollContentBackground(.hidden)
        }
        .listRowSpacing(MasterTaskConstants.shared.listRowSpacing)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .padding(.top, 25)
    }
    
    func topView() -> some View {
        HStack {
            Button {
                isSearchBarHidden.toggle()
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            }
            
            Spacer()
            Text("Projects")
                .font(.helveticaBold(size: 16))
                .foregroundStyle(theme.selectedTheme.textColor)
            Spacer()
            
            NavigationLink {
                NewProjectView(account: Account())
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
}

struct AccountRow: View {
    @EnvironmentObject var userState: UserState
    @StateRealmObject var account: Account
    @ObservedResults(Account.self) var savedAccounts
    @Environment(\.realm) var realm
    
    var body: some View {
        Button {
            userState.selectedAccount = account.name
            savedAccounts.forEach { update(id: $0.id, isSelected: false)}
            update(id: account.id, isSelected: true)
        } label: {
            HStack(spacing: 5) {
                if account.isSelected { checkMark }
                
                Text(account.name)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var checkMark: some View {
        Image("Check")
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
    }
    
    func update(id: ObjectId, isSelected: Bool) {
        guard let edited = realm.object(ofType: Account.self, forPrimaryKey: id) else { return }
        do {
            let accountRealm = savedAccounts.thaw()!.realm!
            try accountRealm.write {
                edited.isSelected = isSelected
            }
        } catch {
            print("Error")
        }
    }
}
