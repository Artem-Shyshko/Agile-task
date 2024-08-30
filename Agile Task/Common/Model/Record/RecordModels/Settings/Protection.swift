//
//  Protection.swift
//  Agile Password
//
//  Created by USER on 08.04.2024.
//

import RealmSwift

enum Protection: String, PersistableEnum, CaseIterable, Hashable, CustomStringConvertible {
    case faceID = "face_id_title"
    case password = "password_title"
    case none = "none_title"
    
    var description: String {
        self.rawValue
    }
    
    var securityOption: SecurityOption? {
        switch self {
        case .faceID:
            return .faceID
        case .password:
            return .password
        case .none:
            return nil
        }
    }
}
