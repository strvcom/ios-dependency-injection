// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DependencyInjection",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DependencyInjection",
            targets: ["DependencyInjection"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DependencyInjection",
            dependencies: [],
            path: "Sources",
            // Agent instructions live alongside the code; they are documentation, not a resource.
            exclude: ["AGENTS.md"],
            swiftSettings: [
                .define("APPLICATION_EXTENSION_API_ONLY"),
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "DependencyInjectionTests",
            dependencies: ["DependencyInjection"],
            path: "Tests",
            exclude: ["AGENTS.md"]
        ),
    ]
)
