//
//  CheckboxTaskRow.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import SwiftUI

struct CheckboxTaskRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var viewModel: TaskListViewModel
    @Binding var checkbox: CheckboxDTO
    var colorName: String
    var taskId: String
    
    var body: some View {
        HStack {
            Image(checkbox.isCompleted ? "done-checkbox" : "empty-checkbox")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text(checkbox.title)
        }
        .foregroundColor(foregroundColor())
        .strikethrough(checkbox.isCompleted , color: .completedTaskLineColor)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(colorName))
        )
        .listRowSeparator(.hidden)
        .padding(.horizontal, -10)
        .onTapGesture(count: 1, perform: {
            viewModel.completeCheckbox(checkbox, with: taskId)
        })
    }
}

private extension CheckboxTaskRow {
    func foregroundColor() -> Color {
        if checkbox.isCompleted {
            if themeManager.theme.rawValue == Constants.shared.nightTheme,
               colorName != themeManager.theme.sectionColor(colorScheme).name {
                return .black.opacity(0.5)
            } else {
                return  .textColor.opacity(0.5)
            }
        } else {
            if themeManager.theme.rawValue == Constants.shared.nightTheme,
               colorName != themeManager.theme.sectionColor(colorScheme).name {
                return .black
            } else {
                return  themeManager.theme.sectionTextColor(colorScheme)
            }
        }
    }
}

#Preview {
    CheckboxTaskRow(
        viewModel: TaskListViewModel(),
        checkbox: .constant(CheckboxDTO(object: CheckboxObject())),
        colorName: "red", 
        taskId: ""
    )
}
