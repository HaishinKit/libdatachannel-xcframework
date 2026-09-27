import hashlib
import json
from pathlib import Path
import re
import sys

base = sys.argv[1].rstrip('/')
if not base.startswith('https://'):
    raise SystemExit('Release URL must use HTTPS')
checksum = hashlib.sha256(Path('libdatachannel.xcframework.zip').read_bytes()).hexdigest()
manifest = Path('Package.swift').read_text().replace('// Local development manifest. Release manifests are generated separately.\n', '')
manifest, count = re.subn(r'\.binaryTarget\(name: "libdatachannel", (?:path: "[^"]+"|url: "[^"]+", checksum: "[^"]+")\)',
    '.binaryTarget(name: "libdatachannel", url: ' + json.dumps(base + '/libdatachannel.xcframework.zip') + ', checksum: "' + checksum + '")', manifest)
if count != 1:
    raise SystemExit('Expected exactly one libdatachannel binary target')
Path('dist').mkdir(exist_ok=True)
Path('dist/Package.swift').write_text(manifest)
print('Prepared dist/Package.swift; no files were uploaded.')
