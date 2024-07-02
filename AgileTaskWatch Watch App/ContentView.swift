//
//  ContentView.swift
//  AgileTaskWatch Watch App
//
//  Created by Artur Korol on 26.06.2024.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Enum
    
    enum Constants {
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 0.3
    }
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var connector: WatchToiOSConnector
    
    var body: some View {
        ScrollView {
            VStack {
                if !connector.tasks.isEmpty {
                    ForEach(connector.tasks, id: \.self) { title in
                        taskTitle(title)
                        if connector.tasks.last != title {
                            divider()
                                .padding(.horizontal, Constants.horizontalPadding)
                        }
                    }
                } else {
                    Text("You don't have any task")
                }
            }
        }
    }
}

private extension ContentView {
    func taskTitle(_ title: String) -> some View {
        Text(LocalizedStringKey(title))
            .font(.helveticaRegular(size: 15))
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .foregroundStyle(.white)
    }
    
    func divider() -> some View{
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.divider)
    }
    
    func foregroundColor() -> Color {
        colorScheme == .dark ? .white : .black
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchToiOSConnector())
}
