#!/usr/bin/env python3
"""Exercise manifest switching and reject mismatched release artifacts without publishing."""
import hashlib
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
script = root / 'scripts/release-manifest.py'
with tempfile.TemporaryDirectory() as name:
    work = Path(name)
    (work / 'support').mkdir()
    template = (root / 'support/Package.swift').read_text()
    (work / 'support/Package.swift').write_text(template)
    archive = work / 'libdatachannel.xcframework.zip'
    archive.write_bytes(b'release fixture')
    def run(*args, succeeds=True):
        result = subprocess.run(['python3', str(script), *args], cwd=work,
                                capture_output=True, text=True)
        assert (result.returncode == 0) == succeeds, result.stdout + result.stderr
    run('local')
    run('check-local')
    run('release', '../invalid', succeeds=False)
    assert (work / 'Package.swift').read_text() == template
    run('release', 'v0.24.6')
    manifest = (work / 'Package.swift').read_text()
    assert '/releases/download/v0.24.6/libdatachannel.xcframework.zip' in manifest
    assert hashlib.sha256(archive.read_bytes()).hexdigest() in manifest
    assert '.product(name: "OpenSSL", package: "OpenSSL-Package")' in manifest
    assert manifest == (work / 'dist/Package.swift').read_text()
    run('check', 'v0.24.6')
    run('check-local', succeeds=False)
    run('check', 'v0.24.7', succeeds=False)
    archive.write_bytes(b'changed artifact')
    run('check', 'v0.24.6', succeeds=False)
    run('release', 'v0.24.6')
    checksum = work / 'libdatachannel.xcframework.zip.sha256'
    checksum.write_text('incorrect\n')
    run('check', 'v0.24.6', succeeds=False)
    run('local')
    assert (work / 'Package.swift').read_text() == template
print('Manifest switching, tag validation, and stale artifact rejection passed; nothing published.')

# Replace Git/GitHub commands inside an isolated fixture: no network or release creation.
import os
import shutil
with tempfile.TemporaryDirectory() as name:
    work = Path(name)
    for directory in ['scripts', 'support', 'bin']:
        (work / directory).mkdir()
    shutil.copyfile(root / 'build.sh', work / 'build.sh')
    shutil.copyfile(script, work / 'scripts/release-manifest.py')
    shutil.copyfile(root / 'support/Package.swift', work / 'support/Package.swift')
    (work / 'libdatachannel.xcframework.zip').write_bytes(b'publish fixture')
    subprocess.run(['bash', 'build.sh', 'release', 'v0.24.6'], cwd=work, check=True,
                   stdout=subprocess.DEVNULL)
    (work / 'scripts/source-distribution.py').write_text('# Source validation is covered separately.\n')
    git = work / 'bin/git'
    git.write_text('''#!/bin/bash
case "$1" in
 status) if [ "${CASE:-}" = dirty ]; then echo ' M README.md'; fi ;;
 rev-parse) if [ "$2" != HEAD ] && [ "${CASE:-}" = tag ]; then echo other; else echo commit; fi ;;
 ls-remote) if [ "${CASE:-}" != remote ]; then printf 'commit\\trefs/tags/v0.24.6\\n'; fi ;;
 *) exit 98 ;;
esac
''')
    gh = work / 'bin/gh'
    gh.write_text('#!/bin/bash\nprintf "%s\\n" "$@" > gh-arguments\n')
    git.chmod(0o755); gh.chmod(0o755)
    for case in ['dirty', 'tag', 'remote', 'ok']:
        environment = dict(os.environ, PATH=str(work / 'bin') + os.pathsep + os.environ['PATH'], CASE=case)
        result = subprocess.run(['bash', 'build.sh', 'publish', 'v0.24.6'], cwd=work,
                                env=environment, capture_output=True, text=True)
        assert (result.returncode == 0) == (case == 'ok'), result.stdout + result.stderr
        assert (work / 'gh-arguments').exists() == (case == 'ok')
    args = (work / 'gh-arguments').read_text().splitlines()
    assert args[:3] == ['release', 'create', 'v0.24.6']
    assert '--verify-tag' in args
    assert args[-7:] == ['libdatachannel.xcframework.zip', 'libdatachannel.xcframework.zip.sha256',
        'dist/licensing/THIRD-PARTY-LICENSES.txt', 'dist/licensing/SOURCE-NOTICE.txt',
        'dist/licensing/SOURCES.json', 'dist/licensing/libdatachannel-sources.zip', 'dist/licensing/SHA256SUMS.json']
print('Publish preflight and upload arguments verified with isolated Git/GitHub stubs.')
