# Picturecat Keep-Alive 巡檢日誌（2026-11-18）

## 2026-11-18 04:02 — ⚠️ 昨日預言成真：03:00 dreaming 二次打死 Discord，inbound 已瞎 59 分鐘<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → **"pong — no active task, no errors; Discord delivery context is connected and healthy."**（runId `1e553eab`，04:02）。
- ⚠️ **代理自述不可信**：picturecat 自稱「Discord delivery context is connected and healthy」，但 gateway 端 8/8 是 `disconnected, error:startup-not-ready` → agent 看到的是 delivery context 物件存在，**不代表 WS READY**。巡檢一律以 `channels status` + journal 為準。
- 本 job（02eb0989）run 史：01:02:08 **ok**（dur 44.2s、model MiniMax-M3/minimax-portal）→ 22:02 ok → **本輪 04:02 running**，ce=0（連續綠）。
- 姊妹 job：Gengar KA ce=0、Celesteela KA ce=0（皆 ok）。
- `prepared model runtime plugin generation was superseded`（前幾輪的良性簽章）**今日 0 筆** → 該雜訊已消失。

### 2. 🔴 昨日的預言成真：03:00 dreaming 又打死 Discord（**連續第 2 天**）
- `36b493db Memory Dreaming Promotion` schedule **仍是 `cron 0 3 * * *`（exact，03:00 整點）**；payload = `agentTurn` + `toolsAllow:["*"]` + `lightContext` + **無 `timeoutSeconds`**，sessionTarget=isolated。
- 今日實跑 03:00:00 → **03:30:08，dur=1,808,947ms（30.1 分鐘）**，status=ok → **next run 2026-11-19 03:00:00（明天會原樣再來一次）**。
- 斷線時間軸（journal 實測）：
  - 03:00:00 dreaming 起跑
  - **03:02:50 8 個 client 同時 `Gateway websocket closed: 1000`**（code 1000 = 乾淨關閉；11-17 是 1005/1006 → 今天更像 gateway 內部把 client 整批換掉，而非外網斷線）
  - 03:03:02 起 event-loop starvation 開始
  - **03:10:54 首次 `READY wait timed out after 15000ms (attempt 1)`**
  - 03:21–03:33 Discord 自己開始錯開重連（`delaying provider startup 10s–70s to reduce Discord startup rate limits`），client 重新 initialized（03:33:36 等）
  - 04:02:29 仍在 timeout，**attempt 已到 99–103，全程 0 次 READY 成功**
- 量測：READY timeout **03:00 段 809 筆 + 04:00 段 70 筆**（≈880 筆/小時，與 11-17 的 ~1660/h 同階）；websocket closed 33 筆（16×1000 / 17×1006）。
- ⭐ **event-loop timer delay 最高 101,948ms（101.9 秒）** → 比 11-17 的 27.1s 嚴重近 4 倍；starvation 26 筆，時間跨度 03:03:02 → 03:30:04 **完全對齊 dreaming 的執行區間**。
- 現況（04:02 `openclaw channels status`）：**8 個帳號全部 `running, disconnected, error:startup-not-ready`**（greninja disabled）——與 11-17 那場**完全同型**的簽名。
- inbound：rowlet 12h、gengar 6h、roaringmoon 5h、celesteela 3h、mrmime 31m（≈03:31，疑為重連風暴中的短暫窗口）→ **使用者對 bot 講話無人回**。
- outbound REST 仍活：mrmime `out:8m ago` → cron announce / 貼文投遞不受影響。
- gateway 本身健康：pid **2548417 自 11-17 13:19:32 活到現在（14h43m，從未重啟，NRestarts=0）**、`/health` 200 in 2ms、load 0.74、mem available 21G → **不是資源不足，是 client 狀態機卡死**（與 11-17 同一結論）。

### 3. Fleet 紅單（45 jobs：ok 32 / skipped 6 / error 6 / never 1）
| job | id | ce | dur | 最後失敗 | 類別 |
|---|---|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | 6 | 157s | 11-17 10:00 | rate limit |
| 每日論文討論 | 58fe15dc | 5 | 95s | 11-17 07:00 | rate limit |
| 每日資安建議 | 911eee45 | 5 | 104s | **11-18 00:02** | 429 Token Plan |
| Jormungand daily all-agent health | 40e09cd1 | 5 | 1804s | 11-17 03:29 | 429 |
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | 4 | 936s | 11-17 08:15 | timeout |
| 每日 OpenClaw 備份 | af94aa92 | 4 | 7s | 11-17 16:09 | 529（payload 已修）|

