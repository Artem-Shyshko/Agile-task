//
//  WelcomeView.swift
//  Agile Task
//
//  Created by Artur Korol on 07.08.2023.
//

import SwiftUI

struct WelcomeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State var showTabBar = false
    
    // MARK: - body
    
    var body: some View {
        ZStack {
            themeManager.theme.gradient(colorScheme)
                .ignoresSafeArea()
            
            VStack {
                VStack() {
                    Spacer()
                    title()
                    Spacer()
                    subTitle()
                    Spacer()
                    AppFeaturesView()
                    Spacer()
                    startButton()
                    Spacer()
                }
            }
            .font(.helveticaRegular(size: 14))
            .foregroundColor(themeManager.theme.textColor(colorScheme))
            .navigationDestination(isPresented: $showTabBar) {
                TabBarView()
            }
        }
    }
}

// MARK: - Private views

private extension WelcomeView {
    func title() -> some View {
        Text("Welcome \nto Agile Task")
            .multilineTextAlignment(.center)
            .font(.helveticaRegular(size: 42))
    }
    
    func subTitle() -> some View {
        Text("Make your plans quickly, easily and without hassle. Agile Task is an efficient task tracker for professional or personal projects to track tasks and execute them efficiently.\n\nPlan everything - from business meetings, trips and doctor appointments to groceries lists. \nDeclutter your notes and organize your schedule with Agile Task.")
            .multilineTextAlignment(.center)
            .font(.helveticaRegular(size: 16))
            .padding(.horizontal, 30)
    }
    
    func startButton() -> some View {
        Button {
            AppHelper.shared.isOnboarding = true
            showTabBar = true
        } label: {
            Text("START")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    
    func groupedLabel(systemImage: String, title: String, imageBackground: Color = .clear) -> some View {
        HStack {
            Image(systemName: systemImage)
                .background(imageBackground.cornerRadius(3))
            Text(title)
        }
        .frame(height: 35)
        .hAlign(alignment: .leading)
    }
}

// MARK: - Preview

#Preview("Ukrainian") {
    WelcomeView()
        .environmentObject(ThemeManager())
        .environment(\.locale, Locale(identifier: "UK"))
}
