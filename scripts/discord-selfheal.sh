#!/usr/bin/env bash
# Discord self-heal for the OpenClaw gateway.
#
# Why: cron 36b493db "Memory Dreaming Promotion" (25 4 * * *, timeoutSeconds 2400)
# runs up to ~40 min with toolsAllow ["*"]; it starves the gateway event loop, the
# enabled Discord clients stop reaching READY (code 1000/1006) and sit at
# "disconnected, error:startup-not-ready" until the gateway is restarted.
#
# CHANGES 2026-11-20 19:2x (rowlet keep-alive round 19:02) after the 2026-11-20
# night run proved the old guard was FAIL-OPEN and caused two separate harms:
#   1) the guard asked the (already saturated) gateway API whether the dreaming
#      job was running; the query failed/returned nothing -> the script printed
#      "False" -> it restarted the gateway at 04:35 WHILE 36b493db was mid-flight
#      -> dreaming was truncated ("cron: job interrupted by gateway restart").
#      Now every uncertainty resolves to "assume running" (fail closed).
#   2) no anti-storm guard: the cron fired 4 times in 90 min (03:35, 03:50,
#      04:35, 04:50) and each fire restarted the gateway again.
#      Now a restart is armed at most once per MIN_GAP_MIN minutes.
#
# It only restarts the gateway when BOTH conditions hold:
#   1) Discord is actually broken (some enabled account reports startup-not-ready)
#   2) the dreaming job 36b493db is provably NOT running
# It detaches the restart via systemd-run so the gateway can kill its own
# caller without aborting the job bookkeeping.
#
# Rollback: restore scripts/discord-selfheal.sh.bak-2026-11-20-1920
#   (or the pre-2026-11-20 original in git history) and
#   openclaw cron edit d4cd45bc-357d-42d4-9ba1-f7eb39e02f59 --cron "35,50 3,4 * * *" --tz Asia/Taipei
set -u

DREAMING_JOB_PREFIX="36b493db"
STATE_DIR="${HOME}/.openclaw/workspace-rowlet/memory"
STAMP_FILE="${STATE_DIR}/discord-selfheal-last-restart.ts"
MIN_GAP_MIN=30

now="$(date +%s)"

# 0) Anti-storm: one restart per MIN_GAP_MIN window.
if [ -f "${STAMP_FILE}" ]; then
  last="$(cat "${STAMP_FILE}" 2>/dev/null || echo 0)"
  if [ "${last}" -gt 0 ] 2>/dev/null && [ $(( now - last )) -lt $(( MIN_GAP_MIN * 60 )) ]; then
    echo "self-heal skipped: a restart was armed $(( (now - last) / 60 )) min ago (< ${MIN_GAP_MIN} min) - avoiding restart storm"
    exit 0
  fi
fi

# 1) Discord broken?
if ! openclaw channels status 2>/dev/null | grep -q "startup-not-ready"; then
  echo "discord healthy (no startup-not-ready) - no action"
  exit 0
fi

# 2) Dreaming job currently running? FAIL CLOSED:
#    if the cron API is unreachable or the payload is unparsable we must NOT restart.
running="$(openclaw cron list --json 2>/dev/null | DREAMING_PREFIX="${DREAMING_JOB_PREFIX}" python3 -c '
import json, os, sys
prefix = os.environ.get("DREAMING_PREFIX", "")
try:
    d = json.load(sys.stdin)
except Exception:
    print("True")   # cannot prove it is idle -> treat as running
    raise SystemExit
jobs = d.get("jobs", []) if isinstance(d, dict) else (d or [])
for j in jobs:
    if not str(j.get("id", "")).startswith(prefix):
        continue
    st = j.get("state") or {}
    if j.get("status") == "running" or st.get("runningAtMs"):
        print("True")
        raise SystemExit
print("False")
' 2>/dev/null || echo 'True')"

if [ "${running}" = "True" ]; then
  echo "dreaming job still running (or state unknown) - postpone self-heal"
  exit 0
fi

echo "discord broken and dreaming idle -> scheduling gateway restart in 10s"
mkdir -p "${STATE_DIR}"
printf '%s' "${now}" > "${STAMP_FILE}"
systemd-run --user --on-active=10s systemctl --user restart openclaw-gateway
