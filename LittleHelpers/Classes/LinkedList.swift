//
//  LinkedList.swift
//  test
//
//  Created by Craig Holliday on 9/7/19.
//  Copyright © 2019 craig.holliday. All rights reserved.
//

import Foundation

// https://www.swiftbysundell.com/articles/picking-the-right-data-structure-in-swift/
public struct LinkedList<Value> {
    private(set) var firstNode: Node?
    private(set) var lastNode: Node?

    public init() {}
}

public extension LinkedList {
    class Node {
        public var value: Value
        fileprivate(set) weak var previous: Node?
        fileprivate(set) var next: Node?

        public init(value: Value) {
            self.value = value
        }
    }
}

extension LinkedList: Sequence {
    public func makeIterator() -> AnyIterator<Value> {
        var node = firstNode

        return AnyIterator {
            // Iterate through all of our nodes by continuously
            // moving to the next one and extract its value:
            let value = node?.value
            node = node?.next
            return value
        }
    }
}

public extension LinkedList {
    @discardableResult
    mutating func append(_ value: Value) -> Node {
        let node = Node(value: value)
        node.previous = lastNode

        lastNode?.next = node
        lastNode = node

        if firstNode == nil {
            firstNode = node
        }

        return node
    }

    mutating func remove(_ node: Node) {
        node.previous?.next = node.next
        node.next?.previous = node.previous

        // Using "triple-equals" we can compare two class
        // instances by identity, rather than by value:
        if firstNode === node {
            firstNode = node.next
        }

        if lastNode === node {
            lastNode = node.previous
        }
    }
}
