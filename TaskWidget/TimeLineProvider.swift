//
//  TimeLineProvider.swift
//  Agile Task
//
//  Created by Artur Korol on 12.12.2023.
//

import WidgetKit

struct Provider: AppIntentTimelineProvider {
    let taskRepo: TaskRepository = TaskRepositoryImpl()
    func placeholder(in context: Context) -> TaskEntry {
        let tasks = TaskDataModel.shared.tasks
        let dateFormat = TaskDataModel.shared.dateFormat()
        let dateString = Date().format(dateFormat)
        return TaskEntry(dateString: dateString, tasks: tasks, configuration: ConfigurationAppIntent())
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> TaskEntry {
        let tasks = TaskDataModel.shared.tasks
        let dateFormat = TaskDataModel.shared.dateFormat()
        let dateString = Date().format(dateFormat)
        
        return TaskEntry(dateString: dateString, tasks: tasks, configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<TaskEntry> {
        let entries = createTaskEntry(for: configuration, context: context)
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

private extension Provider {
    func createTaskEntry(for configuration: ConfigurationAppIntent, context: Context) -> [TaskEntry] {
        TaskDataModel.shared.getTasks()
        var tasks = [TaskDTO]()
        
        let dateFormat = TaskDataModel.shared.dateFormat()
        let dateString = Date().format(dateFormat)
        
        tasks = TaskDataModel.shared.tasks
        
        switch context.family {
        case .systemSmall, .systemMedium:
            tasks = Array(tasks.prefix(3))
        default:
            tasks = Array(tasks.prefix(9))
        }
        
        return [TaskEntry(dateString: dateString, tasks: tasks, configuration: configuration)]
    }
}
