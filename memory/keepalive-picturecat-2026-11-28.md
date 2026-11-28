# Picturecat Keep-Alive 巡檢日誌（2026-11-28）

## 2026-11-28 13:02 — Picturecat Keep-Alive 第 24 輪：🟢 lane PASS、🟢 Discord 現況健康、🔴 **04:25 dreaming 又打瞎 Discord 43 分鐘且 selfheal 守門再次失手（第 5 夜）**、🔴 **06:00 DNS 超級風暴 344 筆**、🔴 **08:00–12:05 Token Plan 配額牆回歸（連續 3 輪零之後）**、🔴 **本 job 連 5 槽 error／6 槽零紀錄** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

> 輪號口徑：上一筆有紀錄的巡檢＝**11-27 16:02 第 17 輪**（`memory/keepalive-picturecat-2026-11-27.md`）。其後 6 槽（11-27 19:02／22:02、11-28 01:02／04:02／07:02／10:02）**全部零記憶檔** → 本輪順推為 **第 24 輪**。

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId **`9e571f20-59d6-4daf-bec4-f65ddcff8183`**、status=ok、回覆「pong — no active task, no recent errors, Discord inbound/outbound OK.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）狀態：enabled、schedule=`every 10800000ms`（3h）、anchor=`1780452122531`、sessionTarget=isolated、agentId=**None**（KA 路由空殼）、delivery.mode=**none**、payload=`agentTurn`「keep-alive test」+ model `minimax-portal/MiniMax-M3` + fallbacks `['minimax/MiniMax-M3','minimax-portal/MiniMax-M2.7']`、**無 `timeoutSeconds`**、上一輪 ce=**5**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` **enabled / ce=4**（agentId=celesteela、payload 已補完整巡檢步驟）、`9d8b6001 Gengar KA` **🔴 已被自動停用（enabled=false / ce=10）** → **三支 KA 只剩 2 支在跑**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 13:02 槽同時在跑：`880b5c17`（celesteela）＋ `02eb0989`（本 job）→ anchor Δ **39ms**（picturecat 1780452122531 → celesteela 1780452122603）＝ **KA 疊窗第 43 次**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🔴 頭號事件：**04:25 dreaming 第 5 夜打死 Discord，盲窗 43 分鐘，而 selfheal 守門再次失手**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion` 今日 04:25:xx 起跑 → **04:54:03 ok / dur=1,741,340ms（29.0 分鐘）**、summary=`NO_REPLY`（連續第 2 天回 NO_REPLY）、ce=0、next 11-29 04:25。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 斷線時間軸（journal 實測，04:20–06:00 共 1,973 行）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:27:56** health-monitor 重啟 `discord:celesteela` ＋ `discord:mrmime`（reason=disconnected）→ **這是本場第一個症狀，簽章是 `disconnected` 不是 `startup-not-ready`**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:28:08** 開始 event-loop starvation（`timer delayed 9267ms, likely event-loop starvation`，全窗共 **28 筆**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 04:28:41 client initialized → 04:32:29 首次 `READY wait timed out after 15000ms (attempt 1)`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:44:01 `channel exited: discord gateway opened but did not reach READY within 30000ms`（roaringmoon）** → 全窗唯一一次 channel exit。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 05:00:26 `channels resolved` → 05:00:43 `client initialized` → **05:11:08 最後一筆 READY timeout（attempt 3）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 計數：READY timeout **203**／code=1006 **214**／channel exit 1／health-monitor 重啟 2／client initialized 11／event-loop starvation 28／`startup-not-ready` **0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **對照 11-27：昨天同一個 04:25 槽是「全盲 48 分鐘 → selfheal 05:13 arm 重啟修好」，今天沒有重啟，靠 client 自己回來（43 分鐘）。** 差別在 **症狀簽章**：今天全窗 `startup-not-ready` = **0 筆** → `scripts/discord-selfheal.sh` 的守門（只認 `startup-not-ready`）在 04:13／04:43／05:13／05:43 每一槽都會回「discord healthy - no action」→ **自動修復機制連續第 2 天啞火**（第 22 輪已列為待決事項 #2，本輪獲得實測反證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 佐證：selfheal 今日 6 槽全 ok、全為 no action（10:13／10:43／11:13／11:43／12:13／12:43），stamp 檔 `memory/discord-selfheal-last-restart.ts` mtime 仍 **11-27 05:13**、內容 `1795727580` → **沒有誤開火，但也沒有正確開火**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **inbound 損失＝0（可觀察範圍）**：`channel_ingress_events`（複製 `state/openclaw.sqlite`＋wal＋shm 唯讀）24h **628 筆全部 completed、not_completed = 0**；盲窗 04:20–05:20 內 **0 筆**（該時段本來就無流量，凌晨桶 02h=1／04h=3／06h=1）→ **沒有可觀察的漏接，但也無法證明深夜無漏**（量測限制，見 §10）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🔴 第二事件：**06:00 DNS 超級風暴（344 筆 EAI_AGAIN）＋ 08:00–12:05 Token Plan 配額牆回歸**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **06:00–07:00 是近 24h 最惡劣的一小時**：`EAI_AGAIN` **344** 筆（其中 `gateway.discord.gg` **228**、`api.minimax.io` **54**）、Discord websocket `code=1006` **153** 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 但同一窗 **channel exit 0／READY timeout 0／reconnect-exhausted 0／health-monitor 0** → **純傳輸層抖動，8 個 channel 全部沒掉線，Discord 沒全盲**（與 11-27 22:38 那場同型但症狀輕）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - EAI_AGAIN 逐時（24h）：13h=8／14h=22／15h=4／**16h=59**／17h=6／18h=6／19h=6／20h=6／21h=4／22h=15／23h=13／00h=11／01h=4／02h=6／**03h=17**／04h=7／05h=10／**06h=332**／07h=18／**08h 之後 = 0** → 風暴在 07:xx 收束。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🔴🔴 **配額牆（Token Plan）回歸：08:00 起、12:05 收，約 163 行**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 逐時：`Token Plan usage limit reached` 08h=**33**／09h=**40**／10h=**30**／11h=**40**／12h=**20**（**12:05:38 為最後一筆**）→ 這是**連續 3 輪「配額牆零」之後的第 4 輪破功**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 簽章：HTTP 429 `rate_limit_error` / `Token Plan usage limit reached: Upgrade your Token Plan or purchase Credits for more usage. (2056)`；**不是** `overloaded_error`（本窗 overloaded = 0）、**不是** DNS、**不是** 餘額。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **殺傷**：本 job 10:02 槽（dur 7,104ms）、Celesteela KA 10:02 槽（dur 7,072ms）＋ 10:07 重試（3,600ms）**同批秒死**；另有 4 支 job 的 lastError 是同一個 429 簽章（健康回報／Jormungand mrmime A2A heartbeat／clean-code研究／Celesteela KA）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 3h 窗（10:02–13:02）：`Token Plan` **70** 行、`status=429` **21**、`model fallback decision` **21**（reason=rate_limit，鏈走 minimax-portal/MiniMax-M3 → minimax/MiniMax-M3 → minimax-portal/MiniMax-M2.7 → next=none）→ **三個候選同一 Token Plan，全鏈斷在同一個配額上**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ✅ **12:05 之後恢復**：本輪（13:02）模型正常回應 → 配額窗已過。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **新故障型態（首次觀測到）：`lane wait exceeded`** —— 6h 窗 **8 筆**，全部集中在 **08:27–08:58**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `lane=session:agent:roaringmoon:roaringmoon-morning-pipeline`：waitedMs=**959,843**／**1,178,619**／**902,541**（最長 **19.6 分鐘**排隊）、queueAhead=0–2。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `lane=session:agent:mrmime:discord:channel:1482069603512221927`：waitedMs=**2,000,019**（**33.3 分鐘**）／**1,748,724**／162,917／134,927／133,353、queueAhead=0–2。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 判讀：**08:00 槽多 job 同時起跑 × 配額牆 × DNS 尾風** → 使用者訊息在 lane 上排隊逾 30 分鐘。這是「600s 牆」的**新變種**（牆從 cron 執行層移到 lane 排隊層），**6h 內 0 筆 `job execution timed out`、0 筆 agent-runner-failure**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：54 jobs / 45 enabled / 9 disabled — ok 21 / **error 15** / skipped 8 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單 15 支（enabled 且 lastRunStatus=error），**根因三分**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | ce | 最後 dur | 根因簽章 |
|---|---|---|---|---|
| Picturecat Keep-Alive（本 job）| 02eb0989 | 5 | 7,104ms | rate_limit（Token Plan）|
| clean-code研究 | 89e2cfe7 | 5 | 3,253ms | 429 Token Plan |
| Celesteela Keep-Alive | 880b5c17 | 4 | 3,600ms | 429 Token Plan |
| 健康回報 | 13ac4b5a | 4 | 4,535ms | 429 Token Plan |
| Jormungand mrmime Codex A2A heartbeat | d7b0355b | 4 | 4,833ms | 429 Token Plan |
| 每日論文討論 | 58fe15dc | 4 | 330,435ms | DNS lookup |
| BBC News Morning Discussion | 88810bfe | 3 | 419,153ms | DNS lookup |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | 4 | 67,036ms | network connection error |
| PTCGP Meta Analysis（每日記錄）| 09c7940b | 1 | 1,197,592ms | DNS lookup |
| 每日資安建議 | 911eee45 | 1 | 902,688ms | DNS lookup |
| 每日模型排行前十 | 5b7c1082 | 1 | 592,411ms | DNS lookup |
| Jormungand daily all-agent health | 40e09cd1 | 1 | 707,515ms | DNS lookup |
| 每日 LLM Wiki 巡讀與擴寫 | ae91b967 | 1 | 44,249ms | DNS lookup |
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | 1 | 106,669ms | DNS lookup |
| PTCGP Meta 三日彙整 | 6ddc8b4c | 1 | 64,530ms | DNS lookup |

