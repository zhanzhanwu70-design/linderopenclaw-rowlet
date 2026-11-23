#!/usr/bin/env python3
"""Decide whether the memory-dreaming cron job (36b493db) is running RIGHT NOW.

Background
----------
`discord-selfheal.sh` restarts the OpenClaw gateway when Discord sits at
"startup-not-ready".  That symptom is produced by the dreaming job starving the
gateway event loop, so the guard must prove the dreaming job is IDLE before it
restarts anything -- otherwise the restart truncates the dreaming run itself.

The hole this closes (2026-11-23)
---------------------------------
Two independent holes made the old guard fail OPEN on the night run:

  1) `openclaw cron list --json` prints {"ok":false,"error":{...}} on stdout
     AND exits 0 when the RPC fails (the 32s-slow cron.list during the 04:46
     dreaming freeze).  json.load() parsed that fine, .get("jobs", []) returned
     [], the loop found no dreaming job -> the old guard printed "False" =
     "dreaming idle" -> it armed a restart while dreaming was mid-flight.

  2) 36b493db is a MANAGED plugin job (agentId=None).  While it runs, the CLI
     publishes only its LAST-RUN status ("ok"/"error") and never a
     `runningAtMs` key -- verified live against `cron list --all --json`:
     state keys are [... lastRunStatus, nextRunAtMs, scheduleActivatedAtMs]
     with no runningAtMs at all.  So an API-only check can NEVER see this job
     as running, no matter how healthy the API is.

Signals used now (any one saying "running" wins):

  receipts  UNFINISHED receipt row (finished_at_ms IS NULL) for the job means a
            run is in flight: the runner creates the row at run start and fills
            finished_at_ms at completion.  Authoritative and independent of the
            cron API -- which is exactly what hole 2 needs.
  cron-list status == "running" / runningAtMs / queuedAtMs.
  window    the job's own run window, derived from lastRunAtMs +
            timeoutSeconds.  Catches an in-flight plugin job whose API state
            never says "running" (hole 2).
  clock     the dreaming schedule itself: "25 4 * * *" with timeoutSeconds
            2400 => it can only be in flight 04:25..05:05 local (+grace).
            Needs NEITHER the API nor the DB, so it still works when both are
            degraded -- which is precisely when the gateway is starved.

FAIL CLOSED: a signal that cannot answer is UNKNOWN, never "idle".  The guard
may decline to act; it may never act on a guess.  "idle" requires at least two
independent definitive signals to agree.

Usage:
    dreaming-running-check.py [--json-file F] [--db F] [--prefix P] [--now-ms N]
Prints exactly one line: "running" or "idle".
"""
import argparse
import json
import os
import sqlite3
import subprocess
import sys
import time

DEFAULT_PREFIX = "36b493db"
DEFAULT_DB = os.environ.get(
    "DREAMING_CHECK_DB", os.path.expanduser("~/.openclaw/state/openclaw.sqlite"))
# Dreaming cron 36b493db: "25 4 * * *", timeoutSeconds 2400 -> in flight
# 04:25..05:05 local.  The window starts a little early and ends a little
# late so a job that starts late or overruns is still covered, while the
# legitimate 05:13 heal slot stays outside it.
CLOCK_WINDOW_START = (4, 15)   # HH, MM local
CLOCK_WINDOW_END = (5, 10)     # HH, MM local
GRACE_SEC = 300                # job may still be finishing right after timeout
# An unfinished receipt row older than this is debris from a crash, not a live
# run: timeout (2400s) + grace + slack.
STALE_ROW_SEC = 2400 + 300 + 600


def log(msg):
    sys.stderr.write("[dreaming-check] %s\n" % msg)


def load_cron_list(json_file=None):
    """Return {"jobs": [...]}, or raise if the list cannot be trusted."""
    if json_file:
        with open(json_file, "r", encoding="utf-8") as fh:
            data = json.load(fh)
    else:
        raw = subprocess.run(
            ["openclaw", "cron", "list", "--all", "--json"],
            capture_output=True, text=True, timeout=25,
        ).stdout
        data = json.loads(raw)
    if isinstance(data, dict) and data.get("ok") is False:
        raise ValueError("cron list error envelope: %s" % data.get("error"))
    jobs = data.get("jobs") if isinstance(data, dict) else data
    if not isinstance(jobs, list):
        raise ValueError("unexpected cron list payload shape")
    return {"jobs": jobs}


