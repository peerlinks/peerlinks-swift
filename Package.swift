// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "peerlinks-swift",
    products: [
        .library(
            name: "peerlinks-swift",
            targets: ["peerlinks-swift"]),
    ],
    dependencies: [
      .package(url: "https://github.com/jedisct1/swift-sodium.git", .upToNextMinor(from: "0.8.0")),
    ],
    targets: [
        .target(
            name: "peerlinks-swift",
            dependencies: []),
        .testTarget(
            name: "peerlinks-swiftTests",
            dependencies: ["peerlinks-swift"]),
    ]
)
