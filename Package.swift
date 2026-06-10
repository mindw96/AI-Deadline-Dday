// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Dday",
    platforms: [
        .macOS(.v13),
        .iOS(.v17)
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
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.9.0")
    ],
    targets: [
        .target(
            name: "DdayCore",
            path: "Sources/DdayCore"
        ),
        .executableTarget(
            name: "DdayApp",
            dependencies: [
                "DdayCore",
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/DdayApp",
            resources: [
                .copy("Resources/conferences.json")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-rpath",
                    "-Xlinker", "@executable_path/../Frameworks"
                ], .when(platforms: [.macOS]))
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
