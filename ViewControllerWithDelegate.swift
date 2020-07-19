//
//  ViewControllerWithDelegate.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 7/19/20.
//

import Foundation

public protocol ViewControllerDelegateProtocol {
    associatedtype Delegate: Any
    var delegate: Delegate? { get set }
}

public typealias ViewControllerWithDelegate = UIViewController & ViewControllerDelegateProtocol
