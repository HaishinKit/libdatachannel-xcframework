#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.


export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/watchos
BUILD=build/watchos

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=WATCHOS\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-watchos/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-watchos/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-watchos/libusrsctp.a\
  $BUILD/deps/libjuice/Release-watchos/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/watchsimulator
BUILD=build/watchsimulator

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=SIMULATOR_WATCHOS\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-watchsimulator/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-watchsimulator/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-watchsimulator/libusrsctp.a\
  $BUILD/deps/libjuice/Release-watchsimulator/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a
