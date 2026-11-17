# Gengar Keep-Alive 巡檢日誌（cron 9d8b6001）

job: `9d8b6001-3178-46bf-ad9b-dfbb1ec0faa7` — Gengar Keep-Alive（每 3h，sessionTarget=isolated，agentId=null → 跑在 rowlet lane）

## 2026-11-16 13:02 — PASS（lane 雙向通，2 項未結案）

- rowlet lane：minimax-portal/MiniMax-M3 正常；上一輪 11:43 ok。
- gengar lane：sessions_send 進 agent:gengar:main → 13:02 回「lane alive」；耿鬼回 sessions_send 給本 cron session → 雙向通。
- gengar 5 顆 cron：全部 ok / consecutiveErrors=0（11:38 的 429 連敗已由 11:45/11:47 recovery 收復，Token Plan cap 已重置）。
- 未結案 A：heartbeat-gengar（c29eca0f）3 連敗 `heartbeat failed: agent-runner-failure`（11:59/250.9s、12:29/14.9s、12:59/15.5s）；先前 20+ 輪為 `skipped: no-route`。耿鬼自報的「600s 上限」與 15s 實測不符 → 已給原始 table 請其自診。
- 未結案 B：每日論文討論（58fe15dc，rowlet 07:00）4 連敗，429 Token Plan cap；不補額度明天再敗第 5 次，10 次自動停用。
- 漂移：本 job agentId=null；停用中的 b7a56e10（gengar keep-alive, agentId=gengar, 5m）才是真正打 agent 的版本。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-16 13:07 — 根因修正（依耿鬼 journal）

heartbeat-gengar 3 連敗真因：M3 → 429 Token Plan；minimax-portal M3 → 429；fallback `minimax/MiniMax-M2.7` → **400 (2013) context window exceeds limit**（gengar main session 363k tokens > M2.7 200k 視窗）→ 鏈全滅 → agent-runner-failure ≈15s。11:59 那輪 250s = 跨憑證重試 4 分鐘。
→ 「3 個 fallback」不構成冗餘（同一份 plan + 無大視窗備援）。修法只有 credits / 跨廠商 provider。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-16 13:10 — 全艦掃描（400(2013) 風險盤點）

- 含 M2.7 fallback 的 job 全是 sessionTarget=isolated（小 context）；唯一非 isolated 的 `45ccf4e9`（roaringmoon-morning-pipeline）實測 23,479 tokens → 都不會撞 200k。**陷阱只在 gengar main session（363k）**，已被移除 M2.7 候選修掉。
- agent chain 實測：gengar = `minimax/MiniMax-M3 → minimax-portal/MiniMax-M3`；其餘 8 agent = 單一 `minimax-portal/MiniMax-M3`。
- fleet 紅單分類：429 限額（e2ffd70d 4、58fe15dc 4）／容量過載（a72cb46b 5）／timeout（45ccf4e9 2）。
- 13:29 驗收 heartbeat-gengar 是否轉綠。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-16 16:02 — PASS（lane 雙向通；heartbeat-gengar 換症狀；全艦 no-route 是通病）

- rowlet lane：minimax-portal/MiniMax-M3 正常（15:59 上輪 ok）。
- gengar lane：sessions_send → agent:gengar:main 已接受並回覆（5 顆 cron 狀態表 + skip 原因）；gengar 回送本 cron session → 落地為 **pendingInput(queued)**（acceptedAt 16:06:26，state=queued，本 run 回合結束後才注入，非丟失）。雙向通 = PASS。
- gengar 7 顆 job：consecutiveErrors 全 0。ac9e7ada English/88810bfe BBC/29c2d630 Watchdog/f5148ff0 版本檢查/7767e03b skill-review = ok；b7a56e10 gengar keep-alive = disabled（刻意）。
- **heartbeat-gengar（c29eca0f）症狀換了**：11:59/12:29/12:59 的 3 次 agent-runner-failure 已過，error counter 歸 0；13:59 起連 5 次 `skipped: no-route`（每次 ~260ms、不呼叫模型、不吃 error counter）。根因＝gengar heartbeat cfg `target:"last"` + main session 近期無 inbound → 無投遞路由。刻意不釘死 target（釘死會每 30 分鐘洗 Linder DM）。nextRun 16:29。

