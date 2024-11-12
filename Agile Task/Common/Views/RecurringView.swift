//
//  RecurringView.swift
//  Agile Task
//
//  Created by Artur Korol on 29.08.2023.
//

import SwiftUI

struct RecurringView: View {
    @StateObject var viewModel: NewTaskViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
            repeatEveryView()
            if viewModel.recurringConfiguration.repeatEvery == .weeks { repeatOnView() }
            endsAfterView()
            endsView()
        }
        .padding(.leading, 20)
    }
}

// MARK: - Views

private extension RecurringView {
    func repeatEveryView() -> some View {
        HStack(spacing: 10) {
            Text("Repeat every")
            Spacer()
            TextField("", text: $viewModel.recurringConfiguration.repeatCount)
                .padding(EdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 10))
                .frame(width: 50, height: 35)
                .background(Color.textFieldColor)
                .cornerRadius(7)
                .keyboardType(.numberPad)
            upDownArrows(
                upAction: { viewModel.addRecurringRepeatingCount() },
                downAction: { viewModel.minusRecurringRepeatingCount() }
            )
            
            Menu(viewModel.recurringConfiguration.repeatEvery.rawValue) {
                ForEach(RepeatRecurring.allCases, id: \.self) { item in
                    Button {
                        viewModel.recurringConfiguration.repeatEvery = item
                    } label: {
                        Text(item.rawValue)
                    }
                }
            }
            .frame(width: 70, height: 35, alignment: .center)
            .background(Color.textFieldColor)
            .cornerRadius(7)
            .padding(.trailing, 10)
        }
        .modifier(SectionStyle(opacity: 0.9))
    }
    
    func repeatOnView() -> some View {
        HStack {
            Text("Repeat on")
            Spacer()
            ForEach(Constants.shared.calendar.weekdaySymbols, id: \.self) { day in
                CheckBoxView(viewModel: viewModel, title: day)
            }
        }
        .padding(.trailing, 10)
        .modifier(SectionStyle(opacity: 0.9))
    }
    
    func endsAfterView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Ends after")
                Spacer()
                Button {
                    viewModel.recurringConfiguration.endsOption = .after
                } label: {
                    Image(viewModel.recurringConfiguration.endsOption == .after ? "done-checkbox" : "empty-checkbox")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                
                Text("Ocurrences")
                TextField("", text: $viewModel.recurringConfiguration.endsAfterOccurrences)
                    .frame(width: 30, height: 35)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    .background(Color.textFieldColor)
                    .cornerRadius(5)
                    .keyboardType(.numberPad)
                    .disabled(viewModel.recurringConfiguration.endsOption != .after)
                
                upDownArrows(
                    upAction: { viewModel.addRecurringEndsAfterOccurrences() },
                    downAction: { viewModel.minusRecurringEndsAfterOccurrences() }
                )
                .disabled(viewModel.recurringConfiguration.endsOption != .after)
            }
            .padding(.trailing, 10)
            .modifier(SectionStyle(opacity: 0.9))
        }
    }
    
    func endsView() -> some View {
        HStack(spacing: 30) {
            Text("Ends")
                .hAlign(alignment: .leading)
            HStack(spacing: 20) {
                Button {
                    viewModel.recurringConfiguration.endsOption = .on
                } label: {
                    Image(viewModel.recurringConfiguration.endsOption == .on ? "done-checkbox" : "empty-checkbox")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                .padding(.leading)
                
                DatePicker("", selection: $viewModel.recurringConfiguration.endsDate, displayedComponents: .date)
                    .disabled(viewModel.recurringConfiguration.endsOption != .on)
                    .frame(width: 80, height: 35)
                    .foregroundColor(viewModel.recurringConfiguration.endsOption == .on ? .black : .secondary)
            }
            
            Button {
                viewModel.recurringConfiguration.endsOption = .never
            } label: {
                HStack {
                    Image(viewModel.recurringConfiguration.endsOption == .never ? "done-checkbox" : "empty-checkbox")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("Never")
                }
            }
        }
        .padding(.trailing, 10)
        .modifier(SectionStyle(opacity: 0.9))
    }
    
    func upDownArrows(upAction: @escaping (()->()), downAction: @escaping (()->())) -> some View {
        VStack(spacing: 7) {
            Button {
                upAction()
            } label: {
                Image(systemName: "chevron.up")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .bold()
            }
            
            Button {
                downAction()
            } label: {
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .bold()
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
        .frame(width: 30, height: 30, alignment: .center)
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
        .task {
            if viewModel.recurringConfiguration.repeatOnDays.contains(where: { $0 == title }) {
                isSelected = true
            }
        }
        .onChange(of: isSelected) { isSelectDay in
            viewModel.controlSelectedDay(isSelectDay: isSelectDay, dayName: title)
        }
    }
}

// MARK: - Preview

#Preview {
    RecurringView(viewModel: .init(appState: AppState(), taskList: []))
}
