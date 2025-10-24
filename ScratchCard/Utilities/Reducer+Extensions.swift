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
        @Dependency(\.logger) var logger
        
        return Reduce { state, action in
            let actionString = "\(action)".replacingOccurrences(of: "ComposableArchitecture.", with: "")
            logger.log("\(Self.self): \(actionString)")
            return self.reduce(into: &state, action: action)
        }
    }
    
}
