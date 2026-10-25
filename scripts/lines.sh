# Release lines maintained by this project. Sourced by the other scripts.
LINES=(v18 v20)

base_tag() {
  case "$1" in
    v18) echo v18.20.8 ;;
    v20) echo v20.20.2 ;;
    *) echo "unknown line: $1" >&2; return 1 ;;
  esac
}

work_dir() {
  local root
  root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
  echo "${NODE_EOL_WORK:-$(cd "$root/.." && pwd)/nodejs-eol-work}/$1"
}
