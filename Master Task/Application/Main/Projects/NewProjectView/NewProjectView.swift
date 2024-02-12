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
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            navigationBar()
            textFieldView()
            Spacer()
        }
        .textFieldStyle(NewTextFieldStyle())
        .modifier(TabViewChildModifier())
        .onAppear {
            isFocused = true
        }
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
        TextField("Enter project name", text: $vm.projectName)
            .focused($isFocused)
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
