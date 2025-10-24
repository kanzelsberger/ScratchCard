//
//  Optional+Extensions.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import Foundation

extension Optional {

    /// Unwraps the optional value or throws an error
    /// Usage: let value = try optional.unwrapped()
    func unwrapped(or error: @autoclosure () -> Error = UnwrappingError.valueIsNil) throws -> Wrapped {
        guard let value = self else {
            throw error()
        }
        return value
    }

    /// Unwraps the optional value or throws a custom error with message
    func unwrapped(or message: @autoclosure () -> String) throws -> Wrapped {
        guard let value = self else {
            throw UnwrappingError.custom(message())
        }
        return value
    }
}

enum UnwrappingError: LocalizedError {
    case valueIsNil
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .valueIsNil:
            return "Required value was nil"
        case .custom(let message):
            return message
        }
    }
}
