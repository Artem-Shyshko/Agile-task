//
//  MasterTaskWidget.swift
//  MasterTaskWidget
//
//  Created by Artur Korol on 11.12.2023.
//

import WidgetKit
import SwiftUI

struct TaskWidget: Widget {
    let kind: String = "AgileTaskWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MasterTaskWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    selectedTheme(entry: entry)
                }
                
        }
        .contentMarginsDisabled()
    }
    
    func selectedTheme(entry: TaskEntry) -> some View {
        VStack {
            switch entry.configuration.selectedTheme {
            case .aquamarine:
                Color.greenGradient
            case .day:
                Color.white
            case .night:
                Color.black
            }
        }
    }
}

#Preview(as: .systemSmall) {
    TaskWidget()
} timeline: {
    let tasks = [TaskDTO(id: .init(), parentId: .init(), status: .do, title: "Task1", timeOption: .none, timePeriod: .am, recurring: RecurringConfigurationDTO(), reminder: .inOneHour, colorName: "red", checkBoxArray: [], bulletArray: []), TaskDTO(id: .init(), parentId: .init(), status: .do, title: "Task", timeOption: .none, timePeriod: .am, recurring: RecurringConfigurationDTO(), reminder: .inOneHour, colorName: "red", checkBoxArray: [], bulletArray: [])]
    TaskEntry(dateString: Date().description, tasks: tasks, configuration: .init())
}

extension Date {
    func format(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
}