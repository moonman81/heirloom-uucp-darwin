#!/bin/sh
# build.sh — apply Darwin port fixes + build Taylor UUCP.
# Run inside vendor/uucp-1.04/ after ./configure.
set -eu

# Ensure ./configure has been run
if [ ! -f conf.h ]; then
    echo "Run ./configure first" >&2
    exit 1
fi

# Apply Darwin config overrides to conf.h
sed -i.bak \
    -e 's|#define HAVE_SIG_ATOMIC_T_IN_SIGNAL_H 0|#define HAVE_SIG_ATOMIC_T_IN_SIGNAL_H 1|' \
    -e 's|#define HAVE_SIZE_T_IN_STDDEF_H 0|#define HAVE_SIZE_T_IN_STDDEF_H 1|' \
    -e 's|#define HAVE_TIME_T_IN_TIME_H 0|#define HAVE_TIME_T_IN_TIME_H 1|' \
    -e 's|#define HAVE_VOID 0|#define HAVE_VOID 1|' \
    -e 's|#define HAVE_UNSIGNED_CHAR 0|#define HAVE_UNSIGNED_CHAR 1|' \
    -e 's|#define ANSI_C 0|#define ANSI_C 1|' \
    -e 's|#define HAVE_GETLINE 0|#define HAVE_GETLINE 1|' \
    -e 's|#define HAVE_BZERO 0|#define HAVE_BZERO 1|' \
    -e 's|#define HAVE_STRERROR 0|#define HAVE_STRERROR 1|' \
    -e 's|#define HAVE_MKDIR 0|#define HAVE_MKDIR 1|' \
    -e 's|#define HAVE_OPENDIR 0|#define HAVE_OPENDIR 1|' \
    -e 's|#define HAVE_SETSID 0|#define HAVE_SETSID 1|' \
    -e 's|#define HAVE_SETPGRP 0|#define HAVE_SETPGRP 1|' \
    -e 's|#define HAVE_SELECT 0|#define HAVE_SELECT 1|' \
    -e 's|#define HAVE_TERMIOS_AND_SYS_IOCTL_H 0|#define HAVE_TERMIOS_AND_SYS_IOCTL_H 1|' \
    -e 's|^#define PID_T int|/* #define PID_T int */|' \
    -e 's|^#define UID_T int|/* #define UID_T int */|' \
    -e 's|^#define GID_T int|/* #define GID_T int */|' \
    -e 's|^#define OFF_T long|/* #define OFF_T long */|' \
    conf.h
rm -f conf.h.bak

# Apply policy.h overrides
sed -i.bak \
    -e 's|^#define HAVE_POSIX_TERMIOS 0$|#define HAVE_POSIX_TERMIOS 1|' \
    -e 's|^#define HAVE_HDB_LOCKFILES 0$|#define HAVE_HDB_LOCKFILES 1|' \
    -e 's|^#define SPOOLDIR_TAYLOR 0$|#define SPOOLDIR_TAYLOR 1|' \
    policy.h
rm -f policy.h.bak

# Modernize CFLAGS in all Makefiles
for m in Makefile lib/Makefile unix/Makefile uuconf/Makefile; do
    sed -i.bak 's|^CFLAGS = |CFLAGS = -std=gnu89 -Wno-int-conversion -Wno-implicit-int -Wno-implicit-function-declaration -Wno-incompatible-function-pointer-types -Wno-int-to-pointer-cast -Wno-pointer-to-int-cast |' "$m"
    rm -f "$m.bak"
done

# Remove -static (no crt0.o on Darwin)
sed -i.bak 's|^LDFLAGS = -static|LDFLAGS =|' Makefile
rm -f Makefile.bak

# Stub redundant unix files (Darwin has all these)
for f in mkdir dirent strerr; do
    if [ -f "unix/$f.c" ]; then
        chmod u+w "unix/$f.c"
        echo "/* Darwin has $f; stub. */" > "unix/$f.c"
    fi
done

# Remove obsolete lib files (Darwin has them)
sed -i.bak 's|bzero.o||g; s|getlin.o||g; s|memchr.o||g; s|memcmp.o||g; s|memcpy.o||g; s|strchr.o||g; s|strdup.o||g; s|strrch.o||g; s|strncs.o||g' lib/Makefile
rm -f lib/Makefile.bak

# Remove uudir (not needed since HAVE_MKDIR=1)
sed -i.bak \
    -e 's|uudir\.o||g' \
    -e 's|^UUDIRFLAGS =.*|UUDIRFLAGS =|' \
    -e 's|^UUDIR = uudir|UUDIR =|' \
    Makefile
rm -f Makefile.bak

echo "Darwin patches applied. Now run: make"
