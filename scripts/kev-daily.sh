#!/usr/bin/env bash
# CISA KEV 每日快照 + 差分比較
# 用法: kev-daily.sh          -> 下載今日 KEV，跟上次的快照比對，列出新增 / 即將到期
#       kev-daily.sh --check  -> 只列出「新增且 7 天內到期」與「逾期未處理」
# 純唯讀（只寫 ~/.openclaw/workspace-rowlet/state/kev/ 下的快照檔）
set -uo pipefail

DIR="${HOME}/.openclaw/workspace-rowlet/state/kev"
URL="https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"
TODAY="$(date +%Y-%m-%d)"
mkdir -p "$DIR"

if ! curl -sS --max-time 90 -o "$DIR/kev-$TODAY.json" "$URL"; then
  echo "[FAIL] KEV 下載失敗（$URL）"
  exit 1
fi

CUR="$DIR/kev-$TODAY.json"
if ! python3 -c "import json,sys;json.load(open('$CUR'))" 2>/dev/null; then
  echo "[FAIL] KEV JSON 解析失敗（可能拿到 HTML 導覽頁）"
  exit 1
fi

PREV="$(ls -1 "$DIR"/kev-*.json 2>/dev/null | grep -v "kev-$TODAY.json" | sort | tail -1)"
[ -z "$PREV" ] && PREV=""

MODE="full"
case "${1:-}" in
  --check) MODE="check" ;;
esac
python3 - "$CUR" "$PREV" "$TODAY" "$MODE" <<'PY'
import json, sys, datetime
cur_p, prev_p, today, mode = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
cur = json.load(open(cur_p))
vs = cur.get('vulnerabilities', [])
print(f"=== KEV catalogVersion={cur.get('catalogVersion')} count={len(vs)} ===")
if prev_p:
    prev = json.load(open(prev_p))
    pv = prev.get('vulnerabilities', [])
    print(f"（上次快照 {prev_p.split('/')[-1]}：{prev.get('catalogVersion')} / {len(pv)} 筆）")
    old = {v['cveID'] for v in pv}
    new = [v for v in vs if v['cveID'] not in old]
    if new:
        print(f"\n[新增] {len(new)} 筆：")
        for v in sorted(new, key=lambda x: x['dueDate']):
            r = ' [已知ranshocare]' if str(v.get('knownRansomwareCampaignUse')).lower() == 'known' else ''
            print(f"  {v['dateAdded']} → due {v['dueDate']} | {v['cveID']} | "
                  f"{v['vendorProject']} {v['product']} | {v['vulnerabilityName'][:80]}{r}")
    else:
        print("\n[新增] 0 筆（與上次快照相同）")
else:
    print("（首次執行，無上次快照可比對）")

now = datetime.date.fromisoformat(today)
horizon = (now + datetime.timedelta(days=7)).isoformat()
soon = [v for v in vs if now.isoformat() <= v['dueDate'] <= horizon]
soon.sort(key=lambda v: v['dueDate'])
overdue = [v for v in vs if v['dueDate'] < now.isoformat()]

def show(v, tag):
    print(f"  {v['dueDate']} [{tag}] {v['cveID']} | {v['vendorProject']} {v['product']} | {v['vulnerabilityName'][:70]}")

if mode == 'check':
    # 只列「新增且 7 天內到期」與「逾期未處理」
    new_soon = [v for v in (new if prev_p else []) if v['dueDate'] <= horizon]
    if new_soon:
        print(f"\n=== 新增且 7 天內到期 {len(new_soon)} 筆 ===")
        for v in sorted(new_soon, key=lambda x: x['dueDate']):
            d = datetime.date.fromisoformat(v['dueDate'])
            show(v, '今日到期' if d == now else f'剩 {(d-now).days} 天')
    else:
        print("\n=== 新增且 7 天內到期：0 筆 ===")
    print(f"\n=== 逾期未處理 {len(overdue)} 筆 ===")
    for v in sorted(overdue, key=lambda x: x['dueDate'])[-10:]:
        odays = (now - datetime.date.fromisoformat(v['dueDate'])).days
        show(v, f'逾期 {odays} 天')
    if len(overdue) > 10:
        print(f"  …（其餘 {len(overdue)-10} 筆更早逾期未逐筆列出）")
else:
    print(f"\n=== 未來 7 天內到期（today..{horizon}）{len(soon)} 筆 ===")
    for v in soon:
        d = datetime.date.fromisoformat(v['dueDate'])
        show(v, '今日到期' if d == now else f'剩 {(d-now).days} 天')
    print(f"\n（另有 {len(overdue)} 筆歷史逾期項未處理 — 不逐筆列出，KEV 目錄已知皆為往期 BOD 累積）")

# 只保留最近 60 份快照
import glob, os
for f in sorted(glob.glob(f"{os.path.dirname(cur_p)}/kev-*.json"))[:-60]:
    os.remove(f)
PY
