#!/usr/bin/env bash
#
# bin/tmux_claude_fork.py forks the Claude Code session running in a tmux
# pane into a new window. It trusts nothing it reads from Claude's session
# registry: stale or reused pids, malformed session ids and missing dirs
# must all be refused without ever calling `tmux new-window`.
#
# tmux, ps and claude are stubbed on PATH; the stub tmux logs each call's
# argv (one element per line, records separated by `---`) and answers the
# pane -> window_id lookup with $TMUX_STUB_WINDOW.

set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="${1:-$REPO/bin/tmux_claude_fork.py}"

fail=0
pass()  { echo "PASS: $1"; }
flunk() { echo "FAIL: $1"; fail=1; }

if [ -x "$SCRIPT" ]; then pass "script is executable"; else flunk "not executable: $SCRIPT"; fi

TMP="$(mktemp -d)"
STUBS="$TMP/stubs"; REG="$TMP/sessions"; COMM="$TMP/comm"; LOG="$TMP/tmux.log"
PROJ="$TMP/proj dir"
mkdir -p "$STUBS" "$REG" "$COMM" "$PROJ"

cat > "$STUBS/tmux" <<'EOF'
#!/usr/bin/env bash
{ echo "---"; printf '%s\n' "$@"; } >> "$TMUX_STUB_LOG"
# `display-message -p -t <pane> '#{window_id}'` resolves the pane's window.
# Real tmux prints an empty line (exit 0) for a pane that doesn't exist.
[ "${1:-}" = display-message ] && [ "${2:-}" = -p ] && printf '%s\n' "$TMUX_STUB_WINDOW"
exit 0
EOF
cat > "$STUBS/ps" <<'EOF'
#!/usr/bin/env bash
# Only `ps -o comm= -p <pid>` is expected; comm comes from a fixture file.
pid=
while [ $# -gt 0 ]; do [ "$1" = "-p" ] && pid="${2:-}"; shift; done
[ -n "$pid" ] && [ -f "$PS_STUB_COMM/$pid" ] || exit 1
cat "$PS_STUB_COMM/$pid"
EOF
printf '#!/bin/sh\nexit 0\n' > "$STUBS/claude"
chmod +x "$STUBS"/*

sleep 600 & LIVE=$!
sleep 600 & LIVE2=$!
sleep 600 & NOTCLAUDE=$!
sleep 0 & DEAD=$!; wait "$DEAD" 2>/dev/null
trap 'kill "$LIVE" "$LIVE2" "$NOTCLAUDE" 2>/dev/null; rm -rf "$TMP"' EXIT

echo claude > "$COMM/$LIVE"
echo /opt/homebrew/Caskroom/claude-code/2.1.269/claude > "$COMM/$LIVE2"
echo bash > "$COMM/$NOTCLAUDE"
echo claude > "$COMM/$DEAD"   # passes the comm check; liveness must catch it

SID_A=11111111-1111-4111-8111-111111111111
SID_B=22222222-2222-4222-8222-222222222222

# reg <file> <pid> <sessionId> <pane> <cwd> <updatedAt>
reg() {
  printf '{"pid":%s,"sessionId":"%s","cwd":"%s","kind":"interactive","tmux":"main:@1.%s","updatedAt":%s}\n' \
    "$2" "$3" "$5" "$4" "$6" > "$REG/$1.json"
}
reset() { rm -f "$REG"/*; : > "$LOG"; WINDOW=@7; }
run() {
  OUT="$(CLAUDE_SESSIONS_DIR="$REG" TMUX_STUB_LOG="$LOG" PS_STUB_COMM="$COMM" \
         TMUX_STUB_WINDOW="$WINDOW" PATH="$STUBS:$PATH" "$SCRIPT" "$1" 2>&1)"
  RC=$?
}
new_windows() { grep -cx 'new-window' "$LOG"; }
forked_with() {  # exact argv of every tmux call: window lookup, then new-window
  local expected
  expected="$(printf '%s\n' --- display-message -p -t "$1" '#{window_id}' \
              --- new-window -a -t @7 -c "$2" -n fork -- \
              "$STUBS/claude" --resume "$3" --fork-session)"
  [ "$(cat "$LOG")" = "$expected" ]
}
expect_refused() {
  if [ "$RC" -ne 0 ]; then pass "$1: non-zero exit"; else flunk "$1: exited 0"; fi
  if [ "$(new_windows)" -eq 0 ]; then pass "$1: no new-window"; else flunk "$1: called new-window"; fi
  if grep -A1 -x 'display-message' "$LOG" | grep -q '^claude-fork: '; then
    pass "$1: reports via display-message"
  else
    flunk "$1: no 'claude-fork:' display-message"
  fi
}

# live match, cwd with spaces passed as one argv element, silent on success
reset; reg a "$LIVE" "$SID_A" %10 "$PROJ" 100
run %10
if [ "$RC" -eq 0 ]; then pass "live match: exit 0"; else flunk "live match: exit $RC ($OUT)"; fi
if forked_with %10 "$PROJ" "$SID_A"; then pass "live match: exact tmux argv"; else flunk "live match: unexpected tmux calls: $(tr '\n' ' ' < "$LOG")"; fi
if [ -z "$OUT" ]; then pass "live match: silent"; else flunk "live match: printed output: $OUT"; fi

# no registry entry for this pane
reset; reg a "$LIVE" "$SID_A" %11 "$PROJ" 100
run %10
expect_refused "no entry for pane"

# stale (dead pid, newer updatedAt) + live entry for the same pane
reset; reg dead "$DEAD" "$SID_A" %10 "$PROJ" 900; reg live "$LIVE2" "$SID_B" %10 "$PROJ" 100
run %10
if forked_with %10 "$PROJ" "$SID_B"; then pass "stale entry skipped, live one used"; else flunk "stale+live: $(tr '\n' ' ' < "$LOG")"; fi

# two live claude entries for the same pane -> newest updatedAt
reset; reg old "$LIVE" "$SID_A" %10 "$PROJ" 100; reg new "$LIVE2" "$SID_B" %10 "$PROJ" 200
run %10
if forked_with %10 "$PROJ" "$SID_B"; then pass "newest live entry wins"; else flunk "newest: $(tr '\n' ' ' < "$LOG")"; fi

# unparseable registry file alongside a valid one is ignored
reset; echo 'not json{' > "$REG/junk.json"; reg a "$LIVE" "$SID_A" %10 "$PROJ" 100
run %10
if forked_with %10 "$PROJ" "$SID_A"; then pass "junk registry file ignored"; else flunk "junk file: $(tr '\n' ' ' < "$LOG")"; fi

# pid alive but not claude (pid reuse)
reset; reg a "$NOTCLAUDE" "$SID_A" %10 "$PROJ" 100
run %10
expect_refused "pid reused by non-claude"

# malformed sessionId
reset; reg a "$LIVE" 'x; rm -rf ~' %10 "$PROJ" 100
run %10
expect_refused "malformed sessionId"

# cwd no longer exists
reset; reg a "$LIVE" "$SID_A" %10 "$TMP/gone" 100
run %10
expect_refused "missing cwd"

# tmux can't resolve the pane's window (empty, as real tmux gives for a gone pane)
for badwin in '' 'main:1' '@7; kill-server'; do
  reset; reg a "$LIVE" "$SID_A" %10 "$PROJ" 100; WINDOW="$badwin"
  run %10
  expect_refused "bad window id '$badwin'"
done

# bad pane ids
for bad in '10' '%10; kill-server' '' '%'; do
  reset; reg a "$LIVE" "$SID_A" %10 "$PROJ" 100
  run "$bad"
  expect_refused "bad pane id '$bad'"
done

exit $fail
