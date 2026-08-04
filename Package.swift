// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sdkName = "KMLocationSDKXiOS"
let binaryName = "LocationSDK"

let binaryUrl = "https://devrepo.kakaomobility.com/repository/kakao-mobility-location-kmp-release/com/kakaomobility/locationx/core-ios-xcframework/1.0.6/core-ios-xcframework-1.0.6.zip"
let checksum = "225a8ddf5b55bea7561c0ba737a85ee668a17b10473433783359c183e23dcb69"

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
