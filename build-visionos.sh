#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

export XROS_DEPLOYMENT_TARGET=1.0

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/visionos
BUILD=build/visionos

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=VISIONOS\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-xros/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-xros/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-xros/libusrsctp.a\
  $BUILD/deps/libjuice/Release-xros/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/visionsimulator
BUILD=build/visionsimulator

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=SIMULATOR_VISIONOS\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-xrsimulator/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-xrsimulator/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-xrsimulator/libusrsctp.a\
  $BUILD/deps/libjuice/Release-xrsimulator/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a
