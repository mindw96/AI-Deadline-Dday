// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Dday",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DdayCore",
            targets: ["DdayCore"]
        ),
        .executable(
            name: "Dday",
            targets: ["DdayApp"]
        ),
        .executable(
            name: "DdayCoreChecks",
            targets: ["DdayCoreChecks"]
        )
    ],
    targets: [
        .target(
            name: "DdayCore",
            path: "Sources/DdayCore"
        ),
        .executableTarget(
            name: "DdayApp",
            dependencies: ["DdayCore"],
            path: "Sources/DdayApp",
            resources: [
                .copy("Resources/conferences.json")
            ]
        ),
        .executableTarget(
            name: "DdayCoreChecks",
            dependencies: ["DdayCore"],
            path: "Checks/DdayCoreChecks",
            resources: [
                .copy("Resources/conferences-fixture.json")
            ]
        )
    ]
)