### 全艦新發現：「no-route」不是 gengar 專屬（8 支 heartbeat 的分佈）
| job | agent | skipped | errors |
|---|---|---|---|
| heartbeat-greninja | greninja | 33 | 0 |
| heartbeat-picturecat | picturecat | 33 | 0 |
| heartbeat-roaringmoon | roaringmoon | 31 | 0 |
| heartbeat-celesteela | celesteela | 14 | 0 |
| heartbeat-gengar | gengar | 5 | 0 |
| heartbeat-rowlet / heartbeat-charizard | — | 0 | 0（ok） |
| heartbeat-mrmime | mrmime | 0 | **2**（15:03/15:33 agent-runner-failure；14:34 還 ok） |
| heartbeat-flaaffy | flaffy | — | never |

→ 解讀：**有 active route 的 agent 真的跑 heartbeat → 撞 429 Token Plan cap 而報錯；沒有 route 的 agent 靜默 skip → 綠燈但其實什麼都沒做。** 「綠」其實是閒著，「紅」才是有在幹活。

### 全艦 tally（50 jobs）：ok 36 / error 8 / skipped 5 / never 1
- 新增（13:10 後）：`bcf270b8` heartbeat-mrmime 2 errors（429 類）。
- 既有 8 支紅單與下次重試：`bcf270b8` every 30m→16:31；`d7b0355b` Jormungand A2A 5→18:00；`e2ffd70d` push-llm-wiki 4→明 05:05；`58fe15dc` 每日論文討論 4→明 07:00（=第 5 次；10 次自動停用）；`45ccf4e9` 晨間情報 2 + `b37129c0` 群體智能 1（皆「gateway restart 打斷」誤記，實有產出）→明 08:00；`a72cb46b` 每日 Agent×軟體開發 5→明 10:00（再 5 次自動停用）；`08b7c00b` rowlet-ut-veteran-cpc 4→明 12:00。
- Provider：16:02 兩邊（minimax-portal/M3 與 minimax/M3）都跑成功 → 429 是間歇性而非全斷，瓶頸仍在 Token Plan cap。

### 未動手（待 Linder，與 13:10 同一張清單）
MiniMax credits／跨廠商 provider；58fe15dc 與 a72cb46b 的停用倒數；llm-wiki 307 項變更 commit 方式。5 支 no-route heartbeat 要不要釘 target（釘＝保證投遞但每 30 分鐘發訊息；不釘＝安靜但閒置）—— 新增待決項。

### 工具路徑備註
本 run 內 `automations` 工具回 0 jobs（automation-run session 限縮 scope），只能用 CLI：`openclaw automations list --all --json`、`openclaw cron runs --id <完整uuid>`（短 id 不吃）。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 16:07 補充：gengar 回訊實際落地（先前為 queued）
gengar 的 "lane alive" 訊息於 16:06:26 接受、16:07 正式注入本 run session（跨 session 訊息，非 pendingInput 遺留）→ **雙向通由「已接受」升級為「已讀回」**，PASS 確立。耿鬼補充的 no-route 語意（`target:"last"` 取 main session 最後 inbound 通道；無近期 inbound → 260ms skip、不呼叫模型、不動 error counter）與本輪實測一致，並補上一點：凌晨各輪本來就是 skipped 類，**只有當路由真的解析成功、模型真的被呼叫時才轉為真錯誤**（然後兩份 MiniMax 憑證一起 429）→ 佐證本輪全艦解讀：有 route 才在幹活，沒 route 才是綠燈閒置。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## Gengar Keep-Alive 巡檢（cron 9d8b6001，19:02 台北）

