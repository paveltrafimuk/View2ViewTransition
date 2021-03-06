// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "View2ViewTransition",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "View2ViewTransition",
                 targets: ["View2ViewTransition"]),
    ],
    targets: [
        .target(
            name: "View2ViewTransition",
            path: "View2ViewTransition")
    ]
)
