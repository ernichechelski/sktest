//
//  ShiftsScreensFactory.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import SwiftUI

protocol ShiftsScreensFactory {
    func makeRoot(onEvent: ((ShiftsScreensFactoryEvents.RootEvent) -> Void)?) -> AnyView
    func makeDetails(shift: Shift, onEvent: ((ShiftsScreensFactoryEvents.DetailsEvent) -> Void)?) -> AnyView
}

enum ShiftsScreensFactoryEvents {
    enum RootEvent {
        case onItemSelected(shift: Shift)
    }
    
    enum DetailsEvent {
        case onDismiss
    }
}

final class DefaultShiftsScreensFactory: ShiftsScreensFactory {
    func makeRoot(onEvent: ((ShiftsScreensFactoryEvents.RootEvent) -> Void)?) -> AnyView {
        ShiftsScreen(
            viewModel: ShiftsScreenViewModel(
                viewState: .loading,
                dataSource: DefaultShiftsDataSource(),
                onEvent: onEvent
            )
        )
        .asAnyView()
    }
    
    func makeDetails(shift: Shift, onEvent: ((ShiftsScreensFactoryEvents.DetailsEvent) -> Void)?) -> AnyView {
        ShiftDetailsView(
            componentModel: .constant(ShiftDetailsView.ComponentModel(shiftModel: shift)),
            onEvent: onEvent
        )
        .asAnyView()
    }
}
