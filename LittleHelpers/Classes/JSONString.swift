//
//  JSONString.swift
//  LittleHelpers
//
//  Created by Craig Holliday on 7/13/20.
//

import Foundation

public extension Data {
    func toPrettyPrintedJSONString() throws -> String {
        let object = try JSONSerialization.jsonObject(with: self, options: [])
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed])
        guard let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            throw NSError(domain: "", code: -1, userInfo: nil)
        }

        return prettyPrintedString as String
    }
}

public extension Encodable {
    func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        return try data.toPrettyPrintedJSONString()
    }
}
