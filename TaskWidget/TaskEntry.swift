//
//  TaskEntry.swift
//  MasterTaskWidgetExtension
//
//  Created by Artur Korol on 12.12.2023.
//

import WidgetKit

struct TaskEntry: TimelineEntry {
    var date: Date = Date()
    
    let dateString: String
    let tasks: [TaskDTO]
    let configuration: ConfigurationAppIntent
}
