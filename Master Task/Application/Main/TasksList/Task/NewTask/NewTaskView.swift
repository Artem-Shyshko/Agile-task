
//
//  NewItemView.swift
//  Master Task
//
//  Created by Artur Korol on 09.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

struct NewTaskView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var theme: AppThemeManager
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @StateObject var viewModel: NewTaskViewModel
    @FocusState private var isFocused: Bool
    @State private var show: Bool = false
    
    @Environment(\.dismiss) var dismiss
    var taskList: [TaskDTO]
    
    var editTask: TaskDTO?
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.shared.listRowSpacing) {
                statusView()
                titleView()
                descriptionView()
                checkList()
                dateView()
                timeView()
                recurringView()
                reminderView()
                colorView()
                bottomButton()
                Spacer()
            }
        }
        .padding(.top, 15)
        .toolbar(.visible, for: .navigationBar)
        .navigationTitle("New Task")
        .modifier(TabViewChildModifier())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                tabBarCancelButton()
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                tabBarSaveButton()
            }
        }
        .onAppear {
            isFocused = true
            viewModel.localNotificationManager = localNotificationManager
            
            if let editTask {
                viewModel.taskStatus = editTask.status
                viewModel.title = editTask.title
                viewModel.checkBoxes = editTask.checkBoxArray.sorted(by: { $0.sortingOrder < $1.sortingOrder })
                viewModel.selectedColor = Color(editTask.colorName)
                viewModel.isCompleted = editTask.isCompleted
                viewModel.selectedRecurringOption = editTask.recurring
                if let date = editTask.date {
                    viewModel.taskDate = date
                    viewModel.selectedDateOption = editTask.dateOption
                }
                if let time = editTask.time {
                    viewModel.taskTime = time
                    viewModel.selectedTimeOption = editTask.timeOption
                }
                if let reminderDate = editTask.reminderDate {
                    viewModel.reminderDate = reminderDate
                    viewModel.reminder = editTask.reminder
                    viewModel.reminderTime = reminderDate
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.showSubscriptionView) {
            SettingsSubscriptionView()
        }
        .fullScreenCover(isPresented: $show, content: {
            NewCheckBoxView(
                viewModel: NewCheckBoxViewModel(),
                taskCheckboxes: $viewModel.checkBoxes,
                isShowing: $show,
                task: editTask
            )
        })
        .alert("Are you sure you want to delete task?", isPresented: $viewModel.showDeleteAlert) {
            Button {
                viewModel.showDeleteAlert = false
            } label: {
                Text("Cancel")
            }
            
            Button {
                if let editTask {
                    viewModel.deleteTask(parentId: editTask.parentId)
                    dismiss.callAsFunction()
                }
            } label: {
                Text("Delete")
            }
        }
        .alert("You can't create task reminder without date/time", isPresented: $viewModel.showReminderAlert) {
            Button("OK") {}
        }
    }
}

// MARK: - Private Views

private extension NewTaskView {
    
