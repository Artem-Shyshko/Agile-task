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
        VStack(spacing: 1) {
            
            Text("Theme")
                .padding(.vertical, 10)
                .modifier(SectionStyle())
                .overlay(alignment: .trailing) {
                    colorButton()
                }
            
            Spacer()
        }
        .navigationTitle("Theme")
        .padding(.top, 25)
        .modifier(TabViewChildModifier())
        .navigationBarBackButtonHidden(false)
    }
}

// MARK: - Private Views

private extension SettingsThemeView {
    func colorButton() -> some View {
        Menu {
            ForEach(0..<appThemeManager.themes.count, id: \.self) { i in
                Button {
                    appThemeManager.savedThemeIndex = i
                    switch i {
                    case 0:
                        appThemeManager.changeTheme(mode: .light)
                    case 1:
                        appThemeManager.changeTheme(mode: .dark)
                    default:
                        appThemeManager.changeTheme(mode: .dark)
                    }
                } label: {
                    HStack {
                        Text(appThemeManager.themes[i].name)
                        appThemeManager.themes[i].backgroundColor
                            .frame(width: 5, height: 5)
                        appThemeManager.themes[i].backgroundGradient
                            .frame(width: 5, height: 5)
                    }
                }
                .buttonStyle(SettingsButtonStyle())
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
