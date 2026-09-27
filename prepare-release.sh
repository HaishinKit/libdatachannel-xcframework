#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
python3 scripts/release-manifest.py "${1:?Provide the libdatachannel release-assets base URL}"
