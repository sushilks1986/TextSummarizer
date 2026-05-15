/// Errors thrown by TextSummarizerKit.
public enum SummarizerError: Error, LocalizedError, Sendable {

    /// Apple Intelligence / FoundationModels is not available on this device,
    /// or the user has not enabled it in Settings › Apple Intelligence & Siri.
    case modelUnavailable

    /// The model is available in principle but cannot run right now
    /// (e.g. thermal state, low battery).
    case modelNotReady(String)

    /// The input text was empty or too short to summarise.
    case inputTooShort

    /// The model returned an empty response.
    case emptyResponse

    /// Any other generation failure with an underlying description.
    case generationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available. Enable it in Settings › Apple Intelligence & Siri."
        case .modelNotReady(let reason):
            return "The on-device model is not ready: \(reason)"
        case .inputTooShort:
            return "The input text is too short to summarise. Please provide at least 20 characters."
        case .emptyResponse:
            return "The model returned an empty summary. Please try again."
        case .generationFailed(let reason):
            return "Summarization failed: \(reason)"
        }
    }
}
