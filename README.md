# libdatachannel.xcframework

libdatachannel **[v0.24.6](https://github.com/paullouisageneau/libdatachannel/releases/tag/v0.24.6)** for Apple platforms, using the shared
[OpenSSL-Package](https://github.com/krzyzanowskim/OpenSSL-Package) dependency
in the range **3.3.3001..<4.0.0**. This project is maintained for HaishinKit
and can also be used independently.

## Platforms

| Platform | Minimum | Architecture |
|---|---|---|
| iOS | 13.0 | arm64 |
| iOS Simulator | 14.0 | arm64 |
| tvOS | 13.0 | arm64 |
| tvOS Simulator | 14.0 | arm64 |
| macOS | 11.0 | arm64 |
| Mac Catalyst | 14.0 | arm64 |
| visionOS / Simulator | 1.3 | arm64 |
| watchOS | 8.0 | arm64_32, armv7k |
| watchOS | 26.0 | arm64 |
| watchOS Simulator | 8.0 | arm64 |

There are ten slices and twelve architecture variants. The watchOS device
slice combines all three architectures. Intel slices are not included.
The minimums account for the upstream Swift package and the compiler's Apple
silicon deployment requirements. Compared with the previous README, macOS is
now explicitly 11.0, visionOS is 1.3, and watchOS is 8.0 (26.0 for full arm64).

## Shared OpenSSL dependency

**OpenSSL is no longer embedded in libdatachannel.a.** The SwiftPM source
wrapper links the upstream dynamic OpenSSL framework and the C++ runtime.
libdatachannel's private libjuice, libSRTP, and usrsctp archives remain bundled.

The build uses headers from package 3.3.3001 (OpenSSL 3.3.3), while applications
can resolve a compatible newer 3.x release. The lower bound allows dependency
sharing; it is not a recommendation to deploy an old unsupported OpenSSL.
Use the same canonical package URL in all consumers, including libsrt.

The upstream framework supplies its own signature, Privacy Manifest, and
dSYM. This project neither modifies nor re-signs it. Its inspected 3.6.3000
iOS dSYM lacks OpenSSL implementation source-line information equivalent to a
custom `-g` build. Consumers still configure their own Crashlytics symbol upload.

Older libdatachannel releases bundle OpenSSL. Do not combine those binaries
with this new package, a separate OpenSSL framework, or other libraries that
embed another OpenSSL implementation. Migrate dependent packages together.

## Build

Requires Xcode with the relevant SDKs, CMake 3.28+, Python 3, and Git:

```sh
./build-clone.sh
python3 scripts/prepare-openssl.py
./build-ios.sh
./build-tvos.sh
./build-macosx.sh
./build-macosx_catalyst.sh
./build-visionos.sh
./build-watchos.sh
./build-xcframework.sh
```

`build-clone.sh` pins v0.24.6 and its submodules, including libjuice v1.7.4
and libSRTP v2.8.0. It refuses to overwrite local source changes. OpenSSL and ios-cmake source checkouts are no longer required.
The OpenSSL preparation script downloads a checksum-pinned release ZIP and
verifies its signature. It creates local CMake-compatible header copies and
library aliases; the signed upstream framework remains unchanged.

Set `CMAKE=/path/to/cmake` and `JOBS=8` as needed. Builds use native CMake Apple
platform support. The existing `libsrtp.patch` is not required or applied.

## Swift Package Manager

After building, add this repository as a local package:

```swift
dependencies: [.package(path: "../libdatachannel-xcframework")],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "libdatachannel", package: "libdatachannel-xcframework")
    ])
]
```

Application code continues to use `import libdatachannel`. The `RTC` wrapper
carries dependencies because a SwiftPM binary target cannot declare them.
For manual binary integration, also link the C++ runtime and embed/sign the
selected upstream `OpenSSL.framework` in the final app. Verify that its Privacy
Manifest reaches the app archive.

## Distribution

The build creates `libdatachannel.xcframework`, its ZIP, and a `.sha256` file.
The XCFramework includes bundled-component licenses and dependency metadata.
Generate a release manifest after building:

```sh
./prepare-release.sh https://github.com/HaishinKit/libdatachannel-xcframework/releases/download/YOUR_NEW_TAG
```

Use `dist/Package.swift` in the release commit and publish the matching ZIP.
The checked-in manifest is for local development after building. Use a new tag
for this distribution change; do not replace the existing v0.24.0 assets.
These scripts do not publish releases.

## Verification

```sh
python3 tests/verify-build.py
tests/verify-package.sh
SRT_PACKAGE_PATH=../libsrt-xcframework tests/verify-package.sh
OPENSSL_PACKAGE_VERSION=3.3.3001 SRT_PACKAGE_PATH=../libsrt-xcframework tests/verify-package.sh
```

The build check validates every slice's architecture/platform, absence of
bundled OpenSSL definitions, and Swift linkage. macOS and Mac Catalyst runtime
checks create peers and exchange a message over DTLS/SCTP. Set
`OPENSSL_XCFRAMEWORK` and `EXPECTED_OPENSSL_VERSION` to test another upstream
3.x artifact. The combined SwiftPM test checks that both projects resolve one
OpenSSL package and that the executable links one dynamic OpenSSL framework.
Device/simulator runtime, on-watch networking, and App Store archive validation
are not covered by these host-side tests.

## License

libdatachannel is MPL-2.0. `build-licenses.sh` collects the license texts for
libdatachannel and its bundled dependencies into the XCFramework. OpenSSL is
separately distributed under Apache-2.0. App distributors must preserve the
applicable notices for all dependencies.
