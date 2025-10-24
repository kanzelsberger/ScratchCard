//
//  ActivationFeature.swift
//  ScratchCard
//
//  Created by Pavel Kanzelsberger on 10/23/25.
//

import ComposableArchitecture
import Foundation

@Reducer struct ActivationFeature {

    @ObservableState struct State: Equatable {
        let code: String
        var isActivating: Bool = false
        @Presents var alert: AlertState<Action.Alert>?
    }

    @CasePathable enum Action {
        case activateButtonTapped
        case activationResponse(Result<VersionResponse, Error>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable enum Alert {
            case okTapped
        }

        @CasePathable enum Delegate {
            case cardActivated(code: String)
        }
    }

    @Dependency(\.apiClient) var api

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .activateButtonTapped:
                guard !state.isActivating else {
                    return .none
                }

                state.isActivating = true

                return .run { [code = state.code] send in
                    // This operation should NOT be cancelled when screen is dismissed
                    let response: VersionResponse = try await api.request(.version(code: code))
                    await send(.activationResponse(.success(response)))
                } catch: { error, send in
                    await send(.activationResponse(.failure(error)))
                }
                // Note: No .cancellable() - operation continues even after screen dismissal

            case .activationResponse(.success(let response)):
                state.isActivating = false

                if response.isVersionValid() {
                    // Version > 6.1, activate the card
                    return .send(.delegate(.cardActivated(code: state.code)))
                } else {
                    // Version <= 6.1, show error
                    state.alert = AlertState {
                        TextState("Activation Failed")
                    } actions: {
                        ButtonState(action: .okTapped) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("The version (\(response.ios)) is not valid. Required version must be greater than 6.1")
                    }
                }

            case .activationResponse(.failure(let error)):
                state.isActivating = false
                state.alert = AlertState {
                    TextState("Error")
                } actions: {
                    ButtonState(action: .okTapped) {
                        TextState("OK")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }

            case .alert:
                break

            case .delegate:
                break
            }

            return .none
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
