//
//  NavigatorWrapper.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

// TODO: - Missing comments.
struct NavigatorWrapper: View {

    var builder: () -> [AnyView]

    var body: some View {
        NavigatorStrongContainer(
            navigator: Navigator(builder: builder)
        )
    }
}
