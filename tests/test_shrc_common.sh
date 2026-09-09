#!/usr/bin/env bash
#
# .shrc.common is consumed by the Mac's .bash_profile AND by ~/.bashrc on
# Linux hosts, so it must behave correctly in both directions. Linux is
# simulated with a
# `uname` stub placed first on PATH -- the file's own guard shells out to
# uname, so the stub exercises the real code path rather than a proxy for it.
#
# Usage: tests/test_shrc_common.sh [path-to-.shrc.common]

set -u

COMMON="${1:-$(cd "$(dirname "$0")/.." && pwd)/.shrc.common}"
[ -f "$COMMON" ] || { echo "FAIL: no such file: $COMMON" >&2; exit 1; }

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fail=0

# A `uname` that claims Linux, first on PATH.
mkdir -p "$WORK/bin"
printf '#!/bin/sh\necho Linux\n' > "$WORK/bin/uname"
chmod +x "$WORK/bin/uname"
LINUX_PATH="$WORK/bin:/usr/bin:/bin"

# --- Case 1: simulated Linux ------------------------------------------------
err=$(env -i HOME="$WORK" PATH="$LINUX_PATH" bash --norc -c \
        "source '$COMMON'" 2>&1 >/dev/null)
if [ -n "$err" ]; then
  echo "FAIL case1: sourcing on Linux emits errors:"
  printf '%s\n' "$err" | sed 's/^/    /'
  fail=1
else
  echo "PASS case1: sources cleanly on Linux"
fi

for a in gst gco cdt digs pubip; do
  if env -i HOME="$WORK" PATH="$LINUX_PATH" bash --norc -c \
       "source '$COMMON' >/dev/null 2>&1; alias $a" >/dev/null 2>&1; then
    echo "PASS case1: portable alias '$a' defined"
  else
    echo "FAIL case1: portable alias '$a' not defined"
    fail=1
  fi
done

ps1=$(env -i HOME="$WORK" PATH="$LINUX_PATH" bash --norc -c \
        "source '$COMMON' >/dev/null 2>&1; printf '%s' \"\$PS1\"" 2>/dev/null)
if [ -n "$ps1" ]; then
  echo "PASS case1: PS1 set"
else
  echo "FAIL case1: PS1 not set"
  fail=1
fi

# macOS-only aliases must NOT leak onto Linux.
for a in brup flushdns; do
  if env -i HOME="$WORK" PATH="$LINUX_PATH" bash --norc -c \
       "source '$COMMON' >/dev/null 2>&1; alias $a" >/dev/null 2>&1; then
    echo "FAIL case1: macOS-only alias '$a' defined on Linux"
    fail=1
  else
    echo "PASS case1: macOS-only alias '$a' correctly absent on Linux"
  fi
done

# --- Case 2: real macOS -----------------------------------------------------
# The guard must not over-suppress: on a Mac these SHOULD be defined.
if [ "$(uname)" = "Darwin" ]; then
  for a in brup flushdns; do
    if env -i HOME="$WORK" PATH=/usr/bin:/bin bash --norc -c \
         "source '$COMMON' >/dev/null 2>&1; alias $a" >/dev/null 2>&1; then
      echo "PASS case2: macOS alias '$a' defined on Darwin"
    else
      echo "FAIL case2: macOS alias '$a' missing on Darwin — guard too strict"
      fail=1
    fi
  done
else
  echo "SKIP case2: not running on Darwin"
fi

exit $fail
