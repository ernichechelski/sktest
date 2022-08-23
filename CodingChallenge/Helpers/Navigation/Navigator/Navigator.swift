//
//  Navigator.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 21/08/2022.
//

import UIKit
import SwiftUI

// TODO: - Missing comments.
final class Navigator: ObservableObject {

    private var navigationController: UINavigationController

    var view: UIView {
        navigationController.view
    }

    init(
        navigationController: UINavigationController = UINavigationController(),
        builder: () -> [AnyView]
    ) {
        self.navigationController = navigationController
        self.set(animated: false, builder: builder)
    }
    
    func set(animated: Bool = true, builder: () -> [AnyView]) {
        navigationController
            .setViewControllers(
                builder().map { $0.hosted() },
                animated: animated
            )
    }

    func push<T: View>(view: T, uuid: UUID = UUID(), animated: Bool = true) {
        let vc = view.environmentObject(self).environmentScreenIdentifier(uuid).hosted(uuid: uuid)
        navigationController.pushViewController(vc, animated: animated)
    }
    
    func present(
        animated: Bool = true,
        uuid: UUID = UUID(),
        presentationStyle: UIModalPresentationStyle = .automatic,
        builder: () -> [AnyView]
    ) -> Navigator {
        let navigator = Navigator(builder: builder)
        let vc = NavigatorContainer()
            .environmentObject(navigator)
            .hosted(uuid: uuid)
        vc.modalPresentationStyle = presentationStyle
        UIApplication.rootViewController?.present(vc, animated: animated)
        return navigator
    }
    
    func pop(animated: Bool = true) {
        _ = navigationController.popViewController(animated: animated)
    }
    
    func pop(to: UUID, animated: Bool = true) {
        guard let match = navigationController.viewControllers.first (where: { viewController in
            (viewController as? IdentifableScreen)?.uuid == to
        }) else {
            return
        }

        _ = navigationController.popToViewController(match, animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        _ = navigationController.popToRootViewController(animated: animated)
    }
    
    func dismiss(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }
    
    func dismissPresented(animated: Bool = true) {
        UIApplication.rootViewController?.presentedViewController?.dismiss(animated: animated)
    }
}
