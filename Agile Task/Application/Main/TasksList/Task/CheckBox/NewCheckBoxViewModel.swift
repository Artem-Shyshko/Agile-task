//
//  NewCheckBoxViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 30.10.2023.
//

import Foundation
import RealmSwift

final class NewCheckBoxViewModel: ObservableObject {
    let taskRepository = TaskRepositoryImpl()
    var deletedCheckboxes: [CheckboxDTO] = []
    @Published var checkboxes: [CheckboxDTO] = []
    @Published var deletedCheckbox: CheckboxDTO?
    
    func onSubmit(checkBoxesCount: Int, textFieldIndex: Int, focusedInput: inout Int?) {
        if textFieldIndex < checkBoxesCount {
            focusedInput = textFieldIndex + 1
        } else {
            focusedInput = nil
        }
    }
    
    func trashButtonAction(task: TaskDTO?) {
        guard let deletedCheckbox else { return }
        if let task {
            guard task.checkBoxArray.contains(where: { $0.id == deletedCheckbox.id }) else {
                checkboxes.removeAll(where: { $0.id == deletedCheckbox.id })
                return
            }
            deletedCheckboxes.append(deletedCheckbox)
        }
        checkboxes.removeAll(where: { $0.id == deletedCheckbox.id })
    }
    
    func focusNumber(checkbox: CheckboxDTO) -> Int {
        if let index = checkboxes.firstIndex(where: { $0.id == checkbox.id}) {
            return index
        }
        
        return 0
    }
    
    func saveButtonAction(task: TaskDTO?, taskCheckboxes: inout [CheckboxDTO]) {
        if let task {
            checkboxes.forEach {
                if $0.title.isEmpty {
                    deletedCheckboxes.append($0)
                }
            }
            
            deletedCheckboxes.forEach { deletedCheckbox in
                taskRepository.deleteCheckbox(task.id, checkboxId: deletedCheckbox.id)
            }
        }
        
        taskCheckboxes = checkboxes
    }
    
    func move(from source: IndexSet, to destination: Int) {
        checkboxes.move(fromOffsets: source, toOffset: destination)
    }
}
