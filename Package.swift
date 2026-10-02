// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ElapseCore",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ElapseCore", targets: ["ElapseCore"])
    ],
    targets: [
        .target(
            name: "ElapseCore",
            path: "Shared"
        ),
        .testTarget(
            name: "ElapseCoreTests",
            dependencies: ["ElapseCore"],
            path: "Tests"
        )
    ]
)
