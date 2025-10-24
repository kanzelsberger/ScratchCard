//
//  ScratchFeature.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import ComposableArchitecture
import Foundation

nonisolated(unsafe) enum ScratchCancelID: Hashable, Sendable {
    case scratching
}

struct ScratchFeature: Reducer {
    @ObservableState struct State: Equatable {
        let currentCardState: ScratchCardState
        var isScratching: Bool = false
        var revealedCode: String?

        var canScratch: Bool {
            if case .unscratched = currentCardState {
                return !isScratching
            }
            return false
        }
    }

    @CasePathable enum Action {
        case scratchButtonTapped
        case scratchingCompleted(String)
        case delegate(Delegate)

        @CasePathable enum Delegate {
            case cardScratched(code: String)
        }
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.continuousClock) var clock

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .scratchButtonTapped:
                guard case .unscratched = state.currentCardState, !state.isScratching else {
                    return .none
                }

                state.isScratching = true
                let code = uuid().uuidString

                return .run { send in
                    // Simulate heavy operation (2 seconds)
                    try await clock.sleep(for: .seconds(2))
                    await send(.scratchingCompleted(code))
                }
                .cancellable(id: ScratchCancelID.scratching, cancelInFlight: true)

            case .scratchingCompleted(let code):
                state.isScratching = false
                state.revealedCode = code
                return .send(.delegate(.cardScratched(code: code)))

            case .delegate:
                break
            }

            return .none
        }
    }
}
