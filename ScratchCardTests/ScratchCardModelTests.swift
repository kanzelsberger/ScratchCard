import Testing
@testable import ScratchCard

struct ScratchCardModelTests {
    @Test
    func scratchCardStateProperties() {
        let unscratched = ScratchCardState.unscratched
        #expect(unscratched.isUnscratched)
        #expect(!unscratched.isScratched)
        #expect(!unscratched.isActivated)
        #expect(unscratched.code == nil)

        let scratched = ScratchCardState.scratched(code: "ABC123")
        #expect(!scratched.isUnscratched)
        #expect(scratched.isScratched)
        #expect(!scratched.isActivated)
        #expect(scratched.code == "ABC123")

        let activated = ScratchCardState.activated(code: "XYZ789")
        #expect(!activated.isUnscratched)
        #expect(!activated.isScratched)
        #expect(activated.isActivated)
        #expect(activated.code == "XYZ789")
    }

    @Test
    func scratchCardDisplayText() {
        #expect(ScratchCardState.unscratched.displayText == "Unscratched")
        #expect(ScratchCardState.scratched(code: "ABC").displayText == "Scratched - Code: ABC")
        #expect(ScratchCardState.activated(code: "XYZ").displayText == "Activated - Code: XYZ")
    }

    @Test
    func versionResponseValidation() {
        let validVersion = VersionResponse(ios: "6.24")
        #expect(validVersion.isVersionValid())
        #expect(validVersion.version == 6.24)

        let invalidVersion = VersionResponse(ios: "6.0")
        #expect(!invalidVersion.isVersionValid())

        let exactlyInvalid = VersionResponse(ios: "6.1")
        #expect(!exactlyInvalid.isVersionValid())

        let invalidFormat = VersionResponse(ios: "invalid")
        #expect(!invalidFormat.isVersionValid())
        #expect(invalidFormat.version == nil)
    }

    @Test
    func versionResponseCustomMinimum() {
        let response = VersionResponse(ios: "5.0")
        #expect(!response.isVersionValid(minimumVersion: 6.1))
        #expect(response.isVersionValid(minimumVersion: 4.0))
    }
}
