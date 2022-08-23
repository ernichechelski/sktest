//
//  ShiftsScreenViewModel.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine
import Foundation

final class ShiftsScreenViewModel: BaseCoordinatedViewModel<
    ShiftsScreenViewModel.ViewState,
    ShiftsScreenViewModel.Action,
    ShiftsScreensFactoryEvents.RootEvent
> {
    enum ViewState: Equatable {
        struct Ready: Equatable {
            struct ShiftDisplayable: Equatable, Identifiable {
                let id: UUID
                let modelID: Int
                let timeText: String
                let timezoneText: String
                let isPremiumRate: Bool
                let isCovid: Bool
                let shiftKind: String
            }

            var isLoadingMore: Bool
            var shifts: [ShiftDisplayable]
        }

        case loading
        case error(text: String)
        case ready(state: Ready)

        var currentReady: Ready? {
            switch self {
            case let .ready(state: state):
                return state
            default: return nil
            }
        }
    }

    enum Action: Equatable {
        case viewDidAppear
        case listScrolledToBottom
        case itemSelected(item: ViewState.Ready.ShiftDisplayable)
        case none
    }

    private let dataSource: ShiftsDataSource

    init(
        viewState: ViewState,
        dataSource: ShiftsDataSource,
        onEvent: ((ShiftsScreensFactoryEvents.RootEvent) -> Void)? = nil
    ) {
        self.dataSource = dataSource
        super.init(viewState: viewState, onEvent: onEvent)
    }

    override func handle(
        state: ViewState,
        action: Action
    ) -> AnyPublisher<Action, Error> {
        switch action {
        case .viewDidAppear:
            return onViewDidAppear()
        case .listScrolledToBottom:
            return onListScrolledToBottom()
        case let .itemSelected(shift):
            return onShiftSelected(shift: shift)
        case .none:
            return Just(Action.none).asEffect
        }
    }
}

private extension ShiftsScreenViewModel {
    func onViewDidAppear() -> AnyPublisher<Action, Error> {
        let finalDataSource = dataSource
            .fetchInitial()
            .flatMap {
                self.dataSource
                    .shiftsSource()
                    .setFailureType(to: Error.self)
            }
            .first()
            .receive(on: RunLoop.main)
            .map { shifts in
                shifts.map { shift in
                    self.map(shift: shift)
                }
            }
            .handleEvents { _ in
                self.viewState = .loading
            } receiveOutput: { shifts in
                self.viewState = .ready(state: ViewState.Ready(isLoadingMore: false, shifts: shifts))
            } receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self.viewState = .error(text: error.localizedDescription)
                }
            } receiveCancel: {
            } receiveRequest: { _ in
                self.viewState = .loading
            }
        return finalDataSource.flatMap { _ in Just(Action.none).asEffect }.eraseToAnyPublisher()
    }

    func onListScrolledToBottom() -> AnyPublisher<Action, Error> {
        let finalDataSource = dataSource
            .fetchNext()
            .flatMap {
                self.dataSource
                    .shiftsSource()
                    .setFailureType(to: Error.self)
            }
            .first()
            .receive(on: RunLoop.main)
            .map { shifts in
                shifts.map({ shift in
                    self.map(shift: shift)
                })
            }
            .handleEvents { _ in
                guard var currentReady = self.viewState.currentReady else {
                    return
                }
                currentReady.isLoadingMore = true
                self.viewState = .ready(state: currentReady)
            } receiveOutput: { shifts in
                self.viewState = .ready(state: ViewState.Ready(isLoadingMore: false, shifts: shifts))
            } receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self.viewState = .error(text: error.localizedDescription)
                }
            } receiveCancel: {
            } receiveRequest: { _ in
                guard var currentReady = self.viewState.currentReady else {
                    return
                }
                currentReady.isLoadingMore = true
                self.viewState = .ready(state: currentReady)
            }
        return finalDataSource.flatMap { _ in Just(Action.none).asEffect }.eraseToAnyPublisher()
    }

    func onShiftSelected(shift selectedShift: ViewState.Ready.ShiftDisplayable) -> AnyPublisher<Action, Error> {
        if let match = dataSource.currentValue.first(where: { shift in
            shift.shiftID == selectedShift.modelID
        }) {
            send(event: .onItemSelected(shift: match))
        }
        return Just(Action.none).asEffect
    }

    func map(shift: Shift) -> ViewState.Ready.ShiftDisplayable {
        ViewState.Ready.ShiftDisplayable(
            id: UUID(),
            modelID: shift.shiftID,
            timeText: "\(shift.normalizedStartDateTime)",
            timezoneText: shift.timezone,
            isPremiumRate: shift.premiumRate,
            isCovid: shift.covid,
            shiftKind: shift.shiftKind
        )
    }
}
