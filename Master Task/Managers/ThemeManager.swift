//
//  ThemeManager.swift
//  Master Task
//
//  Created by Artur Korol on 07.09.2023.
//

import SwiftUI

enum AppMode: String {
    case light = "LIGHT_MODE"
    case dark = "DARK_MODE"
}

final class AppThemeManager: ObservableObject {
    private let defaults = UserDefaults.standard
    
    @AppStorage("SelectedThemeIndex") var savedThemeIndex = 0 {
        didSet {
            updateTheme()
        }
    }
    
    @Published var selectedTheme: Theme = GreenTheme()
    var themes: [Theme] = [GreenTheme(), RubyTheme(), OceanTheme(), BlackTheme()]
    
    init() {
        updateTheme()
    }
    
    func setAppMode(mode: AppMode) {
        defaults.set(mode.rawValue, forKey: Constants.shared.appMode)
    }
    
    func getAppMode() -> AppMode {
        let mode = defaults.string(forKey: Constants.shared.appMode) ?? Constants.shared.lightMode
           return AppMode(rawValue: mode) ?? .light
       }
    
    func setAppTheme() {
        changeTheme(mode: getAppMode())
    }
    
    func changeTheme(mode: AppMode) {
          (UIApplication.shared.connectedScenes.first as?
           UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = mode == .dark ? .dark : .light
          setAppMode(mode: mode)
      }
    
    func getTheme(index: Int) -> Theme {
        themes[index]
    }
    
    func updateTheme() {
        selectedTheme = getTheme(index: savedThemeIndex)
    }
}

protocol Theme {
    var name: String { get set }
    var textColor: Color { get set }
    var sectionTextColor: Color { get set }
    var sectionColor: Color { get set }
    var backgroundColor: Color? { get set }
    var backgroundGradient: LinearGradient? { get set }
}

struct GreenTheme: Theme {
    var name: String = Constants.shared.aquamarineTheme
    var textColor: Color = .white
    var sectionTextColor: Color = .black
    var sectionColor: Color = .sectionColor
    var backgroundColor: Color? = nil
    var backgroundGradient: LinearGradient? = Color.greenGradient
}

struct RubyTheme: Theme {
    var name: String = Constants.shared.rubyTheme
    var textColor: Color = .white
    var sectionTextColor: Color = .black
    var sectionColor: Color = .sectionColor
    var backgroundColor: Color? = nil
    var backgroundGradient: LinearGradient? = Color.rubyGradient
}

struct OceanTheme: Theme {
    var name: String = Constants.shared.oceanTheme
    var textColor: Color = .white
    var sectionTextColor: Color = .black
    var sectionColor: Color = .sectionColor
    var backgroundColor: Color? = nil
    var backgroundGradient: LinearGradient? = Color.oceanGradient
}

struct BlackTheme: Theme {
    var name: String = Constants.shared.nightTheme
    var textColor: Color = .white
    var sectionTextColor: Color = .white
    var sectionColor: Color = .sectionColor
    var backgroundColor: Color? = .black
    var backgroundGradient: LinearGradient? = nil
}
