//
//  Just+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine

extension Just {
    /// Creates simple publisher, called elsewhere `Effect`.
    var asEffect: AnyPublisher<Self.Output, Error> {
        setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}
