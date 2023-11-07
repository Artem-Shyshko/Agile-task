//
//  SettingsButtonStyle.swift
//  Master Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct SettingsButtonStyle: ButtonStyle {
    @EnvironmentObject var theme: AppThemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.helveticaRegular(size: 16))
            .foregroundColor(theme.selectedTheme.sectionTextColor)
            .frame(height: 40)
            .hAlign(alignment: .leading)
            .padding(.leading)
            .background(theme.selectedTheme.sectionColor)
            .cornerRadius(4)
    }
}
