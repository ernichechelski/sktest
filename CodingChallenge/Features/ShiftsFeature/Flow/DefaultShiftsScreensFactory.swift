//
//  DefaultShiftsScreensFactory.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

final class DefaultShiftsScreensFactory {
    private let timeManager: AppTimeManager
    
    init(timeManager: AppTimeManager) {
        self.timeManager = timeManager
    }
}

extension DefaultShiftsScreensFactory: ShiftsScreensFactory {
    func makeRoot(onEvent: ((ShiftsScreensFactoryEvents.RootEvent) -> Void)?) -> AnyView {
        ShiftsScreen(
            viewModel: ShiftsScreenViewModel(
                viewState: .loading,
                dataSource: DefaultShiftsDataSource(
                    timeManager: AppRealTimeManager(),
                    shiftsRepository: ShiftsRepository()
                ),
                onEvent: onEvent
            )
        )
        .asAnyView()
    }
    
    func makeDetails(shift: Shift, onEvent: ((ShiftsScreensFactoryEvents.DetailsEvent) -> Void)?) -> AnyView {
        ShiftDetailsScreen(
            componentModel: .constant(ShiftDetailsScreen.ComponentModel(shiftModel: shift, timeManager: timeManager)),
            onEvent: onEvent
        )
        .asAnyView()
    }
}
