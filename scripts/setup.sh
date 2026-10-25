#!/usr/bin/env bash
# Clone nodejs/node and create the EOL branches by applying this repository's
# patch series on top of the last upstream tag of each line.
#
# usage: scripts/setup.sh [work-dir]
#   work-dir defaults to $NODE_EOL_WORK or ../nodejs-eol-work and must not
#   contain spaces (the gyp/make build does not support them).
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=${1:-${NODE_EOL_WORK:-$(cd "$ROOT/.." && pwd)/nodejs-eol-work}}
source "$ROOT/scripts/lines.sh"

case "$WORK" in
  *" "*) echo "error: work dir must not contain spaces: $WORK" >&2; exit 1 ;;
esac

mkdir -p "$WORK"
if [ ! -d "$WORK/node.git" ]; then
  git clone --bare --filter=blob:none https://github.com/nodejs/node.git "$WORK/node.git"
fi

for line in "${LINES[@]}"; do
  base=$(base_tag "$line")
  dir="$WORK/$line"
  if [ -d "$dir" ]; then
    echo "$dir exists, skipping"
    continue
  fi
  git -C "$WORK/node.git" worktree add -b "$line.x-eol" "$dir" "$base"
  shopt -s nullglob
  patches=("$ROOT/patches/$line.x/"*.patch)
  if [ ${#patches[@]} -gt 0 ]; then
    git -C "$dir" am --keep-cr --committer-date-is-author-date "${patches[@]}"
  fi
  echo "$line: $(git -C "$dir" rev-list --count "$base..HEAD") patches applied on $base"
done
