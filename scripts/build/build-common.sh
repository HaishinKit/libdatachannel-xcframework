#!/bin/bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
ROOT=$(pwd)
CMAKE=${CMAKE:-cmake}

build_datachannel() {
  local platform=$1 sdk=$2 system=$3 minimum=$4 target=$5 arch=${6:-arm64} output=${7:-$1}
  local dependency="$ROOT/build/dependencies/sdk/$platform"
  local build="$ROOT/build/native/$output"
  if [ ! -f "$dependency/OpenSSL" ]; then
    echo 'Run python3 scripts/prepare-openssl.py first.' >&2
    return 1
  fi
  python3 scripts/source-distribution.py record "$build/source-before.json"
  "$CMAKE" -S "$ROOT/libdatachannel" -B "$build" \
    -DCMAKE_SYSTEM_NAME="$system" \
    -DCMAKE_OSX_SYSROOT="$(xcrun --sdk "$sdk" --show-sdk-path)" \
    -DCMAKE_OSX_ARCHITECTURES="$arch" -DCMAKE_OSX_DEPLOYMENT_TARGET="$minimum" \
    -DCMAKE_C_COMPILER_TARGET="$target" -DCMAKE_CXX_COMPILER_TARGET="$target" \
    -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_SHARED_DEPS_LIBS=OFF \
    -DNO_EXAMPLES=ON -DNO_TESTS=ON -DOPENSSL_USE_STATIC_LIBS=OFF \
    -DOPENSSL_ROOT_DIR="$dependency" -DOPENSSL_INCLUDE_DIR="$dependency/include" \
    -DOPENSSL_CRYPTO_LIBRARY="$dependency/lib/libcrypto.dylib" \
    -DOPENSSL_SSL_LIBRARY="$dependency/lib/libssl.dylib"
  "$CMAKE" --build "$build" --parallel "${JOBS:-8}" --target datachannel
  mkdir -p "$ROOT/build/$output"
  # Bundle libdatachannel's private transport dependencies, but never OpenSSL.
  xcrun libtool -static -o "$ROOT/build/$output/libdatachannel.a" \
    "$build/libdatachannel.a" "$build/deps/libsrtp/libsrtp2.a" \
    "$build/deps/usrsctp/usrsctplib/libusrsctp.a" "$build/deps/libjuice/libjuice.a"
  python3 scripts/source-distribution.py record "$ROOT/build/$output/SOURCES.json"
  cmp "$build/source-before.json" "$ROOT/build/$output/SOURCES.json"
}
