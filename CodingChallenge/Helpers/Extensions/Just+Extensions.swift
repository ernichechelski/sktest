//
//  Just+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine

extension Just {
    var asEffect: AnyPublisher<Self.Output, Error> {
        setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}
