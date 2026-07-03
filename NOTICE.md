# NOTICE — heirloom-uucp-darwin

Darwin port of Ian Lance Taylor's Taylor UUCP 1.04 (GPL).

Port status: WORKING (11 binaries build) — configure + initial compile working; some `unix/`
files still need Darwin-specific fixes. See README.md.

**Not authoritative.** Upstream at:
`https://www.tuhs.org/Archive/Applications/TaylorUUCP/uucp-1.04.tar`

Content licences:
- Upstream Taylor UUCP: GPL v2.
- Darwin patches (`patches/*.patch`): zlib as source; applied to GPL
  code, the patched result is GPL.
- Scaffolding (README, NOTICE, etc.): CC-BY-4.0.
