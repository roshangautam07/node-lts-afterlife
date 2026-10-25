#!/usr/bin/env bash
# Build one release line on macOS and install it into nvm under its own
# version (default: last upstream patch + 1, e.g. v20.20.2 -> v20.20.3), so it
# does not replace an official Node.js version that nvm already has.
#
# usage: scripts/install-nvm.sh <v18|v20> [version]
#   then: nvm use <version>
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
line=${1:?usage: install-nvm.sh <v18|v20> [version]}
dir=$(work_dir "$line")
base=$(base_tag "$line")
IFS=. read -r major minor patch <<<"${base#v}"
version=${2:-$major.$minor.$((patch + 1))}
version=${version#v}
IFS=. read -r vmajor vminor vpatch <<<"$version"
if [ "$vmajor.$vminor" != "$major.$minor" ]; then
  echo "error: $line builds $major.$minor.x, not $version" >&2
  exit 1
fi

NVM_DIR=${NVM_DIR:-$HOME/.nvm}
prefix="$NVM_DIR/versions/node/v$version"
if [ -e "$prefix" ]; then
  echo "error: $prefix already exists (remove it or pass another version)" >&2
  exit 1
fi
JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN)}

# Pick a Python this line supports and that actually works (the gyp helpers
# need plistlib/pyexpat). Override with PYTHON=/path/to/python3.
case "$line" in
  v18) candidates="python3.11 python3.10 python3.9 python3.8 /usr/bin/python3" ;;
  *) candidates="python3.13 python3.12 python3.11 python3.10 python3.9 /usr/bin/python3" ;;
esac
PY=${PYTHON:-}
if [ -z "$PY" ]; then
  for c in $candidates; do
    if command -v "$c" >/dev/null && "$c" -c 'import plistlib' 2>/dev/null; then
      PY=$(command -v "$c")
      break
    fi
  done
fi
[ -n "$PY" ] || { echo "error: no working Python found for $line; set PYTHON=" >&2; exit 1; }
# gyp's helper scripts run through `/usr/bin/env python3`, so put the chosen
# interpreter first on PATH as python3.
shim=$(mktemp -d)
ln -s "$PY" "$shim/python3"
ln -s "$PY" "$shim/python"
export PATH="$shim:$PATH"
echo "Using $("$PY" --version) ($PY)"

cd "$dir"
# Stamp the requested patch version for this build only.
cp src/node_version.h src/node_version.h.orig
trap 'mv -f src/node_version.h.orig src/node_version.h; rm -rf "$shim"' EXIT
sed -i '' -E "s/^(#define NODE_PATCH_VERSION) [0-9]+$/\1 $vpatch/" src/node_version.h

# Run configure ourselves: node_version.h is a dependency of config.gypi, and
# letting make re-run ./configure would pick the first python3.X it finds.
"$PY" configure.py
make -j"$JOBS" PYTHON="$PY"
make install PREFIX="$prefix" PYTHON="$PY"

"$prefix/bin/node" -p '`installed ${process.version} (OpenSSL ${process.versions.openssl}) -> ${process.execPath}`'
echo "Run: nvm use $version"
