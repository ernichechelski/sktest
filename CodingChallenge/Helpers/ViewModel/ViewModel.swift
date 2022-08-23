//
//  ViewModel.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine

/// Common protocol for management complex view models.
protocol ViewModel: ObservableObject {
    associatedtype ViewState: Equatable
    associatedtype Action: Equatable

    /// Publishes current view state.
    var state: Published<ViewState>.Publisher { get }

    /// Sends action to the view model.
    func send(action: Action)
}
