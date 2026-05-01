// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DocumentScannerKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "DocumentScannerKit",
            targets: ["DocumentScannerKit"]),
    ],
    targets: [
        .target(name: "DocumentScannerKit"),
        .testTarget(
            name: "DocumentScannerKitTests",
            dependencies: ["DocumentScannerKit"]
        ),
    ]
)