- ✅ **本輪無新紅單**：6 張紅單最後失敗時間都 ≤ 11-18 00:02，且沒有任何一支在 00:02 之後新增紅字。
- `af94aa92 每日 OpenClaw 備份` payload 已確認為 **`kind:"command"`**（`sh -lc "bash …/backup-openclaw.sh"`，timeout 1800s）→ ce=4 是 11-17 那次 529 的殘留；**今日 16:05（08:05 UTC）是第一次用新 payload 執行 → 待今日驗證**。
- `skipped: no-route` 6 支（rowlet/picturecat/roaringmoon/gengar/greninja/celesteela）＝良性長態；`6e93c179 heartbeat-flaaffy` never run＝良性 → **皆不計紅單**。
- 綠燈：3 支 keep-alive、dreaming（但見 §2）、系統維護、健康回報、push-llm-wiki、heartbeat-charizard/mrmime、轉錄監控等。

### 4. Provider 壓力：已退潮（與 Discord 問題無關）
- 最後一筆 MiniMax 429 = **11-18 00:02:17**（打「每日資安建議」）；00:02 之後到現在 **0 筆 provider 429/529**（24h 內 `All models failed` 僅 2 筆，都是 11-17 16:0x 的 529）。
- ⚠️ 別再誤判：journal 03:21–03:33 的 "rate limits" 字串是 **Discord 自己的 startup backoff**（`delaying provider startup 50s to reduce Discord startup rate limits`），**不是** MiniMax 額度問題。
- 本 job fallback 鏈 `["minimax/MiniMax-M3","minimax-portal/MiniMax-M2.7","minimax/MiniMax-M2.7"]` → 三個全是 MiniMax 同廠同 Token Plan → **跨廠冗餘仍為 0**（老問題，未動）。

### 5. 給 Linder 的待決事項（第 11 輪 —— 收斂成 2 條，其中 1 條是「再等一天就重演第 3 次」）
1. **【最急・只剩 23 小時】把 `36b493db` 移出 03:00 整點**：schedule 改 `17 3 * * *`（或 04:30 / 23:30），並加 `timeoutSeconds` 上限、限縮 `toolsAllow`（現在是 `["*"]`）。
   證據已是**連續兩天同一組數字**：03:00 起跑 → 跑 30 分鐘 → event loop timer delay 最高 101.9s → 8 隻 bot 全掉 → inbound 瞎。
   ⚠️ 這次**不能只靠重啟**：昨天 13:19 的重啟只治標，dreaming 沒移位 → 明天 03:00 原樣再來。
2. **【急】重啟 gateway 恢復今日 inbound**：8/8 disconnected、attempt 103 全敗、client 狀態機與 11-17 同型 → 必須重啟。重啟後 **60 秒內驗** `openclaw channels status` 應 8/8 connected；若仍 `startup-not-ready` → 先 `openclaw plugins enable discord --accept-capabilities` 再重啟。
   ⚠️ 不處理第 1 條的話，這次重啟只再撐 1 天。
3. `openai/*` provider 憑證仍 Auth=no → 跨廠 fallback 仍無從啟用（**我做不了，不碰憑證**）。
4. 尖峰仍存在（07:00 / 08:00 / 10:00 / 16:00 / 21:00）→ 429 的歷史來源，持續錯開整點。
5. `heartbeat-*` 的 `skipped:no-route` 與 flaaffy never-run 屬預期長態，別算紅單。