**結果：PASS** — rowlet→gengar lane 雙向通，本 job 自身 lastStatus=ok / errs=0 / 連續 3 輪 succeeded。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 實測（19:02–19:05）
- `sessions_send` 探 `agent:gengar:main` → 耿鬼回完整 lane 表（5 顆 cron 狀態 + Discord 可達性 + 當前降級項），runId `1033857e-99b7-4157-858b-10f54694e08c`，delivery pending→已取得回覆文字。雙向通確立。
- 耿鬼側 8 顆 job：**有 route 的 5 顆全 ok / errs=0**（ac9e7ada English reminder delivered、88810bfe BBC drill delivered、29c2d630 watchdog not-delivered=靜默健康、f5148ff0 版本檢查、7767e03b skill review）；`heartbeat-gengar` (c29eca0f) = skipped / errs=0（no-route 預期行為）；`b7a56e10 gengar keep-alive` = disabled（刻意）。
- 耿鬼回報：Discord **ON / state OK / accounts 9/9**；3 小時內 13 次 websocket close (code 1005)，每次都被 `resume=true` 接回，兩支 crons 今日皆已投遞成功；gateway uptime 10h44m、RSS 1.35 GiB。**最近 60 分鐘 0 次 429**（Token Plan cap 窗口已退潮）。
- 本 job 自身：enabled、`agentId=null`（跑在 rowlet lane，設計如此）、payload model `minimax-portal/MiniMax-M3` + 三層 fallback、近 3 輪 entries 全 `ok/succeeded`。

### 全艦 tally（50 jobs / 45 enabled）：ok 37 / error 7 / skipped 5 / never 1
| Job | agent | errs |
|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | rowlet | **5** |
| 健康回報 | mrmime | 4 |
| push-llm-wiki | mrmime | 4 |
| 每日論文討論 | rowlet | 4 |
| rowlet-ut-veteran-cpc-maintenance-noon | rowlet | 4 |
| 晨間情報 pipeline | roaringmoon | 2 |
| 群體智能架構研究 | roaringmoon | 1 |

- 與 16:02 那輪（8 紅）比 → **16:02 之後淨減 1 紅**；與 18:08 心跳巡檢時的峰值 10 紅比 → 已回落。**18:38 之後無新增紅單**，429 尖峰確實過了。
- 5 支 skipped 全是 no-route heartbeat（celesteela / greninja / picturecat / roaringmoon / gengar），errs 皆 0 → 綠燈閒置，非故障（沿用 16:02 的解讀）。
- 停用倒數仍未解：a72cb46b 已 **5/10**、58fe15dc 明日 07:00 將成第 5 次。根因同為單一 MiniMax Token Plan（cap 2056 / cooldown / overload 529），非各家獨立問題。

### 未結案（沿用前兩輪清單，本輪無新項目）
MiniMax credits / 跨廠商 provider（OpenAI 餘額為 0，仍無 fallback）；a72cb46b + 58fe15dc 停用倒數；5 支 no-route heartbeat 要不要釘 target（釘＝保證投遞但每 30 分鐘洗 DM；不釘＝安靜閒置）；llm-wiki 307 項變更 commit 方式。

### 工具路徑備註（再次確認）
本 run 內 `automations` 工具：`get` 回 not found、`list` 回 0 jobs（automation-run session scope 限縮）→ 一律改用 CLI `openclaw cron list --all --json` / `openclaw cron runs --id <完整uuid>`。注意 `jq ... | todate` 對 ms 級 epoch 會印出 58844/58845 這種 nonsense 年份，需自行 `/1000`。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 19:05 補充：no-route 語意經 `openclaw status` 實測確認（全艦級行為，非 gengar 專屬）
- `openclaw status` 對 **celesteela / greninja / picturecat / rowlet** 與 gengar 一樣列 `waiting for delivery route` → 所有 `target:"last"` 的 agent 同一種行為。
- 語意：`target:"last"` 取 main session 最後一個 inbound 通道；近期無 inbound → **~260ms skip、不呼叫模型、不吃 error counter**（→ error counter 仍 0）。
- 與我的 tally 對照：本輪 5 支 skipped = celesteela / greninja / picturecat / roaringmoon / gengar；**rowlet 的 heartbeat-rowlet 雖同樣無 route，但 lastStatus 已是 ok（已轉綠），故不在 skipped 名單內** —— 兩者不矛盾，差別只在「最近一次是否真的被路由到」。
- 耿鬼刻意不釘死 target：釘死＝每 30 分鐘洗 Linder DM；不釘＝安靜閒置。維持現狀。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
