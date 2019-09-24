// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PeerLinks",
    products: [
        .library(
            name: "PeerLinks",
            targets: ["PeerLinks"]),
    ],
    dependencies: [
      .package(url: "https://github.com/jedisct1/swift-sodium.git", .upToNextMinor(from: "0.8.0")),
    ],
    targets: [
        .target(
            name: "PeerLinks",
            dependencies: [ "Sodium" ]),
        .testTarget(
            name: "PeerLinksTests",
            dependencies: ["PeerLinks"]),
    ]
)
