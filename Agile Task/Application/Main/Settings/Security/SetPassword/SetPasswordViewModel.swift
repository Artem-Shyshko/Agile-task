//
//  SetPasswordViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 09.10.2023.
//

import Foundation

final class SetPasswordViewModel: ObservableObject {
    let characterLimit = 20
    @Published var settings: SettingsDTO
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var allRequirementsMet = false
    
    let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    
    init() {
        self.settings = settingsRepository.get()
    }
}
