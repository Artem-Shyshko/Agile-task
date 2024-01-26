//
//  SettingsButtonStyle.swift
//  Master Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct SettingsButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.helveticaRegular(size: 16))
            .foregroundStyle(themeManager.theme.sectionTextColor(colorScheme))
            .frame(height: 40)
            .hAlign(alignment: .leading)
            .padding(.leading)
            .background(themeManager.theme.sectionColor(colorScheme))
            .cornerRadius(4)
    }
}
