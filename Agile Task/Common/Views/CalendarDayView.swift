//
//  CalendarDayView.swift
//  MasterAppsUI
//
//  Created by Artur Korol on 01.04.2024.
//

import SwiftUI

public struct CalendarDayView: View {
    
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var calendarDate: Date
    var currentMonthDatesColor: Color
    var items: [CalendarItem]?
    var isForCalendarPicker: Bool
    var onDateTap: ()->()
    
    var cellFrame: CGFloat {
        isForCalendarPicker ? 30 : 40
    }
    
    var weekDayFontSize: CGFloat {
        isForCalendarPicker ? 13 : 10
    }
    
    init(
        viewModel: CalendarViewModel,
        calendarDate: Binding<Date>,
        currentMonthDatesColor: Color,
        items: [CalendarItem]? = nil,
        isForCalendarPicker: Bool = false,
        onDateTap: @escaping ()->()
    ) {
        self.viewModel = viewModel
        self._calendarDate = calendarDate
        self.currentMonthDatesColor = currentMonthDatesColor
        self.items = items
        self.isForCalendarPicker = isForCalendarPicker
        self.onDateTap = onDateTap
    }
    
    public var body: some View {
        VStack(spacing: 11) {
            HStack {
                ForEach(viewModel.getWeekSymbols(), id: \.self) { day in
                    Text(day.uppercased())
                        .font(.helveticaRegular(size: weekDayFontSize))
                        .foregroundStyle(currentMonthDatesColor)
                }
                .frame(maxWidth: .infinity)
            }
            
            LazyVGrid(columns: viewModel.calendarGridLayout, spacing: isForCalendarPicker ? 0 : 5) {
                ForEach(viewModel.getAllDates(currentDate: calendarDate), id: \.self) { date in
                    calendarCell(date: date)
                        .id(date)
                        .disabled(viewModel.isDisabledDate(date))
                }
            }
        }
    }
}

private extension CalendarDayView {
    func calendarCell(date: Date) -> some View {
        VStack {
            if date.isSameMonth(with: calendarDate) {
                Button {
                    calendarDate = date
                    onDateTap()
                } label: {
                    if date.isSameDay(with: calendarDate) {
                        Text(date.format("d"))
                            .frame(width: cellFrame, height: cellFrame)
                            .background {
                                if !isForCalendarPicker {
                                    Color.calendarSelectedDateCircleColor
                                        .cornerRadius(20)
                                        .clipShape(Circle())
                                }
                            }
                            .font(isForCalendarPicker ? .helveticaBold(size: 16) : .helveticaRegular(size: 12))
                    } else {
                        Text(date.format("d"))
                            .frame(width: cellFrame, height: cellFrame)
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
                    .frame(width: cellFrame, height: cellFrame)
            }
        }
        .font(.helveticaRegular(size: 12))
    }
}

#Preview {
    CalendarDayView(
        viewModel: CalendarViewModel(),
        calendarDate: .constant(Date()),
        currentMonthDatesColor: .black,
        onDateTap: {}
    )
}
