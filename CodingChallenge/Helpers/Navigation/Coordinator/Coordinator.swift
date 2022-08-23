//
//  Coordinator.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 22/08/2022.
//

import Foundation

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
    /// Searches parent coordinators stack to find mainCoordinator
    var mainCoordinator: Coordinator? {
        parentCoordinator?.parentCoordinator ?? parentCoordinator ?? self
    }

    func coordinateToParent() {
        parentCoordinator?.childDidFinish(self)
    }

    /**
      Call while child flow is finishing, example user finishes profiling and is moved to home.
      Removes child from the stack, and passes navigation delegation to self if self conforms to `UINavigationControllerDelegate`
      - Parameter child: Coordinator to be removed
     */
    func childDidFinish(_ child: Coordinator?) {
        childCoordinators.removeAll(where: {
            $0 === child
        })
    }

    /// Removes all coordinators from the stack, which might result in self becoming delegate of
    /// `UINavigationControllerDelegate` if conforms to
    func removeAllChildren() {
        childCoordinators.forEach {
            $0.removeAllChildren()
        }
        childCoordinators = []
    }

    /// Call while adding child flow, example user goes from settings to off-boarding which has it's own coordinator
    /// adds child to the stack
    /// - Parameter coordinator: child coordinator to be added
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
