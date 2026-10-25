#!/usr/bin/env bash
# Check where every commit of an EOL branch comes from.
#
# For each commit it finds the upstream nodejs/node commit it was cherry-picked
# from (the outermost "(cherry picked from commit …)" reference that is not one
# of this project's own commits) and compares the two changes:
#
#   IDENTICAL  the change is byte-for-byte the upstream change (same patch-id)
#   ADAPTED    backported with modifications; use --diff to see exactly what
#              differs from upstream (git range-diff). Hand-ported commits
#              explain why in a Backport-Notes: trailer.
#   PROJECT    no upstream commit (dependency syncs, toolchain fixes, release
#              commits); the commit message explains the source.
#
# usage: scripts/verify-provenance.sh <v18|v20> [--diff] [commit-ish]
#   --diff       also print the range-diff for every ADAPTED commit
#   commit-ish   only check this commit
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
line=${1:?usage: verify-provenance.sh <v18|v20> [--diff] [commit]}
shift
show_diff=0
only=
for arg in "$@"; do
  case "$arg" in
    --diff) show_diff=1 ;;
    *) only=$arg ;;
  esac
done

dir=$(work_dir "$line")
base=$(base_tag "$line")
cd "$dir"

# Commits that belong to this project (any line), so references between the
# EOL branches are not mistaken for upstream sources.
ours=$(mktemp)
trap 'rm -f "$ours"' EXIT
for l in "${LINES[@]}"; do
  b=$(base_tag "$l")
  git rev-list "$b..$l.x-eol" 2>/dev/null || true
done | sort -u > "$ours"

patch_id() { git show "$1" | git patch-id --stable | cut -d' ' -f1; }

if [ -n "$only" ]; then
  commits=$(git rev-parse "$only^{commit}")
else
  commits=$(git rev-list --reverse "$base..HEAD")
fi

identical=0 adapted=0 project=0
for c in $commits; do
  subject=$(git log -1 --format=%s "$c")
  upstream=
  via=
  for ref in $(git log -1 --format=%B "$c" |
               sed -n 's/.*(cherry picked from commit \([0-9a-f]\{40\}\)).*/\1/p'); do
    if grep -qx "$ref" "$ours"; then
      via=$ref
    elif git cat-file -e "$ref^{commit}" 2>/dev/null; then
      upstream=$ref   # keep the last (outermost) upstream reference
    fi
  done

  short=$(git rev-parse --short "$c")
  if [ -z "$upstream" ]; then
    project=$((project + 1))
    printf 'PROJECT    %s %s\n' "$short" "$subject"
    continue
  fi

  up=$(git rev-parse --short "$upstream")
  extra=${via:+ (via $(git rev-parse --short "$via"))}
  if [ "$(patch_id "$c")" = "$(patch_id "$upstream")" ]; then
    identical=$((identical + 1))
    printf 'IDENTICAL  %s %s  <- upstream %s%s\n' "$short" "$subject" "$up" "$extra"
  else
    adapted=$((adapted + 1))
    notes=$(git log -1 --format=%B "$c" | grep -q '^Backport-Notes:' && echo ' [Backport-Notes]' || true)
    printf 'ADAPTED    %s %s  <- upstream %s%s%s\n' "$short" "$subject" "$up" "$extra" "$notes"
    if [ "$show_diff" = 1 ]; then
      git range-diff --no-color "$upstream^!" "$c^!" | sed 's/^/           /'
    fi
  fi
done

echo
echo "$line: $identical identical, $adapted adapted, $project project commits"
