// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LLMMarkdown",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LLMMarkdown",
            targets: ["LLMMarkdown"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "LLMMarkdown",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "LLMMarkdownTests",
            dependencies: ["LLMMarkdown"],
            path: "Tests"),
    ]
)