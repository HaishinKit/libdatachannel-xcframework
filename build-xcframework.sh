#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

rm -rf include
mkdir -p include/libdatachannel
# creating a directory in libsrt to address modulemap conflicts.
# seealso:
#   https://github.com/shogo4405/HaishinKit.swift/discussions/1403
#   https://github.com/jessegrosjean/swift-cargo-problem
cp -r libdatachannel/include/rtc include/libdatachannel
cp module.modulemap include/libdatachannel/module.modulemap

rm -rf libdatachannel.xcframework
xcodebuild -create-xcframework \
    -library ./build/appletvos/libdatachannel.a -headers include \
    -library ./build/appletvsimulator/libdatachannel.a -headers include \
    -library ./build/iphoneos/libdatachannel.a -headers include \
    -library ./build/iphonesimulator/libdatachannel.a -headers include \
    -library ./build/macosx/libdatachannel.a -headers include \
    -library ./build/visionos/libdatachannel.a -headers include \
    -library ./build/visionsimulator/libdatachannel.a -headers include \
    -output libdatachannel.xcframework

