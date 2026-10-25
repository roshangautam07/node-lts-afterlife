#!/usr/bin/env bash
# Export each line's EOL branch as a patch series into patches/<line>.x/.
#
# usage: scripts/export-patches.sh [line...]
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
[ $# -gt 0 ] && LINES=("$@")

for line in "${LINES[@]}"; do
  dir=$(work_dir "$line")
  out="$ROOT/patches/$line.x"
  rm -rf "$out"
  mkdir -p "$out"
  git -C "$dir" format-patch --quiet --no-signature --zero-commit \
    -o "$out" "$(base_tag "$line")..HEAD"
  echo "$line: $(ls "$out" | wc -l | tr -d ' ') patches -> patches/$line.x/"
done
