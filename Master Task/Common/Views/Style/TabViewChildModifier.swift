//
//  TabViewChildModifier.swift
//  Agile Task
//
//  Created by Artur Korol on 08.01.2024.
//

import SwiftUI

struct TabViewChildModifier: ViewModifier {
  @EnvironmentObject var theme: AppThemeManager
  
  func body(content: Content) -> some View {
    ZStack {
      background()
      
      content
        .padding(.horizontal, 5)
        .padding(.bottom, 35)
    }
    .scrollContentBackground(.hidden)
    .navigationBarBackButtonHidden()
    .onAppear {
      UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
  }
  
  func background() -> some View {
    ZStack {
      theme.selectedTheme.backgroundColor
      theme.selectedTheme.backgroundGradient
    }
    .ignoresSafeArea()
  }
}

