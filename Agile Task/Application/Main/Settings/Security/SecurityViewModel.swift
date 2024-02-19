//
//  SecurityViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 04.10.2023.
//

import Foundation

final class SecurityViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    @Published var showPasswordView = false
    let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    
    init() {
        self.settings = settingsRepository.get()
    }
}
