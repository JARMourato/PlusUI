// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlusUI",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v6), .tvOS(.v15)],
    products: [
        .library(name: "PlusUI", targets: ["PlusUI"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "PlusUI", dependencies: [], path: "Sources"),
        .testTarget(name: "PlusUITests", dependencies: ["PlusUI"], path: "Tests"),
    ]
)
