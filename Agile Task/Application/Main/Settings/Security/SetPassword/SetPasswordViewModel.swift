//
//  SetPasswordViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 09.10.2023.
//

import Foundation
import RealmSwift

enum SetPasswordGoal {
    case tasks
    case records
}

final class SetPasswordViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var allRequirementsMet = false
    @Published var showErrorAlert = false
    @Published var showPasswordView = false
    @Published var dismiss = false
    
    let isFirstSetup: Bool
    let defaults = UserDefaults.standard
    let characterLimit = 20
    var appState: AppState
    var setPasswordGoal: SetPasswordGoal
    
    init(appState: AppState, 
         isFirstSetup: Bool,
         setPasswordGoal: SetPasswordGoal) {
        self.appState = appState
        self.settings = appState.settingsRepository!.get()
        self.isFirstSetup = isFirstSetup
        self.setPasswordGoal = setPasswordGoal
    }
    
   func saveRecordWith() {
        let record = returnRecord(password: confirmPassword)
        savePasswordDataFor(record: record)
        appState.recordsRepository?.saveRecord(record)
    }
    
    private func returnRecord(password: String) -> RecordDTO {
        let openRecordInfo = OpenRecordInfo(title: "Agile password - record details",
                                            recordDescription: "",
                                            bulletInfo: [])
        
        let settings = SettingsRecordInfo(protectWith: .none,
                                          autoClose: .none)
        
        
        let id = ObjectId.generate()
        
        let protectedInfo = ProtectedRecordInfo(userName: "Agile password - record details",
                            password: password,
                            fields: [])
        
        return RecordDTO(id: id,
                         openRecordInfo: openRecordInfo,
                         protectedRecordInfo: protectedInfo,
                         settingsRecordInfo: settings, 
                         taskType: .light)
    }
    
    func savePasswordDataFor(record: RecordDTO) {
        KeychainService.save(passwordData: PasswordData(account: record.protectedRecordInfo.userName,
                                                        password: record.protectedRecordInfo.password,
                                                        key: record.protectedRecordInfo.password,
                                                        url: ""))
        
        let array = KeychainService.getStringArray(forKey: Constants.shared.passwordsKeys)
        guard var array else {
            KeychainService.saveOrUpdateStringArray(strings: [record.protectedRecordInfo.password], forKey: Constants.shared.passwordsKeys)
            return
        }
        
        if !array.contains(record.protectedRecordInfo.password) {
            array.append(record.protectedRecordInfo.password)
        }
        KeychainService.saveOrUpdateStringArray(strings: array, forKey: Constants.shared.passwordsKeys)
    }
}
