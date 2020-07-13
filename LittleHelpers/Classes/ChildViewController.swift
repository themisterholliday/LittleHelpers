//
//  ChildViewController.swift
//  test
//
//  Created by Craig Holliday on 9/9/19.
//  Copyright © 2019 craig.holliday. All rights reserved.
//

import UIKit

// https://www.swiftbysundell.com/basics/child-view-controllers/
public extension UIViewController {
    func addChildViewController(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    func embed(vc: UIViewController, in containerView: UIView) {
        addChild(vc)
        containerView.addSubview(vc.view)
        didMove(toParent: self)

        vc.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
}
