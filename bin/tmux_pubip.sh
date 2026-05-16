#!/usr/bin/env bash
# Cache public IP. Invalidate immediately when the default-route interface or
# its IP changes (catches network roam, ethernet plug, VPN, DHCP renew); fall
# back to a TTL for ISP-side WAN IP rotation at the same physical location.
# Always retry on placeholder so transient curl failures self-heal.
set -u

cache="${TMPDIR:-/tmp}/tmux_pubip.cache"
fingerprint="${TMPDIR:-/tmp}/tmux_pubip.fp"
max_age=300

default_if=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
default_ip=$(ipconfig getifaddr "$default_if" 2>/dev/null)
current_fp="${default_if}:${default_ip}"

stale=0
[ ! -f "$cache" ] && stale=1
[ ! -f "$fingerprint" ] && stale=1
[ -f "$fingerprint" ] && [ "$(cat "$fingerprint")" != "$current_fp" ] && stale=1
[ -f "$cache" ] && [ "$(cat "$cache" 2>/dev/null)" = "?" ] && stale=1
[ -f "$cache" ] && [ $(($(date +%s) - $(stat -f %m "$cache" 2>/dev/null || echo 0))) -gt $max_age ] && stale=1

if [ "$stale" = "1" ]; then
  ip=$(curl -fsS --max-time 3 https://ifconfig.co 2>/dev/null) || ip="?"
  printf '%s' "$ip" > "$cache"
  printf '%s' "$current_fp" > "$fingerprint"
fi

cat "$cache"
