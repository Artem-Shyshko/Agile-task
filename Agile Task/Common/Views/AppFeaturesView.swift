//
//  TaskFeaturesView.swift
//  Agile Task
//
//  Created by Artur Korol on 27.10.2023.
//

import SwiftUI

struct AppFeaturesView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 35) {
            VStack(alignment: .leading, spacing: 12) {
                label(image: "Status", text: "Status")
                label(image: "Description", text: "Description")
                label(image: "Checklists", text: "Checklists")
                label(image: "Bullet", text: "Bullet lists")
                label(image: "DateAndTime", text: "Date and time")
                label(image: "Recurring", text: "Reccuring tasks")
                label(image: "Reminders", text: "Reminders")
                label(image: "Color", text: "Color highlights")
            }
            
            VStack(alignment: .leading, spacing: 12) {
                label(image: "Projects", text: "Projects")
                label(image: "CalendarIcon", text: "Calendar")
                label(image: "Navigation", text: "Advanced navigation")
                label(image: "SettingsIcon", text: "Customization")
                label(image: "FaceID", text: "Face ID protection")
                label(image: "Themes", text: "Themes")
                label(image: "Widgets", text: "Widgets")
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
        .background {
            Color.aquamarineColor
                .ignoresSafeArea()
        }
}
