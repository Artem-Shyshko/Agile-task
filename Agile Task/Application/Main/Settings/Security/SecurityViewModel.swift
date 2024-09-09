//
//  SecurityViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 04.10.2023.
//

import Foundation

final class SecurityViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    @Published var oldSettings: SettingsDTO
    @Published var showPasswordView = false
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        let settings = appState.settingsRepository!.get()
        self.settings = settings
        self.oldSettings = settings
    }
}
