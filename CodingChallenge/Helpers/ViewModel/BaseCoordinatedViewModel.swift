//
//  BaseCoordinatedViewModel.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

/// Base view model which supports also sending events to coordinator.
class BaseCoordinatedViewModel<ViewState: Equatable, Action: Equatable, Event>: BaseViewModel<ViewState, Action> {

    private var onEvent: ((Event) -> Void)?

    init(
        viewState: ViewState,
        onEvent: ((Event) -> Void)? = nil
    ) {
        self.onEvent = onEvent
        super.init(viewState: viewState)
    }

    func send(event: Event) {
        onEvent?(event)
    }
}
