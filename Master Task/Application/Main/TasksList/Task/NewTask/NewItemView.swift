
//
//  NewItemView.swift
//  Master Task
//
//  Created by Artur Korol on 09.08.2023.
//

import SwiftUI
import RealmSwift
import MasterAppsUI

struct NewItemView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var theme: AppThemeManager
    @StateObject var viewModel: NewTaskViewModel
    @FocusState private var isFocused: Bool
    
    @ObservedResults(TaskObject.self) var taskList
    @ObservedResults(Account.self) var savedAccountsList
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.realm) var realm
    
    private var selectedAccount: Account {
        savedAccountsList.first { $0.isSelected }!
    }
    
    var editTask: TaskObject?
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 2) {
                titleView()
                checkList()
                dateAndTime()
                recurringView()
                reminderView()
                colorView()
                projectView()
                Spacer()
            }
        }
        .padding(.top, 25)
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
            viewModel.account = selectedAccount.name
            isFocused = true
            
            if let editTask {
                viewModel.title = editTask.title
                viewModel.date = editTask.date ?? Date()
                viewModel.account = editTask.account
                viewModel.checkBoxes = Array(editTask.checkBoxList)
                viewModel.selectedColor = Color(editTask.colorName)
            }
        }
    }
}

// MARK: - Private Views

private extension NewItemView {
    
    // MARK: - TaskView
    
    func titleView() -> some View {
        ZStack {
            TextField("add a new task", text: $viewModel.title ,axis: .vertical)
                .lineLimit(1...10)
                .frame(minHeight: 35)
                .fixedSize(horizontal: false, vertical: true)
                .focused($isFocused)
                .submitLabel(.done)
            
            Button {
                viewModel.title.append("\n")
            } label: {
                Image("enter")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: 10,height: 10)
                    .padding(.trailing, 16)
            }
            .hAlign(alignment: .trailing)
        }
        
        .modifier(SectionStyle())
    }
    
    func checkList() -> some View {
        ZStack {
            Text("Checklist")
                .padding(.vertical, 8)
                .hAlign(alignment: .leading)
            
            NavigationLink(destination: {
//                NewCheckBoxView(viewModel: NewCheckBoxViewModel(), checkBoxes: $viewModel.checkBoxes)
                NewCheckBoxView(viewModel: NewCheckBoxViewModel(), checkBoxes: $viewModel.checkBoxes, editedTask: editTask != nil ? true : false)
            }, label: {
                Text("add")
            })
            .hAlign(alignment: .trailing)
            .padding(.trailing, 10)
            .foregroundColor(.gray)
        }
        .modifier(SectionStyle())
    }
    
    func dateAndTime() -> some View {
        VStack {
            HStack {
                Text("Date and time")
                Spacer()
                Picker("", selection: $viewModel.selectedDateType) {
                    ForEach(DateType.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag($0.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .tint(viewModel.selectedDateType == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            }
            
            switch viewModel.selectedDateType {
            case .none:
                EmptyView()
            case .set:
                datePiker()
            }
        }
        .modifier(SectionStyle())
        .onChange(of: $viewModel.selectedDateType.wrappedValue) { _ in
            viewModel.date = Date()
        }
    }
    
    func recurringView() -> some View {
        VStack {
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
                .tint(viewModel.selectedRecurringOption == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            }
            
            if viewModel.selectedRecurringOption == .custom {
                divider()
                RecurringView(viewModel: viewModel)
            }
        }
        .modifier(SectionStyle())
    }
    
    func reminderView() -> some View {
        VStack {
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
                .tint(viewModel.reminder == .none ? .secondary : theme.selectedTheme.sectionTextColor)
            }
            
            if viewModel.reminder == .custom {
                divider()
                HStack {
                    Text("Selected date")
                    DatePicker("", selection: $viewModel.reminderDate, in: MasterTaskConstants.shared.currentDate...)
                        .tint(Color.calendarSelectedDateCircleColor)
                        .environment(\.locale, MasterTaskConstants.shared.local)
                }
            }
        }
        .modifier(SectionStyle())
    }
    
    func colorView() -> some View {
        VStack(spacing: 15) {
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
                                .foregroundColor(.white)
                        }
                }
                .padding(.trailing, 10)
            }
            
            if viewModel.showColorPanel {
                colorsPanel()
            }
        }
        .padding(.vertical, 6)
        .modifier(SectionStyle())
    }
    
    func projectView() -> some View {
        HStack {
            Text("Project")
            Spacer()
            Picker("", selection: $viewModel.account) {
                ForEach(savedAccountsList) {
                    Text($0.name)
                        .tag($0.name)
                }
            }
            .pickerStyle(.menu)
            .tint(theme.selectedTheme.sectionTextColor)
        }
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
            guard !viewModel.title.isEmpty else { return }
            
            if let editTask {
                viewModel.writeEditedTask(editTask)
            } else {
                let allTasks = Array(TaskObject.findAll())
                
                guard viewModel.canCreateTask(
                    allTasks: allTasks,
                    hasSubscription: purchaseManager.hasUnlockedPro
                ) else { return }
                
                let account = savedAccountsList.first { $0.name == viewModel.account }!
                let task = viewModel.createTask(in: $taskList)
                Account.addTask(for: account, newTask: task)
                viewModel.writeRecurringTaskArray(for: task, selectedAccount: account)
            }
            
            dismiss.callAsFunction()
        } label: {
            Text("Save")
        }
        .font(.helveticaRegular(size: 16))
    }
    
    func datePiker() -> some View {
        DatePicker("", selection: $viewModel.date, in: MasterTaskConstants.shared.currentDate...)
            .datePickerStyle(.compact)
            .tint(Color.calendarSelectedDateCircleColor)
            .environment(\.locale, MasterTaskConstants.shared.local)
    }
    
    func colorsPanel() -> some View {
        ColorPanel(selectedColor: $viewModel.selectedColor, colors: viewModel.colors)
    }
    
    func divider() -> some View {
        Divider()
            .padding(.leading, 25)
    }
}

// MARK: - NewItemView_Previews

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView(viewModel: NewTaskViewModel(), editTask: TaskObject())
            .environmentObject(LocalNotificationManager())
            .environmentObject(PurchaseManager())
            .environmentObject(AppThemeManager())
    }
}
