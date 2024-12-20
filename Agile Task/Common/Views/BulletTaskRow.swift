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
    
    var viewModel: TasksViewModel
    @Binding var bullet: BulletDTO
    var colorName: String
    
    var body: some View {
        HStack {
            Image(.bullet)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
            Text(LocalizedStringKey(bullet.title))
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(colorName))
        )
        .listRowSeparator(.hidden)
        .padding(.horizontal, Constants.shared.listRowHorizontalPadding)
    }
}

private extension BulletTaskRow {
}

#Preview {
    BulletTaskRow(
        viewModel: TasksViewModel(appState: AppState()),
        bullet: .constant(BulletDTO(object: BulletObject())),
        colorName: "red"
    )
}
