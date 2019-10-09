//
//  Identifier.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 10/1/19.
//

import Foundation

// https://swiftbysundell.com/articles/type-safe-identifiers-in-swift/
public protocol Identifiable {
    associatedtype RawIdentifier: Codable & Hashable = String

    var id: Identifier<Self> { get }
}

public struct Identifier<Value: Identifiable> {
    public let rawValue: Value.RawIdentifier

    public init(rawValue: Value.RawIdentifier) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByStringLiteral conformance
extension Identifier: ExpressibleByStringLiteral where Value.RawIdentifier == String {
    public typealias StringLiteralType = String

    public init(stringLiteral value: Self.StringLiteralType) {
        rawValue = value
    }
}

extension Identifier: ExpressibleByUnicodeScalarLiteral where Value.RawIdentifier == String {
    public typealias UnicodeScalarLiteralType = String
}

extension Identifier: ExpressibleByExtendedGraphemeClusterLiteral where Value.RawIdentifier == String {
    public typealias ExtendedGraphemeClusterLiteralType = String
}

// MARK: - ExpressibleByIntegerLiteral Conformance
extension Identifier: ExpressibleByIntegerLiteral where Value.RawIdentifier == Int {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: Self.IntegerLiteralType) {
        rawValue = value
    }
}

// MARK: - CustomStringConvertible
extension Identifier: CustomStringConvertible {
    public var description: String {
        return String(describing: rawValue)
    }
}

// MARK: Codable
extension Identifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(Value.RawIdentifier.self)
    }

    public func encode(to encoder: Encoder) throws {
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

public protocol ModelLoader {
    associatedtype T: Identifiable

    var cache: Cache<T.RawIdentifier, T> { get }

    func loadModel(withID id: Identifier<T>) throws -> T
    func saveModel(withID id: Identifier<T>) throws
}

public enum IdentifiableModelError<T: Identifiable>: Error {
    case couldNotFindModelWithID(id: Identifier<T>)
}

extension IdentifiableModelError: LocalizedError {
    public var errorDescription: String? {
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
