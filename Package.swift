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
        .executable(
            name: "clt-swiftyohlc",
            targets: ["clt-swiftyohlc"]),
        .executable(
            name: "clt-ohlcplot",
            targets: ["clt-ohlcplot"]),
    ],
    dependencies: [
        // Dependencies can be added here if needed
    ],
    targets: [
        .target(
            name: "SwiftyOHLC",
            dependencies: [],
            path: "Sources/SwiftyOHLC"),
        .executableTarget(
            name: "clt-swiftyohlc",
            dependencies: ["SwiftyOHLC"],
            path: "Sources/clt-swiftyohlc"),
        .executableTarget(
            name: "clt-ohlcplot",
            dependencies: ["SwiftyOHLC"],
            path: "Sources/clt-ohlcplot"),
    ]
) 
