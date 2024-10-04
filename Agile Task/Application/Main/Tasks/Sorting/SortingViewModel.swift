//
//  SortingViewModel.swift
//  Agile Task
//
//  Created by Artur Korol on 29.09.2023.
//

import Foundation
import RealmSwift

enum SortingState {
    case tasks
    case records
}

final class SortingViewModel: ObservableObject {
    @Published var settings: SettingsDTO
    var appState: AppState
    var sortingState: SortingState
    
    init(appState: AppState,
         sortingState: SortingState) {
        self.appState = appState
        self.sortingState = sortingState
        settings = appState.settingsRepository!.get()
    }
    
    func editValue(with option: TaskSorting) {
        settings.taskSorting = option
    }
    
    func editValue(with option: SortingType) {
        settings.sortingType = option
    }
}
