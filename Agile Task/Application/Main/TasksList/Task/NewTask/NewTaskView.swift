
//
//  NewItemView.swift
//  Agile Task
//
//  Created by Artur Korol on 09.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

struct NewTaskView: View {
    
    enum Field: Hashable {
        case title
        case description
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: NewTaskViewModel
    @FocusState private var isFocusedField: Field?
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
            .padding(.bottom, 12)
        }
        .modifier(TabViewChildModifier())
        .onAppear {
            isFocusedField = .title
            viewModel.localNotificationManager = localNotificationManager
            viewModel.updateFromEditTask(editTask)
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
        .alert("Task should have title", isPresented: $viewModel.showTitleAlert) {
            Button("OK") {}
        }
    }
}

// MARK: - Private Views

private extension NewTaskView {
    
    func statusView() -> some View {
        CustomPickerView(
            image: .status,
            title: "Status",
            options: TaskStatus.allCases,
            selection: $viewModel.taskStatus,
            isSelected: viewModel.taskStatus != .none
        )
    }
    
    func titleView() -> some View {
        TextFieldWithEnterButton(placeholder: "add a new task", text: $viewModel.title.max(200)) {
            keyboardButtonAction()
        }
        .focused($isFocusedField, equals: .title)
        .padding(.vertical, 8)
        .tint(themeManager.theme.sectionTextColor(colorScheme))
        .modifier(SectionStyle())
        .onTapGesture {
            isFocusedField = .title
        }
    }
    
