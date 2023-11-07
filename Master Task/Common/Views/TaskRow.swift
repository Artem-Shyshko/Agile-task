//
//  TaskRow.swift
//  Master Task
//
//  Created by Artur Korol on 25.08.2023.
//

import SwiftUI
import RealmSwift

struct TaskRow: View {
    @ObservedResults(TaskObject.self) var savedTaskList
    @ObservedResults(TaskSettings.self) var savedTaskSettings
    @EnvironmentObject var theme: AppThemeManager
    @ObservedRealmObject var task: TaskObject
    @Environment(\.realm) var realm
    @State var isAlert = false
    
    var taskSettings: TaskSettings {
        savedTaskSettings.first!
    }
    
    var body: some View {
        VStack {
            if task.checkBoxList.isEmpty {
                singleTaskRow()
            } else {
                checkBoxesTaskRow()
            }
        }
        .font(.helveticaRegular(size: 16))
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(task.colorName))
        )
        .alert("Are you sure you want to delete", isPresented: $isAlert) {
            Button("Cancel", role: .cancel) {
                isAlert = false
            }
            
            Button("Delete") {
                $savedTaskList.remove(task)
            }
        }
    }
    
    private func updateTask() {
        guard let updateObject = realm.object(ofType: TaskObject.self, forPrimaryKey: task.id) else { return }
        do {
            try realm.write {
                updateObject.isCompleted.toggle()
                
                if !updateObject.checkBoxList.isEmpty {
                    Array(updateObject.checkBoxList).forEach {
                        $0.isCompleted = true
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func updateCheckBox(id: ObjectId) {
        guard let updateObject = realm.object(ofType: CheckBoxObject.self, forPrimaryKey: id) else { return }
        do {
            try realm.write {
                updateObject.isCompleted.toggle()
            }
        } catch {
            print(error)
        }
    }
}

private extension TaskRow {
    func singleTaskRow() -> some View {
        HStack(spacing: 5) {
            if task.isCompleted {
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 15)
            }
            
            Text(task.title)
                .font(.helveticaRegular(size: 16))
            Spacer()
            
            if let date = task.date {
                Text(date.format(
                    taskSettings.taskDateFormat == .dayFirst
                    ? "EE dd/MM/yy"
                    : "EE MM/dd/yy")
                )
                .font(.helveticaRegular(size: 14))
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
        .foregroundColor(task.isCompleted ? .textColor.opacity(0.5) : theme.selectedTheme.sectionTextColor)
        .overlay(alignment: .leading) {
            if task.isCompleted {
                Rectangle()
                    .padding(.leading, 15)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.completedTaskLineColor)
            }
        }
        .onTapGesture(count: 2, perform: {
            updateTask()
        })
        .swipeActions {
            Button {
                isAlert = true
            } label: {
                Image("trash")
            }
            .tint(.red)
            
            NavigationLink {
                NewItemView(viewModel: NewTaskViewModel(), editTask: task)
            } label: {
                Image("edit")
            }
            .tint(Color.editButtonColor)
            
            Button {
                updateTask()
            } label: {
                Image("done-checkbox")
            }
            .tint(.green)
        }
    }
    
    func checkBoxTaskRow(title: String, isDone: Bool) -> some View {
        HStack {
            Image(isDone ? "done-checkbox" : "empty-checkbox")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text(title)
        }
        .foregroundColor(isDone ? .textColor.opacity(0.5) : theme.selectedTheme.sectionTextColor)
        .overlay(alignment: .leading) {
            if isDone {
                Rectangle()
                    .padding(.leading, 15)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.completedTaskLineColor)
            }
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(task.colorName))
        )
        .listRowSeparator(.hidden)
    }
    
    func checkBoxesTaskRow() -> some View {
        VStack(alignment: .leading) {
            let completedTaskCount = task.checkBoxList.filter {$0.isCompleted}.count
            HStack(spacing: 5) {
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 15)
                }
                
                Text(task.title)
                Spacer()
                Text("\(completedTaskCount)/\(task.checkBoxList.count)")
            }
            .font(.helveticaRegular(size: 16))
            .foregroundColor(
                completedTaskCount == task.checkBoxList.count 
                ? .textColor.opacity(0.5)
                : theme.selectedTheme.sectionTextColor
            )
            .onTapGesture(count: 2, perform: {
                updateTask()
            })
            .overlay(alignment: .leading) {
                if task.isCompleted {
                    Rectangle()
                        .padding(.leading, 15)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.completedTaskLineColor)
                }
            }
            
            ForEach(task.checkBoxList, id: \.id) { checkBox in
                checkBoxTaskRow(title: checkBox.title, isDone: checkBox.isCompleted)
                    .onTapGesture(count: 2, perform: {
                        updateCheckBox(id: checkBox.id)
                    })
            }
        }
        .swipeActions {
            Button {
                isAlert = true
            } label: {
                Image("trash")
            }
            .tint(.red)
            
            NavigationLink {
                NewItemView(viewModel: NewTaskViewModel(), editTask: task)
            } label: {
                Image("edit")
            }
            .tint(Color.editButtonColor)
            
            Button {
                updateTask()
            } label: {
                Image("done-checkbox")
            }
            .tint(.green)
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: MasterTaskConstants.mockTask)
            .environmentObject(AppThemeManager())
    }
}
