//
//  SettingsThemeView.swift
//  Master Task
//
//  Created by Artur Korol on 16.08.2023.
//

import SwiftUI

struct SettingsThemeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var appThemeManager: AppThemeManager
    
    // MARK: - Body
    
    var body: some View {
            Text("Theme")
                .padding(.vertical, 10)
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
            ForEach(appThemeManager.themes.indices, id: \.self) { i in
                Button {
                    appThemeManager.savedThemeIndex = i
                    switch i {
                    case 3:
                        appThemeManager.changeTheme(mode: .dark)
                    default:
                        appThemeManager.changeTheme(mode: .light)
                    }
                } label: {
                    switch i {
                    case 0:
                        HStack {
                            Image("AquamarineColorImage")
                            Text(appThemeManager.themes[i].name)
                        }
                    case 1:
                        HStack {
                            Image("RubyColorImage")
                            Text(appThemeManager.themes[i].name)
                        }
                    case 2:
                        HStack {
                            Image("OceanColorImage")
                            Text(appThemeManager.themes[i].name)
                        }
                    default:
                        HStack {
                            Image("NightColorImage")
                            Text(appThemeManager.themes[i].name)
                        }
                    }
                }
                .modifier(SectionStyle())
            }
        } label: {
            ZStack {
                appThemeManager.selectedTheme.backgroundColor
                    .frame(width: 25, height: 25)
                    .cornerRadius(3)
                    .padding(.trailing, 15)
                appThemeManager.selectedTheme.backgroundGradient
                    .frame(width: 25, height: 25)
                    .cornerRadius(3)
                    .padding(.trailing, 15)
            }
        }
    }
}

// MARK: - Preview

struct SettingsThemeView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsThemeView()
            .environmentObject(AppThemeManager())
    }
}
