# Picturecat Keep-Alive 巡檢日誌（2026-11-19）

## 2026-11-19 01:02 — Picturecat Keep-Alive 第 9 輪：lane PASS、Discord 8/8 連線、紅單淨減 1、但**03:00 雙重負載是連續第 3 天未解（距 03:00 約 1h55m）**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `4a61e1f9-de03-4af1-83a0-0e109c8803ed`，status=ok，回覆「pong — no active task, no recent errors; idle and healthy.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）：enabled、schedule=`every 10800000ms`（3h）、sessionTarget=isolated、model=minimax-portal/MiniMax-M3、delivery.mode=none、**status=ok / ce=0**、上一輪 dur=410,483ms（22:02 那輪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- payload 複查：`kind=agentTurn`、`message="keep-alive test"`、**無 timeoutSeconds**、無 toolsAllow 限制（等於預設全開）。
- 姊妹 job：`880b5c17 Celesteela KA` **ok / ce=0 / dur=86,692ms**（前一輪連 2 次被 120s timeout 砍掉；本輪 payload 已見 `timeoutSeconds:300` → **待辦 #3 已解**）；`9d8b6001 Gengar KA` ok / ce=0 / dur=10,408ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) Discord runtime：可用且穩定（gateway 連續活 20h20m 未重啟）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 01:02 `openclaw channels status`：**8/8 enabled 帳號全部 `running, connected`**（greninja disabled/stopped = 預期）；picturecat transport:1m ago、celesteela in:12m ago。
- inbound 新鮮度：celesteela 12m / mrmime 55m / roaringmoon 1h / rowlet 3h / charizard 16h / gengar 17h；picturecat、flaaffy 視窗內無 inbound → **Discord 使用者傳訊仍有人收到**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal（`--user`）：**READY timeout 近 3h = 0**；**event-loop starvation 近 3h = 0**（24h 內 26 筆全落在 11-18 03:00–03:30 dreaming 區間）；websocket closed 近 3h 13 行 = 12×code 1005 + 1×code 1001 → 全部自癒重連，未演變成 READY timeout。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：pid **2724303 自 11-18 04:44:05 CST 起（20h20m）**、systemd NRestarts=0 / ActiveState=active、`/health` HTTP 200 in 1.84ms、uptime 38d、load 0.76、mem available 20GiB、disk 60%。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⚠️ 量測教訓（省得後人重踩）：grep「starvation / event-loop」會命中**自己報告的文字**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪第一次量測 `grep -c starvation` = 1、`grep -c "event[- ]loop"` = 3 → 追下去才發現**三筆全是上一輪 agent 報告的內文**（[agent:nested] session 行裡的「…高機率重演（Discord inbound 變瞎的風險點）…」「likely event-loop starvation」字樣來自報告句，不是 runtime 事件）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **正確 runtime 簽章**＝`[fetch-timeout] … timer delayed Nms, likely event-loop starvation`（11-18 03:03:02 的實例：`timer delayed 5455ms`）。用此簽章重算：近 3h = **0**、近 24h = **26**，max timer delayed = **101,948ms（101.9 秒）**（即 11-18 那場，未再被觸發）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 同理「superseded」簽章近 3h = 24 筆、`lane task error` 幾乎全是 `prepared model runtime plugin generation was superseded`（durationMs 3–17，瞬間死）→ **良性競態**，非紅單。

### 4) Fleet：52 jobs / 45 enabled / 7 disabled — ok 29 / error 9 / skipped 6 / never 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- vs 22:02 基準（ok 29 / error 10）→ **error −1**；轉綠的是 `880b5c17 Celesteela Keep-Alive`（ce 6→0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單 9 支（enabled 且 lastRunStatus=error）：

| job | id | ce | 最後 dur | schedule | 類別 |
|---|---|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | **7** | 143,782ms | `0 10 * * *` | 429（距自動停用門檻 10 剩 3 次）|
| 每日論文討論 | 58fe15dc | 6 | 246,782ms | `0 7 * * *` | 429 |
| Jormungand daily all-agent health | 40e09cd1 | 5 | 1,804,451ms | `0 3 * * *` | timeout |
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | 5 | 1,200,815ms | `0 8 * * *` | timeout |
| 每日 LLM Wiki 巡讀與擴寫 | ae91b967 | 4 | 3,859ms | `0 9 * * *` | 429 |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | 4 | 4,986ms | `0 12 * * *` | 429 |
| PTCGP Meta 三日彙整 | 6ddc8b4c | 4 | 2,471ms | every 72h | 429 |
| skill-collection-review-mrmime | 9e2cec7c | 4 | 629ms | every 7d | 429 |
| 群體智能架構研究 | b37129c0 | 2 | 1,907,824ms | `0 8 * * *` + stagger | timeout |

- ✅ 綠燈（含三支 KA）：`911eee45 每日資安建議` ce=0/725,054ms、`13ac4b5a 健康回報` ce=0/47,880ms、`ca222989 系統維護` ce=0/155,833ms、`e2ffd70d push-llm-wiki` ce=0/19,803ms、`09c7940b PTCGP Meta Analysis` ce=0/636,194ms、`af94aa92 每日 OpenClaw 備份` ce=0/128,371ms（script payload 第二次自動執行成功）、`36b493db dreaming` ce=0（但 dur 1,808,947ms，見 §5）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `skipped: no-route` 6 支、`6e93c179 heartbeat-flaaffy` never run → 良性長態，**不計紅單**。

### 5) Provider 429：18:00 後退潮，只剩零星單筆<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 「All models failed」近 12h = 25 筆，全部集中在 **11-18 16:00（18 筆）與 17:00（7 筆）**；18:00 之後 = **0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 近 3h 僅 2 筆 `status=429`（minimax-portal，elapsedMs 17 / 11）：23:02:51 與 00:02:31，皆為 **embedded run**（Discord 來源的使用者回合被限流），非 job 層失敗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- fallback 鏈仍是 4 個候選**全同一 MiniMax Token Plan**（minimax-portal/MiniMax-M3 → minimax/MiniMax-M3 → minimax-portal/MiniMax-M2.7 → minimax/MiniMax-M2.7）→ **跨廠冗餘仍 0**（老問題；`openai/*` 憑證仍 Auth=no，我不碰憑證）。

### 6) 🔴 03:00 槽雙重負載：連續第 3 天未解（距 03:00 約 1h55m）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | schedule | payload 弱點 | 昨夜實跑 |
|---|---|---|---|---|
| Memory Dreaming Promotion | 36b493db | `0 3 * * *`（無 tz） | `toolsAllow:["*"]`、**無 timeoutSeconds**、lightContext、isolated | dur 1,808,947ms（30.1 分鐘）|
| Jormungand daily all-agent health | 40e09cd1 | `0 3 * * *` tz=Asia/Taipei | 已有 timeoutSeconds=3600 + 受限 toolsAllow | 1,804,451ms timeout，ce=5 |

