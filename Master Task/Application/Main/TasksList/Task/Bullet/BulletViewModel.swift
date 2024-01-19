//
//  BulletViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import Foundation
import RealmSwift

final class BulletViewModel: ObservableObject {
    let taskRepository = TaskRepositoryImpl()
    @Published var deletedBullets: [BulletDTO] = []
    @Published var bulletArray: [BulletDTO] = []
    @Published var showDeleteAlert = false
    @Published var deletedCheckboxIndex = 0
    
    func onSubmit(checkBoxesCount: Int, textFieldIndex: Int, focusedInput: inout Int?) {
        if textFieldIndex < checkBoxesCount {
            focusedInput = textFieldIndex + 1
        } else {
            focusedInput = nil
        }
    }
    
    func trashButtonAction(task: TaskDTO?, index: Int) {
        if let task {
            guard task.bulletArray.contains(where: { $0.id == bulletArray[index].id }) else { return }
            
            deletedBullets.append(bulletArray[index])
        }
        
        bulletArray.remove(at: index)
    }
    
    func saveButtonAction(task: TaskDTO?, taskBullets: inout [BulletDTO]) {
        if let task {
            deletedBullets.forEach { deletedBullet in
                taskRepository.deleteBullet(task.id, bulletId: deletedBullet.id)
            }
        }
        
        taskBullets = bulletArray
    }
    
    func move(from source: IndexSet, to destination: Int) {
        bulletArray.move(fromOffsets: source, toOffset: destination)
    }
}
