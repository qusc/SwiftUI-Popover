// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftUI-Popover",
    platforms: [.iOS(.v16), .macOS(.v14), .watchOS(.v11), .tvOS(.v18), .visionOS(.v1)],
    products: [
        .library(
            name: "SwiftUI-Popover",
            targets: ["SwiftUI-Popover"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftUI-Popover"
        ),
        .testTarget(
            name: "SwiftUI-PopoverTests",
            dependencies: ["SwiftUI-Popover"]
        ),
    ]
)
