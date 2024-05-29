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
    @Published var deletedBullet: BulletDTO?
    
    func onSubmit(checkBoxesCount: Int, textFieldIndex: Int, focusedInput: inout Int?) {
        if textFieldIndex < checkBoxesCount {
            focusedInput = textFieldIndex + 1
        } else {
            focusedInput = nil
        }
    }
    
    func trashButtonAction(task: TaskDTO?) {
        guard let deletedBullet else { return }
        if let task {
            guard task.bulletArray.contains(where: { $0.id == deletedBullet.id }) else {
                bulletArray.removeAll(where: { $0.id == deletedBullet.id })
                return
            }
            deletedBullets.append(deletedBullet)
        }
        bulletArray.removeAll(where: { $0.id == deletedBullet.id })
    }
    
    func focusNumber(bullet: BulletDTO) -> Int {
        if let index = bulletArray.firstIndex(where: { $0.id == bullet.id}) {
            return index
        }
        
        return 0
    }
    
    func saveButtonAction(task: TaskDTO?, taskBullets: inout [BulletDTO]) {
        if let task {
            bulletArray.forEach {
                if $0.title.isEmpty {
                    deletedBullets.append($0)
                }
            }
            
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
