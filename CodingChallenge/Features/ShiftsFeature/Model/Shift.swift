//
//  ShiftModel.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Foundation

/// Shift business layer model.
// TODO: - Add comments.
struct Shift {
    let shiftID: Int
    let startTime, endTime: Date
    let normalizedStartDateTime: Date
    let normalizedEndDateTime: Date
    let timezone: String
    let premiumRate, covid: Bool
    let shiftKind: String
    let withinDistance: Int?
    let facilityType, skill: FacilityType
    let localizedSpecialty: LocalizedSpecialty
}
