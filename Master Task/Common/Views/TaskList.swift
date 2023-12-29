//
//  TaskList.swift
//  Master Task
//
//  Created by Artur Korol on 18.10.2023.
//

import SwiftUI

struct TaskList: View {
  @Binding var taskArray: [TaskDTO]
  
  var body: some View {
    ForEach($taskArray, id: \.self) { task in
        TaskRow(viewModel: TaskListViewModel(), task: task)
    }
    .onMove(perform: { from, to in
      taskArray.move(fromOffsets: from, toOffset: to)
    })
    .listRowSeparator(.hidden)
  }
}

#Preview {
    TaskList(taskArray: .constant([TaskDTO(object: Constants.shared.mockTask)]))
}
