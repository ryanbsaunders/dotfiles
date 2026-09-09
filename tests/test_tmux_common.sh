#!/usr/bin/env bash
#
# .tmux.common.conf holds ONLY settings shared by the Mac and the remote
# host. Anything host-specific (prefix, status colour, plugins) belongs in
# the per-host overlay, not here.

set -u

COMMON="${1:-$(cd "$(dirname "$0")/.." && pwd)/.tmux.common.conf}"
[ -f "$COMMON" ] || { echo "FAIL: no such file: $COMMON" >&2; exit 1; }

fail=0

# Must contain the genuinely shared settings.
for want in "history-limit 50000" "mode-keys vi" "base-index 1" \
            "renumber-windows on" "focus-events on" "select-pane -D"; do
  if grep -qF -- "$want" "$COMMON"; then
    echo "PASS: contains '$want'"
  else
    echo "FAIL: missing '$want'"
    fail=1
  fi
done

# Must NOT contain host-specific settings.
for unwanted in "set -g prefix" "status-bg" "@plugin" "gitmux" "default-command"; do
  if grep -qF -- "$unwanted" "$COMMON"; then
    echo "FAIL: host-specific setting '$unwanted' leaked into the shared base"
    fail=1
  else
    echo "PASS: no '$unwanted' in the shared base"
  fi
done

# tmux must accept it.
if command -v tmux >/dev/null 2>&1; then
  if tmux -L testcommon -f "$COMMON" new-session -d -s t 2>/dev/null; then
    echo "PASS: tmux parses the shared base"
    tmux -L testcommon kill-server 2>/dev/null
  else
    echo "FAIL: tmux rejected the shared base"
    fail=1
  fi
else
  echo "SKIP: tmux not installed"
fi

exit $fail
