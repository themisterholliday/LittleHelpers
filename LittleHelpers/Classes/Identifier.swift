//
//  Identifier.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 10/1/19.
//

import Foundation

// https://swiftbysundell.com/articles/type-safe-identifiers-in-swift/
protocol Identifiable {
    associatedtype RawIdentifier: Codable = String

    var id: Identifier<Self> { get }
}

struct Identifier<Value: Identifiable> {
    let rawValue: Value.RawIdentifier

    init(rawValue: Value.RawIdentifier) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByStringLiteral conformance
extension Identifier: ExpressibleByStringLiteral where Value.RawIdentifier == String {
    typealias StringLiteralType = String

    init(stringLiteral value: Self.StringLiteralType) {
        rawValue = value
    }
}

extension Identifier: ExpressibleByUnicodeScalarLiteral where Value.RawIdentifier == String {
    typealias UnicodeScalarLiteralType = String
}

extension Identifier: ExpressibleByExtendedGraphemeClusterLiteral where Value.RawIdentifier == String {
    typealias ExtendedGraphemeClusterLiteralType = String
}

// MARK: - ExpressibleByIntegerLiteral Conformance
extension Identifier: ExpressibleByIntegerLiteral where Value.RawIdentifier == Int {
    typealias IntegerLiteralType = Int

    init(integerLiteral value: Self.IntegerLiteralType) {
        rawValue = value
    }
}

// MARK: - CustomStringConvertible
extension Identifier: CustomStringConvertible {
    var description: String {
        return String(describing: rawValue)
    }
}

// MARK: Codable
extension Identifier: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(Value.RawIdentifier.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}


// MARK: - Example

// Identifiable with String id (Default)
private struct User: Identifiable {
    let id: Identifier<User>
    let name: String
}

// Identifiable with Int id
private struct Group: Identifiable {
    typealias RawIdentifier = Int

    let id: Identifier<Group>
    let name: String
}

internal protocol Database {
    associatedtype T: Identifiable

    func record(withID id: Identifier<T>) -> T?
}

internal protocol ModelLoader {
    associatedtype T: Identifiable

    typealias Handler<T> = (Result<T, Error>) -> Void

    func loadModel(withID id: Identifier<T>, then handler: @escaping Handler<T>)
}

enum ModelLoaderError<T: Identifiable>: Error {
    case couldNotFindModelWithID(id: Identifier<T>)
}

extension ModelLoaderError: LocalizedError {
    var errorDescription: String? {
        let className = String(describing: T.self)
        
        switch self {
        case .couldNotFindModelWithID(let id):
            return NSLocalizedString(
                "Coulde not find \(className) model with id: \(id)",
                comment: ""
            )
        }
    }
}
