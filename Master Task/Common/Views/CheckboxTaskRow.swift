//
//  CheckboxTaskRow.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 27.12.2023.
//

import SwiftUI

struct CheckboxTaskRow: View {
    @EnvironmentObject var theme: AppThemeManager
    var viewModel: TaskListViewModel
    @Binding var checkbox: CheckboxDTO
    var colorName: String
    
    var body: some View {
        HStack {
            Image(checkbox.isCompleted ? "done-checkbox" : "empty-checkbox")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text(checkbox.title)
        }
        .foregroundColor(checkbox.isCompleted ? .textColor.opacity(0.5) : theme.selectedTheme.sectionTextColor)
        .strikethrough(checkbox.isCompleted , color: .completedTaskLineColor)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(colorName))
        )
        .listRowSeparator(.hidden)
        .padding(.horizontal, -10)
        .onTapGesture(count: 1, perform: {
            viewModel.completeCheckbox(&checkbox)
        })
    }
}

#Preview {
    CheckboxTaskRow(
        viewModel: TaskListViewModel(),
        checkbox: .constant(CheckboxDTO(object: CheckboxObject())),
        colorName: "red"
    )
}
