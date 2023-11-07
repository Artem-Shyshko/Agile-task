//
//  SectionStyle.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 16.10.2023.
//

import SwiftUI

struct SectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.helveticaRegular(size: 16))
            .hAlign(alignment: .leading)
            .padding(10)
            .background(Color.sectionColor)
            .cornerRadius(4)
            .padding(.horizontal, 10)
    }
}
