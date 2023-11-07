//
//  SortingViewModel.swift
//  Master Task
//
//  Created by Artur Korol on 29.09.2023.
//

import Foundation
import RealmSwift

final class SortingViewModel: ObservableObject {
    
    @Published var taskSorting: TaskSorting = .creation
    
    private let realm = try! Realm()
    
    func editValue(for settings: Results<TaskSettings>, with option: TaskSorting) {
        guard let edited = realm.object(ofType: TaskSettings.self, forPrimaryKey: settings.first!.id) else { return }
        do {
            try realm.write {
                edited.taskSorting = option
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
