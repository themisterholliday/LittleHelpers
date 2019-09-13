//
//  ObservationToken.swift
//  test
//
//  Created by Craig Holliday on 9/7/19.
//  Copyright © 2019 craig.holliday. All rights reserved.
//

import Foundation

// https://www.swiftbysundell.com/posts/observers-in-swift-part-2
public class ObservationToken {
    private let cancellationClosure: () -> Void

    init(cancellationClosure: @escaping () -> Void) {
        self.cancellationClosure = cancellationClosure
    }

    func cancel() {
        cancellationClosure()
    }
}

private extension Dictionary where Key == UUID {
    mutating func insert(_ value: Value) -> UUID {
        let id = UUID()
        self[id] = value
        return id
    }
}
