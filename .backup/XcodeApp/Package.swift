// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TMBMApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "TMBMApp",
            targets: ["TMBMApp"]
        )
    ],
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .executableTarget(
            name: "TMBMApp",
            dependencies: [
                .product(name: "TMBM", package: "TMBM")
            ],
            path: ".",
            sources: ["TMBMApp.swift"]
        )
    ]
) 