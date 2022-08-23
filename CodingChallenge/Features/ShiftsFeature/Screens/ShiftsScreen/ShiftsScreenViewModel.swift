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
    
    /// To support native pull to refresh, this is async method.
    func pullToRefresh() async {
        do {
            let result = try await pullToRefresh().async()
            await MainActor.run {
                self.viewState = .ready(state: result)
            }
        } catch {
            self.viewState = .error(text: error.localizedDescription)
        }
    }
}

private extension ShiftsScreenViewModel {
    func onViewDidAppear() -> AnyPublisher<Action, Error> {
        let finalDataSource = dataSource
            .fetchInitial()
            .tryFlatMap { [weak self] _ -> AnyPublisher<[Shift], Error> in
                guard let self = self else {
                    throw AppError.arc
                }
                return self.dataSource
                    .shiftsSource()
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .first()
            .eraseToAnyPublisher()
            .tryMap { [weak self] shifts in
                guard let self = self else {
                    throw AppError.arc
                }
                return shifts.map { shift in
                    self.map(shift: shift)
                }
            }
            .receive(on: RunLoop.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.viewState = .loading
                },
                receiveOutput: { [weak self] shifts in
                    self?.viewState = .ready(state: ViewState.Ready(isLoadingMore: false, shifts: shifts))
                },
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                    case let .failure(error):
                        self?.viewState = .error(text: error.localizedDescription)
                    }
                
                },
                receiveRequest: { [weak self] _ in
                    self?.viewState = .loading
                }
            )
        return finalDataSource.flatMap { _ in Just(Action.none).asEffect }.eraseToAnyPublisher()
    }
    
    func pullToRefresh() -> AnyPublisher<ViewState.Ready, Error> {
        let finalDataSource = dataSource
            .fetchInitial()
            .tryFlatMap { [weak self] _ -> AnyPublisher<[Shift], Error> in
                guard let self = self else {
                    throw AppError.arc
                }
                return self.dataSource
                    .shiftsSource()
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .first()
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .tryMap { [weak self] shifts in
                guard let self = self else {
                    throw AppError.arc
                }
                return shifts.map { shift in
                    self.map(shift: shift)
                }
            }
            .map { shifts in
                ViewState.Ready(isLoadingMore: false, shifts: shifts)
            }
        return finalDataSource.eraseToAnyPublisher()
    }

    func onListScrolledToBottom() -> AnyPublisher<Action, Error> {
        let finalDataSource = dataSource
            .fetchNext()
            .tryFlatMap { [weak self] _ -> AnyPublisher<[Shift], Error> in
                guard let self = self else {
                    throw AppError.arc
                }
                return self.dataSource
                    .shiftsSource()
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .first()
            .receive(on: RunLoop.main)
            .tryMap { [weak self] shifts in
                guard let self = self else {
                    throw AppError.arc
                }
                return shifts.map { shift in
                    self.map(shift: shift)
                }
            }
            .handleEvents { [weak self]  _ in
                guard var currentReady = self?.viewState.currentReady else {
                    return
                }
                currentReady.isLoadingMore = true
                self?.viewState = .ready(state: currentReady)
            } receiveOutput: { [weak self] shifts in
                self?.viewState = .ready(state: ViewState.Ready(isLoadingMore: false, shifts: shifts))
            } receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.viewState = .error(text: error.localizedDescription)
                }
            } receiveRequest: { [weak self] _ in
                guard var currentReady = self?.viewState.currentReady else {
                    return
                }
                currentReady.isLoadingMore = true
                self?.viewState = .ready(state: currentReady)
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return ViewState.Ready.ShiftDisplayable(
            id: UUID(),
            modelID: shift.shiftID,
            timeText:  "\(dateFormatter.string(from: shift.normalizedStartDateTime))-\(dateFormatter.string(from: shift.normalizedEndDateTime))",
            timezoneText: shift.timezone,
            isPremiumRate: shift.premiumRate,
            isCovid: shift.covid,
            shiftKind: shift.shiftKind
        )
    }
}
