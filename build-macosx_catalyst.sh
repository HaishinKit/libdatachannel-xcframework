#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/macosx_catalyst
BUILD=build/macosx_catalyst

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=MAC_CATALYST_ARM64\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES

pbxproj="$BUILD/libdatachannel.xcodeproj/project.pbxproj"
if grep -q "MACOSX_DEPLOYMENT_TARGET" "$pbxproj"; then
    sed -i '' 's/MACOSX_DEPLOYMENT_TARGET = [0-9.]*/IPHONEOS_DEPLOYMENT_TARGET = 14.0/g' "$pbxproj"
fi

xcodebuild \
  -project $BUILD/libdatachannel.xcodeproj \
  -scheme datachannel \
  -configuration Release \
  -destination "generic/platform=macOS,variant=Mac Catalyst,name=Any Mac"

libtool -static -o $BUILD/libdatachannel-all.a\
  $BUILD/Release/libdatachannel.a\
  $BUILD/deps/libsrtp/Release/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release/libusrsctp.a\
  $BUILD/deps/libjuice/Release/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a

lipo $BUILD/libdatachannel-all.a -thin arm64 -output $BUILD/libdatachannel.a 
