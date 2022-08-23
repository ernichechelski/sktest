//
//  ScreenIdentifierEnvironmentKey.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

// TODO: - Add documentation.

struct ScreenIdentifierEnvironmentKey: EnvironmentKey {
    static let defaultValue = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

extension EnvironmentValues {
    var screenIdentifier: UUID {
        get { self[ScreenIdentifierEnvironmentKey.self] }
        set { self[ScreenIdentifierEnvironmentKey.self] = newValue }
    }
}

extension View {
    func environmentScreenIdentifier(_ screenIdentifier: UUID) -> some View {
        environment(\.screenIdentifier, screenIdentifier)
    }
}
