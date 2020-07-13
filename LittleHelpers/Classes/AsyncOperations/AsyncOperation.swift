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

    public override var isAsynchronous: Bool {
        return true
    }

    public override var isExecuting: Bool {
        return self.state == .executing
    }

    public override var isFinished: Bool {
        return self.state == .finished
    }

    public var state = State.ready {
        willSet {
            willChangeValue(forKey: self.state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: self.state.keyPath)
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

    public override func start() {
        if self.isCancelled {
            self.state = .finished
        } else {
            self.state = .ready
            self.main()
        }
    }

    open override func main() {
        if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function started") }
        if self.isCancelled {
            if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function Cancelled") }
            self.state = .finished
        } else {
            if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function Executing") }
            self.state = .executing
        }
        if self.debugMode { print("AsyncOperation \(self.name ?? "") -  Main function Ended") }
    }

    public override func cancel() {
        super.cancel()
        self.operationQueue.cancelAllOperations()
    }

    func checkIsCancelled() {
        if self.isCancelled {
            self.state = .finished
        }
    }
}

// MARK: - AsyncOperationExample

private class AsyncOperationExample: AsynchronousOperation {
    public override func main() {
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

private class AsyncOperationQueueExample {
    private lazy var asyncOperationQueue: CompletionOperationQueue = {
        let asyncOperationQueue = CompletionOperationQueue { [weak self] in
            self?.completedQueue()
        }
        asyncOperationQueue.maxConcurrentOperationCount = 3
        return asyncOperationQueue
    }()

    init() {
        print("AsyncOperationExample Before Total operations: \(self.asyncOperationQueue.operationCount)")

        var previousOperation: AsyncOperationExample?
        for index in 1...10 {
            let operation = AsyncOperationExample()
            operation.name = "--\(index)--"
            if let previous = previousOperation {
                operation.addDependency(previous)
            }
            self.asyncOperationQueue.addOperation(operation)

            previousOperation = operation
        }

        print("AsyncOperationExample After Total operations: \(self.asyncOperationQueue.operationCount)")
        print("AsyncOperationExample After waiting for operations: \(self.asyncOperationQueue.operationCount)")
    }

    private func completedQueue() {
        print("Completed operation queue")
    }
}
