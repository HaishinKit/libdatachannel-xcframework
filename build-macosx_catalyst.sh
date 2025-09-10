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
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release/libdatachannel.a\
  $BUILD/deps/libsrtp/Release/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release/libusrsctp.a\
  $BUILD/deps/libjuice/Release/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a
