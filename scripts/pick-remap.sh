#!/usr/bin/env bash
# Apply an upstream commit whose files were moved between release lines,
# rewriting paths first, then commit it with the original author/message and
# a cherry-pick provenance line.
#
# usage: scripts/pick-remap.sh <commit> [from=to ...]
#   default mappings cover the lib/internal/tls/* move that happened in v22.
set -eu
c=$1; shift
maps=("$@")
if [ ${#maps[@]} -eq 0 ]; then
  maps=(
    "lib/internal/tls/wrap.js=lib/_tls_wrap.js"
    "lib/internal/tls/common.js=lib/_tls_common.js"
  )
fi
sedexpr=()
for m in "${maps[@]}"; do
  sedexpr+=(-e "s#${m%%=*}#${m#*=}#g")
done

full=$(git rev-parse "$c")
git format-patch -1 --stdout "$full" | sed "${sedexpr[@]}" > "$(git rev-parse --git-dir)/remap.patch"
if ! git am -3 --keep-cr "$(git rev-parse --git-dir)/remap.patch"; then
  echo "FAIL  $c (resolve, 'git am --continue', then amend in: (cherry picked from commit $full))"
  exit 1
fi
msg=$(git log -1 --format=%B)
git commit --amend -q -m "$msg

(cherry picked from commit $full)"
echo "OK    $c $(git log -1 --format=%s)"
