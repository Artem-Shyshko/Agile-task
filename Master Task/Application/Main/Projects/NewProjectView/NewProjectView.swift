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
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: NewProjectViewModel
    
    var body: some View {
        VStack {
            navigationBar()
            textFieldView()
            Spacer()
        }
        .textFieldStyle(NewTextFieldStyle())
        .modifier(TabViewChildModifier())
    }
}

private extension NewProjectView {
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: cancelButton(),
            header: NavigationTitle("Projects"),
            rightItem: saveButton()
        )
    }
    
    func textFieldView() -> some View {
        TextField(
            vm.editedProject == nil ? "Enter new name" : "Enter name for new account",
            text: $vm.projectName
        )
    }
    
    func saveButton() -> some View {
        Button {
            let isSaved = vm.saveButtonAction(purchaseManager: purchaseManager)
            
            if isSaved {
                dismiss.callAsFunction()
            }
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
        NewProjectView(vm: NewProjectViewModel(editedProject: ProjectDTO(ProjectObject())))
            .environmentObject(PurchaseManager())
    }
}