    func statusView() -> some View {
        HStack {
            Text("Status")
            Spacer()
            Picker("", selection: $viewModel.taskStatus) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Text(status.rawValue)
                        .tag(status.rawValue)
                }
                .pickerStyle(.menu)
            }
        }
        .tint(viewModel.taskStatus == .none ? .secondary : theme.selectedTheme.sectionTextColor)
        .foregroundStyle(viewModel.taskStatus == .none ? .secondary : theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
    }
    
    func titleView() -> some View {
        TextFieldWithEnterButton(placeholder: "add a new task", text: $viewModel.title) {
            keyboardButtonAction()
        }
        .focused($isFocused)
        .padding(.vertical, 8)
        .tint(theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
    }
    
    func descriptionView() -> some View {
        TextFieldWithEnterButton(placeholder: "Description", text: $viewModel.description.max(400)) {
            keyboardButtonAction()
        }
        
        .padding(.vertical, 8)
        .tint(theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
    }
    
    func checkList() -> some View {
        ZStack {
            Text("Checklist")
                .padding(.vertical, 8)
                .hAlign(alignment: .leading)
            
            Button {
                show = true
            } label: {
                Text(viewModel.checkBoxes.isEmpty ? "Add" : "Edit")
            }
            .hAlign(alignment: .trailing)
            .padding(.trailing, 10)
        }
        .tint(viewModel.checkBoxes.isEmpty ? .secondary : theme.selectedTheme.sectionTextColor)
        .foregroundColor(viewModel.checkBoxes.isEmpty ? .secondary : theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
    }
    
    func dateView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack {
                Text("Date")
                Spacer()
                Picker("", selection: $viewModel.selectedDateOption) {
                    ForEach(DateType.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag($0.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
            .tint(viewModel.selectedDateOption == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .foregroundStyle(viewModel.selectedDateOption == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .modifier(SectionStyle())
            
            if viewModel.selectedDateOption == .custom {
                CustomCalendarView(
                    selectedCalendarDay: $viewModel.taskDate,
                    currentMonthDatesColor: theme.selectedTheme.sectionTextColor,
                    backgroundColor: theme.selectedTheme.sectionColor
                )
            }
        }
        .onChange(of: $viewModel.selectedDateOption.wrappedValue) { newValue in
            viewModel.setupTaskDate(with: newValue)
        }
    }
    
    func timeView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack {
                Text("Time")
                Spacer()
                Picker("", selection: $viewModel.selectedTimeOption) {
                    ForEach(TimeOption.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag($0.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
            .tint(viewModel.selectedTimeOption == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .foregroundStyle(viewModel.selectedTimeOption == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .modifier(SectionStyle())
            
            if viewModel.selectedTimeOption == .custom {
                TimeView(
                    date: $viewModel.taskTime,
                    timePeriod: $viewModel.selectedDateTimePeriod,
                    timeFormat: viewModel.settings.timeFormat, isTypedTime: .constant(false)
                )
                .modifier(SectionStyle())
            }
        }
        .onChange(of: $viewModel.selectedTimeOption.wrappedValue) { newValue in
            viewModel.setupTaskTime(with: newValue)
        }
    }
    
    func recurringView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack {
                Text("Recurring")
                Spacer()
                Picker("", selection: $viewModel.selectedRecurringOption) {
                    ForEach(RecurringOptions.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option.rawValue)
                    }
                    .pickerStyle(.menu)
                }
            }
            .tint(viewModel.selectedRecurringOption == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .foregroundStyle(viewModel.selectedRecurringOption == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .modifier(SectionStyle())
            
            if viewModel.selectedRecurringOption == .custom {
                RecurringView(viewModel: viewModel)
            }
        }
    }
    
    func reminderView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack {
                Text("Reminder")
                Spacer()
                Picker("", selection: $viewModel.reminder) {
                    ForEach(Reminder.allCases, id: \.self) { reminder in
                        Text(reminder.rawValue)
                            .tag(reminder.rawValue)
                    }
                    .pickerStyle(.menu)
                }
            }
            .tint(viewModel.reminder == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .foregroundStyle(viewModel.reminder == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .modifier(SectionStyle())
            
            if viewModel.reminder == .custom {
                CustomCalendarView(
                    selectedCalendarDay: $viewModel.reminderDate,
                    currentMonthDatesColor: theme.selectedTheme.sectionTextColor,
                    backgroundColor: theme.selectedTheme.sectionColor
                )
                .modifier(SectionStyle())
                
                TimeView(
                    date: $viewModel.reminderTime,
                    timePeriod: $viewModel.selectedReminderTimePeriod,
                    timeFormat: viewModel.settings.timeFormat, isTypedTime: $viewModel.isTypedReminderTime
                )
                .modifier(SectionStyle())
            }
        }
    }
    
    func colorView() -> some View {
        VStack(spacing: 3) {
            HStack {
                Text("Color")
                Spacer()
                Button {
                    viewModel.showColorPanel.toggle()
                } label: {
                    viewModel.selectedColor
                        .frame(width: 20, height: 20)
                        .cornerRadius(4)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(lineWidth: 1)
                                .foregroundColor(theme.selectedTheme.sectionTextColor)
                        }
                }
                .padding(.trailing, 10)
            }
            .modifier(SectionStyle())
            
            if viewModel.showColorPanel {
                colorsPanel()
                    .modifier(SectionStyle())
            }
        }
    }
    
    func tabBarCancelButton() -> some View {
        Button {
            dismiss.callAsFunction()
        } label: {
            Text("Cancel")
        }
        .font(.helveticaRegular(size: 16))
    }
    
    func tabBarSaveButton() -> some View {
        Button {
            let isSaved = viewModel.saveButtonAction(
                hasUnlockedPro: purchaseManager.hasUnlockedPro,
                editTask: editTask,
                taskList: taskList
            )
            if isSaved { dismiss.callAsFunction() }
        } label: {
            Text("Save")
        }
        .font(.helveticaRegular(size: 16))
    }
    
    @ViewBuilder
    func bottomButton() -> some View {
        if let editTask {
            HStack {
                Spacer()
                Button {
                    viewModel.toggleCompletionAction(editTask)
                } label: {
                    Text(viewModel.isCompleted ? "Restore task" : "Complete task")
                }
                
                Button {
                    viewModel.showDeleteAlert = true
                } label: {
                    Text("Delete")
                }
            }
            .foregroundStyle(theme.selectedTheme.textColor)
            .padding(.top, 10)
        }
    }
    
    func keyboardButtonAction() {
        let isSaved = viewModel.saveButtonAction(
            hasUnlockedPro: purchaseManager.hasUnlockedPro,
            editTask: editTask,
            taskList: taskList
        )
        
        if isSaved { dismiss.callAsFunction() }
    }
    
    func colorsPanel() -> some View {
        ColorPanel(selectedColor: $viewModel.selectedColor, colors: viewModel.colors)
    }
}

// MARK: - NewItemView_Previews

struct NewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskView(viewModel: NewTaskViewModel(), taskList: [TaskDTO(object: Constants.shared.mockTask)], editTask: TaskDTO(object: TaskObject()))
            .environmentObject(LocalNotificationManager())
            .environmentObject(PurchaseManager())
            .environmentObject(AppThemeManager())
    }
}
