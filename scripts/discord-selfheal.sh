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
# CHANGES 2026-11-23 07:2x (rowlet keep-alive round 07:02): the "dreaming is
#   idle" check was still fail-OPEN on two counts (a valid-JSON RPC error
#   envelope, and the fact that the managed dreaming job 36b493db never
#   publishes a running state through the cron API at all).  Both were fixed
#   together with a third, API-independent signal (unfinished receipt rows +
#   the dreaming clock window).  This is the 3rd dreaming truncation avoided
#   (11-19, 11-20, 11-23).
#
# Rollback: restore scripts/discord-selfheal.sh.bak-2026-11-23-0715
#   (or scripts/discord-selfheal.sh.bak-2026-11-20-1920 for the pre-2026-11-20
#   original) and
#   openclaw cron edit d4cd45bc-357d-42d4-9ba1-f7eb39e02f59 --cron "35,50 3,4 * * *" --tz Asia/Taipei
set -u

DREAMING_JOB_PREFIX="36b493db"
DREAMING_CHECK="${HOME}/.openclaw/workspace-rowlet/scripts/dreaming-running-check.py"
STATE_DIR="${HOME}/.openclaw/workspace-rowlet/memory"
STAMP_FILE="${STATE_DIR}/discord-selfheal-last-restart.ts"
MIN_GAP_MIN=30
# Dreaming cron 36b493db is scheduled "25 4 * * *" with timeoutSeconds 2400
# (40 min), so it can be in flight from 04:25 until ~05:05 local time.
# This window is a guard that does NOT depend on the cron API answering.
# The end is 05:10 so the legitimate 05:13 heal slot is NOT blocked.
DREAMING_WINDOW_START="04:15"
DREAMING_WINDOW_END="05:10"

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
#    Every uncertainty must resolve to "assume running" -> we must NOT restart.
#
#    CHANGES 2026-11-23 07:2x (rowlet keep-alive round 07:02): the guard from
#    2026-11-20 still failed OPEN on a *valid-JSON error envelope*.
#      "openclaw cron list" prints {"ok":false,"error":{...}} on stdout AND
#      exits 0 when the RPC fails (e.g. the 32s-slow cron.list during the
#      04:46 dreaming freeze). json.load() parsed that fine, .get("jobs",[])
#      returned [], the loop found no dreaming job, and the script printed
#      "False" = "dreaming idle" -> it armed a gateway restart at 04:46 while
#      dreaming job 36b493db was mid-flight (04:25-04:48). The restart truncated
#      dreaming ("cron: job interrupted by gateway restart").
#
#    A second, deeper hole: 36b493db is a MANAGED plugin job (agentId=None).
#    While it runs, `cron list --all --json` publishes ONLY its last-run status
#    ("ok"/"error") and NEVER a runningAtMs/queuedAtMs key -- verified live
#    (state keys: lastRunStatus, nextRunAtMs, scheduleActivatedAtMs, ...).  So
#    an API-only check can NEVER see this job as running, however healthy the
#    API is.  The fix needs evidence that does not come from the cron API.
#
#    The check now lives in scripts/dreaming-running-check.py and combines three
#    INDEPENDENT families of evidence:
#      api   - cron list payload (status/runningAtMs/queuedAtMs) + the job's own
#              run window from lastRunAtMs + timeoutSeconds
#      db    - an UNFINISHED receipt row (finished_at_ms IS NULL) in
#              cron_run_receipts means a run is in flight; the runner creates
#              the row at run start and fills finished_at_ms at completion
#      clock - the dreaming schedule itself ("25 4 * * *", timeoutSeconds 2400
#              => in flight 04:25..05:05 local), needs neither API nor DB
#    Any family saying "running" wins; "idle" requires two independent
#    families to agree; a family that cannot answer is not a vote, and fewer
#    than two votes => fail closed to "running".
#
#    2b) Belt and braces: the clock window below also blocks the 04:15-05:10
#    slot outright, independent of everything above.
running_state="$(python3 "${DREAMING_CHECK}" --prefix "${DREAMING_JOB_PREFIX}" 2>/dev/null || echo 'running')"

if [ "${running_state}" != "idle" ]; then
  echo "dreaming job still running (or state unknown) - postpone self-heal"
  exit 0
fi

# 2b) Clock window: inside the dreaming slot we assume dreaming is running even
#     if the cron API says the job is idle. The API's own view is unreliable
#     exactly when it matters (the gateway is frozen/starved), so this second,
#     independent signal has the final word.
now_hm="$(date +%H:%M)"
if [[ "${now_hm}" > "${DREAMING_WINDOW_START}" && "${now_hm}" < "${DREAMING_WINDOW_END}" ]]; then
  echo "inside dreaming window ${DREAMING_WINDOW_START}-${DREAMING_WINDOW_END} - postpone self-heal"
  exit 0
fi

echo "discord broken and dreaming idle -> scheduling gateway restart in 10s"
mkdir -p "${STATE_DIR}"
printf '%s' "${now}" > "${STAMP_FILE}"
systemd-run --user --on-active=10s systemctl --user restart openclaw-gateway
