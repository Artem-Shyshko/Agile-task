//
//  RecurringView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 12.10.2023.
//

import SwiftUI

struct RecurringView: View {
    @Binding var recurringConfiguration: RecurringConfiguration
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            repeatEveryView()
            if recurringConfiguration.repeatEvery == .weeks { repeatOnView() }
            endsView()
        }
        .padding(.vertical, 15)
    }
}

// MARK: - Views

private extension RecurringView {
    func repeatEveryView() -> some View {
        HStack(spacing: 15){
            Text("Repeat every")
            TextField("", text: $recurringConfiguration.repeatCount)
                .padding(EdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 10))
                .frame(width: 60, height: 45)
                .background(Color.textFieldColor)
                .cornerRadius(7)
                .keyboardType(.numberPad)
            upDownArrows(
                upAction: { recurringConfiguration.addRecurringRepeatingCount() },
                downAction: { recurringConfiguration.minusRecurringRepeatingCount() }
            )
            
            Picker("", selection: $recurringConfiguration.repeatEvery) {
                ForEach(RepeatRecurring.allCases, id: \.self) { item in
                    Text(item.rawValue)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 90, height: 45, alignment: .leading)
            .background(Color.textFieldColor)
            .cornerRadius(7)
        }
    }
    
    func repeatOnView() -> some View {
        VStack(alignment: .leading) {
            Text("Repeat on")
            HStack {
                ForEach(recurringConfiguration.weekDays, id: \.self) { day in
                    CheckBoxView(configuration: recurringConfiguration, title: day)
                }
            }
        }
    }
    
    func endsView() -> some View {
        VStack(alignment: .leading) {
            Text("Ends")
            HStack(alignment: .bottom, spacing: 30) {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(RecurringEnds.allCases, id: \.self) { rec in
                        Button {
                            recurringConfiguration.recurringEnds = rec
                        } label: {
                            HStack {
                                if recurringConfiguration.recurringEnds == rec {
                                    ZStack {
                                        Circle()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.blue)
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 3)
                                            .fill(Color.white)
                                            .frame(width: 12, height: 12)
                                    }
                                } else {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(lineWidth: 2)
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 20, height: 20)
                                }
                                Text(rec.rawValue)
                                    .foregroundColor(Color.textColor)
                            }
                        }
                    }
                }
                
                VStack(alignment: .center, spacing: 5) {
                    DatePicker("", selection: $recurringConfiguration.recurringEndsDate, displayedComponents: .date)
                        .disabled(recurringConfiguration.recurringEnds != .on)
                        .frame(width: 150, height: 45)
                        .foregroundColor(recurringConfiguration.recurringEnds == .on ? .black : .secondary)
                    HStack(spacing: 20) {
                        TextField("", text: $recurringConfiguration.recurringEndsAfterOccurrences)
                            .frame(width: 150, height: 35)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                            .background(Color.textFieldColor)
                            .cornerRadius(5)
                            .overlay(alignment: .trailing) {
                                Text("occurrences")
                                    .padding(.trailing, 20)
                            }
                            .keyboardType(.numberPad)
                        
                        upDownArrows(
                            upAction: { recurringConfiguration.addRecurringEndsAfterOccurrences() },
                            downAction: { recurringConfiguration.minusRecurringEndsAfterOccurrences() }
                        )
                    }
                    .disabled(recurringConfiguration.recurringEnds != .after)
                }
            }
        }
    }
    
    func upDownArrows(upAction: @escaping (()->()), downAction: @escaping (()->())) -> some View {
        VStack(spacing: 15) {
            Button {
                upAction()
            } label: {
                Image(systemName: "chevron.up")
            }
            
            Button {
                downAction()
            } label: {
                Image(systemName: "chevron.down")
            }
        }
    }
}

// MARK: - DayCheckBox

struct DayCheckBox: Identifiable {
    var id = UUID()
    var dayName: String
    var isSelected: Bool
}

// MARK: - CheckBoxView

struct CheckBoxView: View {
    var configuration: RecurringConfiguration
    var title: String
    @State var isSelected: Bool = false
    
    var body: some View {
        Button(title) {
            isSelected.toggle()
        }
        .foregroundColor(.white)
        .frame(width: 30, height: 30, alignment: .center)
        .background(isSelected ? .blue : .gray.opacity(0.3))
        .cornerRadius(15)
        .onChange(of: isSelected) { isSelectDay in
            configuration.controlSelectedDay(isSelectDay: isSelectDay, dayName: title)
        }
    }
}

// MARK: - Preview

struct RecurringView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringView(recurringConfiguration: .constant(RecurringConfiguration()))
    }
}

final class RecurringConfiguration: ObservableObject {
    @Published var repeatCount: String = "0"
    @Published var repeatEvery: RepeatRecurring = .weeks
    @Published var recurringEnds: RecurringEnds = .never
    @Published var recurringEndsDate: Date = Date()
    @Published var recurringEndsAfterOccurrences = "2"
    @Published var selectedRepeatOnDays: [String] = []
    
    lazy var weekDays = Calendar.current.standaloneWeekdaySymbols
    
    func addRecurringRepeatingCount() {
        repeatCount = String((Int(repeatCount) ?? 0) + 1)
    }
    
    func minusRecurringRepeatingCount() {
        if (Int(repeatCount) ?? 0) > 0 {
            repeatCount = String((Int(repeatCount) ?? 0) - 1)
        }
    }
    
    func addRecurringEndsAfterOccurrences() {
        recurringEndsAfterOccurrences = String((Int(recurringEndsAfterOccurrences) ?? 0) + 1)
    }
    
    func minusRecurringEndsAfterOccurrences() {
        if (Int(recurringEndsAfterOccurrences) ?? 0) > 0 {
            recurringEndsAfterOccurrences = String((Int(recurringEndsAfterOccurrences) ?? 0) - 1)
        }
    }
    
    func controlSelectedDay(isSelectDay: Bool, dayName: String) {
        if isSelectDay {
            selectedRepeatOnDays.append(dayName)
        } else {
            selectedRepeatOnDays.removeAll(where: {$0 == dayName})
        }
    }
}

enum RepeatRecurring: String, CaseIterable {
    case days = "days"
    case weeks = "weeks"
    case month = "month"
    case years = "years"
}

enum RecurringEnds: String, CaseIterable {
    case never = "Never"
    case on = "On"
    case after = "After"
}
