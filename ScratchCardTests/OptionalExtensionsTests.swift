import Testing
@testable import ScratchCard
import Foundation

struct OptionalExtensionsTests {
    @Test
    func unwrappedWithValue() throws {
        let optional: String? = "Hello"
        let unwrapped = try optional.unwrapped()
        #expect(unwrapped == "Hello")
    }

    @Test
    func unwrappedWithNilThrowsError() {
        let optional: String? = nil
        #expect(throws: UnwrappingError.self) {
            try optional.unwrapped()
        }
    }

    @Test
    func unwrappedWithCustomMessage() throws {
        let optional: Int? = 42
        let unwrapped = try optional.unwrapped(or: "Custom error message")
        #expect(unwrapped == 42)
    }

    @Test
    func unwrappedWithNilThrowsCustomMessage() {
        let optional: Int? = nil
        do {
            _ = try optional.unwrapped(or: "Value should not be nil")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error.localizedDescription.contains("Value should not be nil"))
        }
    }

    @Test
    func unwrappingErrorDescription() {
        #expect(UnwrappingError.valueIsNil.errorDescription == "Required value was nil")
        #expect(UnwrappingError.custom("Test").errorDescription == "Test")
    }
}
