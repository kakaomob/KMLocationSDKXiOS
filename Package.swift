// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sdkName = "KMLocationSDKXiOS"
let binaryName = "LocationSDK"

let binaryUrl = "https://devrepo.kakaomobility.com/repository/kakao-mobility-location-kmp-release/com/kakaomobility/locationx/core-ios-xcframework/0.1.12/core-ios-xcframework-0.1.12.zip"
let checksum = "11727301a3694bf226b19e89c9290007a438d808ec63afa1ceb971f5828d932b"

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
