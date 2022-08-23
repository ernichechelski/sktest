//
//  AppPreviewTimeManager.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import Foundation

/// Time manager returning mocked values.
final class AppPreviewTimeManager: AppTimeManager {
    var timezone = TimeZone.current
    var locale = Locale.current
    var now: Date {
        Date(timeIntervalSince1970: 1648807200) // First April 2022
    }

    private(set) var calendar: Calendar

    init() {
        var systemCalendar: Calendar = .current
        systemCalendar.firstWeekday = 2
        calendar = systemCalendar
    }
}
