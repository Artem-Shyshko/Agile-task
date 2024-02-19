//
//  AppThemeManager.swift
//  Agile Task
//
//  Created by Artur Korol on 25.01.2024.
//

import Foundation

final class ThemeManager: ObservableObject {
    @Published var theme: Theme = .ruby {
        didSet {
            UserDefaults.standard.setValue(theme.rawValue, forKey: Constants.shared.userTheme)
        }
    }
    
    init() {
        let themeName = UserDefaults.standard.string(forKey: Constants.shared.userTheme) ?? Constants.shared.aquamarineTheme
        theme = Theme(rawValue: themeName) ?? .aquamarine
    }
}
