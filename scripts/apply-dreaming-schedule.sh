#!/usr/bin/env bash
# Apply the memory-core `dreaming.frequency` change (0 3 * * * -> 25 4 * * *) by
# restarting the gateway, then record the post-restart state on disk.
#
# Why a restart: `openclaw config set plugins.entries.memory-core.config.dreaming.frequency`
# is only picked up on gateway start — the plugin's managed dreaming job
# (36b493db, tag [managed-by=memory-core.short-term-promotion]) keeps its old
# schedule until the plugin re-resolves config (verified 2026-11-19 22:20: after
# 2+ reconcile cycles the job was still "0 3 * * *").
#
# Why detached: the keep-alive cron run that armed this must finish and write its
# run bookkeeping BEFORE the gateway dies (same pattern as scripts/discord-selfheal.sh).
#
# Why move it: at 03:00 two heavy agent jobs collide — 36b493db dreaming (~30 min,
# toolsAllow ["*"]) AND 40e09cd1 "Jormungand daily all-agent health" (~11 min).
# That double load is what starved the gateway event loop for the last 3 nights and
# closed all 8 Discord clients (code 1000) into "disconnected, error:startup-not-ready".
# Separating them (03:00 health alone, 04:25 dreaming alone) gives each job the
# event loop to itself.
#
# The self-heal job d4cd45bc ("35,50 3,4,5 * * *") covers both windows: it restarts
# the gateway only when Discord really is broken AND dreaming is idle.
set -u

LOG="/home/amr/.openclaw/workspace-rowlet/memory/dreaming-schedule-check.log"

# --- dreaming guard (added 2026-11-23 13:15) ----------------------------------
# Restarting the gateway while 36b493db is in flight truncates the dreaming run
# (11-19 / 11-20 / 11-23 were all truncated by a restart).  Fail closed: when
# the state is unknown, postpone and let the caller re-run after the dreaming
# slot instead of killing the run.  DREAMING_CHECK is overridable only so the
# guard can be unit-tested.
DREAMING_CHECK="${DREAMING_CHECK:-${HOME}/.openclaw/workspace-rowlet/scripts/dreaming-running-check.py}"
dreaming_state="$(python3 "${DREAMING_CHECK}" --prefix 36b493db 2>/dev/null || true)"
dreaming_state="$(printf '%s' "${dreaming_state}" | tr -d '[:space:]')"
[ "${dreaming_state}" = "idle" ] || dreaming_state="running"
if [ "${dreaming_state}" != "idle" ]; then
  {
    echo "=== apply-dreaming-schedule postponed $(date -Is) ==="
    echo "dreaming job is '${dreaming_state}' - a restart would truncate it; nothing changed"
  } >> "$LOG"
  echo "postponed: dreaming job is '${dreaming_state}' - no restart, nothing changed"
  exit 75
fi

{
  echo "=== apply-dreaming-schedule start $(date -Is) ==="
  echo "restarting openclaw-gateway (user unit, Restart=always RestartSec=5)"
} >> "$LOG"

systemctl --user restart openclaw-gateway

# give the gateway time to come back and the plugin to reconcile the managed job
sleep 90

{
  echo "--- post-restart check $(date -Is) ---"
  echo "[gateway] $(systemctl --user is-active openclaw-gateway 2>&1)"
  echo "[managed dreaming job]"
  openclaw cron get 36b493db-deee-471d-a5a9-955d2455d067 2>&1 \
    | jq -c '{schedule:.schedule,payload:.payload,nextRunAtMs:.state.nextRunAtMs,lastStatus:.state.lastStatus}' 2>&1
  echo "[discord accounts]"
  openclaw channels status 2>&1 | grep -E "Discord" | sed 's/token:\*\*\*//' | head -12
  echo "[jobs still running]"
  openclaw cron list --json 2>/dev/null | jq -r '.jobs[]|select(.status=="running")|"RUNNING \(.id[0:8]) \(.name)"' 2>&1
  echo "=== done $(date -Is) ==="
} >> "$LOG" 2>&1
