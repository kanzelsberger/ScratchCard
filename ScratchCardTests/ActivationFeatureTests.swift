import Testing
import Foundation
import ComposableArchitecture
@testable import ScratchCard

@MainActor
struct ActivationFeatureTests {
    @Test
    func successfulActivationWithValidVersion() async {
        let store = TestStore(
            initialState: ActivationFeature.State(code: "test-code")
        ) {
            ActivationFeature()
        } withDependencies: {
            $0.apiClient.request = { _ in
                let encoder = JSONEncoder()
                return try encoder.encode(VersionResponse(ios: "6.24"))
            }
        }

        await store.send(.activateButtonTapped) {
            $0.isActivating = true
        }

        await store.receive(\.activationResponse.success) {
            $0.isActivating = false
        }

        await store.receive(\.delegate.cardActivated)
    }

    @Test
    func failedActivationWithInvalidVersion() async {
        let store = TestStore(
            initialState: ActivationFeature.State(code: "test-code")
        ) {
            ActivationFeature()
        } withDependencies: {
            $0.apiClient.request = { _ in
                let encoder = JSONEncoder()
                return try encoder.encode(VersionResponse(ios: "6.0"))
            }
        }

        await store.send(.activateButtonTapped) {
            $0.isActivating = true
        }

        await store.receive(\.activationResponse.success) {
            $0.isActivating = false
            $0.alert = AlertState {
                TextState("Activation Failed")
            } actions: {
                ButtonState(action: .okTapped) {
                    TextState("OK")
                }
            } message: {
                TextState("The version (6.0) is not valid. Required version must be greater than 6.1")
            }
        }

        await store.finish()
    }

    @Test
    func activationWithAPIError() async {
        let store = TestStore(
            initialState: ActivationFeature.State(code: "test-code")
        ) {
            ActivationFeature()
        } withDependencies: {
            $0.apiClient.request = { _ in
                throw APIError.httpError(statusCode: 500)
            }
        }

        await store.send(.activateButtonTapped) {
            $0.isActivating = true
        }

        await store.receive(\.activationResponse.failure) {
            $0.isActivating = false
            $0.alert = AlertState {
                TextState("Error")
            } actions: {
                ButtonState(action: .okTapped) {
                    TextState("OK")
                }
            } message: {
                TextState("HTTP error with status code: 500")
            }
        }
    }

    @Test
    func cannotActivateWhileActivating() async {
        let store = TestStore(
            initialState: ActivationFeature.State(code: "test-code", isActivating: true)
        ) {
            ActivationFeature()
        }

        await store.send(.activateButtonTapped)
    }
}
