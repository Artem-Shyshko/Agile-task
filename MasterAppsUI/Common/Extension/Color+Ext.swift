//
//  Color+Ext.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 13.10.2023.
//

import SwiftUI

extension Color {
    var name: String {
        switch self {
        case .battleshipGray: return "BattleshipGray"
        case .nyanza: return "Nyanza"
        case .lemonСhiffon: return "LemonСhiffon"
        case .periwinkle: return "Periwinkle"
        case .teaRose: return "TeaRose"
        case .jordyBlue: return "JordyBlue"
        case .mauve: return "Mauve"
        case .mindaro: return "Mindaro"
        case .malachite: return "Malachite"
        case .timberwolf: return "Timberwolf"
        default: return "BattleshipGray"
        }
    }
    
    static let tabBarBackgroundColor = Color("Onyx")
    static let textFieldColor = Color("Timberwolf")
    static let taskTextfieldColor = Color("AntiFlashWhite")
    
    static let textColor = Color("TextColor")
    static let backgroundColor = Color("BackgroundColor")
    static let navigationBarColor = Color("NavigationBarColor")
    static let newTaskButtonBackground = Color("NewTaskButtonBackground")
    static let newTaskButtonForeground = Color("NewTaskButtonForeground")
    static let sectionColor = Color("SectionColor")
    static let tabBarInactiveItemColor = Color("TabBarInactiveItemColor")
    static let completedTaskLineColor = Color("CompletedTaskLineColor")
    static let calendarSelectedDateCircleColor = Color("Cerise")
    
    static let battleshipGray = Color("BattleshipGray")
    static let nyanza = Color("Nyanza")
    static let lemonСhiffon = Color("LemonСhiffon")
    static let periwinkle = Color("Periwinkle")
    static let teaRose = Color("TeaRose")
    static let jordyBlue = Color("JordyBlue")
    static let mauve = Color("Mauve")
    static let mindaro = Color("Mindaro")
    static let malachite = Color("Malachite")
    static let timberwolf = Color("Timberwolf")
}
