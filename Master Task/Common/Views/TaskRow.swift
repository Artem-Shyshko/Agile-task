//
//  TaskRow.swift
//  Master Task
//
//  Created by Artur Korol on 25.08.2023.
//

import SwiftUI
import RealmSwift

struct TaskRow: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel: TaskListViewModel
    @EnvironmentObject var theme: AppThemeManager
    @Binding var task: TaskDTO
    
    @State private var draggingOffset: CGFloat = .zero
    @State private var startOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var isDeleteAlert = false
    @State private var showAddNewTaskView = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            generalRow()
            checkboxesView()
        }
        .font(.helveticaRegular(size: 16))
        .alert("Are you sure you want to delete", isPresented: $isDeleteAlert) {
            Button("Cancel", role: .cancel) {
                isDeleteAlert = false
            }
            
            Button("Delete") {
                viewModel.deleteTask(task)
            }
        }
        .navigationDestination(isPresented: $showAddNewTaskView) {
            NewTaskView(viewModel: NewTaskViewModel(), taskList: viewModel.filteredTasks, editTask: self.task)
        }
        .swipeActions(edge: .trailing) {
            Button {
                isDeleteAlert = true
            } label: {
                Image("trash")
            }
            .tint(.red)
            
            NavigationLink {
                NewTaskView(viewModel: NewTaskViewModel(), taskList: viewModel.filteredTasks, editTask: task)
            } label: {
                Image("edit")
            }
            .tint(Color.editButtonColor)
        }
        .swipeActions(edge: .leading) {
            Button {
                viewModel.updateTaskCompletion(&task)
            } label: {
                Image(task.isCompleted ? "done-checkbox" : "empty-checkbox")
            }
            .tint(.green)
        }
    }
}

// MARK: - Layout

private extension TaskRow {
    
    func foregroundColor() -> Color {
        if task.isCompleted {
            if theme.selectedTheme.name == Constants.shared.nightTheme,
               task.colorName != theme.selectedTheme.sectionColor.name {
                return .black.opacity(0.5)
            } else {
                return  .textColor.opacity(0.5)
            }
        } else {
            if theme.selectedTheme.name == Constants.shared.nightTheme,
               task.colorName != theme.selectedTheme.sectionColor.name {
                return .black
            } else {
                return  theme.selectedTheme.sectionTextColor
            }
        }
    }
    
    func generalRow() -> some View {
        HStack(spacing: 5) {
            HStack(spacing: 7) {
                if !task.checkBoxArray.isEmpty {
                    Button {
                            viewModel.updateTaskShowingCheckbox(&task)
                    } label: {
                        Image(systemName: task.showCheckboxes ? "chevron.up" : "chevron.down")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 10)
                }
                
                if task.status != .none {
                    Image(task.status.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                
                Text(task.title)
                    .font(.helveticaRegular(size: 16))
            }
            Spacer()
            
            let timeFormat = viewModel.settings.timeFormat == .twelve ? "hh" : "HH"
            if let date = task.date {
                Text(date.format(viewModel.dateFormat()))
                    .font(.helveticaRegular(size: 14))
                    .foregroundStyle(
                        task.isCompleted
                        ? foregroundColor()
                        : viewModel.calculateDateColor(
                            whit: date,
                            themeTextColor: theme.selectedTheme.sectionTextColor,
                            isDate: true
                        )
                    )
            }
            
            if let time = task.time {
                HStack {
                    Text(time.format("\(timeFormat):mm"))
                    
                    if viewModel.settings.timeFormat == .twelve {
                        Text(task.timePeriod.rawValue)
                    }
                }
                .font(.helveticaRegular(size: 14))
                .foregroundStyle(
                    task.isCompleted
                    ? foregroundColor()
                    : viewModel.calculateDateColor(
                        whit: time,
                        themeTextColor: theme.selectedTheme.sectionTextColor,
                        isDate: false
                    )
                )
            }
            
            if task.reminder != .none {
                Image("Reminder")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 15)
            }
            
            if task.recurring != .none {
                Image("Recurring")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 15)
            }
        }
        .foregroundColor(foregroundColor())
        .padding(.horizontal, -10)
        .strikethrough(task.isCompleted, color: .completedTaskLineColor)
        .onTapGesture(count: 2, perform: {
            viewModel.updateTaskCompletion(&task)
//            viewModel.sortTask()
        })
    }
    
    @ViewBuilder
    func checkboxesView() -> some View {
        if !task.checkBoxArray.isEmpty, task.showCheckboxes {
            ForEach($task.checkBoxArray
                .sorted(by: {$0.sortingOrder.wrappedValue < $1.sortingOrder.wrappedValue}), id: \.id.wrappedValue
            ) { checkBox in
                CheckboxTaskRow(viewModel: viewModel, checkbox: checkBox, colorName: task.colorName)
            }
        }
    }
}

// MARK: - Preview

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(viewModel: TaskListViewModel(), task: .constant(TaskDTO(object: Constants.shared.mockTask)))
            .environmentObject(AppThemeManager())
    }
}
