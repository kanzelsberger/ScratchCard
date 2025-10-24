//
//  Logger.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import Foundation
import ComposableArchitecture

@DependencyClient struct Logger: Sendable {
    var log: @Sendable (_ message: String) -> Void
}

extension Logger: DependencyKey {
    static let liveValue = Logger(
        log: { message in
            print("[\(Date().ISO8601Format())] \(message)")
        }
    )

    static let testValue: Logger = .liveValue
}

extension DependencyValues {
    var logger: Logger {
        get { self[Logger.self] }
        set { self[Logger.self] = newValue }
    }
}
