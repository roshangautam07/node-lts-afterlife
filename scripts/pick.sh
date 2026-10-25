#!/usr/bin/env bash
# Cherry-pick upstream commits (with -x provenance) onto the current branch,
# stopping at the first conflict so it can be resolved by hand.
#
# usage: scripts/pick.sh <commit>...
set -u
for c in "$@"; do
  subject=$(git log -1 --format=%s "$c")
  if git cherry-pick -x "$c" >/dev/null 2>&1; then
    echo "OK    $c $subject"
  elif git diff --cached --quiet && [ -z "$(git diff --name-only --diff-filter=U)" ]; then
    echo "EMPTY $c $subject (already applied)"
    git cherry-pick --skip >/dev/null 2>&1
  else
    echo "FAIL  $c $subject"
    git diff --name-only --diff-filter=U | sed 's/^/      conflict: /'
    exit 1
  fi
done
