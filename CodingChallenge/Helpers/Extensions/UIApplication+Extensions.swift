//
//  UIApplication+Extensions.swift
//  CodingChallenge
//
//  Created by Ernest Chechelski on 23/08/2022.
//

import UIKit

// TODO: - Missing docs.
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
}
