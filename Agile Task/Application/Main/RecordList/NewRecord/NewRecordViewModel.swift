//
//  NewRecordViewModel.swift
//  Agile Task
//
//  Created by USER on 09.04.2024.
//

import Foundation
import RealmSwift
import AuthenticationServices

final class NewRecordViewModel: ObservableObject {
    // MARK: - Published
    @Published var isEditing = false
    @Published var showErrorAlert = false
    @Published var isScreenClose = false
    @Published var editedRecord: RecordDTO?
    @Published var selectedAccount: String = ""
    
    // Open info
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var bulletInfo: [BulletDTO] = []
    
    // Protected info
    @Published var account: String = ""
    @Published var password: String = ""
    
    @Published var fieldsInfo: [FieldsInfo] = []
    
    // Settings
    @Published var protection: Protection = .none
    @Published var autoClose: AutoClose = .sec15
    @Published var protectWith: Protection = .none
    
    // MARK: - Internal
    var fieldsInfoModel: FieldsInfoViewModel {
        .init(appState: appState, fieldArray: returnFieldInfpModel(from: editedRecord?.protectedRecordInfo.fields))
    }
    var settings: SettingsDTO
    var appState: AppState
    
    init(appState: AppState, editedRecord: RecordDTO? = nil) {
        self.appState = appState
        let settings = appState.settingsRepository!.get()
        self.settings = settings
        self.editedRecord = editedRecord
        self.title = editedRecord?.openRecordInfo.title ?? ""
        self.description = editedRecord?.openRecordInfo.recordDescription ?? ""
        self.bulletInfo = editedRecord?.openRecordInfo.bulletInfo ?? []
        self.account = editedRecord?.protectedRecordInfo.userName ?? ""
        self.fieldsInfo = editedRecord?.protectedRecordInfo.fields ?? []
        self.protection = editedRecord?.settingsRecordInfo.protectWith ?? .none
        self.autoClose = editedRecord?.settingsRecordInfo.autoClose ?? .sec15
        self.isEditing = editedRecord != nil
        protectWith = editedRecord?.settingsRecordInfo.protectWith ?? .none
        self.getPassword()
    }
    
    func saveRecord() {
        let record = returnRecord()
        guard isRecordValid(record: record) else {
            showErrorAlert = true
            return
        }
        savePasswordDataFor(record: record)
        appState.recordsRepository?.saveRecord(record)
    }
}

// MARK: - Private methods
private extension NewRecordViewModel {
    func getPassword() {
        guard let editedRecord else { return }
        password = KeychainService.loadPasswordData(key: editedRecord.protectedRecordInfo.password)?.password ?? ""
    }
    
    func isRecordValid(record: RecordDTO) -> Bool {
        guard !record.openRecordInfo.title.isEmpty else {
            return false
        }
        
        guard !record.protectedRecordInfo.fields.isEmpty else {
            return true
        }
        
        return record.protectedRecordInfo.fields.allSatisfy { field in
            switch field {
            case .email(let string):
                return string.isStringValid(regEx: .email)
            case .url(let string):
                return string.isStringValid(regEx: .url)
            default:
                return true
            }
        }
    }
    
    func returnRecord() -> RecordDTO {
        let openRecordInfo = OpenRecordInfo(title: title,
                                            recordDescription: description,
                                            bulletInfo: bulletInfo)
        
        let settings = SettingsRecordInfo(protectWith: protection,
                                          autoClose: autoClose)
        
        
        let id = editedRecord == nil ? ObjectId.generate() :
        editedRecord?.id ?? ObjectId.generate()
        
        let protectedInfo = editedRecord == nil ? ProtectedRecordInfo(userName: account,
                                                                      fields: fieldsInfoModel.returnAllFieldsInfo()) :
        ProtectedRecordInfo(userName: account,
                            password: editedRecord?.protectedRecordInfo.password ?? "",
                            fields: fieldsInfoModel.returnAllFieldsInfo())
        
        return RecordDTO(id: id,
                         openRecordInfo: openRecordInfo,
                         protectedRecordInfo: protectedInfo,
                         settingsRecordInfo: settings)
    }
    
    func returnFieldInfpModel(from fieldsInfo : [FieldsInfo]?) -> [FieldInfoModel] {
        guard let fieldsInfo else { return [] }
        var fieldInfoModel = [FieldInfoModel]()
        
        fieldsInfo.forEach { field in
            switch field {
            case .title(let title):
                fieldInfoModel.append(FieldInfoModel(type: .title, title: title))
            case .password(let password):
                fieldInfoModel.append(FieldInfoModel(type: .password, title: password))
            case .email(let email):
                fieldInfoModel.append(FieldInfoModel(type: .email, title: email))
            case .url(let url):
                fieldInfoModel.append(FieldInfoModel(type: .url, title: url))
            case .number(let number):
                fieldInfoModel.append(FieldInfoModel(type: .number, title: number))
            case .date(let date):
                fieldInfoModel.append(FieldInfoModel(type: .date, title: date))
            case .bulletList(let array):
                fieldInfoModel.append(FieldInfoModel(type: .bulletList, list: array))
            case .address(let address):
                fieldInfoModel.append(FieldInfoModel(type: .address, title: address))
            case .phone(let phone):
                fieldInfoModel.append(FieldInfoModel(type: .phone, title: phone))
            }
        }
        
        return fieldInfoModel
    }
    
    func savePasswordDataFor(record: RecordDTO) {
        guard !password.isEmpty else { return }
        
        KeychainService.save(passwordData: PasswordData(account: record.protectedRecordInfo.userName,
                                                        password: password,
                                                        key: record.protectedRecordInfo.password,
                                                        url: getRecordURL(record: record)))
        
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
    
    func getRecordURL(record: RecordDTO) -> String {
        guard let url = record.protectedRecordInfo.fields.compactMap({
            if case .url(let url) = $0 {
                return url
            }
            return nil
        }).first else {
            return ""
        }
        
        return url
    }
}
