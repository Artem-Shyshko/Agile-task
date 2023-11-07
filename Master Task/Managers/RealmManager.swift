//
//  RealmManager.swift
//  Master Task
//
//  Created by Artur Korol on 10.10.2023.
//

import RealmSwift
import SwiftUI

final class RealmManager: ObservableObject {
    static let shared = RealmManager()
    
    private(set) var localRealm: Realm?
    @Published var allTasks: [TaskObject] = []
    
    init() {
        openRealm()
        getAllTask()
    }
    
    func openRealm() {
        do {
            let configuration = Realm.Configuration(schemaVersion: 1)
            
            Realm.Configuration.defaultConfiguration = configuration
            localRealm = try Realm()
            
        } catch {
            print("Error opening Realm: \(error.localizedDescription)")
        }
    }
    var settings: TaskSettings? {
        if let localRealm = localRealm {
            return localRealm.objects(TaskSettings.self).first
        }
        return nil
    }
    
    var account: Account? {
        if let localRealm = localRealm {
            return localRealm.objects(Account.self).first(where: {$0.isSelected})
        }
        return nil
    }
    
    func getAllTask() {
        guard let localRealm else { return }
        let allTasks = localRealm.objects(TaskObject.self)
        self.allTasks = []
        
        allTasks.forEach {
            self.allTasks.append($0)
        }
    }
    
    func deleteTask(_ task: TaskObject) {
        guard let localRealm  else { return }
        do {
            guard let taskToDelete = localRealm.object(ofType: TaskObject.self, forPrimaryKey: task.id) else { return }
            
            try localRealm.write {
                localRealm.delete(taskToDelete)
                getAllTask()
            }
        } catch {
            print("Error deleting")
        }
    }
}
