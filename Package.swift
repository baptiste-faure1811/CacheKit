// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CacheKit",
    platforms: [.iOS(.v14)], products: [
        .library(
            name: "CacheKit",
            targets: ["CacheKit"]),
    ],
    targets: [
        .target(
            name: "CacheKit",
            dependencies: []),
    ]
)
