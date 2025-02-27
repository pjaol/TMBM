// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TMBM",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "TMBM",
            targets: ["TMBM"]
        ),
    ],
    dependencies: [
        // Dependencies go here
    ],
    targets: [
        .executableTarget(
            name: "TMBM",
            dependencies: []
        ),
        .testTarget(
            name: "TMBMTests",
            dependencies: ["TMBM"]
        ),
    ]
) 