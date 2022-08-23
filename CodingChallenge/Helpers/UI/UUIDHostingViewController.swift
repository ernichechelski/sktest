//
//  UUIDHostingViewController.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import SwiftUI

final class UUIDHostingViewController<T: View>: UIHostingController<T>, IdentifableScreen {
    let uuid: UUID

    init(view: T, uuid: UUID) {
        self.uuid = uuid
        super.init(rootView: view)
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var contents: AnyView {
        AnyView(rootView)
    }
}
