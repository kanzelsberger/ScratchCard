//
//  MainFeature.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import ComposableArchitecture
import Foundation

@Reducer struct MainFeature {

    @ObservableState struct State: Equatable {
        var scratchCardState: ScratchCardState = .unscratched
        @Presents var scratch: ScratchFeature.State?
        @Presents var activation: ActivationFeature.State?
    }

    @CasePathable enum Action {
        case scratchButtonTapped
        case activationButtonTapped
        case scratch(PresentationAction<ScratchFeature.Action>)
        case activation(PresentationAction<ActivationFeature.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .scratchButtonTapped:
                state.scratch = ScratchFeature.State(
                    currentCardState: state.scratchCardState
                )

            case .activationButtonTapped:
                guard case .scratched(let code) = state.scratchCardState else {
                    break
                }
                state.activation = ActivationFeature.State(code: code)

            case .scratch(.presented(.delegate(.cardScratched(let code)))):
                state.scratchCardState = .scratched(code: code)
                state.scratch = nil

            case .scratch:
                break

            case .activation(.presented(.delegate(.cardActivated(let code)))):
                state.scratchCardState = .activated(code: code)
                state.activation = nil

            case .activation:
                break
            }

            return .none
        }
        .ifLet(\.$scratch, action: \.scratch) {
            ScratchFeature()
        }
        .ifLet(\.$activation, action: \.activation) {
            ActivationFeature()
        }
    }
}
