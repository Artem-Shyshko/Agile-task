//
//  FieldsInfoViewModel.swift
//  Agile Task
//
//  Created by USER on 09.04.2024.
//

import Foundation
import RealmSwift

final class FieldsInfoViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    @Published var deletedBullets: [FieldInfoModel] = []
    @Published var fieldArray: [FieldInfoModel] = []
    @Published var deletedBullet: FieldInfoModel?
    @Published var fieldType: FieldsType = .title
    @Published var isShowingStartDateCalendarPicker = false
    @Published var dateType: TaskDateFormmat = .dayMonthYear
    
    var appState: AppState
    
    init(appState: AppState, fieldArray: [FieldInfoModel] = []) {
        self.appState = appState
        self.fieldArray = fieldArray
        settings = appState.settingsRepository!.get()
        dateType = settings.taskDateFormat
    }
    
    func onSubmit(checkBoxesCount: Int, textFieldIndex: Int, focusedInput: inout Int?) {
        if textFieldIndex < checkBoxesCount {
            focusedInput = textFieldIndex + 1
        } else {
            focusedInput = nil
        }
    }
    
    func trashButtonAction() {
        guard let deletedBullet else { return }
        fieldArray.removeAll(where: { $0.id == deletedBullet.id })
    }
    
    func focusNumber(field: FieldInfoModel) -> Int {
        if let index = fieldArray.firstIndex(where: { $0.id == field.id}) {
            return index
        }
        
        return 0
    }
    
    func move(from source: IndexSet, to destination: Int) {
        fieldArray.move(fromOffsets: source, toOffset: destination)
    }
    
    func returnAllFieldsInfo() -> [FieldsInfo] {
        var fieldsInfo: [FieldsInfo] = []
        fieldArray.forEach { field in
            switch field.type {
            case .title:
                fieldsInfo.append(FieldsInfo.title(field.title))
            case .password:
                fieldsInfo.append(FieldsInfo.password(field.title))
            case .email:
                fieldsInfo.append(FieldsInfo.email(field.title))
            case .url:
                fieldsInfo.append(FieldsInfo.url(field.title))
            case .number:
                fieldsInfo.append(FieldsInfo.number(field.title))
            case .date:
                fieldsInfo.append(FieldsInfo.date(field.title))
            case .bulletList:
                fieldsInfo.append(FieldsInfo.bulletList(field.list))
            case .address:
                fieldsInfo.append(FieldsInfo.address(field.title))
            case .phone:
                fieldsInfo.append(FieldsInfo.phone(field.title))
            }
        }
        
        return fieldsInfo
    }
}
