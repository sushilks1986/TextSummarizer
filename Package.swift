// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TextSummarizerKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "TextSummarizerKit",
            targets: ["TextSummarizerKit"]
        )
    ],
    targets: [
        .target(
            name: "TextSummarizerKit",
            path: "Sources/TextSummarizerKit"
        ),
        .testTarget(
            name: "TextSummarizerKitTests",
            dependencies: ["TextSummarizerKit"],
            path: "Tests/TextSummarizerKitTests"
        )
    ]
)
