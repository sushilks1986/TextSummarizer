// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "TextSummarizer",  // ← changed from TextSummarizerKit
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "TextSummarizer",  // ← changed
            targets: ["TextSummarizer"]  // ← changed
        )
    ],
    targets: [
        .target(
            name: "TextSummarizer",  // ← changed
            path: "Sources/TextSummarizerKit"  // ← keep the folder path as-is
        ),
        .testTarget(
            name: "TextSummarizerTests",  // ← changed
            dependencies: ["TextSummarizer"],  // ← changed
            path: "Tests/TextSummarizerKitTests"  // ← keep folder path as-is
        )
    ]
)
