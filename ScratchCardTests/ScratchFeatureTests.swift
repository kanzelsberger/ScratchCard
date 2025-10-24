import Testing
import Foundation
import ComposableArchitecture
@testable import ScratchCard

@MainActor
struct ScratchFeatureTests {
    @Test
    func scratchingCard() async {
        let clock = TestClock()
        let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        let store = TestStore(
            initialState: ScratchFeature.State(currentCardState: .unscratched)
        ) {
            ScratchFeature()
        } withDependencies: {
            $0.uuid = .constant(testUUID)
            $0.continuousClock = clock
        }

        await store.send(.scratchButtonTapped) {
            $0.isScratching = true
        }

        await clock.advance(by: .seconds(2))

        await store.receive(\.scratchingCompleted) {
            $0.isScratching = false
            $0.revealedCode = testUUID.uuidString
        }

        await store.receive(\.delegate.cardScratched)
    }

    @Test
    func scratchingStateWhileInProgress() async {
        let clock = TestClock()
        let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        let store = TestStore(
            initialState: ScratchFeature.State(currentCardState: .unscratched)
        ) {
            ScratchFeature()
        } withDependencies: {
            $0.uuid = .constant(testUUID)
            $0.continuousClock = clock
        }

        await store.send(.scratchButtonTapped) {
            $0.isScratching = true
        }

        // Verify state is in scratching mode with no code revealed yet
        #expect(store.state.isScratching == true)
        #expect(store.state.revealedCode == nil)

        // Clean up: advance clock to complete the effect and receive all actions
        await clock.advance(by: .seconds(2))

        await store.receive(\.scratchingCompleted) {
            $0.isScratching = false
            $0.revealedCode = testUUID.uuidString
        }

        await store.receive(\.delegate.cardScratched)
    }

    @Test
    func cannotScratchAlreadyScratchedCard() async {
        let store = TestStore(
            initialState: ScratchFeature.State(
                currentCardState: .scratched(code: "existing-code")
            )
        ) {
            ScratchFeature()
        }

        #expect(!store.state.canScratch)
    }

    @Test
    func cannotScratchWhileScratching() async {
        let clock = TestClock()
        let testUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

        let store = TestStore(
            initialState: ScratchFeature.State(currentCardState: .unscratched)
        ) {
            ScratchFeature()
        } withDependencies: {
            $0.uuid = .constant(testUUID)
            $0.continuousClock = clock
        }

        await store.send(.scratchButtonTapped) {
            $0.isScratching = true
        }

        #expect(!store.state.canScratch)

        await clock.advance(by: .seconds(2))
        await store.skipReceivedActions()
        await store.finish()
    }
}
