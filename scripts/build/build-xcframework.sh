#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

set -euo pipefail
cd "$(dirname "$0")/../.."

rm -rf include
mkdir -p include/libdatachannel
# creating a directory in libdatachannel to address modulemap conflicts.
# seealso:
#   https://github.com/shogo4405/HaishinKit.swift/discussions/1403
#   https://github.com/jessegrosjean/swift-cargo-problem
cp -r libdatachannel/include/rtc include/libdatachannel
cp support/module.modulemap include/libdatachannel/module.modulemap

rm -rf libdatachannel.xcframework
xcodebuild -create-xcframework \
    -library ./build/appletvos/libdatachannel.a -headers include \
    -library ./build/appletvsimulator/libdatachannel.a -headers include \
    -library ./build/iphoneos/libdatachannel.a -headers include \
    -library ./build/iphonesimulator/libdatachannel.a -headers include \
    -library ./build/macosx/libdatachannel.a -headers include \
    -library ./build/macosx_catalyst/libdatachannel.a -headers include \
    -library ./build/visionos/libdatachannel.a -headers include \
    -library ./build/visionsimulator/libdatachannel.a -headers include \
    -library ./build/watchos/libdatachannel.a -headers include \
    -library ./build/watchsimulator/libdatachannel.a -headers include \
    -output libdatachannel.xcframework

bash scripts/build/build-licenses.sh
mkdir -p libdatachannel.xcframework/Licenses
cp LICENSES libdatachannel.xcframework/Licenses/THIRD-PARTY-LICENSES.txt
cat > libdatachannel.xcframework/DEPENDENCIES.json <<'JSON'
{"libdatachannelVersion":"0.24.6","opensslBuildVersion":"3.3.3","opensslPackage":"https://github.com/krzyzanowskim/OpenSSL-Package.git","opensslPackageRange":"3.3.3001..<4.0.0","opensslBundled":false}
JSON
rm -f libdatachannel.xcframework.zip
COPYFILE_DISABLE=1 zip -qry libdatachannel.xcframework.zip libdatachannel.xcframework
swift package compute-checksum libdatachannel.xcframework.zip > libdatachannel.xcframework.zip.sha256
cat libdatachannel.xcframework.zip.sha256

