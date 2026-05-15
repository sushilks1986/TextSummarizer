# TextSummarizerKit

A lightweight Swift Package that wraps Apple's **FoundationModels** framework to summarise any text using the on-device LLM powering **Apple Intelligence** — no API keys, no network, no cost.

---

## Requirements

| Requirement | Version |
|---|---|
| iOS | 26+ |
| macOS | Tahoe 26+ |
| Xcode | 26+ |
| Apple Intelligence | Enabled in Settings |

---

## Installation

### Swift Package Manager (Xcode)

1. In Xcode, go to **File › Add Package Dependencies…**
2. Paste your repo URL (e.g. `https://github.com/yourname/TextSummarizerKit`)
3. Select **Up to Next Major Version** starting from `1.0.0`
4. Add `TextSummarizerKit` to your target

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/yourname/TextSummarizerKit", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["TextSummarizerKit"]
    )
]
```

---

## Usage

### 1. Simple summarization (one call)

```swift
import TextSummarizerKit

let summarizer = TextSummarizer()

let result = try await summarizer.summarize("Your long text here…")
print(result.summary)
```

### 2. Key points

```swift
let result = try await summarizer.summarize(text, style: .keyPoints)
for point in result.keyPoints {
    print("• \(point)")
}
```

### 3. Full (paragraph + key points + topic)

```swift
let result = try await summarizer.summarize(text, style: .full)
print(result.summary)
print(result.topic)
result.keyPoints.forEach { print("• \($0)") }
```

### 4. Streaming (real-time token updates)

```swift
for try await partial in await summarizer.summarizeStream(text) {
    label.text = partial   // updates as tokens arrive
}
```

### 5. SwiftUI ViewModel

```swift
import SwiftUI
import TextSummarizerKit

struct MyView: View {
    @StateObject var vm = SummarizerViewModel()
    let article = "A very long article…"

    var body: some View {
        VStack {
            if vm.isLoading { ProgressView() }
            Text(vm.summary)
            Button("Summarise") { vm.summarize(article, style: .full) }
        }
    }
}
```

### 6. SwiftUI View Modifier (zero boilerplate)

```swift
Text(myLongText)
    .summarizable(text: myLongText, style: .full)
```

This attaches a **Summarise** button and output panel directly below your view.

### 7. UIKit + Combine

```swift
import Combine
import TextSummarizerKit

class MyViewController: UIViewController {
    let vm = SummarizerViewModel()
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.$summary
            .receive(on: RunLoop.main)
            .sink { [weak self] text in self?.summaryLabel.text = text }
            .store(in: &cancellables)

        vm.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] loading in self?.spinner.isHidden = !loading }
            .store(in: &cancellables)
    }

    @IBAction func summarizeTapped(_ sender: Any) {
        vm.summarize(myTextView.text, style: .paragraph)
    }
}
```

---

## Error Handling

```swift
do {
    let result = try await summarizer.summarize(text)
} catch SummarizerError.modelUnavailable {
    // Prompt user to enable Apple Intelligence in Settings
} catch SummarizerError.inputTooShort {
    // Text must be >= 20 characters
} catch SummarizerError.emptyResponse {
    // Model returned nothing — retry
} catch SummarizerError.generationFailed(let reason) {
    print("Failed: \(reason)")
}
```

---

## SummaryStyle

| Style | `summary` | `keyPoints` | `topic` |
|---|---|---|---|
| `.paragraph` | ✅ | ➖ | ➖ |
| `.keyPoints` | ➖ | ✅ | ✅ |
| `.full` | ✅ | ✅ | ✅ |

---

## License

MIT
