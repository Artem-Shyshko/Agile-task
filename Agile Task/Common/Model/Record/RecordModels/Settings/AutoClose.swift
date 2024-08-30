//
//  AutoClose.swift
//  Agile Password
//
//  Created by USER on 08.04.2024.
//

import RealmSwift

enum AutoClose: String, PersistableEnum, CaseIterable, Hashable, CustomStringConvertible {
    case sec15 = "15_sec"
    case sec30 = "30_sec"
    case sec60 = "60_sec"
    case none = "none_title"
    
    var description: String {
        self.rawValue
    }
}
