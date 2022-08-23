//
//  Publisher+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine
import SwiftUI

extension Publisher {

    /// - Returns:  A single publisher flatMapped with throwing closure.
    func tryFlatMap<Pub: Publisher>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) throws -> Pub
    ) -> Publishers.FlatMap<AnyPublisher<Pub.Output, Error>, Self> {
        flatMap(maxPublishers: maxPublishers) { input -> AnyPublisher<Pub.Output, Error> in
            do {
                return try transform(input)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            } catch {
                return Fail(outputType: Pub.Output.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
    }
    
    /// - Returns:  A single cancellable only with receiveValue sink function.
    func sink(output: @escaping (Self.Output) -> Void) -> AnyCancellable {
        sink(receiveCompletion: { _ in
        }, receiveValue: { value in
            output(value)
        })
    }
    
    /// - Returns:  A single publisher with set output type to Void
    func mapToVoid() -> AnyPublisher<Void, Self.Failure> {
        map { _ in () }
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher {
    
    /// Wraps publisher into async.
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .receive(on: RunLoop.main)
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AppError.noData)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}
