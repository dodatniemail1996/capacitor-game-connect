// swift-tools-version:5.9
import PackageDescription

// Capacitor SPM expects plugins to expose Package.swift at the npm package root
// (same folder as package.json), so the Capacitor CLI can add it via a local `path:`.
let package = Package(
    name: "Ni2khannaCapacitorGameConnect",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Ni2khannaCapacitorGameConnect",
            targets: ["Ni2khannaCapacitorGameConnect"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "Ni2khannaCapacitorGameConnect",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm")
            ],
            path: "ios/Plugin",
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

