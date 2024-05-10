//
//  RecurringTimeView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 10.05.2024.
//

import SwiftUI
import MasterAppsUI

struct RecurringTimeView: View {
    @Binding var reminderTime: Date
    @Binding var timePeriod: TimePeriod
    @Binding var isTypedTime: Bool
    var timeFormat: TimeFormat
    var isFocus: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image("done-checkbox")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                Text("recurring_title")
            }
            
            Spacer()
            HStack {
                Text("time_title")
                
                TimeView(
                    date: $reminderTime,
                    timePeriod: $timePeriod,
                    timeFormat: timeFormat,
                    isTypedTime: $isTypedTime,
                    isFocus: isFocus
                )
            }
        }
        .modifier(SectionStyle())
    }
}

#Preview {
    RecurringTimeView(
        reminderTime: .constant(Date()),
        timePeriod: .constant(.am),
        isTypedTime: .constant(false),
        timeFormat: .twelve,
        isFocus: false
    )
}
