// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Scry",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "ScryKit", targets: ["ScryKit"]),
        .executable(name: "Scry", targets: ["ScryApp"]),
        .executable(name: "scry", targets: ["ScryCLI"]),
        .executable(name: "scry-mcp", targets: ["ScryMCP"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        // Shared library: models + scanner (Foundation only, no AppKit/SwiftUI)
        .target(
            name: "ScryKit",
            path: "Sources/ScryKit"
        ),

        // Menu bar app
        .executableTarget(
            name: "ScryApp",
            dependencies: ["ScryKit"],
            path: "Sources/ScryApp",
            exclude: ["Info.plist"]
        ),

        // CLI tool
        .executableTarget(
            name: "ScryCLI",
            dependencies: [
                "ScryKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/ScryCLI"
        ),

        // MCP server
        .executableTarget(
            name: "ScryMCP",
            dependencies: ["ScryKit"],
            path: "Sources/ScryMCP"
        ),

        // Tests
        .testTarget(
            name: "ScryTests",
            dependencies: ["ScryKit"],
            path: "Tests/ScryTests"
        )
    ]
)
