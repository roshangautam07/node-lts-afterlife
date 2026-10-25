# Node.js EOL Support

Unofficial, community security patches for Node.js release lines that have
reached end-of-life upstream.

| Line | Upstream EOL | Last upstream release | This project's branch |
|------|--------------|-----------------------|-----------------------|
| 18.x "Hydrogen" | 2025-04-30 | v18.20.8 | `v18.x-eol` |
| 20.x "Iron"     | 2026-04-30 | v20.20.2 | `v20.x-eol` |

Each branch starts at the last official tag and adds backports of the fixes
from every Node.js security release published after that line's EOL, plus
security-relevant dependency updates. The changes are cherry-picked from the
supported release lines (`v20.x` and `v22.x`) whenever they apply. Each
commit keeps the original author and a `(cherry picked from commit …)`
line. Hand-ported commits also carry a `Backport-Notes:` trailer explaining
how they differ from upstream.

This project is not affiliated with or endorsed by the OpenJS Foundation or
the Node.js project. Upgrading to a supported Node.js release line is always
the better option. This project exists for systems that cannot upgrade yet.

## What is fixed

See [SECURITY-STATUS.md](SECURITY-STATUS.md) for every CVE published since
each line's EOL. For each one it records whether it was fixed (and by which
commit), or why it does not apply.

## Repository layout

```
patches/v18.x/   patch series on top of v18.20.8 (git format-patch output)
patches/v20.x/   patch series on top of v20.20.2
scripts/         helper scripts (setup, build, test, patch export, backporting)
SECURITY-STATUS.md
```

The patch series are the source of truth for releases. They can be applied
to a pristine checkout of the corresponding upstream tag.

## Building

Prerequisites are the same as upstream Node.js for the given line (see
`BUILDING.md` in the source tree). The source path must not contain spaces,
because the gyp/make build does not support them.

```sh
scripts/setup.sh /path/without/spaces   # clone nodejs/node, create both branches from the patches
scripts/build.sh v20                    # configure + make for one line
scripts/test.sh v20                     # parallel + sequential test suites
```

### macOS notes

- If the default `python3` is broken or too new, put a working Python
  (3.9-3.12 for v18, up to 3.14 for v20) first on `PATH`. The gyp helper
  scripts are run through `/usr/bin/env python3`.
- Node.js 18's bundled V8 10.2 needs the toolchain fixes included in the
  v18 patch series to compile with Apple clang 17+.

## Versioning

Releases keep the upstream major/minor and bump the patch number
(`v18.20.9`, `v20.20.3`, …). A pre-release suffix such as `-eol` was not
used, because npm/semver range checks (`engines`) reject pre-release
versions. The release notes and this repository identify the builds as
unofficial.

## Reporting issues

If a fix in this repository is wrong or a published CVE is missing, open
an issue with the CVE ID and the affected line.
