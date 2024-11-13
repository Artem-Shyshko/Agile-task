
//
//  NewItemView.swift
//  Agile Task
//
//  Created by Artur Korol on 09.08.2023.
//

import SwiftUI
import RealmSwift

struct NewTaskView: View, KeyboardReadable {
    
    enum Field: Hashable {
        case title
        case description
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: NewTaskViewModel
    @FocusState private var isFocusedField: Field?
    @State private var isKeyboardVisible = false
    @State private var isShowingCheckBoxView: Bool = false
    @State private var isShowingBulletView: Bool = false
    @State private var isDescriptionEmpty = true
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.shared.viewSectionSpacing) {
            navigationBar()
            ScrollView {
                VStack(spacing: Constants.shared.listRowSpacing) {
                    if viewModel.taskType == .advanced {
                        statusView()
                        titleView()
                        descriptionView()
                        checkboxesView()
                        bulletListView()
                        dateView()
                        timeView()
                        recurringView()
                        reminderView()
                        colorView()
                        projectView()
                    } else {
                        titleView()
                        dateView()
                        timeView()
                        reminderView()
                    }
                    bottomButton()
                    Spacer()
                }
            }
            .padding(.bottom, 12)
        }
        .alert(viewModel.alert?.title ?? "", isPresented: $viewModel.isShowingAlert) {
            alertButtons()
        }
        .modifier(TabViewChildModifier(bottomPadding: isKeyboardVisible ? 0 : 35))
        .onAppear {
            isFocusedField = viewModel.editTask == nil ? .title : nil
            viewModel.localNotificationManager = localNotificationManager
            viewModel.updateFromEditTask()
        }
        .navigationDestination(isPresented: $viewModel.showSubscriptionView) {
            SubscriptionView()
        }
        .overlay(alignment: .top) {
            TipView(title: "tip_add_advanced_features", arrowEdge: .top)
                .hAlign(alignment: .trailing)
                .padding(.trailing, AppHelper.shared.isIPad ? 150 : 60)
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            isKeyboardVisible = newIsKeyboardVisible
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
        .modifier(SectionStyle())
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
    
    func bulletListView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack(spacing: 5) {
                setupIcon(with: .bullet)
                chevronButton(
                    isVisible: viewModel.bullets.isEmpty == false,
                    isShowing: viewModel.isShowingBullets
                ) {
                    viewModel.isShowingBullets.toggle()
                }
                Text("Bulletlist")
                    .hAlign(alignment: .leading)
                Button {
                    viewModel.bullets.append(BulletDTO(object: BulletObject(title: "")))
                } label: {
                    Image(systemName: "plus")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .bold()
                        .foregroundStyle(.black)
                }
            }
            .padding(.vertical, 8)
            .tint(viewModel.bullets.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
            .foregroundColor(viewModel.bullets.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
            .modifier(SectionStyle())
            
            bulletList()
        }
        .onChange(of: viewModel.bullets) { newValue in
            if newValue.isEmpty {
                viewModel.isShowingBullets = false
            } else {
                viewModel.isShowingBullets = true
            }
        }
    }
    
    @ViewBuilder
    func chevronButton(isVisible: Bool, isShowing: Bool, action: @escaping (()->())) -> some View {
        if isVisible {
            Button {
                action()
            } label: {
                Image(systemName: isShowing ? "chevron.down" : "chevron.right")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
            }
            .buttonStyle(.borderless)
            .frame(width: 10)
        }
    }
    
    func checkboxesView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack(spacing: 5) {
                setupIcon(with: .doneCheckbox)
                chevronButton(
                    isVisible: viewModel.checkBoxes.isEmpty == false,
                    isShowing: viewModel.isShowingCheckboxes
                ) {
                        viewModel.isShowingCheckboxes.toggle()
                }
                Text("Checklist")
                    .hAlign(alignment: .leading)
                Button {
                    viewModel.checkBoxes.append(.init(title: ""))
                } label: {
                    Image(systemName: "plus")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .bold()
                        .foregroundStyle(.black)
                }
            }
            .padding(.vertical, 8)
            .tint(viewModel.checkBoxes.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
            .foregroundColor(viewModel.checkBoxes.isEmpty ? .secondary : themeManager.theme.sectionTextColor(colorScheme))
            .modifier(SectionStyle())
            
            checkboxList()
        }
        .onChange(of: viewModel.checkBoxes) { newValue in
            if newValue.isEmpty {
                viewModel.isShowingCheckboxes = false
            } else {
                viewModel.isShowingCheckboxes = true
            }
        }
    }
    