    @ViewBuilder
    func descriptionView() -> some View {
        HStack(spacing: 5) {
            setupIcon(with: .description)
            TextFieldWithEnterButton(placeholder: "Description", text: $viewModel.description.max(400)) {
                keyboardButtonAction()
            }
            .focused($isFocusedField, equals: .description)
            .onTapGesture {
                isFocusedField = .description
            }
        }
        .padding(.vertical, 8)
        .tint(isDescriptionEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
        .foregroundStyle(isDescriptionEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
        .modifier(SectionStyle())
        .onChange(of: viewModel.description) { newValue in
            isDescriptionEmpty = newValue.isEmpty
        }
    }
    
    func checkList() -> some View {
        Button {
            isShowingCheckBoxView = true
        } label: {
            HStack(spacing: 5) {
                setupIcon(with: .doneCheckbox)
                Text("Checklist")
                    .padding(.vertical, 8)
                Spacer()
                Text(viewModel.checkBoxes.isEmpty ? "Add" : "Edit")
            }
            .hAlign(alignment: .trailing)
            .padding(.trailing, 10)
        }
        .tint(viewModel.checkBoxes.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
        .foregroundColor(viewModel.checkBoxes.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
        .modifier(SectionStyle())
    }
    
    func bulletListView() -> some View {
        Button {
            isShowingBulletView = true
        } label: {
            HStack(spacing: 5) {
                setupIcon(with: .bullet)
                Text("Bulletlist")
                    .padding(.vertical, 8)
                Spacer()
                Text(viewModel.bullets.isEmpty ? "Add" : "Edit")
            }
            .hAlign(alignment: .trailing)
            .padding(.trailing, 10)
        }
        .tint(viewModel.bullets.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
        .foregroundColor(viewModel.bullets.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
        .modifier(SectionStyle())
    }
    
    func dateView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            CustomPickerView(
                image: .dateAndTime,
                title: "Date",
                options: DateType.allCases,
                selection: $viewModel.selectedDateOption,
                isSelected: viewModel.selectedDateOption != .none
            )
            
            if viewModel.selectedDateOption == .custom {
                CustomCalendarView(
                    selectedCalendarDay: $viewModel.taskDate,
                    calendarDate: $viewModel.calendarDate,
                    currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
                    backgroundColor:themeManager.theme.sectionColor(colorScheme),
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
            CustomPickerView(
                image: .dateAndTime,
                title: "Time",
                options: TimeOption.allCases,
                selection: $viewModel.selectedTimeOption,
                isSelected: viewModel.selectedTimeOption != .none
            )
            
            if viewModel.selectedTimeOption == .custom {
                TimeView(
                    date: $viewModel.taskTime,
                    timePeriod: $viewModel.selectedDateTimePeriod,
                    timeFormat: viewModel.settings.timeFormat,
                    isTypedTime: .constant(false)
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
            CustomPickerView(
                image: .recurring,
                title: "Recurring",
                options: RecurringOptions.allCases,
                selection: $viewModel.recurringConfiguration.option,
                isSelected: viewModel.recurringConfiguration.option != .none
            )
            
            if viewModel.recurringConfiguration.option == .custom {
                RecurringView(viewModel: viewModel)
            }
        }
    }
    
    func reminderView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            CustomPickerView(
                image: .reminders,
                title: "Reminder",
                options: Reminder.allCases,
                selection: $viewModel.reminder,
                isSelected: viewModel.reminder != .none
            )
            
            if viewModel.reminder == .custom {
                CustomCalendarView(
                    selectedCalendarDay: $viewModel.reminderDate,
                    calendarDate: $viewModel.calendarDate,
                    currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
                    backgroundColor: themeManager.theme.sectionColor(colorScheme),
                    calendar: Constants.shared.calendar
                )
                .modifier(SectionStyle())
                
                TimeView(
                    date: $viewModel.reminderTime,
                    timePeriod: $viewModel.selectedReminderTimePeriod,
                    timeFormat: viewModel.settings.timeFormat, 
                    isTypedTime: $viewModel.isTypedReminderTime
                )
                .modifier(SectionStyle())
            } else if viewModel.reminder == .tomorrow || viewModel.reminder == .nextWeek {
                TimeView(
                    date: $viewModel.reminderTime,
                    timePeriod: $viewModel.selectedReminderTimePeriod,
                    timeFormat: viewModel.settings.timeFormat, 
                    isTypedTime: $viewModel.isTypedReminderTime
                )
                .modifier(SectionStyle())
            }
        }
    }
    
    func colorView() -> some View {
        VStack(spacing: 3) {
                Button {
                    viewModel.showColorPanel.toggle()
                } label: {
                    HStack(spacing: 5) {
                        setupIcon(with: .color)
                        Text("Color")
                        Spacer()
                    viewModel.selectedColor
                        .frame(width: 20, height: 20)
                        .cornerRadius(4)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(lineWidth: 1)
                                .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
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
        CustomPickerView(
            image: .projectMini,
            title: "Project",
            options: viewModel.projectsNames,
            selection: $viewModel.selectedProjectName,
            isSelected: true
        )
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
            .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
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
        NewTaskView(viewModel: NewTaskViewModel(), taskList: TaskDTO.mockArray(), editTask: TaskDTO(object: TaskObject()))
            .environmentObject(LocalNotificationManager())
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
    }
}

// MARK: - CustomPickerView

struct CustomPickerView<SelectionValue: Hashable & CustomStringConvertible>: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var image: ImageResource?
    var title: String
    var options: [SelectionValue]
    @Binding var selection: SelectionValue
    var isSelected: Bool = true
    
    var body: some View {
        HStack(spacing: 5) {
            if let image {
                Image(image)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
            }
            Menu {
                Picker(selection: $selection, label: EmptyView()) {
                    ForEach(options, id: \.self) { option in
                        Text(option.description)
                            .frame(maxWidth: .infinity)
                            .tag(option)
                    }
                }
            } label: {
                customPickerLabel(rightName: title, leftName: selection.description)
            }
        }
        .tint(isSelected ? themeManager.theme.sectionTextColor(colorScheme) : .secondary)
        .foregroundStyle(isSelected ? themeManager.theme.sectionTextColor(colorScheme) : .secondary)
        .modifier(SectionStyle())
    }
    
    private func customPickerLabel(rightName: String, leftName: String) -> some View {
        HStack {
            Text(rightName)
            Spacer()
            Text(leftName)
            Image(systemName: "chevron.up.chevron.down")
                .imageScale(.small)
        }
        .padding(.trailing, 12)
    }
}
