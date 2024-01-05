//
//  StorageService.swift
//  Agile Task
//
//  Created by Artur Korol on 27.12.2023.
//

import Foundation
import RealmSwift
import WidgetKit

extension Results {
    func toArray() -> [Element] {
        .init(self)
    }
}

final class StorageService {
    private let storage: Realm?
    
    init(_ configuration: Realm.Configuration = Realm.Configuration(schemaVersion: 3)) {
        let realmURL = URL.storeURL(for: "group.agiletask.app", databaseName: "default.realm")
        
        print(realmURL.path())
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: configuration.schemaVersion)
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            self.storage = try Realm()
        } catch {
            fatalError("Realm initialization failed with error: \(error)")
        }
    }
    
    func saveOrUpdateObject(object: Object) throws {
        guard let storage else { return }
        do {
            try storage.write {
                storage.add(object, update: .all)
                reloadWidget()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveOrUpdateAllObjects(objects: [Object]) throws {
        try objects.forEach {
            try saveOrUpdateObject(object: $0)
            reloadWidget()
        }
    }
    
    func delete(object: Object) throws {
        guard let storage else { return }
        storage.writeAsync({
            storage.delete(object)
        })
        reloadWidget()
    }
    
    func fetch<T: Object>(by type: T.Type) -> [T] {
        guard let storage else { return [] }
        reloadWidget()
        return storage.objects(T.self).toArray()
    }
    
    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "AgileTaskWidget")
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        else { fatalError("Unable to create URL for \(appGroup)") }
        
        return fileContainer.appending(path: databaseName)
    }
}
