//
//  SectionStyle.swift
//  Agile Task
//
//  Created by Artur Korol on 04.10.2023.
//

import SwiftUI

struct SectionStyle: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    var opacity: CGFloat? = nil
    
    func body(content: Content) -> some View {
        content
            .font(.helveticaRegular(size: 16))
            .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
            .tint(.gray)
            .frame(minHeight: 44)
            .hAlign(alignment: .leading)
            .padding(.horizontal, 10)
            .background(
                opacity == nil
                ? themeManager.theme.sectionColor(colorScheme)
                : themeManager.theme.sectionColor(colorScheme).opacity(opacity ?? 1)
            )
            .cornerRadius(4)
            .environment(\.locale, Locale(identifier: appState.settings.appLanguage.identifier))
    }
}
