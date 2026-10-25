#!/usr/bin/env bash
# Replace the message of an earlier commit on the current branch.
#
# usage: scripts/reword.sh <commit> <message-file>
set -eu
c=$(git rev-parse --short "$1")
msg=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
GIT_SEQUENCE_EDITOR="sed -i.bak 's/^pick $c /edit $c /'" git rebase -q -i "$c~1"
git commit -q --amend -F "$msg"
git rebase --continue >/dev/null