- 前兩晚簽名一致（11-17、11-18）：**03:00 起跑 → 跑約 30 分鐘 → gateway event loop timer delay 最高 101.9 秒 → 8 個 Discord client 全掉且 READY attempt 累積到 100+ → 全部 `running, disconnected, error:startup-not-ready` → inbound 全瞎 7–10 小時**（11-17 靠 13:19 人工核准重啟、11-18 靠 04:44 重啟才恢復）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal-after-dreaming`：**仍 disabled**。腳本 `/home/amr/.openclaw/workspace-rowlet/scripts/discord-selfheal.sh` 已存在且守門得宜（只在 `channels status` 出現 `startup-not-ready` **且** dreaming job 未在 running 時才用 `systemd-run --user --on-active=10s systemctl --user restart openclaw-gateway`），sched=`35,50 3,4 * * *` tz=Asia/Taipei → **今晚 03:35 就會是它能生效的第一個時點**（dreaming 約 03:30 結束）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 系統專家指出：`36b493db` 是 **plugin-declared**（declarationKey `memory-core:memory-dreaming-promotion`），`plugins.entries.memory-core` 只接受 `enabled/hooks/subagent/llm/config.*` 且 `config.*` 無可用鍵 → **CLI 改排程可能被 declaration reconciliation 還原**，持久修法要落到 memory-core plugin 原始碼。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 本輪升級動作<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 向系統專家（`openclaw` tool）開立變更提案 → 回覆：**needsApproval=true，proposalId `system-agent:cdcf0c7b-aea4-4350-9a0c-613a099cb0b2`**。
- ⚠️ 系統專家回報兩個**阻塞點**（它自己無法繞過）：
  1. 有一個它的**殘留無參數 `setup` 提案 `9504a88b90762560ce4aff2333722eaddaf8448bad39d940530103b74f795530`** 佔住 gateway 唯一的「一次一個 staged operation」槽位 → 所有真正的變更提案都被 `proposal-conflict` 擋下；**需人工 decline/取代它**，它自己也無權清理。
  2. 它**讀不到 cron job 定義與提案佇列**（`openclaw.json` 的 `cron.*` 只有全域 scheduler 設定）→ 無法自行驗證 36b493db/40e09cd1/d4cd45bc 的現況，也無法確認 11-18 04:02 的舊提案 `system-agent:00b9d1aa-11fd-42d8-a66d-1173362d2c26` 是否仍待審 → **該提案不可假定仍有效**。
  3. 它明講：**即使提案過了，也不會在 03:00 前套用**；且它不重啟 gateway。
  4. 它建議 dreaming 挪到 **`30 4 * * *`**（03:00 整點必須清空，17 3 仍在同一個小時）、`40e09cd1` 挪到 04:30（前提是 dreaming 不在那裡）、`d4cd45bc` 無論如何都建議啟用；`toolsAllow` 縮減它建議**後置**（怕縮太窄會讓 memory promotion 靜默失效）。
- **唯一外部寫入**：用 rowlet 帳號把巡檢摘要＋03:00 警告＋可直接複製的 `openclaw cron edit/enable` 指令貼到 Discord channel `1482363974119854234` → **messageId `1572659152948563989`，deliveryStatus `sent`**（同時再次實證 REST outbound 活）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未自行 `openclaw cron edit/enable`（03:00 排程與 self-heal 啟用＝全域排程 + 無人值守重啟 gateway，屬 human 決策；11-18 04:02 起 8 輪一致維持此邊界）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron 排程 / payload / timeout / config / provider / model / fallback / channel；未重啟 gateway；未手動 `run` 其他 job；未碰 `elle.service`（system scope crash-loop，需 root）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user`、`systemctl --user show`、`curl /health`、ps/uptime/free/df。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（第 14 輪，已收斂成 3 條）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最急・03:00 前 1h55m】清空 03:00 槽**：
   - `openclaw cron edit 36b493db-deee-471d-a5a9-955d2455d067 --cron "30 4 * * *"`
   - `openclaw cron edit 40e09cd1-7629-42bb-9275-193879665724 --cron "45 4 * * *" --tz Asia/Taipei`
   - （若被 plugin declaration 還原 → 持久修法在 memory-core plugin 原始碼，見 §6）
2. **【急・唯一能自動修復的機制】啟用 self-heal**：`openclaw cron enable d4cd45bc-357d-42d4-9ba1-f7eb39e02f59`（守門已在腳本內，只在真的壞掉時才重啟）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急・解鎖提案槽】請人工 decline 殘留提案** `9504a88b90762560ce4aff2333722eaddaf8448bad39d940530103b74f795530`（系統專家卡住的原因）；同時確認 `system-agent:cdcf0c7b-aea4-4350-9a0c-613a099cb0b2` 是否照第 1、2 條執行（CLI 指令已直接可用，核准與否都不影響）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 附帶（不急）：`a72cb46b` ce=7 距自動停用剩 3 次（明天 10:00 再跑）；跨廠 fallback 仍 0（`openai/*` Auth=no，我不碰憑證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**04:02**（本 job，3h 一次）—— 若今晚 Discord 真的掉線，該輪會偵測到並立刻在此頻道再報。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-19 04:02 — Picturecat Keep-Alive 第 10 輪：lane PASS、**03:00 第 3 次重演但這次 Discord 自癒**（不需重啟）、8 支 heartbeat 被 600s 砍成紅單<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `a4fdb72a-ded3-46c7-aa1d-bb0a906ebbaf`，status=ok，回覆「pong — idle, no active task, no recent errors; Discord inbound/outbound working right now.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）：enabled、schedule=`every 10800000ms`（3h）、sessionTarget=isolated、payload=`agentTurn`「keep-alive test」+ model `minimax-portal/MiniMax-M3` + fallbacks 3 個（**全同一 MiniMax Token Plan → 跨廠冗餘仍 0**）、**無 timeoutSeconds**、delivery.mode=none；上一輪 01:02:02 **ok / dur=276,963ms / ce=0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` ok/ce=0/dur=187,738ms（payload 已含 `timeoutSeconds:300` → 待辦#3 持續有效）；`9d8b6001 Gengar KA` ok/ce=0/dur=10,408ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 本輪關鍵新事實：03:00 dreaming 第 3 晚重演，但**Discord 這次自癒了**（前兩晚的「必重啟」結論需要修正）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion`：03:00:00 → **dur=1,922,307ms（32.0 分鐘）**、status=ok、ce=0、next=**11-20 03:00**（第 4 次原樣再來）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- event-loop starvation **再次發生**：runtime 簽章 `[fetch-timeout] … timer delayed Nms, likely event-loop starvation` **16 筆**，最大 **timer delayed 18,749ms**（03:22:47）→ 比 11-18 的 101,948ms **輕 5.4 倍**；`eventLoopMax` 峰值 2,738.9ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 斷線徵兆一樣出現：`gateway READY wait timed out after 15000ms` **33 筆**（attempt 最高 11）、`websocket closed` **69 行**、03:32:00 有一筆 `channel exited: discord gateway opened but did not reach READY within 30000ms`（gengar）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **但這次沒有卡死**：journal 內 `startup-not-ready` = **0 筆**；03:31:31 / 03:31:55 / 03:32:47 依序 `client initialized` → `channels resolved`；**最後一筆 READY timeout 在 03:31:52**，之後自行恢復。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:02 `openclaw channels status`：**8/8 enabled 帳號全部 `running, connected`**（greninja disabled=預期）；gateway **從未重啟**（pid **2724303 自 11-18 04:44:05 起、23h18m**、systemd NRestarts=0、ActiveState=active、`/health` HTTP 200 in 3.6ms、load 0.54、mem available 20GiB、disk 60%）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **結論修正（前 3 輪寫得太絕對）**：11-17/11-18 是「event loop 塞死 → client 狀態機不可逆卡死 → 必須重啟」；**11-19 證明重啟並非必然** —— starvation 較輕（18.7s vs 101.9s）時 client 能自行重連回 READY。→ **重啟應降級為「自癒失敗時的後備手段」，不是唯一解**；但**根因（dreaming 在 gateway 自己的 event loop 內跑 32 分鐘）完全沒變**，只是今晚症狀較輕。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord inbound 實流量（唯讀查 `~/.openclaw/state/openclaw.sqlite` 的 `channel_ingress_events`，連 WAL/SHM 複製到 /tmp 再查）：**近 400 筆全為 `completed`，0 failed / 0 pending**；最新 `mrmime 04:02:12`、`celesteela 03:59:59` → **使用者傳訊仍有人收有人處理**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 每小時 ingress 量：11-18 19–23h ≈ 70–83/h → 11-19 00h=9、01h=5、02h=3、03h=3、04h=1（深夜低量 + 03:00 視窗）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Provider：03:00 視窗又有 rate limit 回來<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `[model-fetch] status=429` 逐小時：11-18 23h=1、11-19 00h=1、01h=1、**03h=1**、**04h=1** → 幾乎每小時 1 筆的低度滲漏，不是尖峰暴發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 兩筆實際打紅單：**03:34:25** `elapsedMs=173,537` → `40e09cd1 Jormungand` error（**rate_limit**，本輪首次不是 timeout）ce 5→6；**04:02:10** `elapsedMs=74,886` → `ca222989 OpenClaw 系統維護` error（rate_limit，dur=1,757,340ms）ce 1→2。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 別再誤判：journal 裡 Discord 的 `delaying provider startup … to reduce Discord startup rate limits` 是 **Discord 自己的 startup backoff**，不是 MiniMax 額度。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `prepared model runtime plugin generation was superseded` 近 3h = **4 筆**（durationMs 3–17，瞬間死）→ 良性競態，非紅單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：53 jobs / 45 enabled / 8 disabled — enabled ok 27 / error 17 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- vs 01:02 基準（enabled ok 29 / error 9）→ **error +8、ok −2**；新增的 8 張紅單**全部是 heartbeat**，且**全部是同一個簽章**：`dur=600004ms`（cron 預設 timeout 上限）+ `lastErrorReason=timeout` + `sessionTarget=main`。

