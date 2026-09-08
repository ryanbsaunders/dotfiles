#!/usr/bin/env bash
#
# Guards .bash_profile against Mac-only assumptions.
#
# Portable on purpose: this config is headed for Linux hosts as well as the
# Mac, so the test avoids BSD-only constructs (no `sed -i ''`) and skips the
# Homebrew case rather than failing it where brew isn't installed.
#
# Usage: tests/test_bash_profile.sh [path-to-.bash_profile]

set -u

PROFILE="${1:-$(cd "$(dirname "$0")/.." && pwd)/.bash_profile}"
[ -f "$PROFILE" ] || { echo "no such profile: $PROFILE" >&2; exit 2; }

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fail=0

# Case 1: a box with no Homebrew (any Linux host).
#
# Rewrite the Homebrew prefix to a path that does not exist, and neutralise the
# trailing `exec tmux` so the test shell isn't replaced. A login shell must
# then start silently -- an unguarded `eval "$(.../brew shellenv)"` shows up
# here as "No such file or directory" on every single login.
sed -e "s#/opt/homebrew#$WORK/nonexistent-brew#g" \
    -e "s#^  exec tmux new-session.*#  :#" \
    "$PROFILE" > "$WORK/profile_nobrew"

err=$(env -i HOME="$WORK" PATH=/usr/bin:/bin bash --norc -c \
        "source '$WORK/profile_nobrew'" 2>&1 >/dev/null)
if [ -n "$err" ]; then
  echo "FAIL case1 (no Homebrew installed): login shell emits errors:"
  printf '%s\n' "$err" | sed 's/^/    /'
  fail=1
else
  echo "PASS case1 (no Homebrew installed): starts clean"
fi

# Case 2: Homebrew present but not yet on PATH -- a fresh Mac login shell.
#
# The profile is what bootstraps brew onto PATH, so guarding that block with
# `type brew` would be circular and silently break the Mac. Assert it still
# happens.
if [ -x /opt/homebrew/bin/brew ]; then
  out=$(env -i HOME="$WORK" PATH=/usr/bin:/bin bash --norc -c \
          "source '$PROFILE' >/dev/null 2>&1; command -v brew" 2>/dev/null)
  if [ -n "$out" ]; then
    echo "PASS case2 (Homebrew installed): bootstrapped onto PATH -> $out"
  else
    echo "FAIL case2 (Homebrew installed): brew missing from PATH after sourcing"
    fail=1
  fi
else
  echo "SKIP case2 (Homebrew installed): no /opt/homebrew/bin/brew on this host"
fi

exit $fail
