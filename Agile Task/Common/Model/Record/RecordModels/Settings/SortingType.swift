//
//  SortingType.swift
//  Agile Password
//
//  Created by USER on 11.04.2024.
//

import RealmSwift

enum SortingType: String, PersistableEnum, CaseIterable, Hashable, CustomStringConvertible {
    case manualy = "manualy_title"
    case alphabetAZ = "Alphabetically A-Z"
    case alphabetZA = "Alphabetically Z-A"
    
    var description: String {
        self.rawValue
    }
}
