//
//  View+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

extension View {
    /// Converts the instance of Self view to `AnyView`
    func asAnyView() -> AnyView {
        AnyView(self)
    }

    /// Wraps the view into hosted view controller.
    func hosted(uuid: UUID = UUID()) -> UIViewController {
        UUIDHostingViewController(view: self, uuid: uuid)
    }
}
