// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "libdatachannel",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v11), .macCatalyst(.v14), .visionOS("1.3"), .watchOS(.v8)],
    products: [.library(name: "libdatachannel", targets: ["RTC"])],
    dependencies: [.package(url: "https://github.com/krzyzanowskim/OpenSSL-Package.git", "3.3.3001"..<"4.0.0")],
    targets: [
        .binaryTarget(name: "libdatachannel", url: "https://github.com/HaishinKit/libdatachannel-xcframework/releases/download/v0.24.8/libdatachannel.xcframework.zip", checksum: "897d5487c6fef1ca20696fc36c8553ee4df6c8828090ea01448442af70930481"),
        .target(name: "RTC", dependencies: ["libdatachannel", .product(name: "OpenSSL", package: "OpenSSL-Package")],
                linkerSettings: [.linkedLibrary("c++")])
    ]
)
