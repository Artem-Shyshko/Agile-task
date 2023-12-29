//
//  AuthViewModel.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var password: String = ""
    @Published var showAlert: Bool = false
    @Published var settings: SettingsDTO
    
    let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    
    init() {
        settings = settingsRepository.get()
    }
}