### 邊界（本次刻意沒動）
- 未自行重啟 gateway（未經核准，且會 kill 掉本輪使報告遺失）；未改 config / cron 排程 / provider / model / fallback / channel 設定；未為了讓紅單轉綠而手動 `run` 其他 job。
- 探測全為唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --json`、`openclaw cron runs --id`、`journalctl --user`、systemctl `--user show`、ps、curl `/health`、free/uptime。

### 6. 本輪升級（delivery = not requested → 最終回覆只進 run log）
- 已用 rowlet 帳號把「① dreaming 移出 03:00 ② 重啟 gateway」貼到 Discord channel `1482363974119854234` → **messageId `1572341703778766960`，deliveryStatus `sent`**（同時再次實證 REST outbound 活 / WS inbound 死）。
- 已向系統專家（`openclaw` tool）開立兩份提案，**needsApproval=true**：
  - 提案 1（治本・改 dreaming cron）：`system-agent:00b9d1aa-11fd-42d8-a66d-1173362d2c26`
  - 提案 2（治標・重啟 gateway）：approval id `0d05745037e311ceccb39884ab5c9df683c02aaafd0c9c54031fca1abfd4b865`
  - 系統專家提醒：目前有 3 個 running cron，請在無關鍵 job 運行時批准，避免被誤記 error。

## 2026-11-18 13:02 — Picturecat Keep-Alive 第 6 輪：lane PASS、Discord 存活、但 03:00 槽是**雙重負載**（新事實）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `fa1a3878-d024-47e8-8ce0-1f05087b8324`，status=ok，回覆「pong — no active task, no errors in the last 3h; Discord inbound working: yes」。
- 代理自述仍只當參考，實際以 `channels status` + journal 為準（見 §2）。

### 2) Discord runtime：已恢復且穩定（04:44 重啟後乾淨）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：8/8 enabled 帳號全部 `running, connected`（greninja disabled/stopped 為預期）。
- READY timeout：今日全日 2023 筆，但 **04:45 之後 0 筆** → runtime 狀態機被 04:44 的重啟清乾淨；websocket closed（04:45 後）11 筆 → 全部自癒。
- inbound 新鮮度：celesteela 4m / roaringmoon 36m / mrmime 57m / charizard 4h / gengar 5h / rowlet 3h；picturecat、flaaffy 視窗內無 inbound。
- gateway：pid **2724303**（04:44:05 起）、NRestarts=0、`/health` 200 in 1.7ms、load 0.67、mem available 20Gi、disk 60%。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐ 新事實：03:00 槽有**兩支 30 分鐘級 job 同時起跑**（先前只報 dreaming 一支）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | schedule | 今日實跑 | 狀態 |
|---|---|---|---|---|
| Memory Dreaming Promotion | 36b493db | `0 3 * * *` tz=None(=gateway local CST) | 03:00→03:30:08（1,808,947ms） | ok（但 03:02:50 打死 Discord） |
| Jormungand daily all-agent health | 40e09cd1 | `0 3 * * *` tz=Asia/Taipei | 03:00→**30.1 分鐘 timeout**（1,804,451ms） | error, ce=5 |
- → **今晚 03:00 同一分鐘會有兩支重 job 並跑**；只搬走 dreaming 只減半負載。Jormungand health 也應錯開。
- `36b493db` 仍 `timeoutSeconds=None`、`toolsAllow=["*"]`、declarationKey=`memory-core:memory-dreaming-promotion` → CLI 改可能被 declaration reconciliation 還原，**治本在 memory-core plugin**。

### 4) Provider 429：上午重災、13:02 窗口恢復<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429 筆數/小時（journal）：07→185、09→129、10→187、11→83、12→150；**12:49–13:04 = 0 筆**。
- 13:02:24 Celesteela KA `880b5c17` = **ok（19,676ms）** → 額度在 13:02 窗口回來。
- 本 job 前一輪 10:02:03 = error（429，dur 5,451ms）→ `consecutiveErrors=5`；Gengar KA 同時段亦 429（ce=5）。
- fallback 鏈 4 個候選（minimax-portal/MiniMax-M3 → minimax/MiniMax-M3 → minimax-portal/MiniMax-M2.7 → minimax/MiniMax-M2.7）**全同一 Token Plan** → 跨廠冗餘仍 0（老問題）。

### 5) Fleet：53 jobs / 46 enabled / 7 disabled — ok 19 / error 20 / skipped 5 / none 2<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- vs 08:37 基準（ok 28 / error 13）→ **ok −9、error +7**；20 張紅單中 18 張是 429 型，2 張 timeout（Jormungand 03:00、晨間情報 08:00）。
- 逼近自動停用（10 次）：OpenClaw 系統維護 ce=7、heartbeat-mrmime ce=7、每日 Agent × 軟體開發潮流研究 ce=7、heartbeat-charizard ce=6、heartbeat-roaringmoon ce=6、每日論文討論 ce=6 → **最嚴重的 3 支只剩 3 次就會被系統停用**。
- 停用中的 7 支：Charizard/RoaringMoon/Rowlet KA、`b7a56e10` gengar KA、`72a0c6ef` PTCGP translation、`8d7e5dfe`（重啟後驗證）、`d4cd45bc` self-heal（待 Linder 啟用）→ 皆非故障。

### 6) 「superseded」簽章已蔓延到 rowlet lane（與 11-17 結論不同）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `prepared model runtime plugin generation was superseded` 04:45 後共 **69 筆**（07→14、08→37、09→11、**13→7**）。
- 耿鬼 08:37 記「rowlet lane 尚未中招」→ **今日已中招**：`nested:agent:rowlet:main` ×2、`session:agent:rowlet:main` ×2。
- 13:02:59 picturecat 的 nested/session lane、13:03:44 gengar 的 nested/session lane 各中招（durationMs=6，瞬間死）→ **Gengar KA 的 13:02 這一輪是被 superseded 打死的，不是 429**。
- mrmime 的 discord session lane 於 09:18:37 連中 6 發 → 該 channel 的 bot lane 壞掉，mrmime inbound 最後一次 57m 前。
- 併發假說：同一分鐘多支 agentTurn job 起跑 → session 的 prepared runtime 被覆寫。仍屬待修項，本輪不動。

### 7) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron / payload / provider / model / channel / plugin 設定；未重啟 gateway；未啟用停用中的 `d4cd45bc`；未為了讓紅單轉綠而手動 run 其他 job。
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list/runs`、`journalctl --user`、`systemctl --user show`、curl `/health`、free/uptime/df。
- `elle.service`（system-level）仍 crash-loop：NRestarts **103,808**（08:37 為 103,279 → 4.4h +529），需 root，未動。

