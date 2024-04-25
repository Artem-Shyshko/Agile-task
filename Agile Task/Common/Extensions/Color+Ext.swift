//
//  Color+Ext.swift
//  Agile Task
//
//  Created by Artur Korol on 08.08.2023.
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
        case .sectionColor: return "SectionColor"
        case .aquamarineColor: return "Aquamarine"
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
    static let editButtonColor = Color("Onyx")
    static let aquamarineColor = Color("Aquamarine")
    
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
    static let launch = Color("LaunchScreenBackgroundColor")
    static let teaGreenColor = Color("TeaGreen")
    
    static let nightGradient = LinearGradient(
        colors: [.black],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let greenGradient = LinearGradient(
        colors: [Color(hex: "#556085"), Color(hex: "#4D8990"), Color(hex: "#3D9E90"), Color(hex: "#82E8CB")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let rubyGradient = LinearGradient(
        gradient: Gradient(stops: [
            Gradient.Stop(color: Color(hex: "#604CF7"), location: 0.0),
            Gradient.Stop(color: Color(hex: "#8734C4"), location: 0.47),
            Gradient.Stop(color: Color(hex: "#B21C8D"), location: 0.67),
            Gradient.Stop(color: Color(hex: "#C00B6B"), location: 0.78),
            Gradient.Stop(color: Color(hex: "#AD0447"), location: 0.99)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let oceanGradient = LinearGradient(
        colors: [Color(hex: "#1A4C99"), Color(hex: "#1E8BE1"), Color(hex: "#1FC2FF"), Color(hex: "#9AF5FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orangeGradient = LinearGradient(
        colors: [Color(hex: "#FAD961"), Color(hex: "#F76B1C")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