| job | id | ce | 最後執行 | dur | 判讀 |
|---|---|---|---|---|---|
| heartbeat-mrmime | bcf270b8 | 4 | 03:47 | 600,004ms | 03:00 視窗下游症狀 |
| heartbeat-rowlet | d82f78e3 | 4 | 03:51 | 600,005ms | 同上 |
| heartbeat-celesteela | 46242a4c | 3 | 03:42 | 600,030ms | 同上 |
| heartbeat-charizard | ffc90b7d | 3 | 03:46 | 600,004ms | 同上 |
| heartbeat-greninja | 7d633ff4 | 3 | 03:47 | 600,003ms | 同上 |
| heartbeat-picturecat | 6525d155 | 3 | 03:47 | 600,004ms | 同上 |
| heartbeat-roaringmoon | 3acd15c2 | 2 | 03:41 | 600,004ms | 同上 |
| heartbeat-gengar | c29eca0f | 2 | 03:45 | 600,004ms | 同上 |

- ⭐ **這 8 張紅單不是新的 provider 問題，是 03:00 斷線視窗的下游症狀**（與 11-17 記錄過的「600s 逾時 → 自動停用倒數」同一機制：job 層 `sessionTarget=main` + 600s cron 上限，Discord 掛掉時 main lane 等不到回應就整整卡 600 秒）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 其他紅單（與 01:02 同批，未惡化）：`a72cb46b 每日 Agent × 軟體開發潮流研究` **ce=7（距自動停用門檻 10 剩 3 次，明天 10:00 再跑）**｜`58fe15dc 每日論文討論` ce=6｜`40e09cd1 Jormungand` ce=6（rate_limit）｜`45ccf4e9 晨間情報 pipeline` ce=5（timeout 1,200,815ms）｜`ae91b967 每日 LLM Wiki 巡讀` ce=4｜`08b7c00b rowlet-ut-veteran` ce=4｜`9e2cec7c skill-collection-review-mrmime` ce=4｜`b37129c0 群體智能架構研究` ce=2｜`ca222989 系統維護` ce=2（rate_limit）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ 轉綠：`6ddc8b4c PTCGP Meta 三日彙整` ce 4→0（01:02 ok, 99,087ms）、`5b7c1082 每日模型排行前十` ce=0（23:00）、`29c2d630 Gengar Cron Health Watchdog` ce=0、`537bd0dd Rowlet 轉錄監控` 04:00 ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 綠燈 27 支（含三支 KA、dreaming 但 dur 32 分鐘、健康回報 02:05 ok/70,032ms、`af94aa92 每日 OpenClaw 備份` ce=0 script payload、`09c7940b PTCGP Meta Analysis` ce=0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 良性長態不計紅單：`6e93c179 heartbeat-flaaffy` never run（每 10h anchor）；disabled 8 支中 `tmp-openai-probe a94330a9` ce=2（04:01 剛跑、已停用，忽略）、`d4cd45bc self-heal` **仍 disabled / never run**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（system scope）仍 crash-loop：NRestarts **105,590**（11-18 22:02 為 104,519 → +1,071／約 6h）；需 root，未動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 🔴 03:00 槽：連續第 3 晚原樣重演（明晚 11-20 03:00 是第 4 次）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | schedule | 本輪狀況 |
|---|---|---|---|
| Memory Dreaming Promotion | 36b493db | `0 3 * * *`（無 tz）| ok、dur **32.0 分鐘**、toolsAllow `["*"]`、**無 timeoutSeconds** → 今晚仍打死 Discord 30 分鐘 |
| Jormungand daily all-agent health | 40e09cd1 | `0 3 * * *` tz=Asia/Taipei | **error（rate_limit）**、dur=2,065,675ms、ce=6 |
| discord-selfheal-after-dreaming | d4cd45bc | `35,50 3,4 * * *` Asia/Taipei | **仍 disabled、never run**（腳本存在且守門完善，只在真的壞掉時才重啟） |

- 今晚 03:35 / 03:50 兩個 self-heal 槽位是「它能生效的第一個時點」，但 job 仍 disabled → **自動修復機制等於沒開**（今晚靠自癒撐過去，算是運氣好，不是機制）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ `36b493db` 是 **plugin-declared**（declarationKey `memory-core:memory-dreaming-promotion`）→ CLI 改排程可能被 declaration reconciliation 還原，持久修法要落到 memory-core plugin。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron 排程 / payload / timeout / config / provider / model / fallback / channel；未重啟 gateway；未啟用 `d4cd45bc`；未為了讓紅單轉綠而手動 run 其他 job；未碰 `elle.service`（需 root）。
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、journal（`--user`）、`systemctl --user show`、curl `/health`、ps/uptime/free/df、`channel_ingress_events`（複製 DB+WAL 後唯讀查詢）。
- **唯一外部寫入**：因 delivery.mode=none（最終回覆只進 run log），沿用前 8 輪做法用 rowlet 帳號把巡檢摘要貼到 Discord channel `1482363974119854234` → messageId `1572704014657912953`，deliveryStatus `sent`（同時再次實證 REST outbound 活）。

### 7) 給 Linder 的待決事項（第 15 輪，排序後）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最急・明晚 03:00 前・約 23 小時】清空 03:00 槽（第 4 次機會）**：
   - `openclaw cron edit 36b493db-deee-471d-a5a9-955d2455d067 --cron "30 4 * * *"`
   - `openclaw cron edit 40e09cd1-7629-42bb-9275-193879665724 --cron "45 4 * * *" --tz Asia/Taipei`
2. **【急】啟用 self-heal**：`openclaw cron enable d4cd45bc-357d-42d4-9ba1-f7eb39e02f59`（腳本有守門：只在真的有 `startup-not-ready` 且 dreaming 未在跑時才重啟）。
3. **【急】8 支 heartbeat 的 600s timeout**：job 層 `sessionTarget=main` → 改成 `isolated`（或照 charizard 加 `target:"none"`）；否則每次 03:00 斷線都會再產生 8 張紅單並逼近自動停用。
4. **【急】`a72cb46b` ce=7（距自動停用剩 3 次）**、429 仍每小時滲漏 1 筆 → 跨廠 fallback 仍是 0（`openai/*` Auth=no，**我不碰憑證**）。
5. （不急）`elle.service` crash-loop NRestarts 105,590，需 root。

