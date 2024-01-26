//
//  TabViewChildModifier.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import SwiftUI

struct TabViewChildModifier: ViewModifier {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        ZStack {
            background()
            
            content
                .padding(.horizontal, 5)
        }
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        }
    }
    
    func background() -> some View {
        themeManager.theme.gradient(colorScheme)
            .ignoresSafeArea()
    }
}

