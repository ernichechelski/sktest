//
//  IdentifableScreen.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

// TODO: - Missing comments.
protocol IdentifableScreen {
    var uuid: UUID { get }

    var contents: AnyView { get }
}
