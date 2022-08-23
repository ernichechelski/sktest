//
//  Optional+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 21/08/2022.
//

import Foundation

extension Optional {
    /// Throws error if no data required
    func throwing(error: Error = AppError.development) throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw error
        }
    }
}
