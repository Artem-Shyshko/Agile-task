//
//  RecurringTimeView.swift
//  Agile Task
//
//  Created by Artur Korol on 19.03.2024.
//

import SwiftUI

struct RecurringTimeView: View {
    @Binding var reminderTime: Date
    @Binding var timePeriod: TimePeriod
    @Binding var isTypedTime: Bool
    var timeFormat: TimeFormat
    var isFocus: Bool
    
    var body: some View {
        HStack {
            Text("Time:")
            Spacer()
            
            TimeView(
                date: $reminderTime,
                timePeriod: $timePeriod,
                timeFormat: timeFormat,
                isTypedTime: $isTypedTime,
                isFocus: isFocus
            )
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
