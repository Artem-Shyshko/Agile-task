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
    @Binding var calendarDates: [Date]
    var weekDayTitles: [String]
    @Binding var currentDate: Date
    var item: [CalendarItem]
    var currentMonthDatesColor: Color
    var backgroundColor: Color
    
    public init(
        selectedCalendarDay: Binding<Date>,
        calendarDates: Binding<[Date]>,
        weekDayTitles: [String],
        currentDate: Binding<Date>,
        item: [CalendarItem],
        currentMonthDatesColor: Color,
        backgroundColor: Color
    ) {
        self._selectedCalendarDay = selectedCalendarDay
        self._calendarDates = calendarDates
        self.weekDayTitles = weekDayTitles
        self._currentDate = currentDate
        self.item = item
        self.currentMonthDatesColor = currentMonthDatesColor
        self.backgroundColor = backgroundColor
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
                    ForEach(weekDayTitles, id: \.self) { day in
                        Text(day)
                            .font(.helveticaRegular(size: 10))
                            .foregroundStyle(currentMonthDatesColor)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                LazyVGrid(columns: viewModel.calendarGridLayout, spacing: 5) {
                    ForEach(calendarDates, id: \.self) { date in
                        calendarCell(date: date)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            
            HStack {
                monthButton()
                yearButton()
            }
            .hAlign(alignment: .leading)
            .vAlign(alignment: .top)
        }
    }
    
    func calendarCell(date: Date) -> some View {
        VStack {
            if date.dateComponents([.year, .month]) == currentDate.dateComponents([.year, .month]) {
                
                Button {
                    selectedCalendarDay = date
                } label: {
                    if date.dateComponents([.day, .month, .year]) == selectedCalendarDay.dateComponents([.day, .month, .year]) {
                        Text(date.format("d"))
                            .frame(width: 40, height: 40)
                            .background {
                                Color.calendarSelectedDateCircleColor
                                    .cornerRadius(20)
                                    .clipShape(Circle())
                            }
                    } else if currentDate == date {
                        Text(date.format("d"))
                            .foregroundColor(.calendarSelectedDateCircleColor)
                            .frame(width: 40, height: 40)
                    } else {
                        Text(date.format("d"))
                            .frame(width: 40, height: 40)
                    }
                }
                .foregroundStyle(currentMonthDatesColor)
                .overlay(alignment: .bottom) {
                    if item.contains(where: { item in
                        (item.date ?? item.createdDate).shortDateFormat == date.shortDateFormat
                    }) {
                        Circle()
                            .foregroundColor(.calendarSelectedDateCircleColor)
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
            Button {
                withAnimation(.easeInOut) {
                    viewModel.showMonthList.toggle()
                }
            } label: {
                HStack {
                    Spacer()
                    Text(currentDate.monthString)
                        .font(.helveticaBold(size: 14))
                    Spacer()
                    Image(systemName: viewModel.showMonthList ? "chevron.up" : "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                }
            }
            .layoutPriority(1)
            .overlay(
                VStack(spacing: 0) {
                    Spacer(minLength: 20)
                    if viewModel.showMonthList {
                        ForEach(0..<viewModel.months.count, id: \.self) { index in
                            Button(action: {
                                viewModel.changeMoth(index: index, current: &currentDate)
                                viewModel.showMonthList = false
                            }, label: {
                                VStack(spacing: 0) {
                                    Text(viewModel.months[index])
                                        .font(.helveticaRegular(size: 14))
                                        .frame(width: 90, alignment: .leading)
                                        .padding(.vertical, 5)
                                        .padding(.leading, 8)
                                    Divider()
                                }
                                .background(backgroundColor)
                            })
                        }
                    }
                }
                    .mask(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.3), radius: 7, x: 0, y: 0),
                alignment: .topLeading
            )
            .padding([.top, .leading], 15)
            .frame(width: 120, alignment: .leading)
            .foregroundColor(currentMonthDatesColor)
    }
    
    func yearButton() -> some View {
        VStack {
            Button {
                withAnimation(.easeInOut) {
                    viewModel.showYearList.toggle()
                }
            } label: {
                HStack {
                    Text(currentDate.yearString)
                        .font(.helveticaBold(size: 14))
                    Image(systemName: viewModel.showYearList ? "chevron.up" : "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 8, height: 8)
                }
            }
            .layoutPriority(1)
            .overlay(
                VStack(spacing: 0) {
                    Spacer(minLength: 20)
                    if viewModel.showYearList {
                        ForEach(viewModel.currentYear..<viewModel.currentYearPlusThen, id: \.self) { year in
                            Button(action: {
                                viewModel.changeYear(year, current: &currentDate)
                                viewModel.showYearList = false
                            }, label: {
                                VStack(spacing: 0) {
                                    Text(year.description)
                                        .font(.helveticaRegular(size: 14))
                                        .frame(width: 80, alignment: .leading)
                                        .padding(.vertical, 5)
                                        .padding(.leading, 8)
                                    Divider()
                                }
                                .background(backgroundColor)
                            })
                        }
                    }
                }
                    .mask(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.3), radius: 7, x: 0, y: 0)
                ,
                alignment: .topLeading
            )
            .padding(.top, 15)
        }
        .foregroundColor(currentMonthDatesColor)
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
            calendarDates: .constant([Date()]),
            weekDayTitles: ["Monday"],
            currentDate: .constant(Date()),
            item: [MyItem()],
            currentMonthDatesColor: .white,
            backgroundColor: .secondary
        )
    }
    
    struct MyItem: CalendarItem {
        var title: String = ""
        var date: Date? = nil
        var createdDate: Date = Date()
    }
}
