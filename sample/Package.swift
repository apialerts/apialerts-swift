// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "sample",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(name: "APIAlerts", path: "..")
    ],
    targets: [
        .executableTarget(
            name: "sample",
            dependencies: [
                .product(name: "APIAlerts", package: "APIAlerts")
            ],
            path: "Sources"
        ),
    ]
)
