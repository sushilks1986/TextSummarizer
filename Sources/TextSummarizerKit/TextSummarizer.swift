import FoundationModels

/// A lightweight, actor-isolated wrapper around Apple's `FoundationModels`
/// framework that summarises any text using the on-device LLM.
///
/// ### Quick start
/// ```swift
/// import TextSummarizerKit
///
/// let summarizer = TextSummarizer()
///
/// // Simple one-liner
/// let result = try await summarizer.summarize("Your long article text here…")
/// print(result.summary)
///
/// // Key points
/// let detailed = try await summarizer.summarize(text, style: .full)
/// print(detailed.keyPoints)
///
/// // Streaming (updates UI token-by-token)
/// for await partial in summarizer.summarizeStream(text) {
///     label.text = partial
/// }
/// ```
///
/// - Note: Requires iOS 26+ / macOS Tahoe 26+ with Apple Intelligence enabled.
public actor TextSummarizer {

    // MARK: - Properties

    private let systemInstructions: String

    // MARK: - Init

    /// Create a summarizer with an optional custom system instruction.
    /// - Parameter systemInstructions: Instructions prepended to every prompt.
    ///   Defaults to a general summarisation persona.
    public init(
        systemInstructions: String = "You are an expert summarization assistant. Produce clear, accurate, and concise summaries that preserve the key ideas of the original text."
    ) {
        self.systemInstructions = systemInstructions
    }

    // MARK: - Public API

    /// Summarise `text` and return a ``SummaryResult``.
    ///
    /// - Parameters:
    ///   - text: The text to summarise. Must be at least 20 characters.
    ///   - style: Controls the shape of the result (paragraph / key points / full).
    /// - Returns: A ``SummaryResult`` containing the summary, key points, and topic.
    /// - Throws: ``SummarizerError`` on failure.
    public func summarize(
        _ text: String,
        style: SummaryStyle = .paragraph
    ) async throws -> SummaryResult {
        try validate(text)
        try checkAvailability()

        let session = LanguageModelSession(instructions: systemInstructions)

        switch style {
        case .paragraph:
            let prompt = "Summarize the following text in 2–3 clear sentences:\n\n\(text)"
            let response = try await withMappedError {
                try await session.respond(to: prompt)
            }
            guard !response.content.isEmpty else { throw SummarizerError.emptyResponse }
            return SummaryResult(
                summary: response.content,
                keyPoints: [],
                topic: "",
                style: .paragraph
            )

        case .keyPoints, .full:
            let prompt = buildStructuredPrompt(for: text, style: style)
            let response = try await withMappedError {
                try await session.respond(to: prompt, generating: _StructuredSummary.self)
            }
            let structured = response.content
            return SummaryResult(
                summary: style == .keyPoints ? "" : structured.summary,
                keyPoints: structured.keyPoints,
                topic: structured.topic,
                style: style
            )
        }
    }

    /// Streams the summary of `text` token-by-token, yielding partial strings.
    ///
    /// Ideal for updating a `UILabel` or SwiftUI `Text` view in real time.
    ///
    /// ```swift
    /// for await partial in summarizer.summarizeStream(myText) {
    ///     await MainActor.run { label.text = partial }
    /// }
    /// ```
    ///
    /// - Parameter text: The text to summarise. Must be at least 20 characters.
    /// - Returns: An `AsyncThrowingStream` of partial summary strings.
    public func summarizeStream(
        _ text: String
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    try self.validate(text)
                    try self.checkAvailability()

                    let session = LanguageModelSession(
                        instructions: self.systemInstructions
                    )
                    let prompt = "Summarize the following text in 2–3 clear sentences:\n\n\(text)"

                    let stream = session.streamResponse(to: prompt)
                    for try await partial in stream {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private helpers

    private func validate(_ text: String) throws {
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 20 else {
            throw SummarizerError.inputTooShort
        }
    }

    private func checkAvailability() throws {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            return
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible, .appleIntelligenceNotEnabled:
                throw SummarizerError.modelUnavailable
            default:
                throw SummarizerError.modelNotReady(reason.debugDescription)
            }
        }
    }

    private func buildStructuredPrompt(for text: String, style: SummaryStyle) -> String {
        switch style {
        case .keyPoints:
            return "Extract 3–5 key points and the main topic from the following text:\n\n\(text)"
        case .full:
            return "Summarize the following text: provide a 2–3 sentence paragraph summary, 3–5 key points, and identify the main topic:\n\n\(text)"
        case .paragraph:
            return "Summarize the following text in 2–3 clear sentences:\n\n\(text)"
        }
    }
}

// MARK: - Error mapping helper

private func withMappedError<T>(_ block: () async throws -> T) async throws -> T {
    do {
        return try await block()
    } catch let error as SummarizerError {
        throw error
    } catch {
        throw SummarizerError.generationFailed(error.localizedDescription)
    }
}
