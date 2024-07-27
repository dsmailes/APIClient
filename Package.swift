// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APIClient",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "APIClient",
            targets: ["APIClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMajor(from: "6.7.1")),
    ],
    targets: [
        .target(
            name: "APIClient",
        dependencies: ["RxSwift"])
    ]
)
