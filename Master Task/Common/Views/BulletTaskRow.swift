//
//  BulletTaskRow.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import SwiftUI

struct BulletTaskRow: View {
    @EnvironmentObject var theme: AppThemeManager
    var viewModel: TaskListViewModel
    @Binding var bullet: BulletDTO
    var colorName: String
    
    var body: some View {
        HStack {
            Image(.bullet)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text(bullet.title)
        }
        .foregroundColor(bullet.isCompleted ? .textColor.opacity(0.5) : theme.selectedTheme.sectionTextColor)
        .strikethrough(bullet.isCompleted , color: .completedTaskLineColor)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(colorName))
        )
        .listRowSeparator(.hidden)
        .padding(.horizontal, -10)
        .onTapGesture(count: 1, perform: {
            viewModel.completeBullet(&bullet)
        })
    }
}

#Preview {
    BulletTaskRow(
        viewModel: TaskListViewModel(),
        bullet: .constant(BulletDTO(object: BulletObject())),
        colorName: "red"
    )
}
