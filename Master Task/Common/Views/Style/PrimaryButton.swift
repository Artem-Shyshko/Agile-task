//
//  PrimaryButton.swift
//  Master Task
//
//  Created by Artur Korol on 27.10.2023.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.helveticaBold(size: 16))
            .foregroundColor(Color(hex: "#F77062"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(themeManager.theme.sectionColor(colorScheme))
            .cornerRadius(3)
            .padding(.horizontal, 50)
            .shadow(
                color: .init(hex: "000000").opacity(0.3),
                radius: 5, x: 0, y: 4
            )
    }
}