### 8) 給 Linder 的待決事項（第 12 輪，排序後）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【今晚 03:00 前・約 14 小時】03:00 槽雙重負載**：dreaming `36b493db` 移位 + Jormungand health `40e09cd1` 也錯開；並給 dreaming 加 `timeoutSeconds`、限縮 `toolsAllow`（現為 `["*"]`）。dreaming 是 plugin-declared → 持久修法在 memory-core plugin。
2. **【急】啟用 self-heal job `d4cd45bc`**（唯一能在 dreaming 打死 Discord 後自動修復的機制）：`openclaw cron enable --id d4cd45bc-357d-42d4-9ba1-f7eb39e02f59`。我未自行啟用＝授權 unattended 重啟 gateway，屬 human 決策。
3. **【急】跨廠 fallback 仍為 0**：4 個候選同一 Token Plan；openai/anthropic 主機層級不可達（11-17 實測）。需加值或修 egress，我不碰憑證。
4. 紅單逼近自動停用（ce 6–7 者 3 支）→ 429 不解就會陸續被系統停用。
5. `elle.service` crash-loop 103,808 次（system-level，需 root）。

### 9) 本輪對外動作（唯一一次外部寫入）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 沿用 04:02 那輪的做法（delivery = not-requested → 最終回覆只進 run log，故主動用 rowlet 帳號貼 Discord）：Discord channel `1482363974119854234`，**messageId `1572477805151785085`，deliveryStatus `sent`**。
- 貼出內容：13:02 巡檢綠燈摘要 ＋ **03:00 雙重負載新發現** ＋ 3 項待 Linder 決定事項（ dreaming/Jormungand 錯開、啟用 `d4cd45bc`、跨廠 fallback）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->


