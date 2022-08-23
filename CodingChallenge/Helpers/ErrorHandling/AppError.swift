//
//  AppError.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Foundation

enum AppError: LocalizedError {
    case development
    case arc
    case noData
    case operationCanceled

    var errorDescription: String? {
        switch self {
        case .arc: return "Memory allocation error" // TODO: - Place into localisables
        case .development: return "Development error" // TODO: - Place into localisables
        case .noData: return "Required data not found" // TODO: - Place into localisables
        case .operationCanceled: return "Operation canceled" // TODO: - Place into localisables
        }
    }

    var recoverySuggestion: String? {
        "Contact support" // TODO: - Place into localisables
    }
}
