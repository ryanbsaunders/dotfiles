#!/usr/bin/env python3
"""Fork the Claude Code session running in a tmux pane into a new window.

Usage: tmux_claude_fork.py <pane_id>    (bound to prefix v in .tmux.common.conf)

Claude Code keeps a registry of running sessions in ~/.claude/sessions/<pid>.json
(undocumented; this reads pid, sessionId, cwd, tmux and updatedAt). The entry
whose tmux field names the pane is resumed with --fork-session from its
original cwd, because transcripts are keyed by launch directory.

Registry contents are untrusted: stale or reused pids, malformed session ids
and missing directories are refused. Errors go to the tmux status line and
never echo registry or argv text (display-message expands #() and strftime).
Success is silent, since run-shell -b would show stdout over the pane.
"""

import glob
import json
import os
import re
import shutil
import subprocess
import sys

PANE_RE = re.compile(r"%\d+")
WINDOW_RE = re.compile(r"@\d+")
UUID_RE = re.compile(r"[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}")
CLAUDE_FALLBACKS = ("/opt/homebrew/bin/claude", os.path.expanduser("~/.local/bin/claude"))


class ForkError(Exception):
    pass


def is_live_claude(pid):
    try:
        os.kill(pid, 0)
    except (ProcessLookupError, OverflowError):
        return False
    except PermissionError:
        pass
    ps = subprocess.run(["ps", "-o", "comm=", "-p", str(pid)], capture_output=True, text=True)
    return ps.returncode == 0 and os.path.basename(ps.stdout.strip()) == "claude"


def find_session(pane_id, sessions_dir):
    candidates = []
    for path in glob.glob(os.path.join(sessions_dir, "*.json")):
        try:
            with open(path) as f:
                entry = json.load(f)
        except (OSError, ValueError):
            continue
        if not isinstance(entry, dict):
            continue
        pid, tmux = entry.get("pid"), entry.get("tmux")
        # pid 0 or negative would signal a process group in os.kill
        if type(pid) is not int or pid <= 0 or not isinstance(tmux, str):
            continue
        if tmux.rpartition(".")[2] == pane_id and is_live_claude(pid):
            candidates.append(entry)

    if not candidates:
        raise ForkError("no live Claude session in this pane")

    def updated(entry):
        value = entry.get("updatedAt")
        return value if isinstance(value, (int, float)) else 0

    entry = max(candidates, key=updated)
    sid, cwd = entry.get("sessionId"), entry.get("cwd")
    if not (isinstance(sid, str) and UUID_RE.fullmatch(sid)):
        raise ForkError("session registry entry has a malformed sessionId")
    if not (isinstance(cwd, str) and os.path.isabs(cwd) and os.path.isdir(cwd)):
        raise ForkError("session directory no longer exists")
    return sid, cwd


def window_of(pane_id):
    # new-window rejects a pane as its target ("can't specify pane here").
    # tmux prints an empty line and exits 0 for a pane that no longer exists.
    lookup = subprocess.run(
        ["tmux", "display-message", "-p", "-t", pane_id, "#{window_id}"],
        capture_output=True, text=True,
    )
    window_id = lookup.stdout.strip()
    if lookup.returncode != 0 or not WINDOW_RE.fullmatch(window_id):
        raise ForkError("could not resolve the window for this pane")
    return window_id


def find_claude():
    found = shutil.which("claude")
    if found:
        return found
    for path in CLAUDE_FALLBACKS:
        if os.access(path, os.X_OK):
            return path
    raise ForkError("claude not found on PATH")


def report(message):
    subprocess.run(["tmux", "display-message", f"claude-fork: {message}"])


def main(argv):
    try:
        if len(argv) != 2 or not PANE_RE.fullmatch(argv[1]):
            raise ForkError("expected a tmux pane id argument")
        pane_id = argv[1]
        sessions_dir = os.environ.get("CLAUDE_SESSIONS_DIR") or os.path.expanduser("~/.claude/sessions")
        sid, cwd = find_session(pane_id, sessions_dir)
        window_id = window_of(pane_id)
        claude = find_claude()
    except ForkError as e:
        report(e)
        return 1

    window = subprocess.run(
        ["tmux", "new-window", "-a", "-t", window_id, "-c", cwd, "-n", "fork",
         "--", claude, "--resume", sid, "--fork-session"],
    )
    if window.returncode != 0:
        report("tmux new-window failed")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
