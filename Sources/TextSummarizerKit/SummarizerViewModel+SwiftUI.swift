import SwiftUI

// MARK: - ViewModel (ObservableObject for UIKit & SwiftUI)

/// A ready-to-use `ObservableObject` that drives a summarisation UI.
///
/// ```swift
/// // SwiftUI
/// @StateObject var vm = SummarizerViewModel()
///
/// // UIKit
/// let vm = SummarizerViewModel()
/// vm.$summary.sink { self.label.text = $0 }.store(in: &cancellables)
/// ```
@MainActor
public final class SummarizerViewModel: ObservableObject {

    @Published public var summary: String = ""
    @Published public var keyPoints: [String] = []
    @Published public var topic: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    private let summarizer = TextSummarizer()

    public init() {}

    /// Summarise `text` and publish results to all `@Published` properties.
    public func summarize(_ text: String, style: SummaryStyle = .paragraph) {
        Task {
            isLoading = true
            errorMessage = nil
            summary = ""
            keyPoints = []
            topic = ""

            do {
                let result = try await summarizer.summarize(text, style: style)
                summary = result.summary
                keyPoints = result.keyPoints
                topic = result.topic
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    /// Stream a summary into `summary` in real time.
    public func summarizeStreaming(_ text: String) {
        Task {
            isLoading = true
            errorMessage = nil
            summary = ""

            do {
                for try await partial in await summarizer.summarizeStream(text) {
                    summary = partial
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - SwiftUI View Modifier

/// Attaches a summarise button and output area below any `View`.
///
/// ```swift
/// Text(longArticle)
///     .summarizable()
/// ```
public struct SummarizableModifier: ViewModifier {
    @StateObject private var vm = SummarizerViewModel()
    let inputText: String
    let style: SummaryStyle

    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content

            Divider()

            if vm.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Summarising…").foregroundStyle(.secondary)
                }
            }

            if !vm.summary.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Summary", systemImage: "text.quote")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(vm.summary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                }
            }

            if !vm.keyPoints.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Key Points", systemImage: "list.bullet")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    ForEach(vm.keyPoints, id: \.self) { point in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 5))
                                .padding(.top, 6)
                            Text(point)
                        }
                    }
                }
            }

            if let error = vm.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button(action: { vm.summarize(inputText, style: style) }) {
                Label("Summarise", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isLoading)
        }
    }
}

public extension View {
    /// Attaches a summarise button and output panel below this view.
    /// - Parameters:
    ///   - text: The text to summarise (pass the same string driving the view).
    ///   - style: The summary style. Defaults to `.paragraph`.
    func summarizable(text: String, style: SummaryStyle = .paragraph) -> some View {
        modifier(SummarizableModifier(inputText: text, style: style))
    }
}
