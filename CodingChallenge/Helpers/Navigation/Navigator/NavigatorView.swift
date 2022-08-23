//
//  NavigatorView.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 21/08/2022.
//

import SwiftUI

// TODO: - Missing comments.
struct NavigatorView: View {

    let navigator: Navigator
   
    var body: some View {
        NavigatorContainer()
            .environmentObject(
                navigator
            )
    }
}
