//
//  ShiftsManager.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 21/08/2022.
//

import SwiftUI

final class ShiftsManager: ObservableObject {

    @Published var navigator = Navigator {
        [
            EmptyView().asAnyView()
        ]
    }
    
    private lazy var coordinator = ShiftsCoordinator(navigator: navigator)
    
    private let screensFactory: ShiftsScreensFactory = DefaultShiftsScreensFactory()
    
    init() {
        coordinator.begin()
    }
}
