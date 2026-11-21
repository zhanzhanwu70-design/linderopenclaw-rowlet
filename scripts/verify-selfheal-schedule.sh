#!/usr/bin/env bash
# One-shot verification that the all-day self-heal schedule ("13,43 * * * *", tz=Asia/Taipei)
# actually fires. Run by the temporary one-shot cron job created on 2026-11-21 04:0x.
#
# It only READS cron state and APPENDS a verdict line to the keep-alive memory log.
# It never restarts anything and never changes a schedule.
#
# Exit codes: 0 = verified (fired) or inconclusive-but-logged, 1 = verified MISS.
set -u

JOB="d4cd45bc-357d-42d4-9ba1-f7eb39e02f59"
LOG="/home/amr/.openclaw/workspace-rowlet/memory/keepalive-picturecat-2026-11-21.md"
RUNS="/tmp/selfheal-runs.json"
CUT="2026-11-21T04:13:00+08:00"
TS="$(date '+%Y-%m-%d %H:%M:%S %Z')"

openclaw cron runs --id "${JOB}" > "${RUNS}" 2>/dev/null

python3 - "${RUNS}" "${CUT}" > /tmp/selfheal-verdict.txt <<'PY'
import json, sys
path, cut = sys.argv[1], sys.argv[2]
cut_ms = None
try:
    import datetime
    cut_ms = datetime.datetime.fromisoformat(cut).timestamp() * 1000
except Exception:
    pass
try:
    with open(path) as fh:
        d = json.load(fh)
except Exception as exc:
    print("ERROR\tquery failed: %s" % exc)
    raise SystemExit(0)
entries = d.get("entries") or []
fired = []
if cut_ms:
    fired = [e for e in entries if (e.get("runAtMs") or 0) >= cut_ms]
recent = " ; ".join(
    "%s|%s|%s" % (e.get("runAtIso"), e.get("status"), (e.get("summary") or "")[:80])
    for e in entries[:4]
)
if fired:
    f = fired[0]
    print("OK\t%s -> status=%s dur=%sms summary=%s"
          % (f.get("runAtIso"), f.get("status"), f.get("durationMs"), (f.get("summary") or "")[:100]))
else:
    print("MISS\tno run at/after %s" % cut)
print("RECENT\t%s" % recent)
PY

VERDICT="$(cat /tmp/selfheal-verdict.txt 2>/dev/null)"

{
  echo ""
  echo "### self-heal 全天排程驗證（${TS} 自動檢查）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->"
  case "${VERDICT}" in
    OK*)
      echo "- ✅ \`13,43 * * * *\` **有正常觸發** → 全天自動修復覆蓋已補上。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->"
      echo "- 詳情：$(echo "${VERDICT}" | grep '^OK' | cut -f2-)<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->"
      ;;
    MISS*)
      echo "- ⚠️ 04:13 之後 **沒有 d4cd45bc 執行紀錄** → 新排程可能沒觸發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->"
      echo "- 建議：改回 \`openclaw cron edit ${JOB} --cron \"35,50 3,4,5 * * *\" --tz Asia/Taipei\` 並檢查 scheduler。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->"
      ;;
    *)
      echo "- ⚠️ 驗證查詢異常（不影響 gateway 運作）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->"
      ;;
  esac
  echo "- 最近幾輪：$(echo "${VERDICT}" | grep '^RECENT' | cut -f2-)<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->"
} >> "${LOG}"

cat /tmp/selfheal-verdict.txt
echo "${VERDICT}" | grep -q '^MISS' && exit 1
exit 0
