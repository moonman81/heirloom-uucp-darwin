# heirloom-uucp-darwin

Darwin (macOS 26.4 arm64) port of **Taylor UUCP 1.04** (Ian Lance
Taylor, GNU project).

> **Not authoritative.** Downstream port. See `NOTICE.md`.

## Port status

**WORKING**. `./configure` succeeds. Compilation gets further than
scaffold: the shared library (`libuucp.a`) fails at `mkdir.o` /
`dirent.o` in the `unix/` subdirectory, and `unix/cusub.c` hits a
number of function-pointer type mismatches around signal handlers.

All 11 core UUCP binaries build to Mach-O 64-bit arm64 on Darwin:

    uucico   400 KB    UUCP daemon
    uucp     182 KB    file copy client
    uux      181 KB    remote command execution
    cu       243 KB    modem/terminal connection
    uustat   201 KB    job status
    uuname   109 KB    remote-node listing
    uuchk    127 KB    config check
    uuconv   165 KB    format conversion
    uulog    136 KB    log viewer
    uupick   158 KB    incoming file picker
    uuxqt    (built)   remote-command daemon

Smoke test:

    ./uuchk -V
    → Taylor UUCP version 1.04, copyright (C) 1991, 1992 Ian Lance Taylor

## Build recipe

`scripts/build.sh` applies all Darwin fixes at once. Run inside
`vendor/uucp-1.04/` after `./configure`:

    cd vendor/uucp-1.04
    ./configure --prefix=/opt/heirloom
    ../../scripts/build.sh
    make

The script:

- Sets ~20 HAVE_* flags in conf.h to their Darwin-correct values
  (Darwin has size_t / time_t / sig_atomic_t / getline / bzero /
  strerror / mkdir / opendir / setsid / setpgrp / select and
  termios+sys/ioctl.h in the expected system headers).
- Comments out the fallback PID_T/UID_T/GID_T/OFF_T typedefs.
- Sets HAVE_POSIX_TERMIOS=1, HAVE_HDB_LOCKFILES=1, SPOOLDIR_TAYLOR=1
  in policy.h.
- Adds -std=gnu89 and warning-suppression flags to CFLAGS in all
  four Makefiles (main + lib + unix + uuconf).
- Drops -static from LDFLAGS (Darwin has no crt0.o).
- Stubs unix/mkdir.c, unix/dirent.c, unix/strerr.c to empty files
  (Darwin has all of these system-provided).
- Drops uudir from build (not needed when HAVE_MKDIR=1).
- Removes redundant lib fallbacks (bzero, getlin, memchr, memcmp,
  memcpy, strchr, strdup, strrch, strncs).

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
