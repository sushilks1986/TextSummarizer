import Foundation  // ← add this

public enum SummarizerError: Error, LocalizedError, Sendable {

    case modelUnavailable
    case modelNotReady(String)
    case inputTooShort
    case emptyResponse
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
