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
        VStack(alignment: .leading, spacing: Constants.shared.listRowSpacing) {
            repeatEveryView()
            if viewModel.repeatEvery == .weeks { repeatOnView() }
            endsAfterView()
            endsView()
        }
    }
}

// MARK: - Views

private extension RecurringView {
    func repeatEveryView() -> some View {
        HStack(spacing: 10) {
            Text("Repeat every")
            Spacer()
            TextField("", text: $viewModel.repeatCount)
                .padding(EdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 10))
                .frame(width: 50, height: 35)
                .background(Color.textFieldColor)
                .cornerRadius(7)
                .keyboardType(.numberPad)
            upDownArrows(
                upAction: { viewModel.addRecurringRepeatingCount() },
                downAction: { viewModel.minusRecurringRepeatingCount() }
            )
            
            Menu(viewModel.repeatEvery.rawValue) {
                ForEach(RepeatRecurring.allCases, id: \.self) { item in
                    Button {
                        viewModel.repeatEvery = item
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
        .modifier(SectionStyle())
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
        .modifier(SectionStyle())
    }
    
    func endsAfterView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Ends after")
                Spacer()
                Button {
                    viewModel.recurringEnds = .after
                } label: {
                    Image(viewModel.recurringEnds == .after ? "done-checkbox" : "empty-checkbox")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
                
                Text("Ocurrences")
                TextField("", text: $viewModel.recurringEndsAfterOccurrences)
                    .frame(width: 30, height: 35)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    .background(Color.textFieldColor)
                    .cornerRadius(5)
                    .keyboardType(.numberPad)
                    .disabled(viewModel.recurringEnds != .after)
                
                upDownArrows(
                    upAction: { viewModel.addRecurringEndsAfterOccurrences() },
                    downAction: { viewModel.minusRecurringEndsAfterOccurrences() }
                )
                .disabled(viewModel.recurringEnds != .after)
            }
            .padding(.trailing, 10)
            .modifier(SectionStyle())
        }
    }
    
    func endsView() -> some View {
        HStack(spacing: 30) {
            Text("Ends")
            Spacer()
            Button {
                viewModel.recurringEnds = .on
            } label: {
                Image(viewModel.recurringEnds == .on ? "done-checkbox" : "empty-checkbox")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
            }
            .padding(.leading)
            
            DatePicker("", selection: $viewModel.recurringEndsDate, displayedComponents: .date)
                .disabled(viewModel.recurringEnds != .on)
                .frame(width: 80, height: 35)
                .foregroundColor(viewModel.recurringEnds == .on ? .black : .secondary)
            
            Button {
                viewModel.recurringEnds = .never
            } label: {
                HStack {
                    Image(viewModel.recurringEnds == .never ? "done-checkbox" : "empty-checkbox")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("Never")
                }
            }
        }
        .padding(.trailing, 10)
        .modifier(SectionStyle())
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
        .onChange(of: isSelected) { isSelectDay in
            viewModel.controlSelectedDay(isSelectDay: isSelectDay, dayName: title)
        }
    }
}

// MARK: - Preview

struct RecurringView_Previews: PreviewProvider {
    static var previews: some View {
        RecurringView(viewModel: NewTaskViewModel())
            .environmentObject(AppThemeManager())
    }
}
