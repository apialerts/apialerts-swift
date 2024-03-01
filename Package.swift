// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APIAlerts",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .visionOS(.v1),
        .watchOS(.v4),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "APIAlerts",
            targets: ["APIAlerts"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "APIAlerts",
            dependencies: []
        ),
        .testTarget(
            name: "APIAlertsTests",
            dependencies: ["APIAlerts"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
