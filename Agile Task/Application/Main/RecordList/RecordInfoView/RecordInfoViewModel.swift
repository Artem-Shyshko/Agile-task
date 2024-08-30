//
//  RecordInfoViewModel.swift
//  Agile Task
//
//  Created by USER on 15.04.2024.
//

import RealmSwift
import UIKit

final class RecordInfoViewModel: ObservableObject {
    // MARK: - Published
    @Published var isScreenClose = false
    @Published var record: RecordDTO

    @Published var account: String = ""
    @Published var password: String = ""
    @Published var fieldsInfo: [FieldsInfo] = []
    @Published var protectWith: Protection = .none
   
    @Published var showCopyAlert = false
    
    // MARK: - Internal
    var fieldsInfoModel: FieldsInfoViewModel {
        .init(appState: appState, fieldArray: returnFieldInfpModel(from: record.protectedRecordInfo.fields))
    }
    var settings: SettingsDTO
    var appState: AppState
    
    // MARK: - Private
    private lazy var copyRecordHelper = CopyRecordHelper(record: record)
    
    init(appState: AppState, record: RecordDTO) {
        self.appState = appState
        self.settings = appState.settingsRepository!.get()
        self.record = record
        self.account = record.protectedRecordInfo.userName
        self.fieldsInfo = record.protectedRecordInfo.fields
        protectWith = record.settingsRecordInfo.protectWith
        getPassword()
    }
    
    func copy(text: String) {
        UIPasteboard.general.string = text
        showCopyAlert = true
    }
    
    func startTimer() {
        guard record.settingsRecordInfo.autoClose != .none else { return }
        let timeInterval: TimeInterval

        switch record.settingsRecordInfo.autoClose {
            case .sec15: timeInterval = 15
            case .sec30: timeInterval = 30
            case .sec60: timeInterval = 60
            case .none: timeInterval = 0
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.isScreenClose = true
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func getPassword() {
        password = KeychainService.loadPasswordData(key: record.protectedRecordInfo.password)?.password ?? ""
    }
    
    private func returnFieldInfpModel(from fieldsInfo : [FieldsInfo]?) -> [FieldInfoModel] {
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
                let dateString = settings.taskDateFormat == .dayMonthYear ? date.formatToFormattedString(format: "dd.MM.yyyy") : date.formatToFormattedString(format: "MM.dd.yyyy")
                fieldInfoModel.append(FieldInfoModel(type: .date, title: dateString))
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
}

