//
//  SortingViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 29.09.2023.
//

import Foundation
import RealmSwift

final class SortingViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        settings = appState.settingsRepository!.get()
    }
    
    func editValue(with option: TaskSorting) {
        settings.taskSorting = option
    }
}
