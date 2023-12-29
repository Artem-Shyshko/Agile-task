//
//  TaskRow.swift
//  Master Task
//
//  Created by Artur Korol on 25.08.2023.
//

import SwiftUI
import RealmSwift

struct TaskRow: View {
    
    // MARK: - Enum
    
    enum Constrains {
        static let triggerRightThreshHold: CGFloat = -210
        static let expansionRightThreshHold: CGFloat = -60
        static let expansionRightOffset: CGFloat = -80
        static let expansionLeftThreshHold: CGFloat = 30
        static let expansionLeftOffset: CGFloat = 35
    }
    
    // MARK: - Properties
    
    @StateObject var viewModel: TaskListViewModel
    @EnvironmentObject var theme: AppThemeManager
    @Binding var task: TaskDTO
    
    @State private var draggingOffset: CGFloat = .zero
    @State private var startOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var isDeleteAlert = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            generalRow()
            checkboxesView()
        }
        .font(.helveticaRegular(size: 16))
        .gesture(swipeGesture())
        .contentShape(Rectangle())
        .alert("Are you sure you want to delete", isPresented: $isDeleteAlert) {
            Button("Cancel", role: .cancel) {
                isDeleteAlert = false
            }
            
            Button("Delete") {
                viewModel.deleteTask(task)
            }
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
            HStack(spacing: 10) {
                if !task.checkBoxArray.isEmpty {
                    Image(systemName: task.showCheckboxes ? "chevron.up" : "chevron.down")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .onTapGesture {
                            viewModel.updateTaskShowingCheckbox(&task)
                        }
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
            viewModel.sortTask()
        })
        .overlay(alignment: .leading, content: {
            rightSwipeViews()
                .padding(.leading, -20)
                .padding(.vertical, -13)
        })
        .overlay(alignment: .trailing, content: {
            leftSwipeViews()
                .padding(.trailing, -20)
                .padding(.vertical, -12)
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

// MARK: - Swipes

private extension TaskRow {
    func swipeGesture() -> some Gesture {
        DragGesture()
            .onChanged {
                if !isDragging {
                    startOffset = draggingOffset
                    isDragging = true
                }
                
                draggingOffset = startOffset + $0.translation.width
                
                if draggingOffset < Constrains.triggerRightThreshHold {
                    isDeleteAlert = true
                    draggingOffset = 0
                }
            }
            .onEnded { value in
                isDragging = false
                
                withAnimation {
                    if startOffset == .zero {
                        if value.translation.width < 10 {
                            if value.translation.width < Constrains.expansionRightThreshHold  {
                                draggingOffset = Constrains.expansionRightOffset
                            } else {
                                draggingOffset = .zero
                                startOffset = .zero
                            }
                        } else if value.translation.width > -10 {
                            if value.translation.width > Constrains.expansionLeftThreshHold {
                                draggingOffset = Constrains.expansionLeftOffset
                            } else {
                                draggingOffset = .zero
                                startOffset = .zero
                            }
                        }
                    } else {
                        draggingOffset = .zero
                        startOffset = .zero
                    }
                }
            }
    }
    
    func leftSwipeViews() -> some View {
        HStack(spacing: 0) {
            Button {
                viewModel.showAddNewTaskView = true
                draggingOffset = .zero
            } label: {
                Image("edit")
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
                    .padding(.leading, 5)
            }
            .buttonStyle(.borderless)
            
            Button {
                isDeleteAlert = true
                draggingOffset = .zero
            } label: {
                Image("trash")
                    .renderingMode(.template)
                    .foregroundColor(.red)
                    .padding(.leading, 5)
            }
            .buttonStyle(.borderless)
        }
        .frame(width: startOffset == .zero ? -draggingOffset : .zero)
        .background(theme.selectedTheme.sectionColor)
        .cornerRadius(3)
    }
    
    func rightSwipeViews() -> some View {
        Button {
            viewModel.updateTaskCompletion(&task)
            draggingOffset = .zero
        } label: {
            Image(task.isCompleted ? "done-checkbox" : "empty-checkbox")
                .renderingMode(.template)
                .foregroundColor(.green)
                .padding(.leading, 5)
        }
        .buttonStyle(.borderless)
        .frame(width: startOffset == .zero ? draggingOffset : .zero)
        .background(theme.selectedTheme.sectionColor)
        .cornerRadius(3)
    }
}

// MARK: - Preview

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(viewModel: TaskListViewModel(), task: .constant(TaskDTO(object: Constants.shared.mockTask)))
            .environmentObject(AppThemeManager())
    }
}
