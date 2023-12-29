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
        case .battleshipGrayColor: return "BattleshipGray"
        case .nyanzaColor: return "Nyanza"
        case .lemonСhiffonColor: return "LemonСhiffon"
        case .periwinkleColor: return "Periwinkle"
        case .teaRoseColor: return "TeaRose"
        case .jordyBlueColor: return "JordyBlue"
        case .mauveColor: return "Mauve"
        case .mindaroColor: return "Mindaro"
        case .malachiteColor: return "Malachite"
        case .timberwolfColor: return "Timberwolf"
        default: return "BattleshipGray"
        }
    }
    
    static let tabBarBackgroundColor = Color("Onyx")
    static let textFieldColor = Color("Timberwolf")
    static let taskTextfieldColor = Color("AntiFlashWhite")
    
    static let textColor = Color("TextColor")
    static let backgroundColor = Color("BackgroundColor")
    static let navigationBarColor = Color("NavigationBarColor")
    static let sectionColor = Color("SectionColor")
    static let tabBarInactiveItemColor = Color("TabBarInactiveItemColor")
    static let completedTaskLineColor = Color("CompletedTaskLineColor")
    static let calendarSelectedDateCircleColor = Color("Cerise")
    
    static let battleshipGrayColor = Color("BattleshipGray")
    static let nyanzaColor = Color("Nyanza")
    static let lemonСhiffonColor = Color("LemonСhiffon")
    static let periwinkleColor = Color("Periwinkle")
    static let teaRoseColor = Color("TeaRose")
    static let jordyBlueColor = Color("JordyBlue")
    static let mauveColor = Color("Mauve")
    static let mindaroColor = Color("Mindaro")
    static let malachiteColor = Color("Malachite")
    static let timberwolfColor = Color("Timberwolf")
    static let teaGreenColor = Color("TeaGreen")
}
