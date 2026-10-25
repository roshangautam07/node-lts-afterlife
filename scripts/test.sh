#!/usr/bin/env bash
# Run the parallel and sequential test suites for one release line.
#
# usage: scripts/test.sh <v18|v20> [test.py args...]
#   Results: <work-dir>/<line>-test.tap
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT/scripts/lines.sh"
line=${1:?usage: test.sh <line>}; shift
dir=$(work_dir "$line")
JOBS=${JOBS:-$(getconf _NPROCESSORS_ONLN)}

cd "$dir"
if [ $# -eq 0 ]; then
  set -- parallel sequential
fi
python3 tools/test.py -j"$JOBS" -p tap --logfile "../$line-test.tap" "$@"
