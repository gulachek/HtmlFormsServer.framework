// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "testpkg",
    targets: [
        .executableTarget(
            name: "testpkg",
            dependencies: ["HtmlFormsServer"]
            ),
        .binaryTarget(
            name: "HtmlFormsServer",
            path: "../HtmlFormsServer.xcframework"
        ),
    ]
)
