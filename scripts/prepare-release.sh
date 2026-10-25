#!/usr/bin/env bash
# Create the release commit for one line, the way upstream Node.js does:
# bump src/node_version.h, replace REPLACEME tags in doc/api, add the
# changelog entry (generated from the commits since the last release) and
# link it from CHANGELOG.md.
#
# usage: scripts/prepare-release.sh <v18|v20> <version> [date]
#   e.g. scripts/prepare-release.sh v20 20.20.3
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
line=${1:?usage: prepare-release.sh <line> <version> [date]}
version=${2:?missing version}
version=${version#v}
date=${3:-$(date +%Y-%m-%d)}
dir=$(work_dir "$line")

cd "$dir"
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  echo "error: $dir has uncommitted changes" >&2
  exit 1
fi
# Changelog covers everything since the previous release on this branch.
prev=$(git describe --tags --abbrev=0 --match "v${version%%.*}.*" 2>/dev/null || base_tag "$line")

python3 - "$version" "$date" "$prev" <<'EOF'
import re, subprocess, sys
version, date, prev = sys.argv[1:4]
major, minor, patch = version.split('.')

def read(p): return open(p, encoding='utf-8').read()
def write(p, s): open(p, 'w', encoding='utf-8').write(s)
def define(text, name): return re.search(r'#define\s+%s\s+(.*)' % name, text).group(1)

# 1. Version header.
vh = read('src/node_version.h')
assert define(vh, 'NODE_MAJOR_VERSION') == major and define(vh, 'NODE_MINOR_VERSION') == minor
vh = re.sub(r'(#define NODE_PATCH_VERSION) \d+', r'\g<1> ' + patch, vh)
vh = re.sub(r'(#define NODE_VERSION_IS_RELEASE) \d', r'\g<1> 1', vh)
write('src/node_version.h', vh)
codename = define(vh, 'NODE_VERSION_LTS_CODENAME').strip('"')

# 2. REPLACEME tags in the API docs.
import glob
for p in glob.glob('doc/api/*.md'):
    s = read(p)
    if 'REPLACEME' in s:
        write(p, s.replace('REPLACEME', 'v' + version))

# 3. Changelog entry from the commits since the previous release.
fmt = '%H%x00%h%x00%s%x00%an%x00%B%x01'
out = subprocess.run(['git', 'log', '--reverse', f'--format={fmt}', f'{prev}..HEAD'],
                     capture_output=True, text=True, check=True).stdout
commits, notable = [], []
for rec in filter(str.strip, out.split('\x01')):
    full, short, subject, author, body = rec.strip('\n').split('\x00', 4)
    commits.append(f'* \\[`{short}`] - {subject} ({author})')
    cves = sorted(set(re.findall(r'CVE-ID:\s*(CVE-\d{4}-\d+)', body)))
    if cves:
        notable.append(f'* ({", ".join(cves)}) {subject} ({author})')
    elif subject.startswith('deps: update') or subject.startswith('deps: upgrade') \
            or 'blocked public keys' in subject:
        notable.append(f'* {subject} ({author})')

cl_path = f'doc/changelogs/CHANGELOG_V{major}.md'
cl = read(cl_path)
entry = f'''<a id="{version}"></a>

## {date}, Version {version} '{codename}' (LTS), @nodejs-eol-support

This is an unofficial security release made after the upstream end-of-life
of Node.js {major}. It contains backports of the fixes from the Node.js
security releases published since then, and security-relevant dependency
updates. It is not built or endorsed by the Node.js project.

### Notable Changes

{chr(10).join(notable)}

### Commits

{chr(10).join(commits)}

'''
first_link = re.search(r'<a href="#\d+\.\d+\.\d+">', cl)
cl = cl[:first_link.start()] + f'<a href="#{version}">{version}</a><br/>\n' + cl[first_link.start():]
first_anchor = re.search(r'<a id="\d+\.\d+\.\d+"></a>', cl)
cl = cl[:first_anchor.start()] + entry + cl[first_anchor.start():]
write(cl_path, cl)

# 4. Main CHANGELOG.md: new bold entry, previous one no longer bold.
main = read('CHANGELOG.md')
m = re.search(r'<b><a href="%s#(\d+\.\d+\.\d+)">\1</a></b><br/>\n' % re.escape(cl_path), main)
old = m.group(1)
main = main.replace(m.group(0),
    f'<b><a href="{cl_path}#{version}">{version}</a></b><br/>\n'
    f'<a href="{cl_path}#{old}">{old}</a><br/>\n', 1)
write('CHANGELOG.md', main)
print(f'release {version} ({codename}): {len(commits)} commits, {len(notable)} notable')
EOF

git add -A src/node_version.h doc CHANGELOG.md
git commit -q -m "$date, Version $version '$(sed -n 's/^#define NODE_VERSION_LTS_CODENAME "\(.*\)"/\1/p' src/node_version.h)' (LTS)

Unofficial security release for Node.js ${version%%.*} after its upstream
end-of-life. See doc/changelogs/CHANGELOG_V${version%%.*}.md."
git tag -a "v$version" -m "$date Node.js v$version (unofficial EOL security release)"
echo "Committed and tagged v$version in $dir"
