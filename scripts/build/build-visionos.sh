#!/bin/bash
source "$(dirname "$0")/build-common.sh"

build_datachannel visionos xros visionOS 1.3 arm64-apple-xros1.3
build_datachannel visionsimulator xrsimulator visionOS 1.3 arm64-apple-xros1.3-simulator
