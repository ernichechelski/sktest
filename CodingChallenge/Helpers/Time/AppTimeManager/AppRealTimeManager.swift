//
//  AppRealTimeManager.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import Foundation

/// Time manager returning real values from device.
final class AppRealTimeManager: AppTimeManager {
    var timezone = TimeZone.autoupdatingCurrent
    var locale = Locale.autoupdatingCurrent
    var now: Date { Date() }
    private(set) var calendar: Calendar

    init() {
        var systemCalendar: Calendar = .autoupdatingCurrent
        systemCalendar.firstWeekday = 2
        calendar = systemCalendar
    }
}
