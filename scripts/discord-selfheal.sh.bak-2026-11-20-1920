#!/usr/bin/env bash
# Discord self-heal for the OpenClaw gateway.
#
# Why: cron 36b493db "Memory Dreaming Promotion" (0 3 * * *) runs ~30 min with
# toolsAllow ["*"] and no timeoutSeconds; it starves the gateway event loop, the
# 8 enabled Discord clients get closed (code 1000) and never reach READY again
# -> all accounts sit at "disconnected, error:startup-not-ready" until the
# gateway is restarted. Seen 2026-11-17 and 2026-11-18 (same signature).
#
# This script is INERT until a human enables the cron job that calls it.
# It only restarts the gateway when BOTH conditions hold:
#   1. Discord is actually broken (some enabled account reports startup-not-ready)
#   2. the dreaming job is NOT currently running (never truncate it mid-flight)
# It detaches the restart via systemd-run so the gateway can kill its own
# caller without aborting the job bookkeeping.
#
# Usage (for Linder, after approving):
#   openclaw cron add --name discord-selfheal-after-dreaming \
#     --cron "35,50 3,4 * * *" --tz Asia/Taipei \
#     --command "/home/amr/.openclaw/workspace-rowlet/scripts/discord-selfheal.sh" \
#     --session isolated --no-deliver --timeout-seconds 60
set -u

DREAMING_JOB_PREFIX="36b493db"

# 1) Discord broken?
if ! openclaw channels status 2>/dev/null | grep -q "startup-not-ready"; then
  echo "discord healthy (no startup-not-ready) - no action"
  exit 0
fi

# 2) Dreaming job currently running? (don't kill it mid-flight)
running="$(openclaw cron list --json 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print('False'); raise SystemExit
jobs = d.get('jobs', []) if isinstance(d, dict) else d
prefix = '${DREAMING_JOB_PREFIX}'
print(any(str(j.get('id','')).startswith(prefix) and j.get('status') == 'running' for j in jobs))
" 2>/dev/null || echo False)"
if [ "${running}" = "True" ]; then
  echo "dreaming job still running - postpone self-heal"
  exit 0
fi

echo "discord broken and dreaming idle -> scheduling gateway restart in 10s"
systemd-run --user --on-active=10s systemctl --user restart openclaw-gateway
