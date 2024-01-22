//
//  CustomCalendarView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 13.10.2023.
//

import SwiftUI

public struct CustomCalendarView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @Binding var selectedCalendarDay: Date
    @Binding var calendarDate: Date
    var currentMonthDatesColor: Color
    var backgroundColor: Color
    var items: [CalendarItem]?
    
    public init(
        selectedCalendarDay: Binding<Date>,
        calendarDate: Binding<Date>,
        currentMonthDatesColor: Color,
        backgroundColor: Color,
        items: [CalendarItem]? = nil,
        calendar: Calendar
    ) {
        self._selectedCalendarDay = selectedCalendarDay
        self._calendarDate = calendarDate
        self.currentMonthDatesColor = currentMonthDatesColor
        self.backgroundColor = backgroundColor
        self.items = items
        viewModel.calendar = calendar
    }
    
    public var body: some View {
        calendar()
    }
}

private extension CustomCalendarView {
    func calendar() -> some View {
        ZStack {
            backgroundColor
                .cornerRadius(4)
            
            VStack(spacing: 11) {
                HStack {
                    ForEach(viewModel.getWeekSymbols(), id: \.self) { day in
                        Text(day)
                            .font(.helveticaRegular(size: 10))
                            .foregroundStyle(currentMonthDatesColor)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                LazyVGrid(columns: viewModel.calendarGridLayout, spacing: 5) {
                    ForEach(viewModel.getAllDates(currentDate: calendarDate), id: \.self) { date in
                        calendarCell(date: date)
                            .id(date)
                            .disabled(viewModel.isDisabledDate(date))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .padding(.bottom, 10)
            
            HStack {
                monthButton()
                yearButton()
                Spacer()
                backToCurrentDateButton()
                minusMonthButton()
                addMonthButton()
            }
            .padding(.top, 15)
            .padding(.horizontal, 15)
            .vAlign(alignment: .top)
        }
    }
    
    func calendarCell(date: Date) -> some View {
        VStack {
            if date.isSameMonth(with: calendarDate) {
                Button {
                    selectedCalendarDay = date
                } label: {
                    if date.isSameDay(with: selectedCalendarDay) {
                        Text(date.format("d"))
                            .frame(width: 40, height: 40)
                            .background {
                                Color.calendarSelectedDateCircleColor
                                    .cornerRadius(20)
                                    .clipShape(Circle())
                            }
                    } else {
                        Text(date.format("d"))
                            .frame(width: 40, height: 40)
                    }
                }
                .foregroundStyle(date.isNotPastDay ? currentMonthDatesColor : .secondary)
                .overlay(alignment: .bottom) {
                    if let items, items.contains(where: { item in
                        (item.date ?? item.createdDate).isSameDay(with: date)
                    }) {
                        Circle()
                            .foregroundColor(date.isNotPastDay ? .calendarSelectedDateCircleColor : .secondary)
                            .frame(width: 4, height: 4)
                            .padding(.bottom, 6)
                    }
                }
            } else {
                Text(date.format("dd"))
                    .foregroundColor(.gray)
                    .frame(width: 35, height: 35)
            }
        }
        .font(.helveticaRegular(size: 12))
    }
    
    func monthButton() -> some View {
        Menu {
            ForEach(0..<viewModel.months.count, id: \.self) { index in
                Button(action: {
                    viewModel.changeMoth(index: index, current: &calendarDate)
                }, label: {
                    Text(viewModel.months[index])
                        .font(.helveticaRegular(size: 14))
                })
            }
        } label: {
            HStack {
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                Text(calendarDate.monthString)
            }
            .font(.helveticaBold(size: 14))
            .foregroundStyle(currentMonthDatesColor)
        }
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func yearButton() -> some View {
        Menu {
            ForEach(viewModel.currentYear..<viewModel.currentYearPlusThen, id: \.self) { year in
                Button(action: {
                    viewModel.changeYear(year, current: &calendarDate)
                    viewModel.showYearList = false
                }, label: {
                    Text(year.description)
                        .font(.helveticaRegular(size: 14))
                })
            }
        } label: {
            HStack {
                Image(systemName: "chevron.down")
                Text(calendarDate.yearString)
            }
            .font(.helveticaBold(size: 14))
            .foregroundStyle(currentMonthDatesColor)
        }
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func addMonthButton() -> some View {
        Button {
            viewModel.addToCurrentDate(currentDate: &calendarDate, component: .month, value: 1)
        } label: {
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func backToCurrentDateButton() -> some View {
        Button(action: {
            viewModel.backToCurrentDateButtonAction(&selectedCalendarDay)
            viewModel.backToCurrentDateButtonAction(&calendarDate)
        }, label: {
            Image(systemName: "arrow.uturn.backward")
        })
        .foregroundStyle(currentMonthDatesColor)
    }
    
    func minusMonthButton() -> some View {
        Button {
            viewModel.minusFromCurrentDate(currentDate: &calendarDate, component: .month, value: 1)
        } label: {
            Image(systemName: "chevron.left")
        }
        .foregroundStyle(currentMonthDatesColor)
    }
}

// MARK: - CalendarItem

public protocol CalendarItem {
    var title: String { get set }
    var date: Date? { get set }
    var createdDate: Date { get set }
}

// MARK: - CalendarView_Previews

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCalendarView(
            selectedCalendarDay: .constant(Date()),
            calendarDate: .constant(Date()),
            currentMonthDatesColor: .white,
            backgroundColor: .secondary,
            items: [],
            calendar: Calendar.current
        )
    }
    
    struct MyItem: CalendarItem {
        var title: String = ""
        var date: Date? = nil
        var createdDate: Date = Date()
    }
}
