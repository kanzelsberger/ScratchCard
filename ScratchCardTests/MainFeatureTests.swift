import Testing
import Foundation
import ComposableArchitecture
@testable import ScratchCard

@MainActor
struct MainFeatureTests {
    @Test
    func scratchButtonOpensSheet() async {
        let store = TestStore(
            initialState: MainFeature.State()
        ) {
            MainFeature()
        }

        await store.send(.scratchButtonTapped) {
            $0.scratch = ScratchFeature.State(currentCardState: .unscratched)
        }
    }

    @Test
    func activationButtonOpensSheetOnlyWhenScratched() async {
        let store = TestStore(
            initialState: MainFeature.State(scratchCardState: .scratched(code: "test-code"))
        ) {
            MainFeature()
        }

        await store.send(.activationButtonTapped) {
            $0.activation = ActivationFeature.State(code: "test-code")
        }
    }

    @Test
    func activationButtonDoesNothingWhenUnscratched() async {
        let store = TestStore(
            initialState: MainFeature.State(scratchCardState: .unscratched)
        ) {
            MainFeature()
        }

        await store.send(.activationButtonTapped)
    }

    @Test
    func cardStateUpdatesAfterScratching() async {
        let store = TestStore(
            initialState: MainFeature.State()
        ) {
            MainFeature()
        }

        await store.send(.scratchButtonTapped) {
            $0.scratch = ScratchFeature.State(currentCardState: .unscratched)
        }

        await store.send(.scratch(.presented(.delegate(.cardScratched(code: "new-code"))))) {
            $0.scratchCardState = .scratched(code: "new-code")
            $0.scratch = nil
        }
    }

    @Test
    func cardStateUpdatesAfterActivation() async {
        let store = TestStore(
            initialState: MainFeature.State(scratchCardState: .scratched(code: "test-code"))
        ) {
            MainFeature()
        }

        await store.send(.activationButtonTapped) {
            $0.activation = ActivationFeature.State(code: "test-code")
        }

        await store.send(.activation(.presented(.delegate(.cardActivated(code: "test-code"))))) {
            $0.scratchCardState = .activated(code: "test-code")
            $0.activation = nil
        }
    }

    @Test
    func scratchSheetDismissalHandled() async {
        let store = TestStore(
            initialState: MainFeature.State(
                scratch: ScratchFeature.State(currentCardState: .unscratched)
            )
        ) {
            MainFeature()
        }

        await store.send(.scratch(.dismiss)) {
            $0.scratch = nil
        }
    }
}
