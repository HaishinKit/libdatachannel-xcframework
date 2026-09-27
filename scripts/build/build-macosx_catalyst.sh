#!/bin/bash
source "$(dirname "$0")/build-common.sh"

build_datachannel macosx_catalyst macosx Darwin "" arm64-apple-ios14.0-macabi
