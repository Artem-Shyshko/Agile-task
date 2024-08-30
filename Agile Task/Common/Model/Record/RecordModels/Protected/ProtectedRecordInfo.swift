//
//  ProtectedRecordInfo.swift
//  Agile Password
//
//  Created by USER on 08.04.2024.
//

import Foundation

struct ProtectedRecordInfo {
    var userName: String
    var password: String = UUID().uuidString
    var fields: [FieldsInfo]
}
