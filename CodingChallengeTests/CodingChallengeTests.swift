//
//  CodingChallengeTests.swift
//  CodingChallengeTests
//
//  Created by Brady Miller on 4/7/21.
//

import XCTest
import Combine
@testable import CodingChallenge

class CodingChallengeTests: XCTestCase {

    func testExample() throws {
        let previewTimeManager = AppPreviewTimeManager()
        let dataSource = TestShiftsDataSource()
        dataSource.value.send([
            Shift(
                shiftID: 1,
                startTime: previewTimeManager.now,
                endTime: previewTimeManager.now,
                normalizedStartDateTime: previewTimeManager.now,
                normalizedEndDateTime: previewTimeManager.now,
                timezone: "Timezone",
                premiumRate: true,
                covid: true,
                shiftKind: "Kind",
                withinDistance: nil,
                facilityType: FacilityType(
                    id: 1,
                    name: "Name",
                    color: "Red",
                    abbreviation: nil
                ),
                skill: FacilityType(
                    id: 1,
                    name: "Skill",
                    color: "Red",
                    abbreviation: nil
                ),
                localizedSpecialty: LocalizedSpecialty(
                    id: 1,
                    specialtyID: 1,
                    stateID: 1,
                    name: "name",
                    abbreviation: "abbreviation"
                )
            )
        ])
        
        let testViewModel = ShiftsScreenViewModel(
            viewState: .loading,
            dataSource: dataSource
        )
        
        testViewModel.send(action: .viewDidAppear)
        
        let result = try awaitPublisher(testViewModel.$viewState.dropFirst())
        
        XCTAssertTrue((result.currentReady?.shifts.count ?? 0) > 0)
    }
}

private final class TestShiftsDataSource: ShiftsDataSource {
    var currentValue: [Shift] {
        value.value
    }
    
    var value = CurrentValueSubject<[Shift], Never>([])
    
    func shiftsSource() -> AnyPublisher<[Shift], Never> {
        value.eraseToAnyPublisher()
    }
    
    func fetchInitial() -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetchNext() -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

extension XCTestCase {
    /// Waits for publisher to send some event.
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        // This time, we use Swift's Result type to keep track
        // of the result of our Combine pipeline:
        var result: Result<T.Output, Error>?
        let expectation = expectation(description: "Awaiting publisher")
        expectation.assertForOverFulfill = false

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    result = .failure(error)
                    expectation.fulfill()
                case .finished:
                    break
                }
            },
            receiveValue: { value in
                result = .success(value)
                expectation.fulfill()
            }
        )

        // Just like before, we await the expectation that we
        // created at the top of our test, and once done, we
        // also cancel our cancellable to avoid getting any
        // unused variable warnings:
        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        // Here we pass the original file and line number that
        // our utility was called at, to tell XCTest to report
        // any encountered errors at that original call site:
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }
}
