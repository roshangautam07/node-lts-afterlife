#!/usr/bin/env bash
# Shallow-clone the upstream tag for a line and apply this repository's patch
# series on top, producing a clean git tree that `make binary` accepts.
#
# usage: scripts/ci-checkout.sh <v18|v20> <dir>
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
line=${1:?usage: ci-checkout.sh <line> <dir>}
dir=${2:?missing dir}
base=$(base_tag "$line")

git clone --quiet --depth 1 --branch "$base" https://github.com/nodejs/node.git "$dir"
git -C "$dir" -c user.name=ci -c user.email=ci@localhost \
  am --quiet --keep-cr "$ROOT/patches/$line.x/"*.patch
git -C "$dir" log --oneline -1
grep -E 'define NODE_(MAJOR|MINOR|PATCH)_VERSION ' "$dir/src/node_version.h"
