
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
    @State private var isShowingCheckBoxView: Bool = false
    @State private var isShowingBulletView: Bool = false
    @State private var isDescriptionEmpty = true
    
    @Environment(\.dismiss) var dismiss
    var taskList: [TaskDTO]
    
    var editTask: TaskDTO?
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            navigationBar()
            ScrollView {
                VStack(spacing: Constants.shared.listRowSpacing) {
                    statusView()
                    titleView()
                    descriptionView()
                    checkList()
                    bulletListView()
                    dateView()
                    timeView()
                    recurringView()
                    reminderView()
                    colorView()
                    projectView()
                    bottomButton()
                    Spacer()
                }
            }
        }
        .modifier(TabViewChildModifier())
        .onAppear {
            isFocused = true
            viewModel.localNotificationManager = localNotificationManager
            
            if let editTask {
                viewModel.taskStatus = editTask.status
                viewModel.title = editTask.title
                viewModel.checkBoxes = editTask.checkBoxArray.sorted(by: { $0.sortingOrder < $1.sortingOrder })
                viewModel.bullets = editTask.bulletArray.sorted(by: { $0.sortingOrder < $1.sortingOrder })
                viewModel.selectedColor = Color(editTask.colorName)
                viewModel.isCompleted = editTask.isCompleted
                if let recurring = editTask.recurring {
                    viewModel.recurringConfiguration = recurring
                }
                viewModel.selectedDateTimePeriod = editTask.timePeriod
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
                if let description = editTask.description {
                    viewModel.description = description
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.showSubscriptionView) {
            SettingsSubscriptionView()
        }
        .fullScreenCover(isPresented: $isShowingCheckBoxView, content: {
            NewCheckBoxView(
                viewModel: NewCheckBoxViewModel(),
                taskCheckboxes: $viewModel.checkBoxes,
                isShowing: $isShowingCheckBoxView,
                task: editTask
            )
        })
        .fullScreenCover(isPresented: $isShowingBulletView, content: {
            BulletView(
                viewModel: BulletViewModel(),
                taskBulletArray: $viewModel.bullets,
                isShowing: $isShowingBulletView,
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
        HStack(spacing: 5) {
            setupIcon(with: .status)
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
    
    @ViewBuilder
    func descriptionView() -> some View {
        HStack(spacing: 5) {
            setupIcon(with: .description)
                .offset(y: isDescriptionEmpty ? -2 : 0)
            TextFieldWithEnterButton(placeholder: "Description", text: $viewModel.description.max(400)) {
                keyboardButtonAction()
            }
        }
        .tint(isDescriptionEmpty ? .secondary : theme.selectedTheme.sectionTextColor)
        .foregroundStyle(isDescriptionEmpty ? .secondary : theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
        .onChange(of: viewModel.description) { newValue in
            isDescriptionEmpty = newValue.isEmpty
        }
    }
    
    func checkList() -> some View {
        HStack(spacing: 5) {
            setupIcon(with: .doneCheckbox)
            Text("Checklist")
                .padding(.vertical, 8)
            Spacer()
            Button {
                isShowingCheckBoxView = true
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
    
    func bulletListView() -> some View {
        HStack(spacing: 5) {
            setupIcon(with: .bullet)
            Text("Bulletlist")
                .padding(.vertical, 8)
            Spacer()
            Button {
                isShowingBulletView = true
            } label: {
                Text(viewModel.bullets.isEmpty ? "Add" : "Edit")
            }
            .hAlign(alignment: .trailing)
            .padding(.trailing, 10)
        }
        .tint(viewModel.bullets.isEmpty ? .secondary : theme.selectedTheme.sectionTextColor)
        .foregroundColor(viewModel.bullets.isEmpty ? .secondary : theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
    }
    
    func dateView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack(spacing: 5) {
                setupIcon(with: .dateAndTime)
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
                    backgroundColor: theme.selectedTheme.sectionColor,
                    calendar: Constants.shared.calendar
                )
            }
        }
        .onChange(of: $viewModel.selectedDateOption.wrappedValue) { newValue in
            viewModel.setupTaskDate(with: newValue)
        }
    }
    
    func timeView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack(spacing: 5) {
                setupIcon(with: .dateAndTime)
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
            HStack(spacing: 5) {
                setupIcon(with: .recurring)
                Text("Recurring")
                Spacer()
                Picker("", selection: $viewModel.recurringConfiguration.option) {
                    ForEach(RecurringOptions.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option.rawValue)
                    }
                    .pickerStyle(.menu)
                }
            }
            .tint(viewModel.recurringConfiguration.option == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .foregroundStyle(viewModel.recurringConfiguration.option == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            .modifier(SectionStyle())
            
            if viewModel.recurringConfiguration.option == .custom {
                RecurringView(viewModel: viewModel)
            }
        }
    }
    
    func reminderView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack(spacing: 5) {
                setupIcon(with: .reminders)
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
                    backgroundColor: theme.selectedTheme.sectionColor,
                    calendar: Constants.shared.calendar
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
            HStack(spacing: 5) {
                setupIcon(with: .color)
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
    
    func projectView() -> some View {
        HStack(spacing: 5) {
            setupIcon(with: .projectMini)
            Text("Project")
            Spacer()
            
            Picker("", selection: $viewModel.selectedProjectName) {
                ForEach(viewModel.projectsNames, id: \.self) { name in
                    Text(name)
                }
            }
            .pickerStyle(.menu)
        }
        .tint(theme.selectedTheme.sectionTextColor)
        .foregroundStyle(theme.selectedTheme.sectionTextColor)
        .modifier(SectionStyle())
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
    
    func setupIcon(with imageResource: ImageResource) -> some View {
        Image(imageResource)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 10, height: 10)
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
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: tabBarCancelButton(),
            header: NavigationTitle("New Task"),
            rightItem: tabBarSaveButton()
        )
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
