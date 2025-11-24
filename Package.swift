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
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.2")
    ],
    targets: [
        .target(
            name: "SPSCRingBuffer",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics")
            ]
        ),
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
        .testTarget(
            name: "SPSCRingBufferTests",
            dependencies: ["SPSCRingBuffer"]
        )
    ]
)