def probe_receipts(db_path, prefix, now_ms):
    """True / False / None(unknown)."""
    if not os.path.exists(db_path):
        log("receipt db not found: %s" % db_path)
        return None
    try:
        con = sqlite3.connect("file:%s?mode=ro" % db_path, uri=True, timeout=8)
        try:
            row = con.execute(
                "select started_at_ms from cron_run_receipts "
                "where job_id like ? and finished_at_ms is null "
                "order by started_at_ms desc limit 1",
                (prefix + "%",),
            ).fetchone()
        finally:
            con.close()
    except Exception as exc:  # noqa: BLE001
        log("receipt probe failed: %s" % exc)
        return None
    if not row:
        return False
    started = row[0] or 0
    age_s = (now_ms - started) / 1000.0
    if age_s > STALE_ROW_SEC:
        log("unfinished receipt row is stale (age %.0fs > %ss) -> ignore"
            % (age_s, STALE_ROW_SEC))
        return False
    return True


def probe_cron_list(prefix, json_file=None):
    """True / False / None(unknown)."""
    try:
        data = load_cron_list(json_file)
    except Exception as exc:  # noqa: BLE001
        log("cron list probe failed: %s" % exc)
        return None
    for job in data["jobs"]:
        if not str(job.get("id", "")).startswith(prefix):
            continue
        state = job.get("state") or {}
        if (job.get("status") == "running" or state.get("runningAtMs")
                or state.get("queuedAtMs")):
            return True
        return False
    log("dreaming job %s absent from cron list -> unknown" % prefix)
    return None


def probe_window(prefix, json_file=None, now_ms=None):
    """True / False / None(unknown), derived from the job's own run window."""
    try:
        data = load_cron_list(json_file)
    except Exception as exc:  # noqa: BLE001
        log("window probe failed: %s" % exc)
        return None
    if now_ms is None:
        now_ms = int(time.time() * 1000)
    for job in data["jobs"]:
        if not str(job.get("id", "")).startswith(prefix):
            continue
        state = job.get("state") or {}
        last_run = state.get("lastRunAtMs") or job.get("lastRunAtMs")
        timeout = (job.get("payload") or {}).get("timeoutSeconds") or 2400
        if not last_run:
            return None
        end = int(last_run) + int(timeout) * 1000 + GRACE_SEC * 1000
        return now_ms <= end
    return None


def probe_clock(now_ms=None):
    """True / False from the dreaming schedule alone -- no API, no DB."""
    if now_ms is None:
        now_ms = int(time.time() * 1000)
    local = time.localtime(now_ms / 1000.0)
    hm = (local.tm_hour, local.tm_min)
    if CLOCK_WINDOW_START <= hm <= CLOCK_WINDOW_END:
        return True
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json-file", default=None,
                    help="use a saved 'openclaw cron list --all --json' dump")
    ap.add_argument("--db", default=DEFAULT_DB)
    ap.add_argument("--prefix", default=DEFAULT_PREFIX)
    ap.add_argument("--now-ms", type=int, default=None,
                    help="override 'now' (epoch ms)")
    args = ap.parse_args()

    now_ms = args.now_ms if args.now_ms is not None else int(time.time() * 1000)

    receipts = probe_receipts(args.db, args.prefix, now_ms)
    cron_list = probe_cron_list(args.prefix, args.json_file)
    window = probe_window(args.prefix, args.json_file, now_ms)
    clock = probe_clock(now_ms)

    for name, val in (("receipts", receipts), ("cron-list", cron_list),
                      ("window", window), ("clock", clock)):
        log("signal %-9s -> %s" % (name, {True: "RUNNING", False: "idle",
                                           None: "unknown"}[val]))

    # Three INDEPENDENT families of evidence:
    #   api  - the cron CLI payload (cron-list + window share one payload, so
    #          they are ONE family, not two votes)
    #   db   - the receipt table (independent of the cron API)
    #   clock- the dreaming schedule itself (needs neither API nor DB)
    # Any family saying RUNNING wins.  Otherwise "idle" needs two independent
    # families to agree; a family that cannot answer is simply not a vote, and
    # if fewer than two can vote we fail closed to "running".
    api_vals = [v for v in (cron_list, window) if v is not None]
    if any(v is True for v in api_vals):
        api_family = True
    elif len(api_vals) == 2 and all(v is False for v in api_vals):
        api_family = False
    else:
        api_family = None

    families = {"api": api_family, "db": receipts, "clock": clock}
    for name, val in families.items():
        log("family %-6s -> %s" % (name, {True: "RUNNING", False: "idle",
                                           None: "unknown"}[val]))

    if any(val is True for val in families.values()):
        print("running")
        return 0

    idle_families = [name for name, val in families.items() if val is False]
    if len(idle_families) >= 2:
        log("idle confirmed by independent families: %s" % idle_families)
        print("idle")
        return 0

    log("fail closed (only %d idle families: %s)" % (len(idle_families), idle_families))
    print("running")
    return 0


if __name__ == "__main__":
    sys.exit(main())
