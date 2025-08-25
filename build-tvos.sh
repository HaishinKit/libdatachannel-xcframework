#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

export TVOS_DEPLOYMENT_TARGET=13.0

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/appletvos
BUILD=build/appletvos

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=TVOS\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-appletvos/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-appletvos/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-appletvos/libusrsctp.a\
  $BUILD/deps/libjuice/Release-appletvos/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/appletvsimulator
BUILD=build/appletvsimulator

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=SIMULATORARM64_TVOS\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-appletvsimulator/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-appletvsimulator/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-appletvsimulator/libusrsctp.a\
  $BUILD/deps/libjuice/Release-appletvsimulator/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a
