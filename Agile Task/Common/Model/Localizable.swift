//
//  Localizable.swift
//  Agile Task
//
//  Created by Artur Korol on 08.04.2024.
//

import SwiftUI

protocol Localizable: Identifiable, CaseIterable, RawRepresentable where RawValue: StringProtocol {}

extension Localizable {
    var localized: LocalizedStringKey {
        LocalizedStringKey(String(rawValue))
    }
    
    var id: String {
        String(self.rawValue)
    }
}
