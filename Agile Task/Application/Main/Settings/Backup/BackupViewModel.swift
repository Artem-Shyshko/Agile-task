//
//  BackupViewModel.swift
//  Agile Money
//
//  Created by Artur Korol on 16.05.2024.
//

import SwiftUI
import SwiftyDropbox

final class BackupViewModel: ObservableObject {
    private var dropboxClient = DropboxClientsManager.authorizedClient
    
    @Published var alertTitle = ""
    @Published var isShowingAlert = false
    @Published var isAuthorized = false
    @Published var savedBackups: [String] = []
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func saveBackup(toICloud: Bool) {
        guard let data = appState.storage?.getRealmData() else { return }
        let result = appState.storage!.saveBackup(data: data, fileName: Date().backupDateString, toICloud: toICloud)
        DispatchQueue.main.async {
            switch result {
            case .success(let success):
                self.alertTitle = success
            case .failure(let failure):
                self.alertTitle = failure.rawValue
            }
            
            self.isShowingAlert = true
        }
    }
    
    func restoreBackup(named: String, fromICloud: Bool) {
        let result = appState.storage!.restoreBackup(named: named, fromICloud: fromICloud)
        
        DispatchQueue.main.async {
            switch result {
            case .success(let success):
                self.alertTitle = success
                self.appState.restore()
            case .failure(let failure):
                self.alertTitle = failure.rawValue
            }
            
            self.isShowingAlert = true
        }
    }
    
    func authorizeToDropbox() {
        let scopeRequest = ScopeRequest(
            scopeType: .user,
            scopes: [
                "files.content.write",
                "files.content.read"
            ],
            includeGrantedScopes: false)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            DropboxClientsManager.authorizeFromControllerV2(
                UIApplication.shared,
                controller: rootViewController,
                loadingStatusDelegate: nil,
                openURL: { (url: URL) -> Void in
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                scopeRequest: scopeRequest
            )
        }
    }
    
    func getUserAuth() {
        dropboxClient = DropboxClientsManager.authorizedClient
        if let dropboxClient {
            isAuthorized = true
        } else {
            isAuthorized = false
        }
    }
    
    func logout() {
        DropboxClientsManager.authorizedClient = nil
        getUserAuth()
    }
    
    func getBackups(fromICloud: Bool) {
        savedBackups = appState.storage!.listAllBackups(fromICloud: fromICloud)
    }
    
    func saveToDropbox() {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("User is not authorized. Please log in.")
            return
        }
        
        guard let fileData = appState.storage!.getRealmData() else {
            print("No data found")
            return
        }
        
        let newFileName = Date().backupDateString
        client.files.upload(path: "/AgileTask/\(newFileName)", input: fileData)
            .response { [weak self] response, error in
                if let response = response {
                    self?.alertTitle = "Backup successfully saved"
                } else if let error = error {
                    self?.alertTitle = error.localizedDescription
                }
                self?.isShowingAlert = true
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
    func restoreDropboxBackup(name: String) {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("User is not authorized. Please log in.")
            return
        }
        
        client.files.download(path: "/AgileTask/\(name)")
            .response { [weak self] response, error in
                if let response = response {
                    let data = response.1
                    let result = self?.appState.storage!.restoreBackup(data: data)
                    switch result {
                    case .success(let success):
                        self?.alertTitle = success
                        self?.appState.restore()
                    case .failure(let failure):
                        self?.alertTitle = failure.rawValue
                    case .none:
                        self?.alertTitle = BackupError.restoringBackupError.rawValue
                    }
                    self?.isShowingAlert = true
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
    func listFilesInDirectory() {
            guard let client = DropboxClientsManager.authorizedClient else {
                print("User is not authorized. Please log in.")
                return
            }
            
            client.files.listFolder(path: "/AgileTask").response { [weak self] response, error in
                if let result = response {
                    let fileNames = result.entries.map { $0.name }
                    self?.savedBackups = fileNames
                } else if let error = error {
                    print("Error listing files: \(error)")
                }
            }
        }
}
