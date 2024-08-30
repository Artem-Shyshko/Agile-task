//
//  SettingsViewModel.swift
//  Agile Task
//
//  Created by USER on 30.08.2024.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    let settingType: SettingType
    
    init(settingType: SettingType) {
        self.settingType = settingType
   }
    
    var purchase: any Hashable {
        switch settingType {
        case .tasksList:
            return TaskListNavigationView.subscription
        case .recordsList:
            return SecuredNavigationView.purchase
        }
    }
    
    var settingsGeneral: any Hashable {
        switch settingType {
        case .tasksList:
            return TaskListNavigationView.appSettings
        case .recordsList:
            return SecuredNavigationView.appSettings
        }
    }
    
    var tasksSettings: any Hashable {
        switch settingType {
        case .tasksList:
            return TaskListNavigationView.taskSettings
        case .recordsList:
            return SecuredNavigationView.taskSettings
        }
    }
    
    var more: any Hashable {
        switch settingType {
        case .tasksList:
            return TaskListNavigationView.more
        case .recordsList:
            return SecuredNavigationView.more
        }
    }
    
    var security: any Hashable {
        switch settingType {
        case .tasksList:
            return TaskListNavigationView.security
        case .recordsList:
            return SecuredNavigationView.security
        }
    }
   
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "x.x"
        }
    }
}