### 8) 量測備忘<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 「event-loop starvation」只認 runtime 簽章 `[fetch-timeout] … timer delayed Nms, likely event-loop starvation`；單純 grep `starvation` / `event-loop` 會命中**自己報告的內文**（01:02 輪已踩過）。
- `channel_ingress_events` 沒有 `created_at` 欄，用 `received_at`（epoch ms）；DB 位於 `~/.openclaw/state/openclaw.sqlite`，唯讀查詢需連 `-wal`/`-shm` 一起複製。
- restricted automation-run session 中 `automations get/list` 對本 job 回 `not found`／空清單 → 改用 `openclaw cron list --all --json`（已知工具限制，非故障）；其 `state.lastDurationMs` / `lastRunAtMs` 才是權威欄位。

## 2026-11-19 07:02 — Picturecat Keep-Alive 第 11 輪：lane PASS、Discord 8/8 連線、紅單 −9、**新發現：OpenClaw 內建 health watchdog 的「host thaw → channel restart」在 04:19:53 真的動了**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `c3f1d160-dc0d-42de-ac4b-5b801e7d7322`、status=ok、回覆 `pong`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）：enabled、schedule=`every 10800000ms`（3h）、sessionTarget=isolated、payload=`agentTurn`「keep-alive test」+ model `minimax-portal/MiniMax-M3` + fallbacks 3 個（全同一 MiniMax Token Plan → 跨廠冗餘仍 0）、**無 timeoutSeconds**、delivery.mode=none；上一輪 04:02:02 **ok / dur=155,796ms / ce=0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`9d8b6001 Gengar KA` 07:02 ok/ce=0/dur=26,687ms；`880b5c17 Celesteela KA` 04:02 ok/ce=0/dur=129,613ms（payload `timeoutSeconds=300` 持續有效）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 本輪關鍵新事實：內建 health watchdog 有「host thaw → channel restart」機制，今天 04:19:53 **真的執行了**（修正 04:02 輪的「完全自癒」說法）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:02 輪記「03:31–03:32 client initialized → channels resolved → Discord 自癒、gateway 全程未重啟」。本輪翻出 **04:19:53 之後還有一次完整的 channel 層重啟**（前一份判讀漏看）：
  - 04:13:52–04:19:23 每 30 秒一筆 `[health] host thaw channel restart deferred: gateway still has active work`（共 13 筆）→ watchdog 想重啟 channel，但被「gateway 有在跑的工作」擋住（03:00–03:33 dreaming 那 32 分鐘正是那件工作）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:19:53** watchdog 終於動作：8 個帳號依序 `delaying provider startup 10s/20s/30s/40s/50s/60s/70s to reduce Discord startup rate limits` → 每 10 秒一個 `client initialized` + `channels resolved` → **04:21:04 第 8 個（rowlet）完成，全部 8/8 connected**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ✅ **gateway 本身從未重啟**：pid **2724303 自 11-18 04:44:05 CST 起（26h20m）**、systemd NRestarts=0、ActiveState=active、`/health` HTTP 200 in 1.27ms、uptime 38d12h、load 0.64、mem available 20GiB、disk 60%。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **修正後的因果鏈**：03:00 dreaming 塞死 event loop → 8 client 掉線、READY attempt 累積、4 個 `channel exited: did not reach READY`（celesteela 03:26、picturecat/mrmime 03:30、gengar 03:32）→ 03:31 起部分 client 自行重連（這是 04:02 輪看到的）→ **但真正讓 8/8 穩定的是 04:19:53 那次內建 channel restart**，不是純粹「client 自癒」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **對 `d4cd45bc` 的啟用決策有直接影響**：內建 watchdog 已能做 **channel 層**重啟（比重啟整個 gateway 輕），且它的門檻是「gateway 有 active work 就等」→ dreaming 跑的 32 分鐘裡它動不了，必須等 job 結束（今天等了 19 分鐘）。`d4cd45bc` 的價值在於「內建 watchdog 還在等、或等到天亮」時的後備重啟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 每次 Discord provider 啟動都會噴 `111 commands exceed the 100-command Discord limit; removing per-skill commands and keeping /skill` → per-skill 斜線指令被裁掉（設定層現象，非故障）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Discord runtime：04:00 之後乾淨（0 READY timeout、0 starvation）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 07:02 `openclaw channels status`：**8/8 enabled 帳號全部 `running, connected`**（greninja disabled/stopped = 預期）；inbound 新鮮度 celesteela 21m、gengar 58m、mrmime 52m、rowlet 3h、roaringmoon 7h、charizard 22h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- READY timeout（真簽章，排除 agent 報告內文）：近 3h = **0**（grep 命中 1 筆是 04:08:37 Gengar KA 的報告句，非 runtime 事件 —— 同一個假陽性陷阱）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- event-loop starvation（`[fetch-timeout] … timer delayed Nms, likely event-loop starvation`）：04:00 後 = **0**；今日共 16 筆全在 03:00–03:30 dreaming 區間，max **timer delayed 18,749ms**（比 11-18 的 101,948ms 輕 5.4 倍）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `startup-not-ready` 自 03:00 起 = **0** 筆；websocket closed 自 04:00 起 9 行（8×code 1005 + 1×code 1006）→ 全部自癒重連，未演變成 READY timeout。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- inbound 實流量（唯讀查 `channel_ingress_events`）：近 3h **18 筆全 completed、0 failed / 0 pending**（rowlet 7、mrmime 7、gengar 3、celesteela 1）；每小時 11-19 04h=10、05h=5、06h=4、07h≥2。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：53 jobs / 45 enabled / 8 disabled — enabled ok 30 / error 8 / skipped 6 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- vs 04:02 基準（ok 27 / error 17）→ **error −9、ok +3**：04:02 那 8 張 heartbeat 紅單（dur=600,004ms / timeout）**全數自動轉綠**（heartbeat-mrmime 06:31 ok、heartbeat-charizard 06:54 ok，其餘 6 支為 skipped、ce=0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 剩餘 8 張紅單**全是 11-18 的舊帳**（本輪未惡化）：

| job | id | ce | 最後 dur | 原因 |
|---|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | **7** | 143,782ms | rate_limit（**距自動停用門檻 10 剩 3 次**）|
| 每日論文討論 | 58fe15dc | 6 | 246,782ms | rate_limit |
| Jormungand daily all-agent health | 40e09cd1 | 6 | 2,065,675ms | rate_limit（03:00 那支）|
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | 5 | 1,200,815ms | timeout |
| 每日 LLM Wiki 巡讀與擴寫 | ae91b967 | 4 | 3,859ms | rate_limit |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | 4 | 4,986ms | rate_limit |
| skill-collection-review-mrmime | 9e2cec7c | 4 | 629ms | rate_limit |
| 群體智能架構研究 | b37129c0 | 2 | 1,907,824ms | rate_limit |

- ✅ 綠燈：`02eb0989 Picturecat KA` ce=0、`880b5c17 Celesteela KA` ce=0、`9d8b6001 Gengar KA` ce=0、`36b493db dreaming` ce=0（dur 1,922,307ms）、`ca222989 系統維護` 06:04 ok、`13ac4b5a 健康回報` 05:05 ok、`d7b0355b Jormungand mrmime Codex A2A heartbeat` 06:00 ok、`af94aa92 每日 OpenClaw 備份` ce=0、`537bd0dd Rowlet 轉錄監控` 07:00 ok。
- `6e93c179 heartbeat-flaaffy` never run、`a94330a9 tmp-openai-probe` disabled+error（忽略）、`d4cd45bc self-heal` **仍 disabled / never run** → 良性長態不計紅單。
- `elle.service`（system scope）仍 crash-loop：NRestarts **105,947**（04:02 為 105,590 → +357／約 3h）；需 root，未動。

