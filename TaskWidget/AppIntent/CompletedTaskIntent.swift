//
//  ToggleStateIntent.swift
//  MasterTaskWidgetExtension
//
//  Created by Artur Korol on 12.12.2023.
//

import Foundation
import AppIntents
import WidgetKit

struct CompletedTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle task state"
    
    @Parameter(title: "Task title")
    var id: String
    
    init() {}
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        let taskRepository: TaskRepository = TaskRepositoryImpl()
        let tasks = taskRepository.getTaskList()
        if let index = tasks.firstIndex(where: {$0.id.stringValue == id }) {
            var task = tasks[index]
            task.isCompleted.toggle()
            taskRepository.saveTask(task)
            TaskDataModel.shared.getTasks()
        }
        
        WidgetCenter.shared.reloadTimelines(ofKind: "AgileTaskWidget")
        
        return .result()
    }
}