## 2026-11-18 19:02 — Picturecat Keep-Alive 第 7 輪：lane PASS、Discord ingress 實流量正常、429 暫退、03:00 雙重負載仍未解<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `23f78041-18af-4e56-8475-4788b66965be`，回覆 `picturecat keep-alive: pong`；agent 自述無 active task/error，Discord inbound/outbound 看起來正常。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job 上一輪 16:08:53 因 MiniMax Token Plan 429 失敗（ce=4）；本輪 19:02 成功，顯示 429 壓力暫時退潮。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) Discord runtime：可用，但仍有頻繁瞬斷自癒<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 19:02 與 19:05 兩次 `channels status`：8/8 enabled 帳號全部 `running, connected`；greninja disabled/stopped 為預期。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `channel_ingress_events`（連 WAL/SHM 一併複製後唯讀查詢）：13:00 後 **261 筆全部 completed，0 failed、0 pending**；celesteela 228、mrmime 20、roaringmoon 12、rowlet 1；最新 celesteela 18:59:47。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:45 重啟後 **實際 READY timeout = 0**（唯一 grep hit 是 08:43 agent 報告內的「0 筆」文字，不是 runtime 錯誤）；13:00–19:05 event-loop starvation = 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 但 13:00–19:05 有 **34 次 unique-flow websocket close**（1005×18、1006×16；journal 51 行含重複 generic close）→ 全數自動重連，未演變成 READY timeout；屬傳輸層反覆抖動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Provider 429：16–17 時段爆發，18:02 後趨緩<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 13:00–19:05 以 embedded runId 去重：**37 個 rate-limit 失敗 run**；逐小時唯一失敗數 14:00=1、15:00=2、16:00=22、17:00=11、18:00=1、19:00 截至 19:05=0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 新增紅單：3 支 Keep-Alive 均在 16:08 失敗（各 ce=4，429）；`13ac4b5a 健康回報` 17:12 失敗（ce=4，429）。本輪 Picturecat probe 已成功。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `prepared model runtime plugin generation was superseded`：13:00 後 12 筆（picturecat lane×4、gengar lane×8），仍是併發 lane 的良性競態簽章，未影響本輪 pong。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：52 jobs / 45 enabled / 7 disabled；error 20 → 14<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Enabled 狀態：ok 25 / error 14 / skipped 5 / never 1；13:02 基準 error 20 → 本輪 14，淨改善 6。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `a72cb46b 每日 Agent × 軟體開發潮流研究` ce=7（rate_limit）距自動停用門檻 10 尚有 3 次；21:00 的 `911eee45 每日資安建議` ce=5 且將再跑，仍可能變紅。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `af94aa92 每日 OpenClaw 備份` 16:00 成功；workspace-rowlet 本機與 `origin/backup/master` 同在 `9852bcef`（16:01:46），新 payload 驗證通過。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 🔴 明日 03:00 雙重負載仍未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion` 仍是 `0 3 * * *`、無 `timeoutSeconds`、`toolsAllow:["*"]`；今日 03:00→03:30:08，dur 1,808,947ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand daily all-agent health` 仍同為 `0 3 * * *`；payload 已有 timeoutSeconds=3600 與受限 toolsAllow，但今日仍在 1,804,451ms timeout、ce=5。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal-after-dreaming` 仍 disabled；self-heal 尚未啟用。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Gateway／主機<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway pid 2724303、04:44:05 起、systemd NRestarts=0；`/health` HTTP 200 in 7.45ms；uptime 38d、load 1.02、RAM available 19GiB、disk 60%。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（system scope）仍 crash-loop：NRestarts **104,519**，較 13:02 的 103,808 增加 711（約 6h）；需 root，未動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 工具異常與邊界<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- restricted automation-run session 中，`automations get/list` 對本 job 回 `not found`／空清單（CLI 可正常看到 52 jobs）；本輪改以 `openclaw cron list --all --json` 做唯讀彙總。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 全程唯讀：未改 cron/config/plugin/provider/model/channel，未重啟 gateway，未啟用 self-heal，未手動 run 其他 job，未送 Discord。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 19:04–19:07 同時段姊妹 KA 收尾補記<!-- <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet --> -->
- Gengar KA 本輪成功（19:02:04 起、185,038ms、ce=0）。<!-- <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet --> -->
- Celesteela KA 本輪 **120,428ms timeout**（payload timeoutSeconds=120、last phase model-call-started、ce=5）→ 429 雖退潮，provider 延遲仍未完全恢復。<!-- <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet --> -->
- 19:07 快照（Picturecat 本 job 尚在 running）：enabled ok 26 / error 13 / skipped 5 / never 1；較 13:02 的 error 20 淨改善 7。Picturecat 本 job 會在本回合最終回覆後落定。<!-- <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet --> -->