- **DNS 類 8 支、Token Plan 429 類 5 支、network 1 支** → 與 §2／§3 兩場事故一一對應，**沒有第三種新根因**。紅單 17 → **15**（對照 11-27 16:02 第 17 輪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🔴 **disabled 端再失 1 支齒輪**：`9d8b6001 Gengar Keep-Alive` **ce=10 → 已被系統自動停用（enabled=false）** → 三支 KA 只剩 picturecat + celesteela。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `ca222989 OpenClaw 系統維護` 仍 disabled（ce=10，11-27 12:51 最後一輪 dur=732,484ms）→ **本輪連續第 2 輪「少一支巡檢齒輪」**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ 綠燈重點：`d4cd45bc discord-selfheal` **ok/ce=0**（10:13→12:43 六槽全 no action、dur 733–806ms）、`36b493db dreaming` ok/ce=0、`29c2d630 Gengar Cron Health Watchdog` **ok/ce=0**（12:04 dur=5,075ms，主動點名 BBC News 連 3 次失敗）、`45ccf4e9` ok、`b37129c0` ok、`c721b4e3` clean-code 自癒重試 ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skipped 8 支＝heartbeat `no-route` ＋ **本輪新增 `quiet-hours`**（13:00 槽 5 支 heartbeat：`heartbeat skipped: quiet-hours`）→ 良性長態，不計紅單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⏰ 長跑型 job（dur≥590s）9 支：備份 643,769ms ok／PTCGP Meta 1,197,592ms error／資安 902,688ms error／排行前十 592,411ms error／Jormungand 707,515ms error／**dreaming 1,741,340ms ok**／晨間情報 1,669,775ms ok／群體智能 707,591ms ok／系統維護 732,484ms error。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 🟢 Discord 現況（巡檢當下）：8/8 connected、gateway 連續 31h49m 未重啟、inbound 正常收發<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（13:03）：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet **全部 enabled, configured, running, connected**（greninja disabled/stopped ＝預期）；transport 新鮮度 just now～1m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實收發：celesteela in:1m ago／gengar in:58m／mrmime in:2h／charizard in:4h／roaringmoon in:4h／rowlet in:22h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：MainPID **1069355**、ActiveEnterTimestamp **11-27 05:13:52 CST**、**NRestarts=0** → 連續 **31h49m 未重啟**；`/health` **HTTP 200 in 0.72ms**；load 0.63/0.57/0.55；mem available 20GiB；disk 61%（268G/468G）；host uptime 47d18h49m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗 journal（435 行）簽章：**READY timeout 0／code=1006 0／channel exit 0／startup-not-ready 0／health-monitor 0／EAI_AGAIN 0／event-loop starvation 0**、code=1005 **10**（良性傳輸抖動）、`was superseded` **2**（良性）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) ✅ 第 17 輪 §9 六項交辦驗收<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 交辦 | 結果 |
|---|---|
| ① DNS 14h 峰值後是否再起 | 🔴 **又起，且更大**：11-28 06h **332** 筆（24h 峰值，遠超 11-27 16h 的 59）；07:xx 收束後 08h 起歸零 |
| ② gengar ce=5 → 是否再 error | 🔴 **更糟**：gengar KA 今日 10:02 槽再錯 → **ce 累到 10 → 被自動停用**（enabled=false）|
| ③ 紅單 17 → ? | 🟡 **15**（DNS 8＋429 5＋network 1），但 **disabled 端再失 1 支**（gengar KA）|
| ④ openai 餘額是否補 | ❌ **未補**：24h 內 openai 429 僅 1 筆（11-27 14h）；`model fallback decision: probe_cooldown_candidate … reason=billing next=none`（11-27 15:19）仍在 → **`openai/*` 全 Auth=no，跨廠 fallback 仍為 0** |
| ⑤ 本 job 13:02 槽是否留紀錄 | ✅ **本檔即為紀錄**；且 11-27 19:02 以來 6 槽零紀錄之謎本輪解開 → 見 §7 |
| ⑥ 16:13 selfheal 槽 | ✅ **全數 no action**（10:13→12:43 六槽），stamp 停在 11-27 05:13 → **Discord 健康時守門不誤開火** |

