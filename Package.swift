// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TextSummarizerKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
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
