//
//  Date+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import Foundation

extension Date {
    /// Returns start of the week date.
    func startOfWeek(timeManager: AppTimeManager) -> Date? {
        let weekNumber = timeManager.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return timeManager.calendar.date(from: weekNumber)
    }

    /// Returns end of the week date.
    func endOfWeek(timeManager: AppTimeManager) -> Date? {
        guard let start = startOfWeek(timeManager: timeManager) else { return nil }
        return timeManager.calendar.date(byAdding: .day, value: 6, to: start)
    }

    /// Returns start of day date.
    func startOfDay(timeManager: AppTimeManager) -> Date {
        timeManager.calendar.startOfDay(for: self)
    }

    /// Returns new date by adding value into specific `Calendar.Component`
    func byAdding(value: Int, component: Calendar.Component, timeManager: AppTimeManager) -> Date {
        timeManager.calendar.date(byAdding: component, value: value, to: self) ?? timeManager.now
    }

    /// Returns end of day date.
    func endOfDay(timeManager: AppTimeManager) -> Date {
        guard let nextDayDate = timeManager.calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay(timeManager: timeManager)
        ) else {
            preconditionFailure("This should never fail")
        }
        return nextDayDate.addingTimeInterval(-1)
    }
}
