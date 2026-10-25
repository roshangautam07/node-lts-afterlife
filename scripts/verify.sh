#!/usr/bin/env bash
# Verify an installed build against the regression tests that came with the
# backported security fixes (every test file touched by a commit in this
# project's patch series), plus the bundled dependency versions.
#
# usage: scripts/verify.sh <v18|v20> [path/to/node]
#   path/to/node defaults to the active `node` on PATH (e.g. after `nvm use`).
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
line=${1:?usage: verify.sh <v18|v20> [node]}
node=${2:-$(command -v node)}
dir=$(work_dir "$line")
base=$(base_tag "$line")

PY=${PYTHON:-}
for c in python3.11 python3.10 python3.9 python3.8 /usr/bin/python3; do
  [ -n "$PY" ] && break
  command -v "$c" >/dev/null && "$c" -c 'import plistlib' 2>/dev/null && PY=$(command -v "$c")
done

echo "== Binary: $node"
"$node" -p '[
  `version  ${process.version}`,
  `openssl  ${process.versions.openssl}   (expected 3.0.22)`,
  `llhttp   ${process.versions.llhttp}    (expected 9.4.3)`,
  `nghttp2  ${process.versions.nghttp2}   (expected 1.69.0)`,
  `c-ares   ${process.versions.ares}   (expected 1.34.9)`,
  `undici   ${process.versions.undici}   (expected 6.29.1)`,
].join("\n")'

cd "$dir"
tests=$(git diff --name-only --diff-filter=AM "$base" HEAD -- \
          'test/parallel/test-*.js' 'test/pummel/test-*.js' 'test/sequential/test-*.js' \
        | sed -E 's#^test/##; s#\.js$##' | sort -u)
echo
echo "== Running $(echo "$tests" | wc -l | tr -d ' ') regression tests from the $line patch series"
# shellcheck disable=SC2086
"$PY" tools/test.py -j"${JOBS:-4}" --shell="$node" $tests
