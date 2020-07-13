//
//  ObservableManagerProtocol.swift
//  test
//
//  Created by Craig Holliday on 9/7/19.
//  Copyright © 2019 craig.holliday. All rights reserved.
//

import Foundation

public protocol MangersObservableObject {
    var id: String { get }
}

public protocol ObservableManager: class {
    associatedtype Object: MangersObservableObject

    var observations: (
        all: [UUID: ([Object]) -> Void],
        single: [UUID: (String, (Object) -> Void)]
    ) { get set }

    func getObject(for id: String) -> Object?
    func getAllObjects() -> [Object]

    func handleNotifySingleObservations(for id: String)
}

public extension ObservableManager {
    @discardableResult func observeAllObjects<T: AnyObject>(_ observer: T, closure: @escaping (T, [Object]) -> Void) -> ObservationToken {
        let uuid = UUID()

        observations.all[uuid] = { [weak self, weak observer] object in
            guard let observer = observer else {
                self?.observations.all.removeValue(forKey: uuid)
                return
            }

            closure(observer, object)
        }

        observations.all[uuid]?(getAllObjects())

        return ObservationToken { [weak self] in
            self?.observations.all.removeValue(forKey: uuid)
        }
    }

    @discardableResult func observeSingleObject<T: AnyObject>(for id: String, _ observer: T, closure: @escaping (T, Object) -> Void) -> ObservationToken {
        let uuid = UUID()

        observations.single[uuid] = (id, { [weak self, weak observer] object in
            guard let observer = observer else {
                self?.observations.single.removeValue(forKey: uuid)
                return
            }

            closure(observer, object)
        })

        if let object = getObject(for: id) {
            observations.single[uuid]?.1(object)
        }

        return ObservationToken { [weak self] in
            self?.observations.single.removeValue(forKey: uuid)
        }
    }
}
