//
//  MasterTaskWidgetEntryView.swift
//  MasterTaskWidgetExtension
//
//  Created by Artur Korol on 12.12.2023.
//

import SwiftUI
import WidgetKit

struct MasterTaskWidgetEntryView: View {
    
    // MARK: - Enum
    
    enum Constants {
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 0.3
    }
    
    // MARK: - Entry
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            headerView()
            divider()
            taskList()
            Spacer()
        }
    }
}

// MARK: - Views

private extension MasterTaskWidgetEntryView {
    
    func headerView() -> some View {
        HStack {
            Text(entry.dateString)
                .font(.helveticaRegular(size: 12))
            Spacer()
            Link(destination: URL(string: "agiletask://addnewtask")!) {
                Image("Plus")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 20)
            }
        }
        .foregroundStyle(foregroundColor())
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
    
    func divider() -> some View{
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.divider)
    }
    
    func taskList() -> some View {
        ForEach(entry.tasks, id: \.id) { task in
                taskTitle(task.title)
                    .strikethrough(
                        task.isCompleted,
                        color: .compleatedTaskLine
                    )
                    .foregroundStyle(
                        task.isCompleted
                        ? .compleatedTaskLine
                        : foregroundColor()
                    )
            if entry.tasks.last != task {
                divider()
                    .padding(.horizontal, Constants.horizontalPadding)
            }
        }
    }
    
    func taskTitle(_ title: String) -> some View {
        Text(LocalizedStringKey(title))
            .font(.helveticaRegular(size: 12))
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
    }
    
    func foregroundColor() -> Color {
        switch entry.configuration.selectedTheme {
        case .aquamarine, .night:
            Color.white
        case .day:
            Color.black
        }
    }
}
