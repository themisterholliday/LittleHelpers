//
//  CompletionOperationQueue.swift
//  Bonjoro
//
//  Created by Keith Holliday on 7/24/19.
//  Copyright © 2019 Verbate. All rights reserved.
//

import Foundation

public class CompletionOperationQueue: OperationQueue {
    public var completionBlock: (() -> Void)?

    public init(completionBlock: (() -> Void)? = nil) {
        self.completionBlock = completionBlock
        super.init()
        addObserver(self, forKeyPath: "operationCount", options: NSKeyValueObservingOptions.new, context: .none)
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "operationCount", operationCount == 0 {
            completionBlock?()
        }
    }
}
