// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sdkName = "KMLocationSDKXiOS"
let binaryName = "LocationSDK"

let binaryUrl = "https://devrepo.kakaomobility.com/repository/kakao-mobility-location-kmp-release/com/kakaomobility/locationx/core-ios-xcframework/0.0.5/core-ios-xcframework-0.0.5.zip"
let checksum = "8c8bb0f6acf4b168a9603f29ffeea1f7c4f05be126b081237f40b5c528f9aae4"

let package = Package(
    name: sdkName,
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: sdkName,
            targets: ["\(sdkName)Wrapper"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(name: binaryName, url: binaryUrl, checksum: checksum),
        .target(name: "\(sdkName)Wrapper",
                dependencies: [.target(name: binaryName)])
    ]
)