## 2026-11-18 22:02 — Picturecat Keep-Alive 第 8 輪：lane PASS、Discord 8/8 連線、紅單淨減 3、但**明日 03:00 雙重負載是第 3 次未解**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `0848176a-fda0-4ebf-bd76-1f7377182e24`，status=ok，回覆「pong — no active task, no recent errors; Discord inbound/outbound looks healthy (origin + delivery context both intact.)」。
- 本 job（02eb0989）狀態：enabled、schedule=`every 10800000ms`（3h）、sessionTarget=isolated、model=minimax-portal/MiniMax-M3、fallbacks 3 個候選**全是 MiniMax 同 Token Plan**（跨廠冗餘仍 0）、ce=0、上一輪 dur=349,093ms（349s，ok）、**delivery.mode=none → 最終回覆只進 run log**。

### 2) Discord runtime：可用且穩定（連續 17h20m 未重啟）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 22:04 `openclaw channels status`：**8/8 enabled 帳號全部 `running, connected`**（greninja disabled/stopped = 預期）。
- inbound 新鮮度：celesteela **in:just now**、mrmime 51m、roaringmoon 4h、rowlet 9h、charizard 13h、gengar 14h；picturecat/flaaffy 視窗內無 inbound → **Discord 使用者傳訊仍有人收到並處理**（celesteela just now 為實證）。
- journal（`--user`）：**READY wait timeout 近 3h = 0**；**event-loop starvation 近 3h = 0**（今日 28 筆全落在 03:00–03:30 dreaming 區間）；websocket closed 近 3h = 19 行（16 筆 unique-flow 1005/1006 + 3 筆 generic）→ 全部自癒重連。
- gateway：pid **2724303 自 04:44:05 CST 起（17h20m）**、NRestarts=0、ActiveState=active/running、`/health` 200 in 4.3ms、uptime 38d、load 0.95、mem available 20GiB。

### 3) Provider 429：18:00 後退潮，21:02 一筆被 fallback 救回<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 今日逐小時 429/529：00→2、07→64、09→42、10→58、11→25、12→51、16→72、17→32、18→2、**19→0、20→0、21→2**、22→0。
- 21:02:51 一筆 `provider=minimax-portal status=429 elapsedMs=165288` → **fallback 鏈救回**：`911eee45 每日資安建議`（sched `5 0 21 * *`）最終 **ce=0 / ok / dur 725,054ms** → 21:00 波不再打紅。
- 21:02 同時段 Gengar KA 亦完成（journal 22:04:21 記 gengar main lane 仍在跑）。

### 4) Fleet：52 jobs / 45 enabled / 7 disabled — ok 29 / error 10 / skipped 5 / never 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- vs 19:07 基準（ok 26 / error 13）→ **error −3、ok +3（淨改善）**。
- ✅ **轉綠 4 支**：① `911eee45 每日資安建議` ce 5→0（ok）② `13ac4b5a 健康回報` ce 4→0（ok, 54.8s）③ `09c7940b PTCGP Meta Analysis (每日記錄)` ce=0（ok, 636,194ms — 脫離紅單多日）④ `af94aa92 每日 OpenClaw 備份` ce=0（ok, 128,371ms — **新 script payload 首次驗證成功**）⑤ `36b493db dreaming` ce=0（但 dur 1,808,947ms ＝ 30.1 分鐘，見 §5）。
- 🔴 **新紅 3 支**：
  | job | id | ce | 失敗時間 | 原因 |
  |---|---|---|---|---|
  | 每日 LLM Wiki 巡讀與擴寫 | ae91b967 | 4 | 09:24 | 429「All models failed (3)」（原為綠）|
  | PTCGP Meta 三日彙整 | 6ddc8b4c | 4 | 10:23 | 429「All models failed (3): minimax/MiniMax-M2.7」|
  | skill-collection-review-mrmime | 9e2cec7c | 4 | 12:07 | 429 rate_limit（dur 609ms 快掛）|
- ⚠️ **逼近自動停用（門檻 10）**：`a72cb46b 每日 Agent × 軟體開發潮流研究` **ce=7**（10:00 失敗：All models failed (4)）→ 距停用僅剩 3 次，明天 10:00 再跑。
- 其他紅單：`58fe15dc 每日論文討論` ce=6（07:04 429, 246,782ms）｜`45ccf4e9 晨間情報 pipeline` ce=5（timeout 1,200,815ms）｜`40e09cd1 Jormungand` ce=5（1,804,451ms timeout）｜`b37129c0 群體智能架構研究` ce=2｜`08b7c00b rowlet-ut-veteran` ce=4。
- 🔴 **`880b5c17 Celesteela Keep-Alive` 連 2 次 timeout**：19:02（120,428ms）＋ **22:04（120,085ms，「last phase: model-call-started」）** → ce 5→6。根因是 payload `timeoutSeconds=120` 對 MiniMax 延遲太短（provider 已恢復、429 已退潮，純粹是被 timeout 砍掉）→ **建議把 timeout 從 120s 放寬到 600s**。
- `skipped: no-route` 5 支、`6e93c179 heartbeat-flaaffy` never run、`d4cd45bc self-heal` never run → 皆屬預期長態，**不計紅單**。

