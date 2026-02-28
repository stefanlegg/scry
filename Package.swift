// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Scry",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Scry", targets: ["Scry"])
    ],
    targets: [
        .executableTarget(
            name: "Scry",
            path: "Sources"
        ),
        .testTarget(
            name: "ScryTests",
            dependencies: ["Scry"],
            path: "Tests/ScryTests"
        )
    ]
)
