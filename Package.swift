// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "RingBuffers",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: "RingBufferCore", targets: ["RingBufferCore"]),
        .library(name: "VanillaRingBuffer", targets: ["VanillaRingBuffer"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RingBufferCore",
            dependencies: []
        ),
        .target(
            name: "VanillaRingBuffer",
            dependencies: ["RingBufferCore"]
        ),
        .testTarget(
            name: "VanillaRingBufferTests",
            dependencies: ["VanillaRingBuffer"]
        ),
    ]
)
