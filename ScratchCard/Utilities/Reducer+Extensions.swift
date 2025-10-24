//
//  Reducer+Extensions.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import ComposableArchitecture
import Foundation

extension Reducer {

    /// Wraps the reducer with automatic action logging
    /// Logs every action that flows through the reducer to help with debugging
    ///
    /// So called higher order reducer, can actually observe child reducer actions being fired.

    func withLogger() -> some Reducer<State, Action> {
        LoggingReducer(base: self)
    }
}

private struct LoggingReducer<Base: Reducer>: Reducer {
    @Dependency(\.logger) var logger

    let base: Base

    func reduce(into state: inout Base.State, action: Base.Action) -> Effect<Base.Action> {
        let actionString = "\(action)".replacingOccurrences(of: "ComposableArchitecture.", with: "")
        logger.log("\(Base.self): \(actionString)")
        return base.reduce(into: &state, action: action)
    }
}
