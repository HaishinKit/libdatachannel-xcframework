// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "libdatachannel",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v11), .macCatalyst(.v14), .visionOS("1.3"), .watchOS(.v8)],
    products: [.library(name: "libdatachannel", targets: ["RTC"])],
    dependencies: [.package(url: "https://github.com/krzyzanowskim/OpenSSL-Package.git", "3.3.3001"..<"4.0.0")],
    targets: [
        .binaryTarget(name: "libdatachannel", url: "https://github.com/HaishinKit/libdatachannel-xcframework/releases/download/v0.24.7/libdatachannel.xcframework.zip", checksum: "524213882b9ca6f08dc6e6af87d0fdda3618b6ced848c2d8c8c36a08f932b851"),
        .target(name: "RTC", dependencies: ["libdatachannel", .product(name: "OpenSSL", package: "OpenSSL-Package")],
                linkerSettings: [.linkedLibrary("c++")])
    ]
)