### 7) 🔴 本 job 自身：**5 槽連敗（ce=5）＋ 6 槽零紀錄，且「status=ok 卻零紀錄」第 1 例**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 收據序列（`openclaw cron runs --id 02eb0989…`）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| 槽 | 結果 | dur | 簽章 |
|---|---|---|---|
| 11-27 16:02 | error | 1,038,259ms | DNS lookup（**報告寫完才死在投遞**）|
| 11-27 19:02 | error ×2 | 408,329＋393,727ms | network connection error → DNS lookup |
| 11-27 22:02 | **ok** | 510,982ms | 回覆是**工具呼叫 echo 垃圾字串**（開頭即 `]<invoke …exec…<command>python3 - <<'PY'`）→ **零記憶檔** |
| 11-28 01:02 | error | 58,705ms | DNS lookup |
| 11-28 04:02 | error ×2 | 117,630＋169,284ms | network connection error → DNS lookup |
| 11-28 07:02 | error | 296,684ms | DNS lookup |
| 11-28 10:02 | error | 7,104ms | 429 Token Plan（cause=rate_limit）|
| 11-28 13:02 | **本輪** | — | ✅ 執行中 |

- ⭐ **「status=ok ≠ 有紀錄」第 1 例**：11-27 22:02 那輪 job 狀態是 **ok**，但回覆是一串未執行的工具呼叫字串、且沒有寫任何記憶檔 → **第 17 輪之後連續 6 槽沒有留下巡檢紀錄**（19:02／22:02／01:02／04:02／07:02／10:02）。這比紅單本身更值得修：**紅單會被系統看見，零紀錄不會**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ 本輪（13:02）模型正常、lane 正常 → **證明 payload 的 agentTurn 能跑**，壞掉的是「槽位時機 × 網路/配額」，不是機制本身。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程／payload／model／fallback／timeout／agentId／enabled 全未動）、未改 `scripts/discord-selfheal.sh` 守門、未改 config/provider/model/channel、**未碰憑證（含 openai 餘額與被標 disabled 的 auth profile）**、未重啟 gateway（Discord 健康 → 無須）、未改 DNS/網路設定、未 force-run 任何 job、未重新啟用被自動停用的 `9d8b6001`／`ca222989`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（picturecat）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`（×4）、`openclaw tasks list`、`openclaw models list`、`journalctl --user`（3h／6h／24h 多窗逐項計數）、`systemctl --user show`、`curl /health`、`resolvectl status`＋`getent`×3、`channel_ingress_events`（複製 DB＋wal＋shm 後唯讀查詢）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **對外寫入**：因 delivery.mode=none（最終回覆只進 run log），沿用歷輪做法把巡檢摘要貼到 Discord 團隊頻道（rowlet 帳號）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（第 24 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高・延續・第 18 輪】DNS 架構根因**：`resolvectl status enp43s0` **Current Scopes: none**（已複驗）→ DNS 100% 靠 Wi-Fi `wlp0s20f3`（1.1.1.1 + 路由器 192.168.1.1）＋ tailscale0。**11-28 06h 單小時 332 筆 EAI_AGAIN**（gateway.discord.gg 228 / api.minimax.io 54）＋ 今日 8 支 DNS 紅單 ＝ 根因仍在發作。修法：給有線介面也配 DNS scope，或把 1.1.1.1/8.8.8.8 設為全域 DNS。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【最高・新・本輪最實錘】selfheal 守門只認 `startup-not-ready`，認不出 `disconnected`**：今日 04:25 dreaming 造成的 43 分鐘盲窗**全程 `startup-not-ready` = 0 筆**，首個症狀是 health-monitor 的 `restarting (reason: disconnected)` → selfheal 六槽全部「no action」，靠 Discord client 自己回來。**建議守門改為「`startup-not-ready` **或** enabled 帳號出現 `disconnected` 且連續 ≥2 次才 arm」**（30 分鐘防風暴 stamp 已在腳本內）。⚠️ 這會放寬「自動重啟 gateway」的觸發條件，屬邊界外動作，**我不在無人值守時自行放寬** → 等你點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【最高・延續】跨廠 fallback 仍為 0**：`openai/*` 全 **Auth=no**，帳戶 billing 已耗盡（`reason=billing next=none`）→ MiniMax Token Plan 一開牆，三個候選同時死（今日 08:00–12:05 即是如此）。需要**第二廠可用餘額**（**我不碰憑證**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高・新】配額牆的時段會變**：連續 3 輪「零配額牆」後，今日 **08:00–12:05（4 小時）** 出現 163 行 Token Plan 429 → 排避時段不能只照 09–13 點那套舊表，需把 08:00–12:00 視為高風險帶。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【高・延續・第 6 輪】本 job payload 仍是空殼**：message 只有 `keep-alive test`（15 字元）、`agentId=None`（跑在 rowlet lane）、**無 `timeoutSeconds`**、delivery=none。**這是 6 槽零紀錄的直接原因**：payload 沒有規定「先寫記憶檔再回覆」的順序，於是 DNS/配額一炸就整段蒸發。修法（**改 job 需你點頭**）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - `openclaw cron edit 02eb0989-891b-43fe-8a6e-dbcb059a4124 --message "<五步巡檢 + 檔名 memory/keepalive-picturecat-YYYY-MM-DD.md + 先寫檔再回覆>" --timeout 1800`
   - 若要讓它回報到團隊頻道，另需 `delivery.mode` 與 `agentId`（目前 none/None）。
6. **【中・新】`lane wait exceeded` 是新故障型態**：08:27–08:58 共 8 筆，roaringmoon morning-pipeline 排隊最長 **19.6 分鐘**、mrmime Discord lane 最長 **33.3 分鐘** → 這是「600s 牆」從 cron 執行層移到 lane 排隊層的變種，**目前無任何 watchdog 看得到它**（`29c2d630` 只看 cron receipt）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中・延續】兩支齒輪已被自動停用**：`9d8b6001 Gengar KA`（ce=10，**本輪新停用**）與 `ca222989 OpenClaw 系統維護`（ce=10）→ fleet 的巡檢覆蓋面正在縮小；是否重新啟用（ce 歸零後）或改成降頻＋容忍失敗？<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中・延續】三支 KA anchor 疊窗第 43 次**（picturecat 1780452122531 / gengar …570 / celesteela …603，Δ 39ms / 33ms）→ 每次主機抖動就是同批紅單。建議拉開 ≥15 分鐘（改 anchor 需你點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【低・延續】dreaming 回 NO_REPLY 連 2 天**（11-27、11-28 皆 summary=`NO_REPLY`）→ 04:25 那槽的報告內容是否真的沒寫出來，值得查一次 dreaming 的輸出。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 量測備忘（本輪新增）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Discord 兩種失明要分開讀**：`startup-not-ready`（client 從未起來）vs `disconnected`（起來過、又掉）→ **selfheal 只抓前者**。今日 04:25 那場屬後者 → 自動修復啞火。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `channel_ingress_events` 沒有 `created_at`，用 `received_at`（epoch ms）；唯讀查詢＝複製 db＋wal＋shm 到 /tmp 再 `mode=ro`＋`PRAGMA query_only=ON`。凌晨時段 inbound 稀疏 → **「0 筆」無法證明「0 漏接」**，只能證明「無可觀察損失」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`lane wait exceeded` 的欄位**：`waitedMs`（實際排隊等待）、`queueAhead`（前面排幾個）、`activeAhead`（同時活躍數）→ 判讀 lane 飽和要看 waitedMs，不是看 job dur。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw cron list --all --json` 的 enabled 桶要分口徑：ok 21／error 15／skipped 8／none 1；disabled 9 支另有 3 支帶 error（gengar KA ce=10、系統維護 ce=10、tmp-openai-probe ce=2）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- restricted automation-run session 中 `automations get/list` 對本 job 回 not found／空清單（已知限制）→ 一律用 `openclaw cron list --all --json` / `openclaw cron runs --id <完整 UUID>`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw cron runs` 的陣列是**新到舊**（`runs[:n]` 才是最近幾輪）；`cause` 欄位只在部分 run 有值（rate_limit／timeout），DNS 類失敗的 cause 常為 null → 判根因要看 `error`/`summary` 字串。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 下一輪（11-28 16:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. ⭐ **配額牆是否再起**（今日 08:00–12:05 → 16:02 是否又有 Token Plan 429；逐時筆數）。
2. ⭐ **DNS 是否再起**（11-28 08h 之後歸零 → 16:02 窗內 EAI_AGAIN 筆數＋逐時）。
3. ⭐ **selfheal 守門缺口**：若 16:02 前 Discord 再現 `disconnected` 而非 `startup-not-ready` → 待決事項 #2 升級為最急（自癒已連 2 天啞火）。
4. **本 job 16:02 槽是否留紀錄**（有紀錄＝payload 空殼至少沒炸；無紀錄＝ce 將來到 6，接近自動停用門檻 10）。
5. **gengar KA（已停用）與 系統維護（已停用）是否維持停用**、fleet 齒輪是否再少。
6. **lane wait exceeded 是否再現**（08:27–08:58 那 8 筆是否有後續同型）。
7. **12:05 之後 provider 是否穩定**（本輪正常回應，須確認不是短暫回彈）。

### 12) 對外投遞記錄（第 24 輪唯一外部寫入）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 因 delivery.mode=none（最終回覆只進 run log），用 rowlet 帳號把巡檢摘要貼到 Discord 團隊頻道 `1482363974119854234` → **messageId `1576101803651760161`、deliveryStatus `sent`**（同時再次實證 REST outbound 活）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紀錄檔：`memory/keepalive-picturecat-2026-11-28.md`（本檔，第 24 輪）＋ `memory/2026-11-28.md`（當日摘要）＋ `MEMORY.md`（新增一節「selfheal 守門的兩種失明簽章 ＋ status=ok ≠ 有紀錄」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
