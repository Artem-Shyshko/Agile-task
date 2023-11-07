//
//  SectionStyle.swift
//  Master Task
//
//  Created by Artur Korol on 04.10.2023.
//

import SwiftUI

struct SectionStyle: ViewModifier {
    @EnvironmentObject var theme: AppThemeManager
    
    func body(content: Content) -> some View {
        content
            .font(.helveticaRegular(size: 16))
            .foregroundColor(theme.selectedTheme.sectionTextColor)
            .tint(.gray)
            .frame(minHeight: 40)
            .hAlign(alignment: .leading)
            .padding(.leading, 10)
            .background(theme.selectedTheme.sectionColor)
            .cornerRadius(4)
    }
}
