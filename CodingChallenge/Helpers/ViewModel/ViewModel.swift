//
//  ViewModel.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Combine

protocol ViewModel: ObservableObject {
    associatedtype ViewState: Equatable
    associatedtype Action: Equatable

    var state: Published<ViewState>.Publisher { get }

    func send(action: Action)
}