### 5) 🔴 明日 03:00 雙重負載：**第 3 次連續未解**（距 03:00 約 5 小時）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion` 仍是 `cron 0 3 * * *`（無 tz）、payload `agentTurn` + **`toolsAllow:["*"]`** + **無 `timeoutSeconds`** + lightContext、sessionTarget=isolated → 今日 03:00→03:30:08（**dur=1,808,947ms**）又把 event loop 塞住。
- `40e09cd1 Jormungand daily all-agent health` 仍是 `cron 0 3 * * *` tz=Asia/Taipei（payload 已有 timeoutSeconds=3600 + 受限 toolsAllow）→ 今日 03:00 同時 30.1 分鐘 timeout。
- 兩者同分鐘起跑 → **明天 03:00 將是連續第 3 天同一簽名**（03:00 起跑 → 30 分鐘 → event-loop starvation → 8 隻 bot 掉線 → inbound 全瞎）。
- `d4cd45bc discord-selfheal-after-dreaming`（sched `35,50 3,4 * * *` tz=Asia/Taipei、payload kind=command、timeout 60s）**仍是 disabled** → 唯一自動修復機制未啟用。

### 6) 其他觀察<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `prepared model runtime plugin generation was superseded`：今日 **100 筆**、近 3h **19 筆** → 併發 lane 競態簽章持續，**仍屬良性**（本輪 pong 正常）。
- restricted automation-run session 中 `automations get/list` 對本 job 回 `not found`／空清單 → 本輪改用 `openclaw cron list --all --json` 唯讀彙總（52 jobs 皆取得）。**已知工具限制，非故障。**
- `elle.service`（system scope）crash-loop 需 root，本輪未動（沿用前輪結論）。

### 7) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 全程唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、journal（`--user`）、systemctl `--user show`、curl `/health`、uptime/free。
- 未改 cron 排程 / payload / timeout / config / provider / model / fallback / channel；未重啟 gateway；未啟用 `d4cd45bc`；未為了讓紅單轉綠而手動 `run` 其他 job。
- **例外（唯一外部寫入）**：沿用前輪做法，因 delivery.mode=none（回覆只進 run log），用 rowlet 帳號把巡檢摘要貼到 Discord channel `1482363974119854234` → **messageId `1572614456377221242`，deliveryStatus `sent`**（同時實證 REST outbound 活）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（第 13 輪，已收斂成 4 條）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最急・約 5 小時後】03:00 槽雙重負載（第 3 次）**：`36b493db` dreaming 移出 `0 3 * * *`（建議 `17 3 * * *` 或 04:30/23:30）+ 加 `timeoutSeconds` + 限縮 `toolsAllow`（現為 `["*"]`）；`40e09cd1` Jormungand 也錯開。⚠️ dreaming 是 plugin-declared（declarationKey `memory-core:memory-dreaming-promotion`），CLI 改可能被 reconciliation 還原 → **持久修法在 memory-core plugin**。
2. **【急】啟用 self-heal `d4cd45bc`**（sched `35,50 3,4 * * *` Asia/Taipei）—— 唯一能在 dreaming 打死 Discord 後自動修復的機制；我未自行啟用＝等同授權無人值守重啟 gateway，屬 human 決策。
3. **【急】`880b5c17 Celesteela KA` timeoutSeconds 120 → 600**：連 2 輪被 timeout 砍掉（不是 provider 壞），放寬即可轉綠。
4. **【急】`a72cb46b` ce=7 距自動停用剩 3 次**：明日 10:00 若再 429 就會變 8/10 → 建議與錯開整點排程一併處理（07:00 / 08:00 / 10:00 / 12:00 / 16:00 是今日 429 高峰帶）。
   附帶：`openai/*` 憑證仍 Auth=no → 跨廠 fallback 仍是 0（**我不碰憑證**）。
