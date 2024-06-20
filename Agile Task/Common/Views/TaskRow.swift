//
//  TaskRow.swift
//  Agile Task
//
//  Created by Artur Korol on 25.08.2023.
//

import SwiftUI
import RealmSwift
import StoreKit

struct TaskRow: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.requestReview) var requestReview
    
    @StateObject var viewModel: TaskListViewModel
    @Binding var task: TaskDTO
    
    @State private var draggingOffset: CGFloat = .zero
    @State private var startOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var isDeleteAlert = false
    @State private var showAddNewTaskView = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            generalRow()
            descriptionView()
            checkboxesView()
            bulletView()
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
        .swipeActions(edge: .trailing) {
            Button {
                isDeleteAlert = true
            } label: {
                Image("trash")
            }
            .tint(.red)
            
            NavigationLink(value: TaskListNavigationView.createTask(editedTask: task)) {
                    Image("edit")
            }
            .tint(Color.editButtonColor)
        }
        .swipeActions(edge: .leading) {
            Button {
                viewModel.updateTaskCompletion(task.id.stringValue)
                makeRequestPreview()
            } label: {
                Image(task.isCompleted ? "done-checkbox" : "empty-checkbox")
            }
            .tint(.green)
        }
        .listRowBackground(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(task.colorName))
                    .padding(.trailing, 12)
                    .overlay(alignment: .topTrailing, content: {
                        Image(.swipes)
                            .padding(.trailing, 2)
                    })
        )
        .padding(.trailing, 12)
    }
}

// MARK: - Layout

private extension TaskRow {
    
    func makeRequestPreview() {
        if UserDefaults.standard.integer(forKey: "CompletedTask") >= 20 {
          requestReview()
          UserDefaults.standard.setValue(0, forKey: "CompletedTask")
        }
    }
    
    func foregroundColor() -> Color {
        if task.isCompleted {
            if colorScheme == .dark,
               task.colorName != themeManager.theme.sectionColor(colorScheme).name {
                return .black.opacity(0.5)
            } else {
                return  .textColor.opacity(0.5)
            }
        } else {
            if colorScheme == .dark,
               task.colorName != themeManager.theme.sectionColor(colorScheme).name {
                return .black
            } else {
                return  themeManager.theme.sectionTextColor(colorScheme)
            }
        }
    }
    
    func generalRow() -> some View {
        HStack(spacing: 5) {
            HStack(spacing: 7) {
                chevronButton()
                
                if task.status != .none {
                    Image(task.status.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                
                Text(LocalizedStringKey(task.title))
                    .font(.helveticaRegular(size: 16))
            }
            Spacer()
            dateView()
            timeView()
            recurringDateView()
            reminderImage()
            recurringImage()
        }
        .foregroundColor(foregroundColor())
        .padding(.horizontal, Constants.shared.listRowHorizontalPadding)
        .strikethrough(task.isCompleted, color: .completedTaskLineColor)
        .onTapGesture(count: 2, perform: {
            viewModel.updateTaskCompletion(task.id.stringValue)
            makeRequestPreview()
        })
    }
    
    @ViewBuilder
    func recurringImage() -> some View {
        if let recurring = task.recurring, recurring.option != .none {
            Image("Recurring")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 15)
        }
    }
    
    @ViewBuilder
    func reminderImage() -> some View {
        if task.reminder != .none {
            Image("Reminders")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 15)
        }
    }
    
    @ViewBuilder
    func recurringDateView() -> some View {
        if let recurring = task.recurring, recurring.option != .none {
            Text(task.createdDate.format(viewModel.dateFormat()))
                .font(.helveticaLight(size: 14))
                .foregroundStyle(foregroundColor())
        }
    }
    
    @ViewBuilder
    func chevronButton() -> some View {
        if !task.checkBoxArray.isEmpty || !task.bulletArray.isEmpty || task.description != nil {
            Button {
                viewModel.updateTaskShowingCheckbox(task)
            } label: {
                Image(systemName: task.showCheckboxes ? "chevron.down" : "chevron.right")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
            }
            .buttonStyle(.borderless)
            .frame(width: 10)
        }
    }
    
    @ViewBuilder
    func dateView() -> some View {
        if let date = task.date, !task.isRecurring{
            Text(date.format(viewModel.dateFormat()))
                .font(.helveticaLight(size: 14))
                .foregroundStyle(
                    task.isCompleted
                    ? foregroundColor()
                    : viewModel.calculateDateColor(
                        whit: date,
                        themeTextColor: foregroundColor(),
                        isDate: true
                    )
                )
        }
    }
    
    @ViewBuilder
    func timeView() -> some View {
        if let time = task.time {
            let timeFormat = viewModel.settings.timeFormat == .twelve ? "hh" : "HH"
            
            HStack {
                Text(time.format("\(timeFormat):mm"))
                
                if viewModel.settings.timeFormat == .twelve {
                    Text(time.format("a"))
                }
            }
            .font(.helveticaLight(size: 14))
            .foregroundStyle(
                task.isCompleted
                ? foregroundColor()
                : viewModel.calculateDateColor(
                    whit: time,
                    themeTextColor: themeManager.theme.sectionTextColor(colorScheme),
                    isDate: false
                )
            )
        }
    }
    
    @ViewBuilder
    func descriptionView() -> some View {
        if let description = task.description, task.showCheckboxes {
            Text(LocalizedStringKey(description))
                .font(.helveticaRegular(size: 16))
                .foregroundColor(foregroundColor())
                .padding(.horizontal, Constants.shared.listRowHorizontalPadding)
                .strikethrough(task.isCompleted, color: .completedTaskLineColor)
        }
    }
    
    @ViewBuilder
    func checkboxesView() -> some View {
        if !task.checkBoxArray.isEmpty, task.showCheckboxes {
            ForEach($task.checkBoxArray
                .sorted(by: {$0.sortingOrder.wrappedValue < $1.sortingOrder.wrappedValue}), id: \.id.wrappedValue
            ) { checkBox in
                CheckboxTaskRow(viewModel: viewModel, checkbox: checkBox, colorName: task.colorName, taskId: task.id.stringValue)
            }
        }
    }
    
    @ViewBuilder
    func bulletView() -> some View {
        if !task.bulletArray.isEmpty, task.showCheckboxes {
            ForEach($task.bulletArray
                .sorted(by: {$0.sortingOrder.wrappedValue < $1.sortingOrder.wrappedValue}), id: \.id.wrappedValue
            ) { bullet in
                BulletTaskRow(viewModel: viewModel, bullet: bullet, colorName: task.colorName)
            }
        }
    }
}

// MARK: - Preview

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(viewModel: TaskListViewModel(appState: AppState()), task: .constant(TaskDTO.mockArray().first!))
            .environmentObject(ThemeManager())
    }
}
