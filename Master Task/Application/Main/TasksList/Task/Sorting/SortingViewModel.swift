//
//  SortingViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 29.09.2023.
//

import Foundation
import RealmSwift

final class SortingViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    let settingsRepository: SettingsRepository = SettingsRepositoryImpl()
    
    init() {
        settings = settingsRepository.get()
    }
    
    func editValue(with option: TaskSorting) {
        settings.taskSorting = option
    }
}