### 5) Provider：429 仍低度滲漏，但 fallback 這次全部兜住了<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `status=429` 逐小時：11-19 04h=2、05h=1、06h=1、**07h=2**（仍是「每小時 1–2 筆」的滲漏，不是尖峰）。
- ✅ **04:00 之後 `All models failed` = 0 筆** → 這段時間沒有任何 job 因此失敗；fallback 鏈全被單一模型擋下時才會炸出紅單，今天沒有。
- ⚠️ 另見 4 筆 `Codex agent harness failed; not falling back to embedded OpenClaw backend`（03h=2、04h=2）→ `lane task error: lane=main|cron-nested durationMs=24–52 "Codex agent harness cannot enforce this conversation's tool policy. Use the embedded runtime or ask in the main conversation."` → 良性（瞬間失敗），但顯示 **Codex 這條路徑仍不可用**（呼應 11-16 記錄的 openai-codex 401）。

### 6) 🔴 03:00 槽：連續第 4 晚原樣（距 11-20 03:00 約 20 小時）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | schedule | 現況 |
|---|---|---|---|
| Memory Dreaming Promotion | 36b493db | `0 3 * * *`（無 tz）| ok、dur **1,922,307ms（32.0 分）**、toolsAllow `["*"]`、**無 timeoutSeconds**、next=**11-20 03:00**（第 4 次）|
| Jormungand daily all-agent health | 40e09cd1 | `0 3 * * *` tz=Asia/Taipei | error（rate_limit）、dur=2,065,675ms、ce=6、next=11-20 03:00 |
| discord-selfheal-after-dreaming | d4cd45bc | `35,50 3,4 * * *` Asia/Taipei | **仍 disabled、never run**（腳本存在且守門完善）|

- 今晚 03:35 / 03:50 是 self-heal 能生效的第一個時點，但 job 仍 disabled → **自動修復機制等於沒開**；今天靠的是內建 watchdog 的 channel restart（04:19:53）撐過去。
- ⚠️ `36b493db` 仍為 **plugin-declared**（declarationKey `memory-core:memory-dreaming-promotion`）→ CLI 改排程可能被 declaration reconciliation 還原，持久修法要落到 memory-core plugin 原始碼。

### 7) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron 排程 / payload / timeout / config / provider / model / fallback / channel；未重啟 gateway 或 channel；未啟用 `d4cd45bc`；未為了讓紅單轉綠而手動 run 其他 job；未碰 `elle.service`（需 root）；未動憑證。
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、journal（`--user`）、`systemctl --user show` / `systemctl show`、curl `/health`、ps/uptime/free/df、`channel_ingress_events`（複製 DB+WAL/SHM 後唯讀查詢）。

### 8) 給 Linder 的待決事項（第 16 輪，排序後）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最急・距 11-20 03:00 約 20 小時】清空 03:00 槽（第 4 次機會）**：
   - `openclaw cron edit 36b493db-deee-471d-a5a9-955d2455d067 --cron "30 4 * * *"`
   - `openclaw cron edit 40e09cd1-7629-42bb-9275-193879665724 --cron "45 4 * * *" --tz Asia/Taipei`
2. **【急】`d4cd45bc` 啟用決策（新增依據）**：內建 watchdog 已在 04:19:53 成功做過 **channel 層**重啟（比重啟整個 gateway 輕、影響小），所以 self-heal 的邊際價值下降；但它是「內建 watchdog 還在等 active work / 等到天亮」時的唯一後備 → **建議仍啟用**當後備，而非唯一解。
3. **【急】8 支 heartbeat 的 `sessionTarget=main`**：04:02 斷線時又全部卡滿 600s 變紅（今天已自動回綠，但每次 03:00 都會再發生）→ 改成 `isolated` 或照 charizard 加 `target:"none"`。
4. **【急】`a72cb46b` ce=7（距自動停用剩 3 次）** + 429 每小時滲漏 1–2 筆 → 跨廠 fallback 仍是 0（`openai/*` Auth=no，**我不碰憑證**）；Codex harness 今天又失敗 4 次（`cannot enforce tool policy`）。
5. （不急）`elle.service` crash-loop NRestarts 105,947，需 root。

### 9) 量測備忘（本輪再確認）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 「event-loop starvation / READY timeout」只認 runtime 簽章，並排除 `agent:nested` / `agent:main` 報告行——本輪 grep READY timeout 命中 1 筆，實為 Gengar KA 的報告文字（04:08:37），真實 runtime = 0。
- `channel_ingress_events` 沒有 `created_at`，用 `received_at`（epoch ms）；DB 在 `~/.openclaw/state/openclaw.sqlite`，唯讀查詢須連 `-wal`/`-shm` 一起複製。
- restricted automation-run session 中 `automations get/list` 對本 job 回 not found／空清單（已知限制）→ 改用 `openclaw cron list --all --json`；`state.lastDurationMs` / `lastRunAtMs` 才是權威欄位。
- **看 Discord 斷線要看「host thaw / client initialized / channels resolved / READY timeout / channel exited」整組簽章**，單看 `channels status` 會誤判「沒事」（04:02 輪就是這樣漏掉 04:19:53 的重啟）。

### 10) 本輪對外動作（唯一一次外部寫入）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 因 delivery.mode=none（最終回覆只進 run log），沿用前 10 輪做法用 rowlet 帳號把巡檢摘要貼到 Discord channel `1482363974119854234` → **messageId `1572749343113478268`，deliveryStatus `sent`**（同時再次實證 REST outbound 活）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-19 13:02 — Picturecat Keep-Alive 第 12 輪：lane PASS、**但本 job 自己在 10:02 連 4 次因 MiniMax Token Plan 用量上限爆紅單（ce=4）**、紅單 8→15、**09:00–13:00 是每日準時發生的 4 小時配額枯竭窗**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `78cfd46c-7f69-442e-bdff-ddbe89b9309e`、status=ok、回覆「pong — no active task, no recent errors, healthy.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）：enabled、schedule=`every 180min`、sessionTarget=isolated、payload=`agentTurn`「keep-alive test」+ model `minimax-portal/MiniMax-M3` + **3 個 fallback 全是 MiniMax**（`minimax/MiniMax-M3`、`minimax-portal/MiniMax-M2.7`、`minimax/MiniMax-M2.7` → **跨廠冗餘仍是 0**）、無 timeoutSeconds、delivery.mode=none。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⛔ **本 job 上一輪（10:02）連 4 次全滅**，這是本輪最大事件：10:02:16 / 10:02:56 / 10:04:03 / 10:09:10 全部 `cause=rate_limit`、dur 6.9–8.8s、error=「All models failed (4): … HTTP 429 … **Token Plan usage limit reached**」→ `consecutiveErrors=4`；本輪 13:02 恢復正常（dur ~2.4 分）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` 10:02 error（ce=1, dur 5,527ms）→ **13:02 已 ok**（`cron_run_receipts` 13:03:28 finished/status=ok）；`9d8b6001 Gengar KA` 10:02 error（ce=4, dur 5,986ms）→ 13:02 當時仍 running。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 本輪關鍵新事實：MiniMax Token Plan 配額枯竭是**每天準時發生的 4 小時窗口**，今天 09:00–13:00<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 用真簽章 `Token Plan usage limit reached`（MiniMax 回傳 code 2056）逐時重算近 4 天：11-16 05–07 / 12–13 / 16–17 / 20–22、11-17 01–03、11-18 07 / **09–12** / 16–17、**11-19 09–12**。→ **每天都有 4 小時級的配額枯竭窗**，且時段高度固定。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 今天窗口內：Token Plan 429 = **463 筆**、`All models failed` = **36 筆**、`status=429` = **649 筆**（09h 152 / 10h 229 / 11h 115 / 12h 136）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **13:00 起幾乎歸零**（13h 僅 1 筆）→ 配額窗在 13:00 關閉 → 13:02 三支 KA 全部恢復（Celesteela 13:03:28 收件 ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **量測教訓（修正前幾輪的誤判）**：前幾輪只數 `status=429` / `All models failed`，把它描述成「每小時 1–2 筆的滲漏」，其實是 100–230 筆/小時的**尖峰**。真正簽章是 `Token Plan usage limit reached`；用它重算才看見真相。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **影響面是 cron lane，不是使用者**：窗口內 463 筆 429 全無 session 屬性（provider 層 fallback 決策），journal 中唯一 `agent:*:main` 筆是 13:02 我自己的 probe（成功）；Discord ingress 近 3h **150 筆全 completed、0 failed / 0 pending**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Fleet：53 jobs / 45 enabled / 8 disabled — ok 25 / error **15** / skipped 4 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- vs 07:02 基準（ok 30 / error 8）→ **error +7、ok −5**。轉綠 3 支：`58fe15dc 每日論文討論`(ce 6→0)、`45ccf4e9 晨間情報 pipeline`(5→0)、`b37129c0 群體智能架構研究`(2→0)。新爆 10 支（全是窗口內跑的）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單 15 支（enabled 且 lastRunStatus=error）：

