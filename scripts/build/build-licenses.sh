#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 scripts/source-distribution.py package
