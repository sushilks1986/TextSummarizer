import FoundationModels

// MARK: - Public result types

/// The style of summary to generate.
public enum SummaryStyle: Sendable {
    /// A single short paragraph (default).
    case paragraph
    /// A list of bullet-point key takeaways.
    case keyPoints
    /// Both a paragraph and key points.
    case full
}

/// The result returned by ``TextSummarizer``.
public struct SummaryResult: Sendable {
    /// A concise paragraph summary of the original text.
    public let summary: String

    /// Key points extracted from the text.
    /// Empty when `style` is `.paragraph`.
    public let keyPoints: [String]

    /// The detected topic / theme of the text.
    public let topic: String

    /// The style used to produce this result.
    public let style: SummaryStyle
}

// MARK: - Internal Generable type (not exposed publicly)

@Generable
struct _StructuredSummary {
    @Guide(description: "A concise 2–3 sentence summary of the content.")
    var summary: String

    @Guide(description: "3 to 5 key points or takeaways from the text.")
    var keyPoints: [String]

    @Guide(description: "The main topic or theme of the text in a few words.")
    var topic: String
}
