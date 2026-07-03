# heirloom-uucp-darwin

Darwin (macOS 26.4 arm64) port of **Taylor UUCP 1.04** (Ian Lance
Taylor, GNU project).

> **Not authoritative.** Downstream port. See `NOTICE.md`.

## Port status

**PARTIAL**. `./configure` succeeds. Compilation gets further than
scaffold: the shared library (`libuucp.a`) fails at `mkdir.o` /
`dirent.o` in the `unix/` subdirectory, and `unix/cusub.c` hits a
number of function-pointer type mismatches around signal handlers.

**What's working**:
- `./configure` runs to completion.
- `conf.h` patches applied to modernise the auto-detected feature flags
  (Darwin has size_t / time_t / sig_atomic_t / getline / bzero /
  strerror / posix_termios all in the expected system headers).
- `policy.h` patched to select `HAVE_POSIX_TERMIOS 1`.
- Compilation reaches `unix/mkdir.c` and `unix/dirent.c`.

**What's not working**:
- `unix/mkdir.c` provides an old K&R `mkdir()` — conflicts with
  Darwin's system mkdir. Needs to be stubbed out.
- `unix/dirent.c` provides an old `opendir()` — conflicts with
  Darwin's system dirent. Needs to be stubbed out.
- `unix/cusub.c` and `unix/proctab.c` have K&R signal-handler
  prototypes incompatible with modern clang.

Estimated remaining effort: 1-2 days. Realistic to complete.

## Patches so far

- `patches/0001-darwin-conf-h-modernize-HAVE-flags.patch` — sets
  `HAVE_SIG_ATOMIC_T_IN_SIGNAL_H`, `HAVE_SIZE_T_IN_STDDEF_H`,
  `HAVE_TIME_T_IN_TIME_H`, `HAVE_VOID`, `HAVE_UNSIGNED_CHAR`,
  `ANSI_C`, `HAVE_GETLINE`, `HAVE_BZERO`, `HAVE_STRERROR`,
  `HAVE_MKDIR`, `HAVE_OPENDIR`, `HAVE_SETSID`, `HAVE_SETPGRP` to
  their Darwin-correct values. Comments out the fallback
  `PID_T int`, `UID_T int`, `GID_T int`, `OFF_T long` typedefs
  (Darwin already provides these).
- `patches/0002-darwin-policy-h-select-POSIX_TERMIOS.patch` — sets
  `HAVE_POSIX_TERMIOS 1` in `policy.h`.

## Building on Darwin

```sh
git clone https://github.com/moonman81/heirloom-uucp-darwin
cd heirloom-uucp-darwin

# Fetch the upstream tarball from TUHS
mkdir -p vendor
curl -L https://www.tuhs.org/Archive/Applications/TaylorUUCP/uucp-1.04.tar \
    -o vendor/uucp-1.04.tar
cd vendor && tar xf uucp-1.04.tar && cd ..

# Configure + apply patches
cd vendor/uucp-1.04
./configure --prefix=/opt/heirloom
patch -p1 < ../../patches/0001-darwin-conf-h-modernize-HAVE-flags.patch
patch -p1 < ../../patches/0002-darwin-policy-h-select-POSIX_TERMIOS.patch

# Add -std=gnu89 + warning suppression to CFLAGS
sed -i.bak 's|^CFLAGS = |CFLAGS = -std=gnu89 -Wno-int-conversion -Wno-implicit-int -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types |' \
    Makefile lib/Makefile unix/Makefile uuconf/Makefile

# Attempt build — PARTIAL success expected
make 2>&1 | grep 'error:' | head
```

## What Taylor UUCP is

Ian Lance Taylor's GPL-licensed free reimplementation of UUCP (Unix-
to-Unix Copy Protocol). The primary open-source UUCP through the
1990s. Provides:

- `uucp` — copy files between hosts
- `uux` — execute commands on remote hosts
- `uucico` — the UUCP daemon
- `cu` — connect to a modem or remote terminal
- `uustat` — UUCP job status

## Licence

- Taylor UUCP itself: **GPL v2**.
- Darwin port patches (`patches/*.patch`): **zlib**, © 2026 moonman81
  — but AS APPLIED to GPL-licensed source, the patched result is
  covered by GPL. Distribute patches separately if you want them
  under zlib; distribute the patched result under GPL.
- Scaffolding (`README.md`, `NOTICE.md`, etc.): CC-BY-4.0.

## Related repos

- <https://github.com/moonman81/heirloom-ancestors-darwin>
- <https://github.com/moonman81/heirloom-workspace-darwin>
