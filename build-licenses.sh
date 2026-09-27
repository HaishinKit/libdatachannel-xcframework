#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
# Only the components actually bundled in libdatachannel.a are listed here.
: > LICENSES
for file in libdatachannel/LICENSE libdatachannel/deps/libsrtp/LICENSE libdatachannel/deps/usrsctp/LICENSE.md libdatachannel/deps/libjuice/LICENSE libdatachannel/deps/plog/LICENSE libdatachannel/deps/json/LICENSE.MIT; do
  test -f "$file"
  printf '\n========================================================================\n%s\n========================================================================\n' "$file" >> LICENSES
  cat "$file" >> LICENSES
done
