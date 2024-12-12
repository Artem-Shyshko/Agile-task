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
    let tasks = TaskDTO.mockArray()
    TaskEntry(dateString: Date().description, tasks: tasks, configuration: .init())
}
