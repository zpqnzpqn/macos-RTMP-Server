// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocalRTMPServer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "LocalRTMPServer", targets: ["LocalRTMPServer"])
    ],
    targets: [
        .executableTarget(
            name: "LocalRTMPServer",
            dependencies: [],
            path: "Sources/macos-App"
        )
    ]
)
