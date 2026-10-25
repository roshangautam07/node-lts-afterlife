#!/usr/bin/env bash
# Configure and build one release line.
#
# usage: scripts/build.sh <v18|v20> [extra configure args...]
#   JOBS defaults to the number of CPUs. Output: <work-dir>/<line>/out/Release/node
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
line=${1:?usage: build.sh <line>}; shift
dir=$(work_dir "$line")
JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN)}

cd "$dir"
python3 configure.py "$@"
make -j"$JOBS"
out/Release/node -p '`${process.version} ${process.versions.openssl} llhttp ${process.versions.llhttp} nghttp2 ${process.versions.nghttp2}`'
