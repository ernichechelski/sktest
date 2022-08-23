//
//  ShiftsScreensFactory.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import SwiftUI

protocol ShiftsScreensFactory {
    /// Returns root screen with shifts.
    func makeRoot(onEvent: ((ShiftsScreensFactoryEvents.RootEvent) -> Void)?) -> AnyView

    /// Returns details screen with shift.
    func makeDetails(shift: Shift, onEvent: ((ShiftsScreensFactoryEvents.DetailsEvent) -> Void)?) -> AnyView
}

enum ShiftsScreensFactoryEvents {
    enum RootEvent {
        /// Triggered when the user taps the shift.
        case onItemSelected(shift: Shift)
    }

    enum DetailsEvent {
        /// Triggered when the user taps the dismiss button.
        case onDismiss
    }
}