| job | id | ce | 最後 dur | schedule | 原因 |
|---|---|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | **8** | 254,444ms | `0 10 * * *` | rate_limit（**距自動停用門檻 10 剩 2 次**）|
| heartbeat-mrmime | bcf270b8 | **8** | 5,491ms | every 30min | agent-runner-failure（429）|
| OpenClaw 系統維護 | ca222989 | **7** | 3,565ms | `0 * * * *` UTC | rate_limit |
| heartbeat-gengar | c29eca0f | **7** | 4,348ms | every 30min | agent-runner-failure（429）|
| heartbeat-charizard | ffc90b7d | 6 | 5,706ms | every 30min | agent-runner-failure（429）|
| heartbeat-roaringmoon | 3acd15c2 | 6 | 3,715ms | every 30min | agent-runner-failure（429）|
| Jormungand daily all-agent health | 40e09cd1 | 6 | 2,065,675ms | `0 3 * * *` | rate_limit（11-19 03:00）|
| 每日 LLM Wiki 巡讀與擴寫 | ae91b967 | 5 | 264,959ms | `0 9 * * *` | rate_limit |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | 5 | 137,368ms | `0 12 * * *` | rate_limit |
| **Picturecat Keep-Alive** | **02eb0989** | 4 | 6,939ms | every 180min | **rate_limit（10:02 連 4 次）** |
| Gengar Keep-Alive | 9d8b6001 | 4 | 5,986ms | every 180min | rate_limit（10:02） |
| 健康回報 | 13ac4b5a | 4 | 3,974ms | `5 */3 * * *` UTC | rate_limit |
| Jormungand mrmime Codex A2A heartbeat | d7b0355b | 4 | 4,359ms | `0 */6 * * *` | rate_limit（12:00）|
| skill-collection-review-mrmime | 9e2cec7c | 4 | 629ms | every 7d | rate_limit（11-18 舊帳）|
| Celesteela Keep-Alive | 880b5c17 | 1 | 5,527ms | every 180min | rate_limit（10:02）|

- ⛔ **逼近自動停用門檻（ce=10）的結構性名單**：`a72cb46b` ce=8（**每天 10:00 固定落在配額窗內 → 明天 10:00 幾乎必爆 ce=9 → 11-21 ce=10 被自動停用**）、`bcf270b8` ce=8、`ca222989` ce=7、`c29eca0f` ce=7、`ffc90b7d` ce=6、`3acd15c2` ce=6。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ 綠燈：`36b493db dreaming` ce=0（dur 1,922,307ms）、`58fe15dc`、`45ccf4e9`、`b37129c0`、`88810bfe BBC News`、`89e2cfe7 clean-code研究`、`af94aa92 每日備份` ce=0、`537bd0dd Rowlet 轉錄監控` 13:00 ok、`29c2d630 Gengar Cron Health Watchdog` 12:04 ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `skipped: no-route` 4 支（heartbeat-rowlet/picturecat/celesteela/greninja）、`6e93c179 heartbeat-flaaffy` never run、`d4cd45bc self-heal` **仍 disabled / never run** → 良性長態，不計紅單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Discord runtime：8/8 connected、0 READY timeout、0 starvation<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 13:03 `openclaw channels status`：**8/8 enabled 帳號全部 `running, connected`**（greninja disabled/stopped = 預期）；inbound 新鮮度 celesteela 1m / roaringmoon 37m / mrmime 58m / rowlet 3h / charizard 4h / gengar 5h；picturecat、flaaffy 視窗內無 inbound。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- READY timeout（真簽章，排除 agent 報告內文）：近 10h = **0**（grep 命中 2 筆在 04:06:54 → 實為 Gengar 報告句 `[agent:nested] session=agent:gengar:main`，同一個假陽性陷阱第三次出現）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- event-loop starvation（`[fetch-timeout] … timer delayed Nms, likely event-loop starvation`）：**16 筆全在 03h**，04:00 之後 = 0，max timer delayed = **18,749ms**（與 07:02 輪同值，09:00 後無新實例）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `channel exited` 13 筆全在 03h；`client initialized` / `channels resolved`：03h 17/8 + 04h 8/8 → **04:19:53 那次 watchdog channel restart 之後 9 小時無任何重啟**；`host thaw` 114 筆（03h 75 / 04h 39）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- websocket closed：05h–12h 每小時 2–6 筆自癒重連，**無一筆演變成 READY timeout** → 穩定。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- inbound 實流量（唯讀查 `channel_ingress_events`）：近 3h **150 筆全 completed、0 failed / 0 pending**（celesteela 142 / roaringmoon 4 / mrmime 3 / rowlet 1；每小時 10h 39、11h 55、12h 50、13h 6）；近 6h 206 筆全 completed。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Gateway / 主機：無恙<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- pid **2724303 自 11-18 04:44:05 CST 起（32h20m）**、systemd NRestarts=0 / ActiveState=active、`/health` HTTP 200 in **1.5ms**、host uptime 38d18h50m、load 1.46/0.75/0.56、mem available 20GiB、disk 60%。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（system scope）仍 crash-loop：NRestarts **106,662**（07:02 為 105,947 → +715／約 6h）；需 root，未動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 🔴 03:00 槽：連續第 4 晚原樣（距 11-20 03:00 約 14 小時）＋**今日新增第二個獨立失敗理由**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | schedule | 現況 |
|---|---|---|---|
| Memory Dreaming Promotion | 36b493db | `0 3 * * *`（無 tz）| ok、ce=0、dur 1,922,307ms（32.0 分）、next=**11-20 03:00**（第 4 次）|
| Jormungand daily all-agent health | 40e09cd1 | `0 3 * * *` tz=Asia/Taipei | error、ce=6、dur 2,065,675ms、next=11-20 03:00 |
| discord-selfheal-after-dreaming | d4cd45bc | `35,50 3,4 * * *` Asia/Taipei | **仍 disabled、never run** |

