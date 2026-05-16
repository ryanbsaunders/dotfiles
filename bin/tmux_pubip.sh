#!/usr/bin/env bash
# Cache the public IP so the tmux status bar doesn't curl ifconfig.co every 5s.
# Refresh at most once every 5 minutes; on failure, fall back to '?'.
set -u

cache="${TMPDIR:-/tmp}/tmux_pubip.cache"
max_age=300

if [ ! -f "$cache" ] || [ $(($(date +%s) - $(stat -f %m "$cache" 2>/dev/null || echo 0))) -gt $max_age ]; then
  ip=$(curl -fsS --max-time 3 https://ifconfig.co 2>/dev/null) || ip="?"
  printf '%s' "$ip" > "$cache"
fi

cat "$cache"
