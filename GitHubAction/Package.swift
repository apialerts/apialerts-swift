// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sample",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    dependencies: [
        .package(path: "../../apialerts-swift")
    ],
    targets: [
        .executableTarget(
            name: "Sample",
            dependencies: [
                .product(name: "APIAlerts", package: "apialerts-swift")
            ]
        ),
    ]
)