- ⭐ **新理由（本日新證據）**：03:00 槽在配額史上也被打到過 —— 11-16T03 有 55 筆 Token Plan 429、11-17 01–03 共 279 筆 → dreaming 在 03:00 既可能整段被 **event-loop 阻塞**，也可能被 **配額枯竭**卡死 → **兩個彼此獨立的失敗原因疊在同一個槽**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ `36b493db` 仍為 **plugin-declared**（declarationKey `memory-core:memory-dreaming-promotion`）→ CLI 改排程可能被 declaration reconciliation 還原，持久修法要落到 memory-core plugin 原始碼。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron 排程 / payload / timeout / fallback / config / provider / model / channel；未重啟 gateway 或 channel；未啟用 `d4cd45bc`；未為了讓紅單轉綠而手動 run 其他 job；未碰 `elle.service`（需 root）；未動憑證。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id <full-uuid>`、journalctl --user（唯讀）、`systemctl --user show` / `systemctl show`、curl `/health`、uptime/free/df、`cron_run_receipts` 唯讀、`channel_ingress_events`（複製 DB+WAL/SHM 後唯讀查詢）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 例外：本輪有且只有一次外部寫入 = 貼巡檢摘要到 Discord（見 §10）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（第 17 輪，排序後）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最急・距 11-20 03:00 約 14 小時】清空 03:00 槽（第 4 次機會）**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - `openclaw cron edit 36b493db-deee-471d-a5a9-955d2455d067 --cron "30 4 * * *"`
   - `openclaw cron edit 40e09cd1-7629-42bb-9275-193879665724 --cron "45 4 * * *" --tz Asia/Taipei`
2. **【最急・本輪新增】MiniMax Token Plan 配額窗（每日 09:00–13:00）需要一個跨廠 fallback 或改時段**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - 現在 KA 三支的 4 個 fallback **全是 MiniMax** → 配額一枯竭就「4 個模型一起死」，跨廠冗餘 = 0（這就是 10:02 本 job 自己連爆 4 次的直接原因）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - `a72cb46b` ce=8、再 2 次就被自動停用，而它 **每天 10:00 都在窗口內** → 這是結構性問題，不是運氣問題。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - 可選方案：(a) 把 `a72cb46b` / `ae91b967` / `08b7c00b` 移到配額窗之外（例如 14:00 / 15:00 / 16:00）；(b) 補一個非 MiniMax provider 的 fallback；(c) 兩者都做。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急】`d4cd45bc` 啟用決策（沿用上輪建議：啟用當內建 watchdog 的後備）**：內建 watchdog 已在 04:19:53 做過 channel 層重啟，但它要等 gateway 閒置；self-heal 是它等不到時的唯一後備。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【急】8 支 heartbeat 的 `sessionTarget=main`**：改成 `isolated` 或照 charizard 加 `target:"none"`，避免 03:00 斷線時集體卡滿 600s 變紅。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. （不急）`elle.service` crash-loop NRestarts 106,662，需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 量測備忘（本輪再確認）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **MiniMax 429 的真簽章 = `Token Plan usage limit reached`（code 2056）**；只數 `status=429` 會把 4 小時尖峰誤讀成「每小時 1–2 筆滲漏」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 「event-loop starvation / READY timeout」只認 runtime 簽章，並排除 `agent:nested` / `agent:main` 報告行 —— 本輪 READY timeout 命中 2 筆，實為 Gengar 報告文字（04:06:54），真實 runtime = 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- restricted automation-run session 中 `automations get/list` 對本 job 回 not found／空清單（已知限制）→ 改用 `openclaw cron list --all --json`；`openclaw cron runs --id <完整 UUID>` 才查得到（短 id 會被拒），且 **`entries[].cause`（rate_limit / timeout / agent-runner-failure）才是紅單根因**，`state.lastRunStatus` 只有 ok/error。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `cron_run_receipts`（唯讀）可驗證「某一輪是否真的跑完」：status=running / ok / failed + started_at_ms / finished_at_ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `channel_ingress_events` 沒有 `created_at`，用 `received_at`（epoch ms）；DB 在 `~/.openclaw/state/openclaw.sqlite`，唯讀查詢須連 `-wal`/`-shm` 一起複製。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 本輪對外動作（唯一一次外部寫入）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 因 delivery.mode=none（最終回覆只進 run log），沿用前 11 輪做法用 rowlet 帳號把巡檢摘要貼到 Discord channel `1482363974119854234` → **messageId `1572840700003877066`，deliveryStatus `sent`**（同時再次實證 REST outbound 活）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-19 19:02 — Picturecat Keep-Alive 第 13 輪：lane PASS（本輪轉綠）、**新發現：MiniMax 配額窗今天有「兩個」——下午 16:00–18:00 是第二個尖峰（304 筆）**、Discord 8/8、Gateway 38h 無重啟<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) 本 job 自身狀態：連 4 敗後本輪轉綠（ce 4 → 0）
- run 紀錄（`openclaw cron runs --id 02eb0989-…`，ts=結束時間 UTC／括號內為台北）：**16:06（dur 252,257ms＝4.2 分鐘）/ 16:07 / 16:08 / 16:13 四連敗**，全部 `errorReason=rate_limit`，四個 fallback（minimax-portal/MiniMax-M3、minimax/MiniMax-M3、minimax-portal/MiniMax-M2.7、minimax/MiniMax-M2.7）**全數 HTTP 429 `Token Plan usage limit reached`（MiniMax code 2056）**；`minimax-portal` 當場還被標 "in cooldown"。
- 中間 **13:08 那輪是 ok**（dur 365,465ms）→ ce 由 4 歸零；再被 16:06–16:13 打到 ce=4。**本輪 19:02 用 minimax-portal/MiniMax-M3 正常跑完 → ce 4→0**。
- `openclaw models list`（19:05）：7 個 MiniMax model 全部 `configured`，**無 unavailable / cooldown 標記** → provider 已恢復。

### 2) ⭐⭐ 本輪核心新事實：**配額窗不是「每天只有一個 09:00–13:00」**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `Token Plan usage limit reached` 逐時分布（journalctl 為本地台北時）：

| 台北時 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 429 筆數 | 102 | 172 | 88 | 101 | **0** | **0** | **0** | **193** | **111** | **0** | **0** |

- 對應 `All models failed` 筆數：09→8、10→13、11→7、12→8、16→15、17→9。
- → **今日兩個獨立尖峰**：晨窗 09:00–13:00（463 筆，13:00 歸零）、**午後窗 16:00–18:00（304 筆，18:00 歸零）**；13:00–16:00 完全乾淨（3 小時 0 筆）。18:00 之後 0 筆 → 19:02 本輪恢復。
- **歷史對照（修正既有模型）**：11-16 有 16–17 與 20–22、11-18 有 16–17 → **午後/晚間尖峰是反覆出現的第二峰**，先前 MEMORY.md 寫的「每日準時發生的 4 小時窗口 09:00–13:00」只是**一天中最容易看到的那一段**，不是固定邊界。
- 被午後窗打紅的 job：`02eb0989` Picturecat KA（16:06–16:13，ce=4）、`880b5c17` Celesteela KA（16:07，ce=2）、`13ac4b5a` 健康回報（17:12，ce=4）—— 三支全部 `rate_limit`。

### 3) 全艦 tally（45 enabled / 50 jobs）
| 狀態 | 數量 | 明細 |
|---|---|---|
| ok | 34 | 含 dreaming `36b493db` ce=0（dur 1,922,307ms）、Jormungand `40e09cd1` ce=0、備份/研究類全綠 |
| error | 6 | `02eb0989` ce=4（**本輪轉綠**）、`880b5c17` ce=2、`13ac4b5a` ce=4、`ae91b967` ce=5、`08b7c00b` ce=5、`a72cb46b` ce=8 |
| skipped | 4 | heartbeat-rowlet / picturecat / celesteela / greninja（`no-route`，良性長態） |
| never | 1 | `6e93c179` heartbeat-flaaffy |

- 紅單 6 支全部根因 = **rate_limit（Token Plan 2056）**，無 timeout / agent-runner-failure。
- ⛔ **自動停用倒數（ce=10）**：`a72cb46b` ce=8、**每天 10:00 TPE 固定落在晨窗內 → 11-20 ce=9、11-21 ce=10 被自動停用**；`08b7c00b` ce=5、`ae91b967` ce=5。
- `d4cd45bc discord-selfheal-after-dreaming` **仍 disabled / never run**（良性長態，不計紅單）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Discord runtime：8/8（7 enabled）connected、12h 內 0 次 channel 重啟<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 19:02 `openclaw channels status`：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet 全部 `running, connected`，transport 皆 `just now`；greninja `disabled/stopped`（預期）。
- inbound 新鮮度（in:）：celesteela 5m、mrmime 54m、roaringmoon 31m、gengar 5h、rowlet 6h、charizard 10h；picturecat、flaaffy 視窗內無 inbound。
- 12h 內：`READY wait timed out` = **0**、`client initialized` = **0**、`channel exited` = 0 → **自 04:19:53 watchdog 那次 channel restart 後已 14.7 小時無任何重啟**。
- `websocket closed` 8 筆（17:08/17:16/17:36/17:40/17:57/18:15/18:41/19:02）＝每 15–25 分鐘一次自癒重連，**無一筆演變成斷線**。
- event-loop starvation（真簽章 `[fetch-timeout] … timer delayed Nms, likely event-loop starvation`）：**24h 16 筆全在 03h；12h = 0**（07:00 後無新實例）。
- `prepared model runtime plugin generation was superseded`：12h 30 筆（07h 12 / 08h 4 / 13h 7 / 16h 7）→ 仍集中在多 job 同時起跑＋配額窗附近。
- `Codex agent harness` 失敗：24h 16 筆、**12h = 0**（本輪窗內不再出現）。

### 5) Gateway / 主機：無恙<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- pid **2724303 自 11-18 04:44:05 CST 起（38h19m）**、systemd NRestarts=0 / ActiveState=active、`/health` HTTP 200 in **1.17ms**、host uptime 39d49m、load 0.65/0.48/0.46、mem available 20GiB、disk 60%（265G/468G）。
- `elle.service`（system scope）仍 crash-loop：NRestarts **107,375**（13:07 輪 106,662 → +713／約 6h）、ActiveState=activating；需 root，未動。
- `openclaw models list` 有 config warning：`a2a-gateway` plugin 缺 compiled `dist/index.js`（TypeScript 原始碼僅支援 source checkout）→ **良性但會讓 A2A plugin 走 source fallback**，值得記一筆。

### 6) 03:00 槽：明天（11-20）03:00 又要重演（距今約 8 小時）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | schedule | 現況 |
|---|---|---|---|
| Memory Dreaming Promotion | 36b493db | `0 3 * * *`（無 tz = gateway local） | ok、ce=0、dur 1,922,307ms（32.0 分）、next=**11-20 03:00 TPE**（第 4 次） |
| Jormungand daily all-agent health | 40e09cd1 | `0 3 * * *` tz=Asia/Taipei | ok、ce=0、dur 681,583ms、next=11-20 03:00 TPE |
| discord-selfheal-after-dreaming | d4cd45bc | `35,50 3,4 * * *` Asia/Taipei | **仍 disabled、never run** |

- ⚠️ **小發現**：`40e09cd1` 今天除 03:00 槽外還在 **15:47–15:59 TPE** 多跑了一輪（ok、dur 11.4 分）→ 非 cron 槽內時間，疑為手動 `cron run` 或外部觸發（來源待查，低優先）。
- `36b493db` 仍為 **plugin-declared**（declarationKey `memory-core:memory-dreaming-promotion`）→ CLI 改排程可能被 declaration reconciliation 還原，持久修法要落到 memory-core plugin。

### 7) ⚠️ 量測受限（**本輪新遇到的工具閘**）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sqlite3` 讀 OpenClaw state DB 被新的 exec guard 擋下：`external sqlite3 cannot open databases under the active OpenClaw state directory. Use OpenClaw commands for live state, or inspect a private backup copy outside OPENCLAW_STATE_DIR.`
- **複製到 `/tmp/ka.sqlite`（含 -wal/-shm）與 `/home/amr/ka-check/dbcopy` 都被擋** → guard 是看內容／身分，不是看路徑。
- 影響：**本輪無法查 `channel_ingress_events`（inbound 真流量）與 `cron_run_receipts`（run 完成度）** —— 13:07 輪還能用這招。替代證據改用 Discord 層（`channels status` 的 in:/out: 新鮮度 + journal 的 websocket/READY 簽章組）。
- 量測備忘：`cron runs` 的 `ts` 是**結束時間**（`40e09cd1` 11-18 19:34 UTC + dur 2,065,675ms → 實際 03:00 TPE 起跑）→ 算「起跑時間」要減掉 duration。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron 排程 / payload / timeout / fallback / config / provider / model / channel；未重啟 gateway 或 channel；未啟用 `d4cd45bc`；未為了讓紅單轉綠而手動 run 其他 job；未碰 `elle.service`（需 root）；未動憑證；未自行放寬 modelPolicy（跨廠 fallback 屬全域決策，留給 Linder）。
- 探測全唯讀：`openclaw cron list --all --json`、`openclaw cron runs --id <full-uuid>`、`openclaw channels status`、`openclaw models list`、journalctl --user（唯讀）、`systemctl --user show` / `systemctl show`、curl `/health`、uptime/free/df。
- 例外：本輪有且只有一次外部寫入 = 貼巡檢摘要到 Discord（見 §10）。

