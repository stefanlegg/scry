// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Scry",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Scry",
            path: "Sources"
        )
    ]
)
