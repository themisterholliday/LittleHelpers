//
//  Navigator.swift
//  test
//
//  Created by Craig Holliday on 9/9/19.
//  Copyright © 2019 craig.holliday. All rights reserved.
//

import UIKit

// https://www.swiftbysundell.com/articles/navigation-in-swift/
public protocol Navigator {
    associatedtype Destination

    func navigate(to destination: Destination)
}

// MARK: - Example Navigator

private struct User {}

private class LoginNavigator: Navigator {
    enum Destination {
        case loginCompleted(user: User)
        case forgotPassword
        case signup
    }

    private weak var navigationController: UINavigationController?
    private let viewControllerFactory: LoginViewControllerFactory

    init(navigationController: UINavigationController, viewControllerFactory: LoginViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }

    func navigate(to destination: Destination) {
        let viewController = makeViewController(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeViewController(for destination: Destination) -> UIViewController {
        switch destination {
        case .loginCompleted(let user):
            return viewControllerFactory.makeWelcomeViewController(forUser: user)
        case .forgotPassword:
            return viewControllerFactory.makePasswordResetViewController()
        case .signup:
            return viewControllerFactory.makeSignUpViewController()
        }
    }
}

private protocol LoginViewControllerFactory {
    func makeWelcomeViewController(forUser: User) -> UIViewController
    func makeSignUpViewController() -> UIViewController
    func makePasswordResetViewController() -> UIViewController
}