### 9) 給 Linder 的待決事項（第 13 輪，排序後）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最急・距 11-20 03:00 約 8 小時】清空 03:00 槽**：`openclaw cron edit 36b493db-deee-471d-a5a9-955d2455d067 --cron "30 4 * * *"`、`openclaw cron edit 40e09cd1-7629-42bb-9275-193879665724 --cron "45 4 * * *" --tz Asia/Taipei`（ dreaming 是 plugin-declared，可能被還原 → 治本在 memory-core plugin）。
2. **【急・本輪新證據】配額窗會出現在午後（今天 16:00–18:00）→ 不能只避開 09:00–13:00**：`a72cb46b` 每天 10:00 仍在晨窗內（11-20 ce=9、11-21 ce=10 → 被自動停用）；建議把窗內 job 全部搬到 **19:00 之後**（今天 18:00 起 429 = 0），或補一個**非 MiniMax** provider 的 fallback（現在 4 個 fallback 全 MiniMax → 跨廠冗餘 = 0，配額一枯竭就 4 個模型一起死）。
3. **【急】`d4cd45bc` 啟用決策**：內建 watchdog 已在 04:19:53 做過 channel 層重啟，但它要等 gateway 閒置；self-heal 是它等不到時的唯一後備（`openclaw cron enable d4cd45bc-357d-42d4-9ba1-f7eb39e02f59`）。
4. **【急】8 支 heartbeat 的 `sessionTarget=main`** → 改成 `isolated`（或照 charizard 加 `target:"none"`），避免 03:00 斷線時集體卡滿 600s 變紅。
5. **【新】巡檢的 state DB 唯讀查詢被 exec guard 擋** → 若要保留「inbound 真流量」這個量測維度，需要一個放行方式（`openclaw` 內建命令或調整 guard 的私人備份路徑）。
6. （不急）`elle.service` crash-loop NRestarts 107,375，需 root。

### 10) 本輪對外動作（唯一一次外部寫入）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 因 delivery.mode=none（最終回覆只進 run log），沿用前 12 輪做法用 rowlet 帳號把巡檢摘要貼到 Discord channel `1482363974119854234`（REST outbound 實證活）。
- 結果：**messageId `1572930885903458457`，deliveryStatus `sent`**（REST outbound 再次實證活）。