    @ViewBuilder
    func checkboxList() -> some View {
        if viewModel.isShowingCheckboxes {
            List {
                ForEach($viewModel.checkBoxes, id: \.id) { checkbox in
                    TextEditor(
                        title: checkbox.title,
                        isFieldOnFocus: true) {
                            viewModel.deletedCheckbox = checkbox.wrappedValue
                            viewModel.alert = .deleteCheckbox
                            viewModel.isShowingAlert = true
                        }
                        .scrollContentBackground(.hidden)
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(themeManager.theme.sectionColor(colorScheme).name).opacity(0.9))
                        )
                }
                .onMove(perform: viewModel.moveCheckbox)
            }
            .padding(.leading, 20)
            .listStyle(.plain)
            .listRowSpacing(Constants.shared.listRowSpacing)
            .scrollDisabled(true)
            .frame(height: 47 * CGFloat(viewModel.checkBoxes.count))
        }
    }
    
    @ViewBuilder
    func bulletList() -> some View {
        if viewModel.isShowingBullets {
            List {
                ForEach($viewModel.bullets, id: \.id) { bullet in
                    TextEditor(
                        title: bullet.title,
                        isFieldOnFocus: true) {
                            viewModel.deletedBullet = bullet.wrappedValue
                            viewModel.alert = .deleteBullet
                            viewModel.isShowingAlert = true
                        }
                        .scrollContentBackground(.hidden)
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(themeManager.theme.sectionColor(colorScheme).name).opacity(0.9))
                        )
                }
                .onMove(perform: viewModel.moveBullet)
            }
            .padding(.leading, 20)
            .listStyle(.plain)
            .listRowSpacing(Constants.shared.listRowSpacing)
            .scrollDisabled(true)
            .frame(height: 47 * CGFloat(viewModel.bullets.count))
        }
    }
    
    @ViewBuilder
    func alertButtons() -> some View {
        Button(viewModel.alert?.cancelButtonTitle ?? "", role: .cancel) {
            viewModel.alert = nil
        }
        
        if viewModel.alert == .deleteTask || viewModel.alert == .deleteBullet || viewModel.alert == .deleteCheckbox {
            Button(viewModel.alert?.actionButtonTitle ?? "", role: .destructive) {
                switch viewModel.alert {
                case .deleteTask:
                    if let editTask = viewModel.editTask {
                        viewModel.deleteTask(parentId: editTask.parentId)
                        dismiss.callAsFunction()
                    }
                case .deleteCheckbox:
                    viewModel.deleteCheckbox()
                case .deleteBullet:
                    viewModel.deleteBullet()
                case .none, .emptyTitle, .weeksRecurring:
                    return
                }
                
                viewModel.alert = nil
            }
        }
    }
    
    func dateView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack {
                CustomPickerView(
                    image: .dateAndTime,
                    title: "Date",
                    options: DateType.allCases,
                    selection: $viewModel.selectedDateOption,
                    isSelected: viewModel.selectedDateOption != .none,
                    dateTitle: viewModel.taskDate.format(viewModel.settings.taskDateFormat.format),
                    isShowingDate: !viewModel.isShowingDateCalendar
                )
                
                if viewModel.selectedDateOption == .custom, !viewModel.isShowingDateCalendar {
                    Button {
                        viewModel.isShowingDateCalendar = true
                    } label: {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .bold()
                    }
                }
            }
            .modifier(SectionStyle())
            
            if viewModel.selectedDateOption == .custom && viewModel.isShowingDateCalendar == true {
                CustomCalendarView(
                    selectedCalendarDay: $viewModel.taskDate,
                    isShowingCalendarPicker: $viewModel.isShowingStartDateCalendarPicker,
                    currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
                    backgroundColor:themeManager.theme.sectionColor(colorScheme),
                    calendar: Constants.shared.calendar) {
                        viewModel.isShowingDateCalendar = false
                    }
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
            .modifier(SectionStyle())
            
            if viewModel.selectedTimeOption == .custom {
                TimeView(
                    date: $viewModel.taskTime,
                    timePeriod: $viewModel.selectedDateTimePeriod,
                    timeFormat: viewModel.settings.timeFormat,
                    isTypedTime: .constant(false),
                    isFocus: viewModel.editTask == nil ? true : false
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
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
            .modifier(SectionStyle())
            
            if viewModel.recurringConfiguration.option == .custom {
                RecurringView(viewModel: viewModel)
            }
        }
    }
    
    func reminderView() -> some View {
        VStack(spacing: Constants.shared.listRowSpacing) {
            HStack {
                CustomPickerView(
                    image: .reminders,
                    title: "Reminder",
                    options: Reminder.allCases,
                    selection: $viewModel.reminder,
                    isSelected: viewModel.reminder != .none,
                    dateTitle: viewModel.reminderDate.format(viewModel.settings.taskDateFormat.format),
                    isShowingDate: !viewModel.isShowingReminderCalendar
                )
                
                if viewModel.reminder == .custom, !viewModel.isShowingReminderCalendar {
                    Button {
                        viewModel.isShowingReminderCalendar = true
                    } label: {
                        Image(systemName: "xmark")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .bold()
                    }
                }
            }
            .modifier(SectionStyle())
            
            switch viewModel.reminder {
            case .custom:
                if viewModel.isShowingReminderCalendar == true {
                    TimeView(
                        date: $viewModel.reminderTime,
                        timePeriod: $viewModel.selectedReminderTimePeriod,
                        timeFormat: viewModel.settings.timeFormat,
                        isTypedTime: $viewModel.isTypedReminderTime,
                        isFocus: viewModel.editTask == nil ? true : false
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .modifier(SectionStyle())
                    
                    CustomCalendarView(
                        selectedCalendarDay: $viewModel.reminderDate,
                        isShowingCalendarPicker: $viewModel.isShowingReminderCalendarPicker,
                        currentMonthDatesColor: themeManager.theme.sectionTextColor(colorScheme),
                        backgroundColor: themeManager.theme.sectionColor(colorScheme),
                        calendar: Constants.shared.calendar
                    ) {
                        viewModel.isShowingReminderCalendar = false
                    }
                    .modifier(SectionStyle())
                }
            case .tomorrow, .nextWeek:
                TimeView(
                    date: $viewModel.reminderTime,
                    timePeriod: $viewModel.selectedReminderTimePeriod,
                    timeFormat: viewModel.settings.timeFormat,
                    isTypedTime: $viewModel.isTypedReminderTime,
                    isFocus: viewModel.editTask == nil ? true : false
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
                .modifier(SectionStyle())
            case .withRecurring:
                RecurringTimeView(
                    reminderTime: $viewModel.reminderTime,
                    timePeriod: $viewModel.selectedReminderTimePeriod,
                    isTypedTime: $viewModel.isTypedReminderTime,
                    timeFormat: viewModel.settings.timeFormat,
                    isFocus: viewModel.editTask == nil ? true : false
                )
            case .inOneHour, .none:
                EmptyView()
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
            if viewModel.isValidForm() {
                checkIfCanCreate()
            }
        } label: {
            Text("Save")
        }
        .font(.helveticaRegular(size: 16))
    }
    
    @ViewBuilder
    func bottomButton() -> some View {
        if let editTask = viewModel.editTask {
            HStack {
                Spacer()
                Button {
                    viewModel.toggleCompletionAction(editTask)
                } label: {
                    Text(viewModel.isCompleted ? "Restore task" : "Complete task")
                }
                
                Button {
                    viewModel.alert = .deleteTask
                    viewModel.isShowingAlert = true
                } label: {
                    Text("Delete")
                }
            }
            .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
            .padding(.top, 10)
        }
    }
    
    func keyboardButtonAction() {
        if viewModel.isValidForm() {
            checkIfCanCreate()
        }
    }
    
    func checkIfCanCreate() {
        if viewModel.taskType == .advanced {
            let project = appState.projectRepository!.getSelectedProject()
            let taskCount = project.tasks
                .filter { $0.taskType == .advanced }
                .count
            if !purchaseManager.canCreateTask(taskCount: taskCount) {
                appState.taskListNavigationStack.append(.subscription)
            } else {
                viewModel.saveButtonAction()
                dismiss.callAsFunction()
            }
        } else {
            viewModel.saveButtonAction()
            dismiss.callAsFunction()
        }
    }
    
    func colorsPanel() -> some View {
        ColorPanel(selectedColor: $viewModel.selectedColor, colors: viewModel.colors)
    }
    
    func navigationBar() -> some View {
        NavigationBarView(
            leftItem: tabBarCancelButton(),
            header: CustomSegmentedControl(
                options: TaskType.allCases,
                selection: $viewModel.taskType
            ).padding(.horizontal, viewModel.settings.appLanguage == .ukrainian ? 35 : 15),
            rightItem: tabBarSaveButton()
        )
        .padding(.horizontal, viewModel.settings.appLanguage == .ukrainian ? -10 : 0)
    }
}

// MARK: - CustomPickerView

struct CustomPickerView<SelectionValue: Hashable & CustomStringConvertible>: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var image: ImageResource?
    var title: LocalizedStringKey
    var options: [SelectionValue]
    @Binding var selection: SelectionValue
    var isSelected: Bool = true
    var dateTitle: String?
    var isShowingDate: Bool = true
    
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
                        Text(LocalizedStringKey(option.description))
                            .frame(maxWidth: .infinity)
                            .tag(option)
                    }
                }
            } label: {
                if selection.description.localized == "Custom".localized, let dateTitle, isShowingDate {
                    customPickerLabel(leftName: title, rightName: dateTitle.localized, showImage: false)
                } else {
                    customPickerLabel(leftName: title, rightName: selection.description.localized)
                }
            }
        }
        .tint(isSelected ? themeManager.theme.sectionTextColor(colorScheme) : .secondary)
        .foregroundStyle(isSelected ? themeManager.theme.sectionTextColor(colorScheme) : .secondary)
    }
    
    private func customPickerLabel(leftName: LocalizedStringKey, rightName: LocalizedStringKey, showImage: Bool = true) -> some View {
        HStack {
            Text(leftName)
            Spacer()
            Text(rightName)
            if showImage {
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
    }
}


// MARK: - NewItemView_Previews

struct NewTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NewTaskView(viewModel: NewTaskViewModel(appState: AppState(), editTask: TaskDTO(object: TaskObject()), taskList: TaskDTO.mockArray()))
            .environmentObject(LocalNotificationManager())
            .environmentObject(PurchaseManager())
            .environmentObject(ThemeManager())
            .environmentObject(AppState())
            .environment(\.locale, NSLocale(localeIdentifier: "uk") as Locale)
    }
}
