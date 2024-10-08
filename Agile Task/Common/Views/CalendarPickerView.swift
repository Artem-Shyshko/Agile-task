//
//  CalendarPickerView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 01.04.2024.
//

import SwiftUI

struct CalendarPickerView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @Binding var selectedCalendarDay: Date
    @Binding var isShowing: Bool
    var currentMonthDatesColor: Color
    var backgroundColor: Color
    var months: [String]
    var availableOptions: [CalendarPickerOptions]
    
    @State private var calendarDate: Date = Date()
    @State private var selectedOption: CalendarPickerOptions = .custom
    @State private var fromDateText = ""
    @State private var toDateText = ""
    private let weekGridLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 10)
    private let monthGridLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
    private let yearGridLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 6)
    
     init(
        selectedCalendarDay: Binding<Date>,
        isShowing: Binding<Bool>,
        currentMonthDatesColor: Color,
        backgroundColor: Color,
        items: [CalendarItem]? = nil,
        calendar: Calendar,
        availableOptions: [CalendarPickerOptions]
    ) {
        self._selectedCalendarDay = selectedCalendarDay
        self._isShowing = isShowing
        self.currentMonthDatesColor = currentMonthDatesColor
        self.backgroundColor = backgroundColor
        self.availableOptions = availableOptions
        months = calendar.standaloneMonthSymbols
        viewModel.calendar = calendar
    }
    
    var body: some View {
        VStack(spacing: 10) {
            dateOptionsView()
            divider()
            selectedOptionView()
            divider()
            applyButton()
        }
        .foregroundColor(currentMonthDatesColor)
        .padding(.vertical, 10)
        .background(backgroundColor)
        .cornerRadius(5)
        .shadow(color: .gray, radius: 10)
        .onAppear {
            fromDateText = selectedCalendarDay.fullDateTextField
            toDateText = selectedCalendarDay.fullDateTextField
            selectedOption = availableOptions.first ?? .day
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
    }
}

private extension CalendarPickerView {
    func dateOptionsView() -> some View {
        HStack(spacing: 20) {
            Spacer()
            ForEach(availableOptions, id: \.rawValue) { option in
                Button {
                    selectedOption = option
                } label: {
                    Text(option.rawValue)
                        .font(
                            option == selectedOption
                            ? .helveticaBold(size: 16)
                            : .helveticaRegular(size: 16)
                        )
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            backToCurrentDateButton()
            closeButton()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func selectedOptionView() -> some View {
        switch selectedOption {
        case .day:
            dayView()
        case .week :
            weekView()
        case .month:
            monthView()
        case .year:
            yearView()
        case .custom:
            customView()
        }
    }
    
    func dayView() -> some View {
        CalendarDayView(
            viewModel: viewModel,
            calendarDate: $calendarDate,
            currentMonthDatesColor: currentMonthDatesColor,
            isForCalendarPicker: true,
            onDateTap: {}
        )
    }
    
    func weekView() -> some View {
        LazyVGrid(columns: weekGridLayout, spacing: 5) {
            ForEach(1...viewModel.numberOfWeeksInYear(calendarDate.weekInt), id: \.self) { week in
                Button(action: {
                    viewModel.changeWeek(week, current: &calendarDate)
                }, label: {
                    Text("\(week)")
                        .font(
                            week == calendarDate.weekInt
                            ? .helveticaBold(size: 16)
                            : .helveticaRegular(size: 16)
                        )
                        .foregroundColor(
                            week == calendarDate.weekInt
                            ? currentMonthDatesColor
                            : .secondary
                        )
                })
            }
        }
    }
    
    func monthView() -> some View {
        VStack {
            HStack(spacing: 10) {
                minusMonthButton()
                Text("\(calendarDate.yearString)")
                    .frame(width: 100)
                addMonthButton()
            }
            
            LazyVGrid(columns: monthGridLayout, spacing: 10) {
                ForEach(0..<months.count, id: \.self) { index in
                    Button(action: {
                        viewModel.changeMoth(index: index, current: &calendarDate)
                    }, label: {
                        Text(months[index])
                            .font(
                                months[index] == calendarDate.monthString
                                ? .helveticaBold(size: 16)
                                : .helveticaRegular(size: 16)
                            )
                            .foregroundColor(
                                months[index] == calendarDate.monthString
                                ? currentMonthDatesColor
                                : .secondary
                            )
                    })
                }
            }
        }
    }
    
    func yearView() -> some View {
        LazyVGrid(columns: yearGridLayout, spacing: 10) {
            ForEach(viewModel.fourteenYersAgo..<viewModel.sixteenYersInFuture, id: \.self) { year in
                Button(action: {
                    viewModel.changeYear(year, current: &calendarDate)
                }, label: {
                    Text("\(year)".trimmingCharacters(in: .whitespaces))
                        .font(
                            year == calendarDate.yearInt
                            ? .helveticaBold(size: 16)
                            : .helveticaRegular(size: 16)
                        )
                        .foregroundColor(
                            year == calendarDate.yearInt
                            ? currentMonthDatesColor
                            : .secondary
                        )
                })
            }
        }
    }
    
    func customView() -> some View  {
        HStack(spacing: 40) {
            TextField("", text: $fromDateText)
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(Color.secondary)
                }
                .onChange(of: fromDateText) { newValue in
                    fromDateText = newValue.applyDateMask()
                }
            Text("-")
            TextField("", text: $toDateText)
                .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(Color.secondary)
                }
                .onChange(of: toDateText) { newValue in
                    toDateText = newValue.applyDateMask()
                }
        }
        .keyboardType(.numberPad)
        .padding(.horizontal, 30)
        .padding(.vertical, 55)
    }
    
    func divider() -> some View {
        Rectangle()
            .fill(.secondary.opacity(0.2))
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
    
    func applyButton() -> some View {
        Button(action: {
            selectedCalendarDay = calendarDate
            isShowing = false
        }, label: {
            Text("Apply")
        })
    }
    
    func addMonthButton() -> some View {
        Button {
            viewModel.addToCurrentDate(currentDate: &calendarDate, component: .year, value: 1)
        } label: {
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func backToCurrentDateButton() -> some View {
        Button(action: {
            viewModel.backToCurrentDateButtonAction(&calendarDate)
        }, label: {
            Image(systemName: "arrow.circlepath")
        })
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func minusMonthButton() -> some View {
        Button {
            if viewModel.canGetPreviousYear(from: calendarDate) {
                viewModel.minusFromCurrentDate(currentDate: &calendarDate, component: .year, value: 1)
            }
        } label: {
            Image(systemName: "chevron.left")
        }
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func closeButton() -> some View {
        Button {
            isShowing = false
        } label: {
            Image(systemName: "xmark")
        }
    }
}

#Preview {
    ZStack {
        Color.black
        
        CalendarPickerView(
            selectedCalendarDay: .constant(Date()),
            isShowing: .constant(false),
            currentMonthDatesColor: .black,
            backgroundColor: .sectionColor,
            calendar: Calendar.current, 
            availableOptions: [.day, .month, .year]
        )
    }
}

public enum CalendarPickerOptions: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case custom = "Custom"
}
