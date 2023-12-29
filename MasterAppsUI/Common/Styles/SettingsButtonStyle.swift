//
//  SettingsButtonStyle.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 16.10.2023.
//

import SwiftUI

struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.helveticaRegular(size: 16))
            .frame(height: 40)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            .background(Color.sectionColor)
            .padding(.horizontal, 5)
    }
}
