// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ValidatorKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ValidatorKit",
            targets: ["ValidatorKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ValidatorKit",
            dependencies: [],
            path: "Sources/ValidatorKit"),
        .testTarget(
            name: "ValidatorKitTests",
            dependencies: ["ValidatorKit"],
            path: "Tests/ValidatorKitTests"),
    ]
)
