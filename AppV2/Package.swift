// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppV2",
    platforms: [
        .macOS(.v15),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppV2",
            targets: ["AppV2"]
        ),
    ],
    dependencies: [
        .package(path: "../BookletPDFKit"),
        .package(path: "../BookletCore"),
    ],
    targets: [
        .target(
            name: "AppV2",
            dependencies: ["BookletPDFKit", "BookletCore"]
        ),
    ]
)
