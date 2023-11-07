//
//  TaskFeaturesView.swift
//  Master Task
//
//  Created by Artur Korol on 27.10.2023.
//

import SwiftUI

struct AppFeaturesView: View {
    var body: some View {
        HStack(spacing: 35) {
            VStack(alignment: .leading, spacing: 12) {
                label(image: "done-checkbox", text: "Advanced tasks")
                label(image: "Reminders", text: "Reminders")
                label(image: "Recurring", text: "Reccuring tasks")
                label(image: "DateandTime", text: "Date and time")
                label(image: "empty-checkbox", text: "Color highlights")
            }
            
            VStack(alignment: .leading, spacing: 12) {
                label(image: "Projects", text: "Unlimited Projects")
                label(image: "Navigation", text: "Advanced navigation")
                label(image: "CalendarIcon", text: "Calendar")
                label(image: "SettingsIcon", text: "Fine tuning settings")
                label(image: "Widgets", text: "Interactive widgets")
            }
        }
    }
}

private extension AppFeaturesView {
    func label(image: String, text: String) -> some View{
        HStack {
            Image(image)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
            Text(text)
                .font(.helveticaRegular(size: 16))
        }
    }
}

#Preview {
    AppFeaturesView()
}
