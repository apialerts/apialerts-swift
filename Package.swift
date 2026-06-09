// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "APIAlerts",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .visionOS(.v1),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "APIAlerts",
            targets: ["APIAlerts"]
        ),
    ],
    targets: [
        .target(
            name: "APIAlerts",
            path: "Sources/apialerts-swift"
        ),
        .testTarget(
            name: "APIAlertsTests",
            dependencies: ["APIAlerts"],
            path: "Tests/APIAlertsTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
