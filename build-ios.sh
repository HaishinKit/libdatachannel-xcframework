#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

export IPHONEOS_DEPLOYMENT_TARGET=13.0

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/iphoneos
BUILD=build/iphoneos

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=OS64\
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_BUILD_TYPE=Release\
  -DUSE_GNUTLS=0\
  -DUSE_NICE=0
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-iphoneos/libdatachannel.a\
  $OPENSSL_ROOT_DIR/lib/*.a

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/iphonesimulator
BUILD=build/iphonesimulator

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=SIMULATORARM64\
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_BUILD_TYPE=Release\
  -DUSE_GNUTLS=0\
  -DUSE_NICE=0
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-iphonesimulator/libdatachannel.a\
  $OPENSSL_ROOT_DIR/lib/*.a
