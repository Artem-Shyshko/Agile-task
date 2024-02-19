//
//  Theme.swift
//  Agile Task
//
//  Created by Artur Korol on 25.01.2024.
//

import SwiftUI

enum Theme: String, CaseIterable {
    case systemDefault = "Default"
    case aquamarine = "Aquamarine"
    case ruby = "Ruby"
    case ocean = "Ocean"
    case night = "Night"
    
    func sectionColor(_ schame: ColorScheme) -> Color {
        .sectionColor
    }
    
    func gradient(_ schame: ColorScheme) -> LinearGradient {
        switch self {
        case .systemDefault:
            return schame == .dark ? Color.nightGradient : Color.greenGradient
        case .aquamarine:
            return Color.greenGradient
        case .ruby:
            return Color.rubyGradient
        case .ocean:
            return Color.oceanGradient
        case .night:
            return Color.nightGradient
        }
    }
    
    func sectionTextColor(_ schame: ColorScheme) -> Color {
        switch self {
        case .systemDefault:
            return schame == .dark ? .white : .black
        case .aquamarine, .ruby, .ocean:
            return .black
        case .night:
            return .white
        }
    }
    
    func textColor(_ schame: ColorScheme) -> Color {
        switch self {
        case .systemDefault, .aquamarine, .ruby, .ocean, .night:
            return .white
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            return nil
        case .aquamarine, .ruby, .ocean:
            return .light
        case .night:
            return .dark
        }
    }
    
    func gradientImageName(_ schame: ColorScheme) -> String {
        switch self {
        case .systemDefault:
            return "SystemThemeColorImage"
        case .aquamarine:
           return "AquamarineColorImage"
        case .ruby:
            return "RubyColorImage"
        case .ocean:
            return "OceanColorImage"
        case .night:
            return "NightColorImage"
        }
    }
}
