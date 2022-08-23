//
//  Coordinator.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Foundation

// TODO: - Missing comments.
protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigator: Navigator { get set }

    func begin()
    func addChild(_ coordinator: Coordinator)
    func childDidFinish(_ child: Coordinator?)
    func removeAllChildren()

    func handle(error: Error)
}

extension Coordinator {
    var mainCoordinator: Coordinator? {
        parentCoordinator?.parentCoordinator ?? parentCoordinator ?? self
    }

    func coordinateToParent() {
        parentCoordinator?.childDidFinish(self)
    }

    func childDidFinish(_ child: Coordinator?) {
        childCoordinators.removeAll(where: {
            $0 === child
        })
    }

    func removeAllChildren() {
        childCoordinators.forEach {
            $0.removeAllChildren()
        }
        childCoordinators = []
    }

    func addChild(_ coordinator: Coordinator) {
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }

    func beginChild(coordinator: Coordinator) {
        addChild(coordinator)
        coordinator.begin()
    }

    func beginChild(_ coordinator: () throws -> Coordinator) {
        do {
            beginChild(coordinator: try coordinator())
        } catch {
            handle(error: error)
        }
    }

    func handle(error: Error) {
        if let parent = parentCoordinator {
            parent.handle(error: error)
        } else {
            assertionFailure(error.localizedDescription)
        }
    }
}
