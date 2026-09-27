#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
version=v0.24.0
if [ ! -d libdatachannel ]; then
  git clone --branch "$version" --depth 1 https://github.com/paullouisageneau/libdatachannel.git libdatachannel
fi
if [ -n "$(git -C libdatachannel status --porcelain)" ]; then
  echo "Local changes in libdatachannel; commit or stash them first." >&2
  exit 1
fi
if ! git -C libdatachannel rev-parse --verify "$version^{commit}" >/dev/null 2>&1; then
  git -C libdatachannel fetch --depth 1 origin "refs/tags/$version:refs/tags/$version"
fi
git -C libdatachannel checkout --detach "$version"
git -C libdatachannel submodule update --init --recursive --depth 1
