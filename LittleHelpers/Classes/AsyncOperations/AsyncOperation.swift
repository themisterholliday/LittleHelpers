//
//  AsyncOperation.swift
//  Bonjoro
//
//  Created by Keith Holliday on 7/24/19.
//  Copyright © 2019 Verbate. All rights reserved.
//

import Foundation

open class AsynchronousOperation: Operation {
    public enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }

    override open var isAsynchronous: Bool {
        return true
    }

    override open var isExecuting: Bool {
        return state == .executing
    }

    override open var isFinished: Bool {
        return state == .finished
    }

    public var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    public var debugMode: Bool = false

    // Seperate OperationQueue for AsyncProcess
    public lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .background
        return operationQueue
    }()

    override open func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            self.main()
        }
    }

    override open func main() {
        if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function started") }
        if self.isCancelled {
            if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function Cancelled") }
            state = .finished
        } else {
            if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function Executing") }
            state = .executing
        }
        if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function Ended") }
    }

    override open func cancel() {
        super.cancel()
        operationQueue.cancelAllOperations()
    }

    func checkIsCancelled() {
        if self.isCancelled {
            state = .finished
        }
    }
}

// MARK: - AsyncOperationExample
fileprivate class AsyncOperationExample: AsynchronousOperation {
    override public func main() {
        super.main()
        if self.debugMode { print("AsyncOperationExample \(self.name ?? "") - Called async inside operation") }

        // Here write the async operation
        operationQueue.addOperation {
            // Making delay
            sleep(5)
            if self.debugMode { print("AsyncOperationExample \(self.name ?? "") - async response came") }
            // Set the state to .finished once your operation completed
            self.state = .finished
        }
    }
}

fileprivate class AsyncOperationQueueExample {
    private lazy var asyncOperationQueue: CompletionOperationQueue = {
        let asyncOperationQueue = CompletionOperationQueue { [weak self] in
            self?.completedQueue()
        }
        asyncOperationQueue.maxConcurrentOperationCount = 3
        return asyncOperationQueue
    }()

    init() {
        print("AsyncOperationExample Before Total operations: \(asyncOperationQueue.operationCount)")

        var previousOperation: AsyncOperationExample?
        for index in 1...10 {
            let operation = AsyncOperationExample()
            operation.name = "--\(index)--"
            if let previous = previousOperation {
                operation.addDependency(previous)
            }
            asyncOperationQueue.addOperation(operation)

            previousOperation = operation
        }


        print("AsyncOperationExample After Total operations: \(asyncOperationQueue.operationCount)")
        print("AsyncOperationExample After waiting for operations: \(asyncOperationQueue.operationCount)")
    }

    private func completedQueue() {
        print("Completed operation queue")
    }
}
