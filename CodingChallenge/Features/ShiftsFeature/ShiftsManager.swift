//
//  ShiftsManager.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 21/08/2022.
//

import SwiftUI

/// Component which using inner navigator runs the Shifts feature.
final class ShiftsManager: ObservableObject {
    @Published var navigator = Navigator {
        [
            EmptyView().asAnyView(),
        ]
    }

    private lazy var coordinator = ShiftsCoordinator(navigator: navigator)

    init() {
        coordinator.begin()
    }
}
