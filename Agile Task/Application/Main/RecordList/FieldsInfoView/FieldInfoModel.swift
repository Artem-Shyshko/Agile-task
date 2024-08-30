//
//  FieldInfoModel.swift
//  Agile Task
//
//  Created by USER on 09.04.2024.
//

import Foundation

struct FieldInfoModel {
    var id = UUID()
    var type: FieldsType
    var title: String = ""
    var list: [BulletDTO] = []
    var isCalendarShowing = false
    var startDate = Date()
    var isShowingBulletView = false
    
    var typeTitle: String {
        switch type {
        case .title:
            "Title"
        case .password:
            "Password"
        case .email:
            "Email"
        case .url:
            "URL"
        case .number:
            "Number"
        case .date:
            "Date"
        case .bulletList:
            "Bullet list"
        case .address:
            "Address"
        case .phone:
            "Phone"
        }
    }
}

// MARK: - Hashable
extension FieldInfoModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
