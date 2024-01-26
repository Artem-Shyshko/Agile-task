//
//  BulletTaskRow.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import SwiftUI

struct BulletTaskRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
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
        .foregroundColor(foregroundColor())
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(colorName))
        )
        .listRowSeparator(.hidden)
        .padding(.horizontal, -10)
    }
}

private extension BulletTaskRow {
    func foregroundColor() -> Color {
            if themeManager.theme.rawValue == Constants.shared.nightTheme,
               colorName != themeManager.theme.sectionColor(colorScheme).name {
                return .black
            } else {
                return  themeManager.theme.sectionTextColor(colorScheme)
            }
    }
}

#Preview {
    BulletTaskRow(
        viewModel: TaskListViewModel(),
        bullet: .constant(BulletDTO(object: BulletObject())),
        colorName: "red"
    )
}
