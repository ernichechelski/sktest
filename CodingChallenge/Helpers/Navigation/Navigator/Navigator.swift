//
//  Navigator.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 21/08/2022.
//

import UIKit
import SwiftUI

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

extension UIApplication {
    static var currentKeyWindow: UIWindow? {
        UIApplication.shared.currentKeyWindow
    }

    static var rootViewController: UIViewController? {
        UIApplication.shared.rootViewController
    }

    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }

    var currentKeyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }

    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


extension View {
    
    /// Converts the instance of Self view to `AnyView`
    func asAnyView() -> AnyView {
        AnyView(self)
    }
    
    func hosted(uuid: UUID = UUID()) -> UIViewController {
        UUIDHostingViewController(view: self, uuid: uuid)
    }
}

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

protocol IdentifableScreen  {
    var uuid: UUID { get }

    var contents: AnyView { get }
}


final class UUIDHostingViewController<T: View>: UIHostingController<T>, IdentifableScreen  {
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

struct NavigatorWrapper: View {

    var builder: () -> [AnyView]

    var body: some View {
        NavigatorStrongContainer(
            navigator: Navigator(builder: builder)
        )
    }
}

struct NavigatorStrongContainer: UIViewRepresentable {

    @StateObject var navigator: Navigator

    func makeUIView(context: Context) -> UIView {
        navigator.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct NavigatorContainer: UIViewRepresentable {

    @EnvironmentObject var navigator: Navigator

    func makeUIView(context: Context) -> UIView {
        navigator.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
