//
//  Publisher+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine

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
