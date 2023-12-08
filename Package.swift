// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NETURLSchemeHandler",
    products: [
        .library(
            name: "NETURLSchemeHandler",
            targets: ["NETURLSchemeHandler"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "NETURLSchemeHandler",
            dependencies: [],
            path: "NETURLSchemeHandler/Classes",
            publicHeadersPath: ".")
    ]
)
