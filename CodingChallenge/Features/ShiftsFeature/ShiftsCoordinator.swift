//
//  ShiftsCoordinator.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Foundation

final class ShiftsCoordinator: Coordinator {
    var parentCoordinator: Coordinator?

    var childCoordinators: [Coordinator] = []

    var navigator: Navigator

    var shiftsScreensFactory: ShiftsScreensFactory = DefaultShiftsScreensFactory()

    init(
        parentCoordinator: Coordinator? = nil,
        childCoordinators: [Coordinator] = [],
        navigator: Navigator
    ) {
        self.parentCoordinator = parentCoordinator
        self.childCoordinators = childCoordinators
        self.navigator = navigator
    }

    func begin() {
        navigator.set {
            [
                shiftsScreensFactory.makeRoot(onEvent: { [weak self] event in
                    switch event {
                    case let .onItemSelected(shift: shift):
                        self?.presentDetails(shift: shift)
                    }
                })
            ]
        }
    }
    
    func presentDetails(shift: Shift) {
        _ = navigator.present {
            [
                self.shiftsScreensFactory.makeDetails(shift: shift, onEvent: { event in
                    switch event {
                    case .onDismiss:
                        self.navigator.dismissPresented()
                    }
                })
            ]
        }
    }
}
