//
//  EventDispatcher.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 7/19/20.
//

import Foundation

/// Vanilla implementation of an Observable.
public class EventDispatcher<T: Equatable> {
    typealias CompletionHandler = ((T) -> Void)

    /// Current value and the value to update
    public var value: T {
        didSet {
            let newValue = value
            let isValueDistinct = oldValue != newValue

            observers.values.forEach { isDistinct, completionHandler in
                if isDistinct, isValueDistinct == false {
                    return
                }
                completionHandler(newValue)
            }
        }
    }

    /// Current observers listening to this dispatcher
    private var observers: [UUID: (distinct: Bool, completionHandler: CompletionHandler)] = [:]

    /// Init
    /// - Parameter value: Initial value for this disptachers
    public init(value: T) {
        self.value = value
    }

    /// Function to observe changes for a specific property.
    /// - Parameters:
    ///   - observer: The class observing changes.
    ///   - distinct: Distinct until changed
    ///   - queue: Dispatch queue the closure will callback on.
    ///   - closure: The callback which will contain (The based in observer, The update value that is being observed)
    public func observe<O: AnyObject>(_ observer: O,
                                      distinct: Bool = false,
                                      skip: Int = 0,
                                      onQueue queue: DispatchQueue = .main,
                                      closure: @escaping (O, T) -> Void) {
        let initialValue = value
        let uuid = UUID()
        
        var skipsLeft = skip

        let completionHandler: CompletionHandler = { [weak self, weak observer] newValue in
            guard let observer = observer else {
                self?.observers.removeValue(forKey: uuid)
                return
            }

            if skipsLeft > 0 {
                skipsLeft -= 1
                return
            }
            queue.async {
                closure(observer, newValue)
            }
        }

        observers[uuid] = (distinct, completionHandler)

        if skipsLeft == 0 {
            queue.async {
                closure(observer, initialValue)
            }
        }
        skipsLeft -= 1
    }
}

// MARK: - Example

/**
 let disptach = EventDispatcher(value: "String")
 disptach.observe(self, distinct: true) { (self, value) in
     print("$$$ ---- \(value) ----")
     print("$$$ –––––")
 }
 disptach.value = "String"
 disptach.value = "Hello"
 disptach.value = "Hello"
 */
