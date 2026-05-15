import Testing
@testable import TextSummarizerKit

@Suite("SummarizerError")
struct SummarizerErrorTests {

    @Test("inputTooShort has a human-readable description")
    func inputTooShortDescription() {
        let error = SummarizerError.inputTooShort
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("generationFailed embeds the reason")
    func generationFailedDescription() {
        let error = SummarizerError.generationFailed("network timeout")
        #expect(error.errorDescription?.contains("network timeout") == true)
    }

    @Test("modelUnavailable description mentions Settings")
    func modelUnavailableDescription() {
        let error = SummarizerError.modelUnavailable
        #expect(error.errorDescription?.contains("Settings") == true)
    }
}

@Suite("SummaryResult")
struct SummaryResultTests {

    @Test("SummaryResult stores all fields correctly")
    func fieldStorage() {
        let result = SummaryResult(
            summary: "This is a summary.",
            keyPoints: ["Point A", "Point B"],
            topic: "Testing",
            style: .full
        )
        #expect(result.summary == "This is a summary.")
        #expect(result.keyPoints.count == 2)
        #expect(result.topic == "Testing")
        #expect(result.style == .full)
    }

    @Test("Paragraph style has empty keyPoints")
    func paragraphStyleKeyPoints() {
        let result = SummaryResult(
            summary: "Brief summary.",
            keyPoints: [],
            topic: "",
            style: .paragraph
        )
        #expect(result.keyPoints.isEmpty)
    }
}
