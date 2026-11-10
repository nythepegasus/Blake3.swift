// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Blake3",
    platforms: [.macOS(.v10_15), .iOS(.v13), .macCatalyst(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        .library(name: "Blake3", targets: ["Blake3"]),
    ],
    targets: [
        .target(name: "Blake3C", cSettings: [.headerSearchPath("./dependencies/BLAKE3/include")]),
        .target( name: "Blake3", dependencies: ["Blake3C"]),
        .testTarget(name: "Blake3Tests", dependencies: ["Blake3"], resources: [.copy("vectors.json")]),
    ]
)
