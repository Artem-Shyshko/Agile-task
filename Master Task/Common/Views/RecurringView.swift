//
//  RecurringView.swift
//  Master Task
//
//  Created by Artur Korol on 29.08.2023.
//

import SwiftUI

struct RecurringView: View {
    @StateObject var viewModel: NewTaskViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            repeatEveryView()
            if viewModel.repeatEvery == .weeks { repeatOnView() }
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
            TextField("", text: $viewModel.repeatCount)
                .padding(EdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 10))
                .frame(width: 60, height: 45)
                .background(Color.textFieldColor)
                .cornerRadius(7)
                .keyboardType(.numberPad)
            upDownArrows(
                upAction: { viewModel.addRecurringRepeatingCount() },
                downAction: { viewModel.minusRecurringRepeatingCount() }
            )
            
            Picker("", selection: $viewModel.repeatEvery) {
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
                ForEach(viewModel.weekDays, id: \.self) { day in
                    CheckBoxView(viewModel: viewModel, title: day)
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
                            viewModel.recurringEnds = rec
                        } label: {
                            HStack {
                                if viewModel.recurringEnds == rec {
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
                    DatePicker("", selection: $viewModel.recurringEndsDate, displayedComponents: .date)
                        .disabled(viewModel.recurringEnds != .on)
                        .frame(width: 150, height: 45)
                        .foregroundColor(viewModel.recurringEnds == .on ? .black : .secondary)
                    HStack(spacing: 20) {
                        TextField("", text: $viewModel.recurringEndsAfterOccurrences)
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
                            upAction: { viewModel.addRecurringEndsAfterOccurrences() },
                            downAction: { viewModel.minusRecurringEndsAfterOccurrences() }
                        )
                    }
                    .disabled(viewModel.recurringEnds != .after)
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
    var viewModel: NewTaskViewModel
    var title: String
    @State var isSelected: Bool = false
    
    var body: some View {
        Button(title.firstLetter) {
            isSelected.toggle()
        }
        .foregroundColor(.white)
        .frame(width: 30, height: 30, alignment: .center)
        .background(isSelected ? .blue : .gray.opacity(0.3))
        .cornerRadius(15)
        .onChange(of: isSelected) { isSelectDay in
            viewModel.controlSelectedDay(isSelectDay: isSelectDay, dayName: title)
        }
    }
}

// MARK: - Preview

struct RecurringView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringView(viewModel: NewTaskViewModel())
    }
}
