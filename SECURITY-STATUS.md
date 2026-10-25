# Security status

Status of every Node.js security release CVE published after each line's
upstream end-of-life, as of the **October 21, 2026** security release.

Legend: **Fixed**: backported in this project. **Upstream**: fixed in an
official release before EOL. **N/A**: the line does not contain the
affected code (the reason is given). **In progress**: being worked on.

## Node.js 18.x (EOL 2025-04-30, last upstream v18.20.8)

### May 14, 2025

| CVE | Severity | Issue | v18 |
|-----|----------|-------|-----|
| CVE-2025-23166 | High | Async crypto operations crash the process on error | Fixed |
| CVE-2025-23167 | Medium | llhttp accepts `\r\n\rX` as end of headers (request smuggling) | Fixed (llhttp 9.4.3) |
| CVE-2025-23165 | Low | Memory leak in `ReadFileUtf8` (Windows) | N/A: binding not present in 18.x |

### July 15, 2025

| CVE | Severity | Issue | v18 |
|-----|----------|-------|-----|
| CVE-2025-27210 | High | Windows device names bypass `path.normalize()` traversal protection | Fixed |
| CVE-2025-27209 | High | V8 rapidhash HashDoS | N/A: 24.x only |

### January 13, 2026

| CVE | Severity | Issue | v18 |
|-----|----------|-------|-----|
| CVE-2025-55131 | High | `Buffer.alloc`/`Uint8Array` not zero-filled after `vm` timeout race | Fixed |
| CVE-2025-59465 | High | HTTP/2 server crash on malformed HEADERS (TLSSocket error handler) | Fixed |
| CVE-2025-59466 | Medium | Uncatchable stack overflow via `async_hooks` | Fixed |
| CVE-2026-21637 | Medium | TLS PSK/ALPN callback exceptions bypass error handlers | Fixed |
| CVE-2025-55130 | High | Permission model symlink bypass | N/A: no permission model in 18.x |
| CVE-2025-55132 | Low | `fs.futimes()` permission bypass | N/A: no permission model in 18.x |
| CVE-2025-59464 | Medium | TLS client certificate memory leak | N/A: 24.x only |
| CVE-2026-21636 | Medium | Permission model UDS bypass | N/A: 25.x only |
| deps | | c-ares 1.34.6, undici 6.23.0 | Superseded by c-ares 1.34.9, undici 6.29.1 |

### March 24, 2026

| CVE | Severity | Issue | v18 |
|-----|----------|-------|-----|
| CVE-2026-21637 (incomplete fix) | High | `SNICallback` exceptions crash the process | Fixed |
| CVE-2026-21710 | High | `__proto__` header crashes `headersDistinct` | Fixed |
| CVE-2026-21713 | Medium | Timing side channel in WebCrypto HMAC verify | Fixed |
| CVE-2026-21714 | Medium | HTTP/2 `WINDOW_UPDATE` on stream 0 memory leak | Fixed |
| CVE-2026-21717 | Medium | V8 array index HashDoS | Fixed (V8 10.2 backport of seeded array index hash) |
| CVE-2026-21711 | Medium | Permission model UDS bypass | N/A: 25.x only |
| CVE-2026-21712 | Medium | Assertion in `node_url.cc` | N/A: 24.x/25.x only |
| CVE-2026-21715 | Low | `realpathSync.native` permission bypass | N/A: no permission model in 18.x |
| CVE-2026-21716 | Low | `FileHandle.chmod/chown` permission bypass | N/A: no permission model in 18.x |

## Node.js 18.x and 20.x (20.x EOL 2026-04-30, last upstream v20.20.2)

Items from the March 2026 release and earlier are **Upstream** for 20.x.

### June 18, 2026

| CVE | Severity | Issue | v20 | v18 |
|-----|----------|-------|-----|-----|
| CVE-2026-48933 | High | WebCrypto AES integer overflow aborts the process | Fixed | Fixed |
| CVE-2026-48618 | High | TLS wildcard-depth bypass via Unicode dot separators | Fixed | Fixed |
| CVE-2026-48619 | Medium | Unbounded HTTP/2 ORIGIN set | Fixed | Fixed |
| CVE-2026-48937 | Medium | HTTP/2 session not torn down after internal GOAWAY | Fixed (nghttp2 1.69.0) | Fixed (nghttp2 1.69.0) |
| CVE-2026-48928 | Medium | Case-sensitive SNI context matching bypasses mTLS | Fixed | Fixed |
| CVE-2026-48930 | Medium | Embedded NUL in hostnames truncates resolver input | Fixed | Fixed |
| CVE-2026-48934 | Medium | TLS session reuse skips host identity verification | Fixed | Fixed |
| CVE-2026-48931 | Low | `http.Agent` response queue poisoning | Fixed | Fixed |
| CVE-2026-48617 | Low | Permission model bypass via `process.report.writeReport()` | Fixed | N/A: no permission model |
| CVE-2026-48935 | Low | Permission model bypass via `FileHandle.utimes()` | Fixed | N/A: no permission model |
| CVE-2026-48615 | Medium | Proxy credentials in `ERR_PROXY_TUNNEL` | N/A: no built-in HTTP proxy support | N/A |
| CVE-2026-48936 | Low | UDS permission bypass | N/A: 26.x only | N/A |

