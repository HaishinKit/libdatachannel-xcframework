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
./build.sh
```

The single entry point prepares sources/OpenSSL, builds all platforms, packages
the XCFramework, and selects the local development manifest. Implementation
scripts live in `scripts/build/`; there is no need to invoke them directly.
Individual steps are also available:

```sh
./build.sh prepare
./build.sh build watchos
./build.sh build             # All platforms
./build.sh package
./build.sh local
./build.sh verify
```

Source preparation pins v0.24.6 and its submodules, including libjuice v1.7.4
and libSRTP v2.8.0, and refuses to overwrite local source changes. OpenSSL and
ios-cmake source checkouts are no longer required. The OpenSSL preparation
script downloads a checksum-pinned release ZIP and verifies its signature.
It creates local CMake-compatible header copies and library aliases; the signed
upstream framework remains unchanged.

Set `CMAKE=/path/to/cmake` and `JOBS=8` as needed. Builds use native CMake Apple
platform support.
`./build.sh help` lists every command.

## Debug symbols

Builds from this revision use `-O3 -DNDEBUG -g` for C and C++, retaining
Release optimization and embedding DWARF debug information in `libdatachannel.a`.
This applies to all platforms, including the bundled libjuice, libSRTP, and usrsctp libraries.
The release checks require DWARF compilation units with line-table references
in every architecture of the packaged XCFramework. Previously published
release assets are unchanged; this takes effect in the next release.

These static libraries do not ship a standalone dSYM. Archive the consuming
application with **Debug Information Format = DWARF with dSYM File**, preserve
its matching dSYM, and upload it to Firebase Crashlytics. The final app dSYM
must contain the linked library's debug information; merely updating the
package does not configure symbol uploads. Optimization can still affect
inlining and source-line accuracy. OpenSSL's separate upstream dSYM and its
limitations described above are unchanged.

## Swift Package Manager

After publishing a release with the workflow below, other libraries can depend
on this same repository by URL and version, without specifying a checksum:

```swift
dependencies: [
    .package(url: "https://github.com/HaishinKit/libdatachannel-xcframework.git",
             exact: "0.24.6")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "libdatachannel", package: "libdatachannel-xcframework")
    ])
]
```

The version above is a release example; publish that tag and its ZIP before
using it. OpenSSL is resolved transitively. No separate package repository is
needed. For local development, build and run `./build.sh local`, then replace
the URL dependency with `.package(path: "../libdatachannel-xcframework")`.

Application code continues to use `import libdatachannel`. The `RTC` wrapper
carries dependencies because a SwiftPM binary target cannot declare them.
For manual binary integration, also link the C++ runtime and embed/sign the
selected upstream `OpenSSL.framework` in the final app. Verify that its Privacy
Manifest reaches the app archive.

## Distribution

The same repository holds the build scripts, Swift package, version tags, and
GitHub Release assets. The build creates `libdatachannel.xcframework`, its ZIP,
and a `.sha256` file. Source and license assets are generated in `dist/licensing/`:

- `THIRD-PARTY-LICENSES.txt`: original license texts for the six bundled components.
- `SOURCE-NOTICE.txt`: source-availability notice, revision URLs and modification status.
- `SOURCES.json`: machine-readable component, license, version/revision and commit inventory.
- `libdatachannel-sources.zip`: the exact upstream sources, including every pinned submodule.
- `SHA256SUMS.json`: checksums tying these assets to the binary ZIP.

The first three files are also inside `libdatachannel.xcframework/Licenses/`.
Both the Actions workflow and `./build.sh publish TAG` upload all five additional
assets. GitHub's automatic repository source ZIP is not a substitute for this
source bundle because it does not include the dependency submodule contents.

### Release from GitHub Actions (recommended)

After this workflow is merged into `main`:

1. Open **Actions → Release XCFramework → Run workflow**.
2. Select **main** and enter a new package version, such as `0.24.6`.
3. Press **Run workflow**. A successful run publishes the tag and GitHub Release.

The workflow builds all platforms on an Apple silicon macOS 26 runner with
Xcode 26.6 and CMake 3.31.10, runs link/runtime/package checks, and generates the
remote manifest. It creates a release commit from the selected source commit,
adds the version tag to it, and publishes the ZIP in the same workflow.
Only the tag is pushed; `main` stays on its development manifest. Consumers
select the published version tag, not the `main` branch.

The input is the **package distribution version**, not a request to fetch a
different upstream version. Update the pinned libdatachannel version and its
metadata in a reviewed commit before releasing a new upstream version.
Only stable versions are accepted (`0.24.6` or `v0.24.6`). Existing tags and
releases (including drafts) are rejected before building. Runs are serialized.
The workflow uses the built-in `GITHUB_TOKEN` with `contents: write`; no personal
access token or signing secret is needed for this static XCFramework. Repository
or organization rules must allow Actions to create release tags and releases.

Before pushing the tag, the workflow saves a `release-vVERSION` artifact for
30 days containing the exact binary ZIP, checksum, generated manifest, and all
source/license assets. If publication
fails after the tag was pushed, do **not** rebuild or move the tag: download that
artifact, check out the existing tag, restore the ZIP/checksum at the repository
root, restore the five source/license assets under `dist/licensing/`, and run
`./build.sh publish TAG`. If a draft or partial Release already
exists, inspect and complete it using the saved files rather than rerunning the
whole workflow or overwriting published assets.

### Release from your Mac

1. Run `./build.sh` and `./build.sh verify`.
2. Run `./build.sh release v0.24.6` (choose a new, unused version tag).
   This computes the ZIP checksum and writes a remote binary target directly
   to the root `Package.swift`, with a copy in `dist/Package.swift`.
3. Review and commit the release changes, including `Package.swift`, and merge
   if required by your workflow. Tag that exact commit and push the commit/tag:

   ```sh
   git tag v0.24.6
   git push origin HEAD
   git push origin v0.24.6
   ```

4. From that commit, run `./build.sh publish v0.24.6` to upload the ZIP and its
   checksum file and the five source/license assets to this repository's GitHub Releases. This requires an
   authenticated GitHub CLI (`gh`).

`release` only prepares local files; `publish` is the explicit upload step.
Publishing checks the manifest URL/checksum, a clean working tree, and matching
local/remote tags at HEAD. It fails if a release already exists instead of
replacing its assets. Do not replace existing v0.24.0 assets.

`support/Package.swift` is the development template for both modes. Keep
platforms, products, and dependencies there. `./build.sh local` restores it to
the root for local testing; that changes the working tree. Release tags must
contain the generated remote manifest, never the local one. The initial PR's
manifest remains local until an actual release is prepared. After release
preparation, do not rebuild the ZIP without regenerating the manifest and
committing its new checksum before tagging.

## Verification

```sh
./build.sh local
./build.sh verify
python3 tests/verify-release.py
python3 tests/verify-ci-release.py
python3 tests/verify-source-distribution.py
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

