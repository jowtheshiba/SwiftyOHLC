// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyOHLC",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftyOHLC",
            targets: ["SwiftyOHLC"]),
    ],
    dependencies: [
        // Dependencies can be added here if needed
    ],
    targets: [
        .target(
            name: "SwiftyOHLC",
            dependencies: [],
            path: "Sources"),
    ]
) 