//
//  Account.swift
//  Master Task
//
//  Created by Artur Korol on 07.09.2023.
//

import Foundation
import RealmSwift

final class Account: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var tasksList: List<TaskObject>
    @Persisted var isSelected: Bool = false
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

extension Account {
    private static var config = Realm.Configuration(schemaVersion: 1)
    private static var realm = try! Realm(configuration: config)
    
    static func findAll() -> Results<Account> {
        realm.objects(self)
    }
    
    static func allTasks() -> [TaskObject] {
        if let account = realm.objects(self).where({$0.isSelected}).first {
            return Array(account.tasksList)
        } else {
            return []
        }
    }
    
    static func completedTasks() -> [TaskObject] {
        if let account = realm.objects(self).where({$0.isSelected}).first {
            return Array(account.tasksList.filter{$0.isCompleted})
        } else {
            return []
        }
    }
    
    static func add(_ account: Account) {
        try! realm.write {
            realm.add(account, update: .all)
        }
    }
    
    static func addTask(for account: Account, newTask: TaskObject) {
        guard let account = realm.object(ofType: Account.self, forPrimaryKey: account.id) else { return }
        let realm = account.thaw()!.realm!
        try! realm.write {
            account.tasksList.append(newTask)
        }
    }
    
    static func edit(_ account: Account) {
        try! realm.write {
            account.isSelected = true
        }
    }
    
    static func delete(_ account: Account) {
        let actualAccount = realm.object(ofType: Account.self, forPrimaryKey: account.id)!
        try! realm.write {
            realm.delete(actualAccount)
        }
    }
}
