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
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "APIAlerts",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
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
