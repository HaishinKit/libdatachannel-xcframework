#!/bin/bash

# Copyright (c) shogo4405 and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE file in the root directory of this source tree.

if which $(pwd)/libdatachannel >/dev/null; then
  echo ""
else
  git clone git@github.com:paullouisageneau/libdatachannel.git
  pushd libdatachannel
  git checkout refs/tags/v0.24.0
  git submodule update --init --recursive --depth 1
  popd
fi

if which $(pwd)/OpenSSL >/dev/null; then
  echo ""
else
  git clone git@github.com:krzyzanowskim/OpenSSL.git
  pushd OpenSSL
  git checkout refs/tags/3.3.3001
  popd
fi

if which $(pwd)/ios-cmake >/dev/null; then
  echo ""
else
  git clone git@github.com:leetal/ios-cmake.git
  pushd ios-cmake
  git checkout refs/tags/4.5.0
  popd
fi

