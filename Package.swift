// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ValidatorKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ValidatorKit",
            targets: ["ValidatorKit"]
        ),
    ],
    targets: [
        .target(
            name: "ValidatorKit",
            path: "Sources/ValidatorKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ValidatorKitTests",
            dependencies: ["ValidatorKit"],
            path: "Tests/ValidatorKitTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
