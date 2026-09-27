#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/integration/Sources/SharedSmoke
python3 - <<'PY'
import json
import os
from pathlib import Path
root = Path.cwd()
dependencies = ['.package(path: "../..")']
products = ['.product(name: "libdatachannel", package: "libdatachannel-xcframework")']
source = (root/'tests/smoke.swift').read_text()
if os.environ.get('SRT_PACKAGE_PATH'):
    dependencies += ['.package(name: "libsrt-xcframework", path: ' + json.dumps(str(Path(os.environ['SRT_PACKAGE_PATH']).resolve())) + ')']
    products += ['.product(name: "libsrt", package: "libsrt-xcframework")']
    source += '\nimport libsrt\nprecondition(srt_startup() == 0)\nprecondition(srt_cleanup() == 0)\nprint("SRT and libdatachannel share one OpenSSL package successfully")\n'
if os.environ.get('OPENSSL_PACKAGE_VERSION'):
    dependencies += ['.package(url: "https://github.com/krzyzanowskim/OpenSSL-Package.git", exact: ' + json.dumps(os.environ['OPENSSL_PACKAGE_VERSION']) + ')']
manifest = '// swift-tools-version: 5.9\nimport PackageDescription\nlet package = Package(name: "SharedSmoke", platforms: [.macOS(.v11)], dependencies: [' + ','.join(dependencies) + '], targets: [.executableTarget(name: "SharedSmoke", dependencies: [' + ','.join(products) + '])])\n'
(root/'build/integration/Package.swift').write_text(manifest)
(root/'build/integration/Sources/SharedSmoke/main.swift').write_text(source)
PY
swift run --package-path build/integration SharedSmoke
binary_dir=$(swift build --package-path build/integration --show-bin-path)
python3 - "$binary_dir/SharedSmoke" <<'PY'
import json
from pathlib import Path
import subprocess
import sys
libraries = subprocess.check_output(['xcrun','otool','-L',sys.argv[1]],text=True)
assert sum('OpenSSL.framework/' in line for line in libraries.splitlines()) == 1, libraries
pins = json.loads(Path('build/integration/Package.resolved').read_text())['pins']
assert sum(pin['identity'] == 'openssl-package' for pin in pins) == 1
print('Exactly one resolved OpenSSL package and one dynamic OpenSSL dependency verified.')
PY
