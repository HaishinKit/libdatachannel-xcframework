#!/bin/bash
source "$(dirname "$0")/build-common.sh"

build_datachannel appletvos appletvos tvOS 13.0 arm64-apple-tvos13.0
build_datachannel appletvsimulator appletvsimulator tvOS 14.0 arm64-apple-tvos14.0-simulator
