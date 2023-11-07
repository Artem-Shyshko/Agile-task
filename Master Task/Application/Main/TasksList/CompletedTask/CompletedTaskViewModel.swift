//
//  CompletedTaskViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 18.10.2023.
//

import SwiftUI
import RealmSwift

final class CompletedTaskViewModel: ObservableObject {
    @Published var taskArray: [TaskObject] = Account.completedTasks()
    @Published var isSearchBarHidden: Bool = true
    @Published var searchText: String = ""
    
    private var realm = try! Realm()
    
    func updateTask(_ task: TaskObject) {
        guard let updateObject = realm.object(ofType: TaskObject.self, forPrimaryKey: task.id) else { return }
        do {
            try realm.write {
                updateObject.isCompleted.toggle()
            }
        } catch {
            print(error)
        }
        
        taskArray = Account.completedTasks()
    }
    
    func deleteTask(_ task: TaskObject) {
        do {
            guard let updateObject = realm.object(ofType: TaskObject.self, forPrimaryKey: task.id) else { return }
            let realm = updateObject.thaw()!.realm!
            try realm.write {
                realm.delete(updateObject)
            }
        } catch {
            print(error)
        }
        
        taskArray = Account.completedTasks()
    }
}
