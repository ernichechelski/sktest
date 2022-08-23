//
//  AppTimeManager.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import Foundation

/// Component conforming to this protocol should
/// return useful data about current time and place.
/// Because the user can change the timezone data provided from this
/// component should be processed at every request or display the data
/// (The timezone or locale cannot be cached somewhere).
protocol AppTimeManager {
    /// Returns computing timezone.
    var timezone: TimeZone { get set }
    /// Returns computing locale.
    var locale: Locale { get set }
    /// Returns computing current date.
    var now: Date { get }
    /// Returns current calendar domain
    var calendar: Calendar { get }
}
