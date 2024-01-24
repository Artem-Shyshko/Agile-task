//
//  WelcomeView.swift
//  Master Task
//
//  Created by Artur Korol on 07.08.2023.
//

import SwiftUI

struct WelcomeView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var theme: AppThemeManager
    @State var showTabBar = false
    
    // MARK: - body
    
    var body: some View {
        ZStack {
            Group {
                theme.selectedTheme.backgroundColor
                theme.selectedTheme.backgroundGradient
            }
            .ignoresSafeArea()
            
            VStack(spacing: 80) {
                VStack(spacing: 20) {
                    title()
                    subTitle()
                }
                    AppFeaturesView()
                
                startButton()
            }
            .font(.sfProRegular(size: 14))
            .foregroundColor(theme.selectedTheme.textColor)
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
        Text("Make your plans quickly, easily and without hassle. Agile Task is an efficient task tracker for professional or personal projects to track tasks and execute efficiently. \nPlan everything - from business meetings, trips and doctor appointments to groceries lists. \nDeclutter your notes and organize your schedule with Agile Task.")
            .multilineTextAlignment(.center)
            .font(.helveticaRegular(size: 16))
            .padding(.horizontal, 45)
    }
    
    func startButton() -> some View {
        Button {
            AppHelper.shared.isOnboarding = true
            showTabBar = true
        } label: {
            Text("Start")
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

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AppThemeManager())
    }
}
