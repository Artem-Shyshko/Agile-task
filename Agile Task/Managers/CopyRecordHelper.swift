//
//  CopyRecordHelper.swift
//  Agile Task
//
//  Created by USER on 15.04.2024.
//

import UIKit

final class CopyRecordHelper: ObservableObject {
    var copiedText: String = ""
    let record: RecordDTO
    var password: String = ""
    
    init(record: RecordDTO) {
        self.record = record
        getPassword()
        createTextForShare(record: record)
    }
    
    private func getPassword() {
        password = KeychainService.loadPasswordData(key: record.protectedRecordInfo.password)?.password ?? ""
    }
    
    private func createTextForShare(record: RecordDTO) {
        let bulletInfoString = record.openRecordInfo.bulletInfo.map { $0.title}.joined(separator: ", ")
        
        var fieldsList = [String]()
        record.protectedRecordInfo.fields.forEach { field in
            switch field {
            case .title(let title):
                fieldsList.append("Title: " + "\(title)")
            case .password(let password):
                fieldsList.append("Password: " + "\(password)")
            case .email(let email):
                fieldsList.append("Email: " + "\(email)")
            case .url(let url):
                fieldsList.append("URL: " + "\(url)")
            case .number(let number):
                fieldsList.append("Number: " + "\(number)")
            case .date(let date):
                fieldsList.append("Date: " + "\(date)")
            case .bulletList(let list):
                let bulletInfoString = list.map { $0.title}.joined(separator: ", ")
                fieldsList.append("Information: " + "\(bulletInfoString)")
            case .address(let address):
                fieldsList.append("Address: " + "\(address)")
            case .phone(let phone):
                fieldsList.append("Phone: " + "\(phone)")
            }
        }
        
        let copyText = "User name: \(record.protectedRecordInfo.userName)\nPassword: \(password)\n\(fieldsList.map { $0 }.joined(separator: "\n"))"
        
        copiedText = copyText
    }
}
