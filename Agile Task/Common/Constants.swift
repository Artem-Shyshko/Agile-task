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
    let viewSectionSpacing: CGFloat = 20
    let imagesSize: CGFloat = 32
    let listRowHorizontalPadding: CGFloat = -10
    let nightTheme = "Night"
    let oceanTheme = "Ocean"
    let rubyTheme = "Ruby"
    let aquamarineTheme = "Aquamarine"
    let userTheme = "userTheme"
    let selectedSubscriptionID = "SelectedSubscriptionID"
    let freeSubscription = "SelectedSubscriptionID"
    let termsOfServiceURL = "http://agile-app.com/agile-task/terms-of-service"
    let privacyPolicyURL = "http://agile-app.com/agile-task/privacy-policy"
    let supportURL = "support@agile-app.com"
    let appURL = "http://agile-app.com/agile-task"
    let appStoreLink = "https://apps.apple.com/ua/app/agile-task-daily-to-do-list/id6471654166"
    let dailyNotificationID = "DailyNotificationID"
    let appLanguage = "AppLanguage"
    let oneTimeSubscriptionID = "agile_task_one_time"
    let yearlySubscriptionID = "agile_task_yearly"
    let monthlySubscriptionID = "agile_task_monthly"
    let dropboxKey = "2uhkb4ofg0in4ie"
    let dropboxAccessToken = "dropboxAccessToken"
    let appGroupID = "group.agiletask.app"
    let passwordsKeys = "passwordsKeys"
    let charactersLimit = 40
    let simpleTaskReview = "SimpleTaskReview"
    let advancedTaskReview = "AdvancedTaskReview"
    
    lazy var currentDate = Date()
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        let language = UserDefaults.standard.string(forKey: appLanguage) ?? "en"
        formatter.locale = Locale(identifier: "\(language)_\(SettingsDTO.region)")
        
        return formatter
    }
    
    var calendar: Calendar {
        let weekStart = UserDefaults.standard.integer(forKey: "WeekStart")
        
        if weekStart == 0 {
            UserDefaults.standard.setValue(2, forKey: "WeekStart")
        }
        
        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "WeekStart")
        let language = UserDefaults.standard.string(forKey: appLanguage) ?? "en"
        calendar.locale = NSLocale(localeIdentifier: "\(language)_\(SettingsDTO.region)") as Locale
        
        return calendar
    }
    
    enum Constrains {
        static let viewsSpacing = 2
    }
}
