//
//  NewCheckBoxViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 30.10.2023.
//

import Foundation
import RealmSwift

final class NewCheckBoxViewModel: ObservableObject {
    let taskRepository = TaskRepositoryImpl()
    var deletedCheckboxes: [CheckboxDTO] = []
    @Published var checkboxes: [CheckboxDTO] = []
    @Published var deletedCheckboxIndex = 0
    
    func onSubmit(checkBoxesCount: Int, textFieldIndex: Int, focusedInput: inout Int?) {
        if textFieldIndex < checkBoxesCount {
            focusedInput = textFieldIndex + 1
        } else {
            focusedInput = nil
        }
    }
    
    func trashButtonAction(task: TaskDTO?) {
        if let task {
            guard task.checkBoxArray.contains(where: { $0.id == checkboxes[deletedCheckboxIndex].id }) else {
                checkboxes.remove(at: deletedCheckboxIndex)
                return
            }
            deletedCheckboxes.append(checkboxes[deletedCheckboxIndex])
        }
        checkboxes.remove(at: deletedCheckboxIndex)
    }
    
    func saveButtonAction(task: TaskDTO?, taskCheckboxes: inout [CheckboxDTO]) {
        if let task {
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