### July 29, 2026

| CVE | Severity | Issue | v20 | v18 |
|-----|----------|-------|-----|-----|
| CVE-2026-56846 | High | HTTP/2 retained headers bypass `maxSessionMemory` | Fixed | Fixed |
| CVE-2026-56848 | High | HTTP/2 re-entrant send heap use-after-free | Fixed | Fixed |
| CVE-2026-56850 | Medium | HTTPS Agent reuses mTLS identity across PFX arrays | Fixed | Fixed |
| CVE-2026-58040 | Medium | HTTPS Agent session reuse skips hostname verification | Fixed | Fixed |
| CVE-2026-58042 | Medium | `dns.resolveAny()` abort on >256 A records | Fixed | Fixed |
| CVE-2026-58045 | Medium | `zlib` sync APIs crash on spoofed TypedArray length | Fixed | Fixed |
| CVE-2026-58044 | Low | Headers beyond `maxHeadersCount` still used for framing | Fixed | Fixed |
| CVE-2026-58043 | High | Permission model radix tree over-grant | Fixed | N/A: no permission model |
| CVE-2026-56847 | Low | Trace events write outside `--allow-fs-write` | Fixed | N/A: no permission model |
| CVE-2026-58039 | Low | Process reports write outside `--allow-fs-write` | Fixed | N/A: no permission model |
| CVE-2026-58041 | Medium | `node:sqlite` iterator replay | N/A: no `node:sqlite` | N/A |

### October 21, 2026

| CVE | Severity | Issue | v20 | v18 |
|-----|----------|-------|-----|-----|
| CVE-2026-111497 | High | Brotli decoder out-of-bounds write | Fixed | Fixed |
| CVE-2026-105482 | High | `dns.resolve*()`/`reverse()` truncate names at NUL | Fixed | Fixed |
| CVE-2026-106069 | High | TLS hostname bypass with leading-zero IPv4 | Fixed | Fixed |
| CVE-2026-106072 | Medium | DNS SAN matches non-canonical IPv4 spellings | Fixed (same change as CVE-2026-106069) | Fixed |
| CVE-2026-105481 | Medium | Keep-alive socket accepts response sent before request | Fixed | Fixed |
| CVE-2026-106074 | Medium | Random caches persisted into startup snapshots | Fixed | Fixed |
| CVE-2026-106073 | Low | `fs.realpathSync()` permission bypass | Fixed | N/A: no permission model |
| CVE-2026-105483 | High | TLS bypass with fullwidth-digit IPs | N/A: 24.x/26.x regression; rejected by the non-canonical IP check | N/A |
| CVE-2026-106070 | Low | `zlib.ZipFile` prefix bytes | N/A: 26.x only | N/A |
| CVE-2026-106071 | Low | Wildcard permission over-grant | N/A: 26.x only | N/A |

## Dependency and hardening updates

| Item | v20 | v18 |
|------|-----|-----|
| llhttp | 9.3.1 → 9.4.3 | 6.1.1 → 9.4.3 |
| nghttp2 | 1.61.0 → 1.69.0 (HTTP/2 priority signaling removed, DEP0194) | 1.61.0 → 1.69.0 (same) |
| c-ares | 1.34.6 → 1.34.9 | 1.29.0 → 1.34.9 |
| undici | 6.24.1 → 6.29.1 | 5.29.0 → 6.29.1 |
| OpenSSL | 3.0.19 → 3.0.22 | quictls 3.0.16 → 3.0.22 |
| Root certificates | NSS 3.119 → 3.131.1 | NSS 3.108 → 3.131.1 |
| Compromised eMudhra intermediates | SPKI blocklist | SPKI blocklist |
| HTTP/2 rst_stream use-after-free (nodejs/node#64113) | Fixed | Fixed |
| zlib `reset()` during write use-after-free | Fixed | Fixed |
| `TextEncoder#encodeInto` capacity overflow | Fixed | Fixed |
| HTTP keep-alive socket reuse race, HTTP/2 `respondWithFile` FileHandle leak, URL setter crash | Fixed | Fixed |
| 20.x fixes made after 18.x EOL: DNS parse memory leak, DNS task-creation crash, `os.networkInterfaces()` leak, HTTP/2 ping-length crash, HTTP/2 frame-type check, `initialWindowSize` validation, `require.resolve()` crash, null dereference | Upstream | Fixed |

## Known gaps

- **OpenSSL 3.0 is end-of-life upstream** (2026-09-07). 3.0.22 is the last
  public release. The September 29, 2026 OpenSSL advisories that affect
  3.0 (CVE-2026-84782 DTLS, CVE-2026-54872/-77696 timing, CVE-2026-75805
  CMP, CVE-2026-75806 DTLS, CVE-2026-35189 CRL) were fixed only in the
  premium-only 3.0.23. Node.js does not expose DTLS, CMP or CMS, but the
  timing issues for non-NIST curves and SM2 may be reachable. Moving these
  lines to OpenSSL 3.5 LTS, as 22.x did, is the long-term fix.
- **V8**: only V8 issues that the Node.js project classified as Node.js
  CVEs are tracked. General V8/Chromium security fixes after each line's
  EOL are not backported.
