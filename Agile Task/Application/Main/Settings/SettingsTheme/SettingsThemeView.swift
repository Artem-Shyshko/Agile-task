//
//  SettingsThemeView.swift
//  Agile Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct SettingsThemeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        
                HStack(spacing: 6) {
                    setupIcon(with: .settingsTheme, size: 12)
                    Text("Themes")
                        .padding(.vertical, 10)
                }
                .modifier(SectionStyle())
                .overlay(alignment: .trailing) {
                    colorButton()
                }
    }
}

// MARK: - Private Views

private extension SettingsThemeView {
    func colorButton() -> some View {
        Menu {
            ForEach(Theme.allCases, id: \.rawValue) { theme in
                Button {
                    themeManager.theme = theme
                } label: {
                    HStack {
                        Image(theme.gradientImageName(colorScheme))
                        Text(theme.rawValue)
                    }
                }
                .modifier(SectionStyle())
            }
        } label: {
            themeManager.theme.gradient(colorScheme)
                    .frame(width: 25, height: 25)
                    .cornerRadius(3)
                    .padding(.trailing, 15)
                    .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - Preview

struct SettingsThemeView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsThemeView()
            .environmentObject(ThemeManager())
    }
}
