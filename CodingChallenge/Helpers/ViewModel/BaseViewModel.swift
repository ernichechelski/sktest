//
//  BaseViewModel.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine

/// Base class which manages actions loop.
class BaseViewModel<ViewState: Equatable, Action: Equatable>: ViewModel {

    var state: Published<ViewState>.Publisher {
        $viewState
    }

    @Published var viewState: ViewState

    var cancellables = Set<AnyCancellable>()

    private var reducer: AnyPublisher<(ViewState, Action), Error> {
        actionsPublisher
            .removeDuplicates()
            .tryMap { [weak self] in
                try (self.throwing(error: AppError.arc).viewState, $0)
            }
            .eraseToAnyPublisher()
    }

    private var actionsPublisher = PassthroughSubject<Action, Never>()

    init(
        viewState: ViewState
    ) {
        self.viewState = viewState
        setup()
    }

    func handle(state: ViewState, action: Action) -> AnyPublisher<Action, Error> {
        fatalError("Must be overriden")
    }

    func send(action: Action) {
        actionsPublisher.send(action)
    }

    func setup() {
        reducer
            .share()
            .tryFlatMap { [weak self] (currentViewState: ViewState, action: Action) -> AnyPublisher<Action, Error> in
                guard let self = self else {
                    throw AppError.arc
                }
                return self.handle(
                    state: currentViewState,
                    action: action
                )
            }
            .eraseToAnyPublisher()
            .sink(output: { [weak self] action in
                self?.send(action: action)
            })
            .store(in: &cancellables)
    }
}
