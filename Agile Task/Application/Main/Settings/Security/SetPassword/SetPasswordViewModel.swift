//
//  SetPasswordViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 09.10.2023.
//

import Foundation

enum SetPasswordGoal {
    case tasks
    case records
}

final class SetPasswordViewModel: ObservableObject {
    let characterLimit = 20
    @Published var settings: SettingsDTO
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var allRequirementsMet = false
    var appState: AppState
    var setPasswordGoal: SetPasswordGoal
    
    init(appState: AppState,
         setPasswordGoal: SetPasswordGoal) {
        self.appState = appState
        self.settings = appState.settingsRepository!.get()
        self.setPasswordGoal = setPasswordGoal
    }
}
