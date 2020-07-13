//
//  Validator.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 9/19/19.
//

// https://www.swiftbysundell.com/articles/using-errors-as-control-flow-in-swift/
internal struct Validator<Value> {
    let closure: (Value) throws -> Void
}

internal struct ValidationError: LocalizedError {
    let message: String
    var errorDescription: String? { return message }
}

internal func validate(_ condition: @autoclosure () -> Bool, errorMessage messageExpression: @autoclosure () -> String) throws {
    guard condition() else {
        let message = messageExpression()
        throw ValidationError(message: message)
    }
}

func validate<T>(_ value: T,
                 using validator: Validator<T>) throws {
    try validator.closure(value)
}

// Example
private extension Validator where Value == String {
    static var password: Validator {
        return Validator { string in
            try validate(
                string.count >= 7,
                errorMessage: "Password must contain min 7 characters"
            )

            try validate(
                string.lowercased() != string,
                errorMessage: "Password must contain an uppercased character"
            )

            try validate(
                string.uppercased() != string,
                errorMessage: "Password must contain a lowercased character"
            )
        }
    }
}
