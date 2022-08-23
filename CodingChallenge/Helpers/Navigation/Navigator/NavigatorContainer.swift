//
//  NavigatorContainer.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

// TODO: - Missing comments.
struct NavigatorContainer: UIViewRepresentable {
    @EnvironmentObject var navigator: Navigator

    func makeUIView(context _: Context) -> UIView {
        navigator.view
    }

    func updateUIView(_: UIView, context _: Context) {}
}
