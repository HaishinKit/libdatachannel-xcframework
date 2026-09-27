"""Package clean, exact Git sources and notices alongside the binary distribution."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'libdatachannel'
OUT = ROOT / 'dist/licensing'
COMPONENTS = [
    ('libdatachannel', '.', 'https://github.com/paullouisageneau/libdatachannel', 'MPL-2.0', 'LICENSE'),
    ('libjuice', 'deps/libjuice', 'https://github.com/paullouisageneau/libjuice', 'MPL-2.0', 'LICENSE'),
    ('libSRTP', 'deps/libsrtp', 'https://github.com/cisco/libsrtp', 'BSD-3-Clause', 'LICENSE'),
    ('usrsctp', 'deps/usrsctp', 'https://github.com/paullouisageneau/usrsctp', 'BSD-3-Clause', 'LICENSE.md'),
    ('plog', 'deps/plog', 'https://github.com/SergiusTheBest/plog', 'MIT', 'LICENSE'),
    ('nlohmann/json', 'deps/json', 'https://github.com/nlohmann/json', 'MIT', 'LICENSE.MIT'),
]
OUTPUTS = ['THIRD-PARTY-LICENSES.txt', 'SOURCE-NOTICE.txt', 'SOURCES.json', 'libdatachannel-sources.zip']
BUILDS = ['iphoneos', 'iphonesimulator', 'appletvos', 'appletvsimulator', 'macosx',
          'macosx_catalyst', 'visionos', 'visionsimulator', 'watchos-arm64',
          'watchos-arm64_32', 'watchos-armv7k', 'watchsimulator']


def git(directory, *args):
    return subprocess.check_output(['git', '-C', str(directory), *args])


def snapshot():
    status = git(SOURCE, 'submodule', 'status', '--recursive').decode().splitlines()
    if any(not line.startswith(' ') for line in status):
        raise SystemExit('Initialize submodules at their pinned commits before distributing.')
    expected = {p for _, p, _, _, _ in COMPONENTS if p != '.'}
    if {line.split()[1] for line in status} != expected:
        raise SystemExit('Submodule inventory changed; update the source/license inventory.')
    result = []
    for name, path, url, license_id, license_file in COMPONENTS:
        repo = SOURCE / path
        if git(repo, 'status', '--porcelain').strip():
            raise SystemExit(f'Cannot claim unmodified sources: {repo} has local changes.')
        commit = git(repo, 'rev-parse', 'HEAD').decode().strip()
        tags = git(repo, 'tag', '--points-at', 'HEAD').decode().splitlines()
        result.append(dict(name=name, path=path, version=tags[0] if tags else commit,
                           commit=commit, sourceURL=f'{url}/tree/{commit}',
                           license=license_id, licenseFile=license_file, modified=False))
    return result


def package():
    records = snapshot()
    for name in BUILDS:
        stamp = ROOT / 'build' / name / 'SOURCES.json'
        if not stamp.exists() or json.loads(stamp.read_text()) != records:
            raise SystemExit(f'Source record missing/stale for {name}; run ./build.sh build.')
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT/'SOURCES.json').write_text(json.dumps(records, indent=2) + '\n')
    licenses = []
    notice = ['Source availability and third-party notices', '',
              'This distribution contains libdatachannel and the components listed below.',
              'The MPL-2.0 source for libdatachannel and libjuice is available under MPL-2.0.',
              'Obtain the exact source from the commit URLs below or libdatachannel-sources.zip',
              'attached to the same GitHub Release as this XCFramework:',
              'https://github.com/HaishinKit/libdatachannel-xcframework/releases',
              'The source ZIP includes all pinned submodules, original notices and upstream build files.',
              'No upstream source modifications were made for this distribution.', '']
    for r in records:
        licenses.append(f"\n{'='*72}\n{r['name']} | {r['version']} | {r['license']}\n{r['sourceURL']}\n{'='*72}\n" +
                        (SOURCE/r['path']/r['licenseFile']).read_text())
        notice += [f"{r['name']} ({r['license']})", f"Version/revision: {r['version']}",
                   f"Commit: {r['commit']}", f"Source: {r['sourceURL']}", 'Local modifications: none', '']
    notice += ['OpenSSL is a separate runtime dependency, not embedded in this source/binary archive.',
               'OpenSSL-Package: https://github.com/krzyzanowskim/OpenSSL-Package',
               'OpenSSL license: https://www.openssl.org/source/license.html',
               'App distributors must include the license and applicable notices for their actual',
               'resolved OpenSSL version in addition to these bundled-component notices.', '',
               'App redistribution: preserve these license texts and source-availability notices',
               'in the app documentation/resources or an accessible Open Source Licenses screen.',
               'SwiftPM does not automatically copy this XCFramework metadata into your app.', '']
    (OUT/'THIRD-PARTY-LICENSES.txt').write_text('\n'.join(licenses))
    (OUT/'SOURCE-NOTICE.txt').write_text('\n'.join(notice))
    with zipfile.ZipFile(OUT/'libdatachannel-sources.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for r in records:
            prefix = 'libdatachannel/' + (r['path'] + '/' if r['path'] != '.' else '')
            raw = git(SOURCE/r['path'], 'archive', '--format=zip', '--prefix='+prefix, r['commit'])
            with zipfile.ZipFile(io.BytesIO(raw)) as part:
                for entry in part.infolist():
                    if not entry.is_dir():
                        archive.writestr(entry, part.read(entry))
        for name in OUTPUTS[:3]:
            archive.write(OUT/name, 'distribution/'+name)


def check():
    hashes = json.loads((OUT/'SHA256SUMS.json').read_text())
    if set(hashes) != set(OUTPUTS + ['libdatachannel.xcframework.zip']):
        raise SystemExit('Incomplete release source/license inventory.')
    for name, expected in hashes.items():
        p = ROOT/name if name == 'libdatachannel.xcframework.zip' else OUT/name
        if hashlib.sha256(p.read_bytes()).hexdigest() != expected:
            raise SystemExit(f'Release artifact mismatch: {name}; rebuild the package.')
    with zipfile.ZipFile(ROOT/'libdatachannel.xcframework.zip') as archive:
        for name in OUTPUTS[:3]:
            if archive.read('libdatachannel.xcframework/Licenses/'+name) != (OUT/name).read_bytes():
                raise SystemExit(f'XCFramework notice mismatch: {name}')
    print('Source archive, notices and binary ZIP match.')


if __name__ == '__main__':
    mode = sys.argv[1]
    if mode == 'record':
        p = Path(sys.argv[2]); p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(json.dumps(snapshot(), indent=2) + '\n')
    elif mode == 'package':
        package()
    elif mode == 'seal':
        hashes = {name: hashlib.sha256((OUT/name).read_bytes()).hexdigest() for name in OUTPUTS}
        hashes['libdatachannel.xcframework.zip'] = hashlib.sha256((ROOT/'libdatachannel.xcframework.zip').read_bytes()).hexdigest()
        (OUT/'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
        check()
    elif mode == 'check':
        check()
    else:
        raise SystemExit('Use record PATH, package, seal, or check')
