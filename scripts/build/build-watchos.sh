#!/bin/bash
source "$(dirname "$0")/build-common.sh"

build_datachannel watchos watchos watchOS 26.0 arm64-apple-watchos26.0 arm64 watchos-arm64
build_datachannel watchos watchos watchOS 8.0 arm64_32-apple-watchos8.0 arm64_32 watchos-arm64_32
build_datachannel watchos watchos watchOS 8.0 armv7k-apple-watchos8.0 armv7k watchos-armv7k
build_datachannel watchsimulator watchsimulator watchOS 8.0 arm64-apple-watchos8.0-simulator
mkdir -p "$ROOT/build/watchos"
xcrun lipo -create "$ROOT/build/watchos-arm64/libdatachannel.a" "$ROOT/build/watchos-arm64_32/libdatachannel.a" "$ROOT/build/watchos-armv7k/libdatachannel.a" -output "$ROOT/build/watchos/libdatachannel.a"