## License and app redistribution

The source packaging step requires clean upstream checkouts at their pinned
submodule commits. Each architecture records its source inventory before and
after building; packaging rejects missing or mismatched records. Rebuild all
platforms after changing a dependency. If you intentionally modify an upstream
source, extend this process to ship that modified source and accurately declare
the changes; do not label modified code as unmodified.

For applications distributing this framework:

1. Preserve `THIRD-PARTY-LICENSES.txt` and `SOURCE-NOTICE.txt` in accompanying
   documentation or app resources accessible to users (for example, an
   **Open Source Licenses** screen). Add the specific release URL for the
   version you ship, where its source ZIP is available.
2. Keep the MPL-2.0 source-availability notice for both libdatachannel and
   libjuice. Their exact source URLs and commit IDs are recorded in the notice;
   the source bundle also preserves the original source headers and notices.
3. Include the license and applicable notices for the **actual resolved
   OpenSSL version** separately. OpenSSL-Package is external and can resolve to
   different 3.x versions; this source ZIP does not contain OpenSSL. Check your
   resolved artifact's licenses/notices and preserve its Privacy Manifest as
   described above.

SwiftPM does not automatically copy the XCFramework's top-level `Licenses/`
directory into the final app. Verify that your own app packaging includes these
notices; importing the package alone is not a license-notice delivery mechanism.
The MPL obligations concern its covered source and modifications, not automatic
publication of your entire application's proprietary source. See the
[Mozilla MPL FAQ](https://www.mozilla.org/en-US/MPL/2.0/FAQ/) and the license texts.


libdatachannel is MPL-2.0. `scripts/build/build-licenses.sh` generates the source and license distribution
for libdatachannel and its bundled dependencies. OpenSSL is
separately distributed under Apache-2.0. App distributors must preserve the
applicable notices for all dependencies.
