#!/bin/bash
source "$(dirname "$0")/build-common.sh"

build_datachannel iphoneos iphoneos iOS 13.0 arm64-apple-ios13.0
build_datachannel iphonesimulator iphonesimulator iOS 14.0 arm64-apple-ios14.0-simulator
