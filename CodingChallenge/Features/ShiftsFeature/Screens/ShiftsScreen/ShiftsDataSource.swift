//
//  ShiftsDataSource.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import Combine
import Foundation

protocol ShiftsDataSource {
    /// Returns current fetched shifts.
    var currentValue: [Shift] { get }

    /// Returns publisher updated every time when `fetchInitial` or `fetchNext` is called.
    func shiftsSource() -> AnyPublisher<[Shift], Never>

    /// Resets selected time and returns publisher with fetching shifts from the beginning.
    func fetchInitial() -> AnyPublisher<Void, Error>

    /// Moves selected time to the next week and returns publisher with fetching shifts.
    func fetchNext() -> AnyPublisher<Void, Error>
}

final class DefaultShiftsDataSource {
    
    enum DefaultShiftsDataSourceError: LocalizedError {
        case cannotCreateDates
    }
    
    private enum Constants {
        static let address = "Dallas, TX" // Fetching only for this address.
    }
    
    private var currentStartDate: Date? {
        if timeManager.now.compare(selectedDate) == .orderedAscending {
            return timeManager.now
        } else {
            return selectedDate.startOfWeek(timeManager: timeManager)?.startOfDay(timeManager: timeManager)
        }
    }
    
    private var currentEndDate: Date? {
        currentStartDate?.endOfWeek(timeManager: timeManager)?.endOfDay(timeManager: timeManager)
    }
    
    private lazy var selectedDate: Date = timeManager.now
    
    private var timeManager: AppTimeManager = AppRealTimeManager()
    
    private var shiftsRepository: ShiftsRepository = ShiftsRepository()
    
    private var value = CurrentValueSubject<[Shift], Never>([])
}

extension DefaultShiftsDataSource: ShiftsDataSource {
    
    var currentValue: [Shift] { value.value }
    
    func fetchInitial() -> AnyPublisher<Void, Error> {
        selectedDate = timeManager.now
        return fetchWithSelectedDate()
    }
    
    func shiftsSource() -> AnyPublisher<[Shift], Never> {
        value.eraseToAnyPublisher()
    }
    
    func fetchWithSelectedDate() -> AnyPublisher<Void, Error> {
        guard
            let startDate = currentStartDate,
            let endDate = currentEndDate
        else {
            return Fail(outputType: Void.self, failure: DefaultShiftsDataSourceError.cannotCreateDates).eraseToAnyPublisher()
        }
        
        return shiftsRepository.fetchShifts(
            responseType: .week,
            start: startDate,
            end: endDate,
            address: Constants.address,
            radius: nil
        )
        .handleEvents(
            receiveOutput: { [weak self] nextValue in
                guard let self = self else { return }
                self.value.send(nextValue + self.value.value)
            }
        )
        .eraseToAnyPublisher()
        .mapToVoid()
    }
    
    func fetchNext() -> AnyPublisher<Void, Error> {
        selectedDate = selectedDate.byAdding(value: 1, component: .weekOfYear, timeManager: timeManager)
        return fetchWithSelectedDate()
    }
}
