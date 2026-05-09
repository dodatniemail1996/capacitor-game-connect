// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CapacitorGameConnect",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "CapacitorGameConnect",
            targets: ["CapacitorGameConnect"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "CapacitorGameConnect",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm")
            ],
            path: "Plugin",
            exclude: [
                "CapacitorGameConnectPlugin.m",
                "CapacitorGameConnectPlugin.h",
                "Info.plist"
            ],
            sources: [
                "CapacitorGameConnect.swift",
                "CapacitorGameConnectPlugin.swift"
            ]
        )
    ]
)

