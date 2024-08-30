//
//  SettingsTaskViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 02.10.2023.
//

import SwiftUI

@MainActor
final class AppSettingsViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    @Published var isShowingAlert = false
    @Published var isNotificationAccess = false
    @Published var isTypedTime = false
    var appState: AppState
    let tipKeys = [
        "tip_find_share_task",
        "tip_add_new_task",
        "tip_double_tab",
        "tip_advanced_navigation",
        "tip_quick_add",
        "tip_add_advanced_features",
        "tip_swipe_left",
        "tip_swipe_left_project",
        "tip_add_new_project",
        "tip_group_tasks",
        "tap_to_view_details",
        "swipe_left_task_list",
        "hold_on_task_task_list"
    ]
    
    init(appState: AppState) {
        self.appState = appState
        settings = appState.settingsRepository!.get()
    }
    
    func turnOnTips() {
        settings.isShowingInfoTips.toggle()
        appState.settingsRepository!.save(settings)
        
        let defaults = UserDefaults.standard
        if settings.isShowingInfoTips {
            tipKeys.forEach { key in
                defaults.removeObject(forKey: key)
            }
        } else {
            tipKeys.forEach { key in
                defaults.setValue(false, forKey: key)
            }
        }
    }

    func pushNotificationButtonAction() {
        settings.isPushNotificationEnabled.toggle()
    }
    
    func addPlusButtonAction() {
        settings.showPlusButton.toggle()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print("Error requesting notifications authorization: \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    self.redirectToSettings()
                }
            }
    }
    
    func getPermissionState() async throws  {
        let current = UNUserNotificationCenter.current()
        
        let result = await current.notificationSettings()
        switch result.authorizationStatus {
        case .authorized:
            isNotificationAccess = true
        default:
            isNotificationAccess = false
        }
    }
    
    func redirectToSettings() {
        DispatchQueue.main.async {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    }
}
