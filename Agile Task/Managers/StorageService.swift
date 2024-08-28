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

protocol BackupProtocol {
    func getRealmData() -> Data?
    func saveBackup(data: Data, fileName: String, toICloud: Bool) -> Result<String, BackupError>
    func listAllBackups(fromICloud: Bool) -> [String]
    func restoreBackup(named name: String, fromICloud: Bool) -> Result<String, BackupError>
    func restoreBackup(data: Data) -> Result<String, BackupError>
}

final class StorageService {
    private var storage: Realm?
    private let realmURL = URL.storeURL(databaseName: "default.realm")
        
    init(_ configuration: Realm.Configuration = Realm.Configuration(schemaVersion: 17)) {
        print(realmURL.path())
        initializeRealm(with: configuration)
        createBackupDirectory()
    }
    
    private func initializeRealm(with configuration: Realm.Configuration) {
        let config = Realm.Configuration(fileURL: realmURL, 
                                         schemaVersion: configuration.schemaVersion,
                                         migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < configuration.schemaVersion {
                migration.enumerateObjects(ofType: SettingsObject.className()) { oldObject, newObject in
                    newObject?["сompletionСircle"] = true
                    newObject?["hapticFeedback"] = true
                }
            }
        })
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
    
    func fetchAsync<T: Object>(by type: T.Type) async -> [T] {
        await withCheckedContinuation { continuation in
            // Perform Realm operations on a background thread
            DispatchQueue.global(qos: .background).async {
                autoreleasepool {
                    do {
                        let realm = try Realm()
                        let results = realm.objects(T.self)
                        let models = Array(results) // Convert results to Array
                        continuation.resume(returning: models)
                    } catch {
                        print("Error fetching data from Realm: \(error)")
                        continuation.resume(returning: [])
                    }
                }
            }
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
    
    func saveAll(objects: [Object]) throws {
        guard let storage else { return }
        do {
            try storage.write {
                storage.add(objects, update: .all)
                reloadWidget()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAll(object: [Object]) throws {
        guard let storage else { return }
        do {
            try storage.write {
                storage.delete(object)
                reloadWidget()
            }
        } catch {
            print(error.localizedDescription)
        }
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

extension StorageService: BackupProtocol {
    func saveBackup(data: Data, fileName: String, toICloud: Bool = false) -> Result<String, BackupError> {
        let fileManager = FileManager.default
        let backupDirectory = toICloud ? getICloudBackupDirectory() : getLocalBackupDirectory()
        
        guard let directory = backupDirectory else {
            return .failure(.urlIsNotAvailable)
        }
        
        let name = "Backup_\(fileName)"
        let backupURL = directory.appendingPathComponent(name)
        
        do {
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            
            let isSaved = fileManager.createFile(atPath: backupURL.path, contents: data)
            if isSaved {
                return .success("Backup \(name) successfully saved")
            }
            return .failure(.cantSaveBackup)
        } catch {
            print("Error saving backup: \(error.localizedDescription)")
            return .failure(.creatingBackupError)
        }
    }
    
    func listAllBackups(fromICloud: Bool = false) -> [String] {
        let fileManager = FileManager.default
        let backupDirectory = fromICloud ? getICloudBackupDirectory() : getLocalBackupDirectory()
        
        guard let directory = backupDirectory else {
            print("Backup directory is not available")
            return []
        }
        
        if !fileManager.fileExists(atPath: directory.path) {
            print("Backup directory does not exist at path: \(directory.path)")
            return []
        }
        
        if !fileManager.isReadableFile(atPath: directory.path) {
            print("Backup directory is not readable at path: \(directory.path)")
            return []
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory.path)
            return files
        } catch {
            print("Error listing backups in directory \(directory.path): \(error.localizedDescription)")
            return []
        }
    }
    
    func restoreBackup(named name: String, fromICloud: Bool = false) -> Result<String, BackupError> {
        let fileManager = FileManager.default
        let backupDirectory = fromICloud ? getICloudBackupDirectory() : getLocalBackupDirectory()
        
        guard let directory = backupDirectory else {
            return .failure(.urlIsNotAvailable)
        }
        
        let backupURL = directory.appendingPathComponent(name)
        
        do {
            guard fileManager.fileExists(atPath: backupURL.path) else {
                return .failure(.fileDoesNotExist)
            }
            
            if fileManager.fileExists(atPath: realmURL.path) {
                try fileManager.removeItem(at: realmURL)
            }
            
            try fileManager.copyItem(at: backupURL, to: realmURL)
            return .success("Backup \(name) successfully restored")
        } catch {
            print("Error restoring backup: \(error.localizedDescription)")
            return .failure(.restoringBackupError)
        }
    }
    
    func restoreBackup(data: Data) -> Result<String, BackupError> {
        do {
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: realmURL.path) {
                try fileManager.removeItem(at: realmURL)
            }
            
            let isSaved = fileManager.createFile(atPath: realmURL.path, contents: data)
            if isSaved {
                return .success("Backup successfully restored")
            }
            return .failure(BackupError.restoringBackupError)
        } catch {
            print("Error saving backup: \(error.localizedDescription)")
            return .failure(BackupError.creatingBackupError)
        }
    }
    
    func getRealmData() -> Data? {
        let fileManager = FileManager.default
        return fileManager.contents(atPath: realmURL.path)
    }
}

private extension StorageService {
    
    private func getLocalBackupDirectory() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            fatalError("Unable to access document directory")
        }
        let backupDirectory = documentDirectory.appendingPathComponent("Backups")
        print("Local Backup Directory: \(backupDirectory.path)")
        createBackupDirectoryIfNeeded(directory: backupDirectory)
        return backupDirectory
    }

    func getICloudBackupDirectory() -> URL? {
        let fileManager = FileManager.default
        guard let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil) else {
            print("iCloud is not available")
            return nil
        }
        let backupDirectory = iCloudURL.appendingPathComponent("Documents").appendingPathComponent("Backups")
        print("iCloud Backup Directory: \(backupDirectory.path)")
        createBackupDirectoryIfNeeded(directory: backupDirectory)
        return backupDirectory
    }
    
    private func createBackupDirectoryIfNeeded(directory: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                print("Backup directory created at path: \(directory.path)")
            } catch {
                fatalError("Unable to create backup directory: \(error.localizedDescription)")
            }
        } else {
            print("Backup directory already exists at path: \(directory.path)")
        }
    }
    
    func createBackupDirectory() {
        createBackupDirectoryIfNeeded(directory: getLocalBackupDirectory())
        if let iCloudBackupDirectory = getICloudBackupDirectory() {
            createBackupDirectoryIfNeeded(directory: iCloudBackupDirectory)
        }
    }
}

public extension URL {
    static func storeURL(databaseName: String) -> URL {
        let appGroup = Constants.shared.appGroupID
        
        guard let fileContainer = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        else { fatalError("Unable to create URL for \(appGroup)") }
        
        return fileContainer.appending(path: databaseName)
    }
}

enum BackupError: String, Error {
    case urlIsNotAvailable = "Backup URL is not available"
    case fileDoesNotExist = "Backup file does not exist"
    case restoringBackupError = "Restoring backup error"
    case creatingBackupError = "Creating backup error"
    case cantSaveBackup = "Cant save backup"
}
