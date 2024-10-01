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
            return TasksNavigation.subscription
        case .recordsList:
            return SecuredNavigation.purchase
        }
    }
    
    var settingsGeneral: any Hashable {
        switch settingType {
        case .tasksList:
            return TasksNavigation.appSettings
        case .recordsList:
            return SecuredNavigation.appSettings
        }
    }
    
    var tasksSettings: any Hashable {
        switch settingType {
        case .tasksList:
            return TasksNavigation.taskSettings
        case .recordsList:
            return SecuredNavigation.taskSettings
        }
    }
    
    var more: any Hashable {
        switch settingType {
        case .tasksList:
            return TasksNavigation.more
        case .recordsList:
            return SecuredNavigation.more
        }
    }
    
    var security: any Hashable {
        switch settingType {
        case .tasksList:
            return TasksNavigation.security
        case .recordsList:
            return SecuredNavigation.security
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
