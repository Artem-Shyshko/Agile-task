//
//  NewAccountView.swift
//  Master Task
//
//  Created by Artur Korol on 07.09.2023.
//

import SwiftUI
import RealmSwift

struct NewProjectView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @ObservedResults(Account.self) var accounts
    @ObservedRealmObject var account: Account
    @Environment(\.dismiss) var dismiss
    
    @State var accountName: String = ""
    @State var editMode: Bool = false
    @State var searchIsActive: Bool = false
    
    var body: some View {
        VStack {
            if !editMode {
                TextField("Enter name for new account", text: $accountName)
            } else {
                TextField("Enter new name", text: $account.name)
            }
            Spacer()
        }
        .padding(.top, 30)
        .navigationTitle("Projects")
        .textFieldStyle(NewTextFieldStyle())
        .modifier(TabViewChildModifier())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                cancelButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                saveButton()
            }
        }
        .onAppear {
            accountName = account.name
        }
    }
}

private extension NewProjectView {
    func saveButton() -> some View {
        Button {
            if !editMode {
                guard purchaseManager.hasUnlockedPro else { return }
                
                guard !accountName.isEmpty else { return }
                let newAccount = Account()
                newAccount.name = accountName
                $accounts.append(newAccount)
            }
            dismiss.callAsFunction()
        } label: {
            Text("Save")
        }
    }
    
    func cancelButton() -> some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("Cancel")
        }
        .foregroundColor(.white)
    }
}

struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NewProjectView(account: Account())
            .environmentObject(PurchaseManager())
    }
}
