//
//  TabViewChildModifier.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import SwiftUI

struct TabViewChildModifier: ViewModifier {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    var bottomPadding: CGFloat = 35
    
    func body(content: Content) -> some View {
        ZStack {
            background()
            
            content
                .padding(.horizontal, 5)
                .padding(.bottom, bottomPadding)
        }
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func background() -> some View {
        themeManager.theme.gradient(colorScheme)
            .ignoresSafeArea()
    }
}

