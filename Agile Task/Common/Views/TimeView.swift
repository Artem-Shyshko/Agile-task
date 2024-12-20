//
//  TimeView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 29.11.2023.
//

import SwiftUI

struct TimeView: View {
    @StateObject var viewModel = TimeViewModel()
    @State var time = ""
    @Binding var date: Date
    @Binding var timePeriod: TimePeriod
    @Binding var isTypedTime: Bool
    var timeFormat: TimeFormat
    var isFocus: Bool
    
    @FocusState var isFocused: Bool
    
    init(date: Binding<Date>, timePeriod: Binding<TimePeriod>, timeFormat: TimeFormat, isTypedTime: Binding<Bool>, isFocus: Bool) {
        self._date = date
        self._timePeriod = timePeriod
        self.timeFormat = timeFormat
        self._isTypedTime = isTypedTime
        self.isFocus = isFocus
    }
    
    var body: some View {
        HStack {
            TextField("", text: $time)
                .cornerRadius(5)
                .textFieldStyle(.roundedBorder)
                .textContentType(.none)
                .keyboardType(.numberPad)
                .frame(width: 60)
                .onAppear {
                    let timeString = date.getTimeString(with: timeFormat)
                    time = timeString.count == 4 ? "0\(timeString)" : timeString
                    
                    if timeFormat == .twelve {
                        let hour = Calendar.current.component(.hour, from: date)
                        timePeriod = hour >= 12 ? .pm : .am
                    }
                    
                    if isFocus {
                        isFocused = true
                    }
                }
                .onChange(of: timePeriod) { _ in
                    reloadTime()
                }
                .onChange(of: time) { newValue in
                    reloadTime()
                }
                .focused($isFocused)
            
            if timeFormat == .twelve {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    let isSelected = timePeriod.rawValue == period.rawValue
                    Button(action: {
                        timePeriod = period
                    }, label: {
                        Text(period.rawValue)
                            .padding(5)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.teaGreenColor)
                                } else {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(lineWidth: 3)
                                        .fill(Color.teaGreenColor)
                                    
                                }
                            }
                            .cornerRadius(4)
                    })
                }
            }
            
            Button(action: {
                time = ""
            }, label: {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .bold()
            })
        }
        .toolbar {
            if isFocused {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isFocused = false
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    func reloadTime() {
        time = viewModel.formatTimeInput(time, format: timeFormat)
        
        var hour = Int(time.prefix(2)) ?? 00
        let minute = Int(time.suffix(2)) ?? 00
        
        if timeFormat == .twelve {
            if timePeriod == .pm && hour < 12 {
                hour += 12
            } else if timePeriod == .am && hour == 12 {
                hour = 0
            }
        }
        
        date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
        isTypedTime = time.count == 5
    }
}

#Preview {
    TimeView(date: .constant(Date()), timePeriod: .constant(.pm), timeFormat: .twentyFour, isTypedTime: .constant(false), isFocus: false)
}

class TimeViewModel: ObservableObject {
    func formatTimeInput(_ input: String, format: TimeFormat) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let maxHourTime = format == .twelve ? 12 : 23
        
        let numericString = input.components(separatedBy: allowedCharacterSet.inverted).joined()
        
        let limitedString = String(numericString.prefix(4))
        
        let formattedString: String
        if limitedString.count > 2 {
            let index = limitedString.index(limitedString.startIndex, offsetBy: 2)
            var hour = limitedString[..<index]
            var minute = limitedString[index...]
            
            if let hourInt = Int(hour) {
                if hourInt == 0 && format == .twelve {
                    hour = "12"
                } else {
                    hour = hourInt > maxHourTime ? "00" : hour
                }
            }
            
            if let minuteInt = Int(minute) {
                minute = minuteInt > 59 ? "00" : minute
            }
            
            formattedString = "\(hour):\(minute)"
        } else {
            formattedString = limitedString
        }
        
        return formattedString
    }
}

extension Date {
    func getTimeString(with timeFormat: TimeFormat) -> String {
        switch timeFormat {
        case .twentyFour:
            return self.format("HH:mm")
        case .twelve:
            return self.format("h:mm")
        }
    }
}
