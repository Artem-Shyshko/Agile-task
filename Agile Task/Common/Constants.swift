//
//  Constants.swift
//  Agile Task
//
//  Created by Artur Korol on 25.08.2023.
//

import SwiftUI
import RealmSwift

final class Constants {
    static let shared = Constants()
    
    private init() {}
    
    let shortDateFormat = "EE d/M/yy"
    let appMode = ""
    let darkMode = "DARK_MODE"
    let lightMode = "LIGHT_MODE"
    let showOnboarding = "ShowOnboarding"
    let userPassword = "User_Password"
    let listRowSpacing: CGFloat = 3
    let nightTheme = "Night"
    let oceanTheme = "Ocean"
    let rubyTheme = "Ruby"
    let aquamarineTheme = "Aquamarine"
    let userTheme = "userTheme"
    let selectedSubscriptionID = "SelectedSubscriptionID"
    let freeSubscription = "SelectedSubscriptionID"
    
    lazy var local = Locale(identifier: "us")
    lazy var currentDate = Date()
    
    lazy var dateFormatter = DateFormatter()
    
    var calendar: Calendar  {
        let weekStart = UserDefaults.standard.integer(forKey: "WeekStart")
        
        if weekStart == 0 {
            UserDefaults.standard.setValue(2, forKey: "WeekStart")
        }
        
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "WeekStart")
        
        return calendar
    }
    
    enum Constrains {
        static let viewsSpacing = 2
    }
}