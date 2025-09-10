// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "libdatachannel-xcframework",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .visionOS(.v1),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "libdatachannel", targets: ["libdatachannel"]),
    ],
    targets: [
        .binaryTarget(
            name: "libdatachannel",
            url: "https://github.com/HaishinKit/libdatachannel-xcframework/releases/download/v0.23.1/libdatachannel.xcframework.zip",
            checksum: "fe37fa856802f0cdb017161837e433f8279fd94f8f237b442bbba0b2e0616364"
        ),
    ],
)
