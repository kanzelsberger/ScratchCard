//
//  AlertState+Extensions.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import ComposableArchitecture

// extension AlertState {
//     /// Creates a simple alert with title, message, and a single OK button
//     /// - Parameters:
//     ///   - title: The alert title
//     ///   - message: The alert message
//     ///   - buttonTitle: The button text (default: "OK")
//     ///   - action: The action to send when button is tapped
//     /// - Returns: Configured AlertState
//     static func simple(
//         title: String,
//         message: String,
//         buttonTitle: String = "OK",
//         action: Action
//     ) -> AlertState {
//         AlertState {
//             TextState(title)
//         } actions: {
//             ButtonState(action: action) {
//                 TextState(buttonTitle)
//             }
//         } message: {
//             TextState(message)
//         }
//     }
// }
