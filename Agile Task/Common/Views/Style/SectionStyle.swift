//
//  SectionStyle.swift
//  Agile Task
//
//  Created by Artur Korol on 04.10.2023.
//

import SwiftUI

struct SectionStyle: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .font(.helveticaRegular(size: 16))
            .foregroundColor(themeManager.theme.sectionTextColor(colorScheme))
            .tint(.gray)
            .frame(minHeight: 44)
            .hAlign(alignment: .leading)
            .padding(.leading, 10)
            .background(themeManager.theme.sectionColor(colorScheme))
            .cornerRadius(4)
            .preferredColorScheme(themeManager.theme.colorScheme)
    }
}