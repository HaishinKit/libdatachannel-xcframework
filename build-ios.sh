#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/iphoneos
BUILD=build/iphoneos

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=OS64\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-iphoneos/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-iphoneos/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-iphoneos/libusrsctp.a\
  $BUILD/deps/libjuice/Release-iphoneos/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a

export OPENSSL_ROOT_DIR=$(pwd)/OpenSSL/iphonesimulator
BUILD=build/iphonesimulator

cmake libdatachannel\
  -B $BUILD\
  -G Xcode\
  -DCMAKE_TOOLCHAIN_FILE=../ios-cmake/ios.toolchain.cmake\
  -DPLATFORM=SIMULATORARM64\
  -DBUILD_SHARED_LIBS=OFF\
  -DBUILD_SHARED_DEPS_LIBS=OFF\
  -DNO_EXAMPLES=YES\
  -DNO_TESTS=YES
cmake --build $BUILD --config Release

libtool -static -o $BUILD/libdatachannel.a\
  $BUILD/Release-iphonesimulator/libdatachannel.a\
  $BUILD/deps/libsrtp/Release-iphonesimulator/libsrtp2.a\
  $BUILD/deps/usrsctp/usrsctplib/Release-iphonesimulator/libusrsctp.a\
  $BUILD/deps/libjuice/Release-iphonesimulator/libjuice.a\
  $OPENSSL_ROOT_DIR/lib/*.a

