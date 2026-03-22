// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppV1",
    platforms: [
        .macOS(.v15),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppV1",
            targets: ["AppV1"]
        ),
    ],
    dependencies: [
        .package(path: "../BookletPDFKit"),
        .package(path: "../BookletCore"),
    ],
    targets: [
        .target(
            name: "AppV1",
            dependencies: ["BookletPDFKit", "BookletCore"]
        ),
    ]
)
