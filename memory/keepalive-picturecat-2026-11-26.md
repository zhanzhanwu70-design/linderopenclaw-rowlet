# Picturecat Keep-Alive 巡檢（rowlet lane）— 2026-11-26

## 2026-11-26 01:02 — Picturecat Keep-Alive 第 8 輪：🟢 lane PASS、Discord 零症狀 ≈20h11m、紅單維持 2 支；⭐⭐ **上輪交辦 #1 結案（本槽 0 筆 Type B，只有無害的 Type A ping 噪音）**、⭐⭐ **上輪交辦 #2 結案（heartbeat-rowlet 23:08 那輪被 `每日模型排行前十` 佔住 155.7s，結束時間秒級對齊）**、⭐ **配額牆連續第 6 輪 0 筆、00:02 一顆快閃 429 被同模型重試救回**、⭐ **lane 佔用率僅 7.5%、0 筆 600s 硬死（本 job 之外的 fleet 全窗健康）**、⚠️ **量測更正：24h `superseded` 實際 102 行（上輪報 18 筆是明顯低估）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `5aa93953-6aa9-4643-ac79-e549571a8ab4`、status=ok、回覆「pong — (1) 無 active task, (2) 近幾小時無錯誤, (3) Discord 收發正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-25 22:02）**ok / dur=376,059ms（376.1s）/ ce=0** → **上輪報告未自報 dur，本輪以 receipt 補齊：376.1s，超過 300s 自我上限**（自我量測誤差問題仍在，一律以 receipt 為準）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` ok/ce=0（22:02:06 起 dur=334,457ms）、`9d8b6001 Gengar KA` ok/ce=0（22:02:06 起 dur=17,763ms）→ **三支 KA 全綠**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- anchor：`state.nextRunAtMs` picturecat **01:02:04** → gengar **01:02:06** → celesteela **01:02:06（Δ 2s）** → **本槽是 3 支同槽（第 34 次 anchor 觀測）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 上輪交辦 #1 結案：**本槽 0 筆 Type B，只有無害的 Type A ping 噪音** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 窗（22:00–01:06）`was superseded` 共 **4 行**，lane 全部是 `nested:agent:picturecat:main` + `session:agent:picturecat:main`（**Type A**）：**22:02:41（上一輪 ping）與 01:02:31（本輪 ping）各 2 筆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Type B（`*:main:heartbeat` lane ＝ 真正的連帶傷害）本窗 0 筆**；24h 內 Type B 共 12 行，時間戳全部落在 **07:12:44 / 08:31:49 / 08:59:48 / 16:11:40**（＝配額牆與 dreaming 壓力時段），**近 12 小時沒有再出現**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ 上輪 §9-1 的判讀成立：**KA 疊窗本身不是傷害來源**，只會產生自我噪音。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ 上輪交辦 #2 結案：**heartbeat-rowlet 23:08 那輪被 `每日模型排行前十` 佔住 155.7s（結束時間秒級對齊）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-rowlet` 窗內 6 輪：**22:08:22 skipped 263ms → 22:38:22 skipped 517ms → 23:10:59 skipped 155,693ms（異常）→ 23:38:24 skipped 264ms → 00:08:24 skipped 262ms → 00:38:24 skipped 263ms**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 佔用者對齊成功：`每日模型排行前十`（`5b7c1082`）receipt = **ts 23:10:59 / ok / dur=485,286ms** → 佔用區間 **23:02:54 → 23:10:59**；heartbeat-rowlet 那輪 23:08:24 起跑、**skipped dur=155.7s、結束時刻 23:10:59＝前棒結束的同一秒**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **第 3 個「結束時間完全對齊」的獨立實例**（前兩個：11-25 16:08/17:08），**機制再次確認：agent lane 是單執行緒排隊佇列，heartbeat 等到回合後才判 no-route，dur＝剩餘等待時間**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 但**沒有釀成 600s 硬死**（本窗 8 條 lane：≥300s = 0、600s 硬死 = 0、Σdur=841.4s／佔用率 **7.5%**）→ 再次驗證「危險的是前棒接近 600s，不是 heartbeat 本身」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐ Provider：配額牆連續第 6 輪 0 筆；00:02 一顆快閃 429 被同模型重試救回 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- quota 型（`Token Plan usage limit reached`）24h **211 筆，最後一筆 11-25 12:09:37** → 牆已退場 **≈12h56m**（連續第 6 輪窗內 0）。寫法沿用「零星復發觀察中」，**不寫成已解決**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 窗（22:00–01:06）model-fetch **209 次**：**208×status=200 + 1×status=429**；延遲 p50=**1,469ms**、p90=**4,566ms**、max=**94,231ms**（＝那筆 429 本身，elapsedMs=94 的快閃）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯一 429：**00:02:04.971 status=429 elapsedMs=94** → embedded run `66b613a7` isError=true → **00:02:05 `rate-limit same-model retry 1/3 delayMs=10000`** → **00:02:47 status=200 elapsedMs=1,429** → **救回，宿主是 mrmime 的 a2a-codex-heartbeat nested session，沒有任何 job 因此變紅**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Explicit auth order for openai` 24h 3 筆、**最後一筆 11-25 10:02:21 → 本窗 0 筆**（症狀連續 15 小時未復現）；`overloaded_error` 1 筆；24h model-fetch = 2,104×200 / 85×429。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ⭐ Discord：8/8 connected，近 3h 完全零症狀，兩個零症狀起點續長 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（01:03）：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet 全部 **enabled, configured, running, connected**（greninja disabled/stopped ＝預期）；transport 皆 just now~1m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 窗（22:00–01:06，934 行）簽章計數：**READY wait timed out 0 / channel exited 0 / `resume=false` 0 / startup-not-ready 0 / host timing gap 0 / EAI_AGAIN 0 / memory pressure 0 / event-loop starvation 0 / timed out 0**；reconnect `scheduled in` 15 ＋ `reconnect-opcode, resume` 11（≈5.3/h、3.7/h，貼近 24h 基線 2.6–3/h，無 resume=false）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 兩個零症狀起點（24h 視窗實測）：**嚴格（READY-fail／channel-exit）** 最後一筆 **11-25 04:54:40 → ≈20h11m**；**保守（含完整關閉 `close, resume=false`）** 最後一筆 **11-25 12:50:43 → ≈12h15m**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：MainPID **4137629**、`ActiveEnterTimestamp=2026-11-23 04:48:17` → **連續 2d20h17m 未重啟**、NRestarts=0、`/health` HTTP 200 in 1.4ms；host up 45d6h49m、load 0.60/0.47/0.47、mem available 20GiB、`/` 61%（176G free）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Fleet：53 jobs / 46 enabled — 紅單維持 2 支、無 +1 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 活紅單（enabled 且 `consecutiveErrors>0`）**仍只有 2 支**：`89e2cfe7 clean-code研究` **ce=3**（last 11-25 09:07:34、配額牆所傷、**next 11-26 09:00** 才自癒）、`c5352a84 skill-collection-review-roaringmoon` **ce=1**（11-20 DNS 餘波、**next 11-27 03:56**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 綠燈重點：`OpenClaw 系統維護` 22:05 / 23:06 / 00:05 **連續 3 輪 ok**（64.4s / 95.5s / 51.4s，輸出自述 `Crons: 0 failed last hour`）、`discord-selfheal-after-dreaming` 00:43 ok 788ms、`健康回報` 23:06 ok 68.9s、`每日資安建議` 21:19 ok 966.8s（上輪那顆 21:02 error 已自癒、ce=0）、`每日模型排行前十` 23:10:59 ok 485.3s、`PTCGP Meta Analysis` 20:22:56 ok 1,076.1s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `每日論文討論` next 11-26 07:00、`每日資安建議` next 21:00:05、`每日模型排行前十` next 23:02:54、`PTCGP Meta Analysis` next 20:05:00、`dreaming` next 11-26 04:25 → 本輪不驗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) lane 佔用率表（receipts 實測，22:00–01:06，8 條 heartbeat lane） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| lane | runs | Σ dur | ≥300s | 600s 硬死 | 非 ok 型別 |
|---|---|---|---|---|---|
| hb-rowlet | 6 | 157.3s | 0 | 0 | 全 skipped（1 筆 155.7s 被佔用） |
| hb-mrmime | 7 | 360.2s | 0 | 0 | 全 skipped |
| hb-celesteela | 6 | 1.8s | 0 | 0 | 全 skipped |
| hb-charizard | 6 | 95.5s | 0 | 0 | 全 skipped |
| hb-greninja | 6 | 58.8s | 0 | 0 | 全 skipped |
| hb-picturecat | 6 | 1.6s | 0 | 0 | 全 skipped |
| hb-roaringmoon | 6 | 1.6s | 0 | 0 | 全 skipped |
| hb-gengar | 7 | 164.7s | 0 | 0 | 全 skipped |
| **合計** | **50** | **841.4s** | **0** | **0** | 佔用率 **7.5%**（841.4 / 11,160） |
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) ⚠️ 量測更正：24h `superseded` 實際 **102 行**（上輪報「18 筆」是明顯低估） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 視窗（11-25 01:00 → 11-26 01:06）`was superseded` 共 **102 行**：**90 行是非 heartbeat lane**（`nested:agent:X:main` ＋ `session:agent:X:main` 的 Type A ping 噪音，另有 `cron-nested` 16 行與之成對）＋ **12 行是 heartbeat lane（Type B，07:12／08:31／08:59／16:11）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 逐時分布（24h）：01h×12 / 04h×10 / 07h×22 / 08h×31 / 16h×17 / 19h×8 / 22h×2 → **尖峰集中在 07–08h（配額牆＋dreaming）與 16h（KA 槽自傷）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **上輪「24h 總量 18 筆（Type A 12 ＋ Type B 6）」的量測口徑有誤**（可能只數了 distinct 事件或窄化 grep）；**Type B 的 12 行與「近 12h 0 筆」的結論不受影響**（逐行帶 timestamp 重數）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 邊界（本次刻意沒動） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron 排程/payload/model/fallback/timeout、未動 `scripts/discord-selfheal.sh` 守門、未改 config/provider/model/channel、未碰憑證、**未重啟 gateway**、未動 DNS/網路設定。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user`、`systemctl --user show`、`curl /health`、`uptime/free/df`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 給 Linder 的待決事項（更新） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高】rowlet lane 序列化（本輪再補一個實例）**：`每日模型排行前十`（8.1 分鐘）單獨就能把 `heartbeat-rowlet` 拖成 skipped 155.7s；`PTCGP Meta Analysis`（17.9 分）昨天就直接打死 600s。建議把 **PTCGP Meta Analysis／每日資安建議／每日模型排行前十／健康回報／OpenClaw 系統維護** 與 `heartbeat-rowlet` 的整點槽錯開 ≥10 分鐘，或把 heartbeat 的 timeoutSeconds 由 600s 拉高（**改 job 需你點頭**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【高】MiniMax 跨廠 fallback 仍是 0**：配額牆連 6 輪沒出現，但 00:02 的 429 仍只靠同模型重試救回；真冗餘需要一組可用的第二廠憑證（**憑證我不碰，需你提供**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】紅單 2 支等自然自癒**（11-26 09:00 / 11-27 03:56），期間只需確認 ce 沒 +1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】三支 KA anchor Δ=2s（第 34 次）**：本窗 0 傷害，但理由是「降低 lane 擁擠」而非「避免打死鄰 lane」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中】17 支 skill 缺 description（沿用）、`elle.service` 重啟迴圈、DNS root cause（Link 2 無 scope）** → 本輪無新證據，不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【方法論】本輪驗證四件事**：① **Type A／Type B 必須逐行帶 timestamp 分類**，不能用總量混算（上輪的 18 vs 實測 102 就是混算後果）；② **「skipped 卻跑 N 分鐘」的佔用者可以用「同 lane job 的 receipt 結束時刻」秒級對齊**（本輪對到 每日模型排行前十 23:10:59）；③ **自我回報 dur 一律以 receipt 為準**（22:02 輪實測 376.1s，超 300s 上限）；④ **「某槽 0 事故」必須標明量測截止時間**（沿用上輪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 下一輪（11-26 04:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **04:25 dreaming 槽前置與結果**： dreaming job next 04:25（timeout 2400s）、`discord-selfheal` next 04:43 → 04:02 輪需確認守門在位、gateway MainPID 未變；04:25 跑完後驗 receipt（dur ≥1,800,000ms 且 status=ok）＝**連續第 3 夜**。
2. **22:08／23:08 那兩筆 heartbeat dur**：若 04:02 輪看到 04:0x 又出現 >150s 的 skipped dur，用同樣的 receipt 結束時刻對齊法找佔用者（04:00 槽附近的 rowlet lane 長 job：`每日 LLM Wiki` next 05:30、`每日論文討論` 07:00）。
3. **配額牆是否再來**：讀 01:00–04:00 的 quota 型 429（`Token Plan usage limit reached`）與 canonical `model-fetch.*status=429`；寫法沿用「零星復發」。
4. **本槽（01:02）的 Type B 是否出現**：本輪只量到 Type A（picturecat 2 筆 @ 01:02:31）→ 若出現 `*:main:heartbeat` lane 才算有傷害。
5. **紅單 ce 是否沒 +1**（clean-code研究 11-26 09:00 前、skill-collection-review 11-27 03:56 前）。
6. **本輪自身 dur**：仍以 receipt dur 為準（`openclaw cron runs --id 02eb0989-…` 最新一筆）；自報值不作數。
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-26 04:02 — Picturecat Keep-Alive 第 9 輪：🟡 lane PASS、🔴 **01:12–01:14 真實 Discord DNS 事故（8 筆 READY-fail ＋ 2 個 channel 被 health-monitor 重啟）**、✅ dreaming 第 3 夜前置防線全在位、⭐⭐ **24h 配額牆真身＝11-25 09:00–12:59（211 筆）＋ openai fallback 是「有憑證但無額度」**、✅ 紅單維持 2 支無 +1、⚠️ **簽章變體：READY 逾時有 15000ms／30000ms 兩種，只數後者會把事故判成零症狀** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gateway / host：全綠 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- MainPID **4137629**、`ActiveEnterTimestamp=2026-11-23 04:48:17` → **連續 2d23h14m 未重啟**、`NRestarts=0`、`SubState=running`；node **v24.22.3**（`/home/amr/.nvm/versions/node/v24.22.3/bin/node … gateway --port 18789`）；`/health` **HTTP 200 in 0.22s**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- host up 45d9h49m、load 0.67/0.72/0.65、mem available 20.9GiB、`/` 61%（176G free）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 內 **gateway restart 指令 0 筆**（system journal `Started /usr/bin/systemctl --user restart openclaw-gateway`）；SSH 監控仍活著：近 2h **36 次** `Accepted publickey` 全來自 **192.168.50.2**（Linder 筆電，每 10 分鐘 3 次）→ **它這 24h 沒有下過 restart**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🔴 Discord：本輪抓到**真實事故**（01:12:42–01:14:38）——這是上輪「零症狀 ≈20h11m」的續段斷點 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **症狀組**：`01:12:42` 2 筆 `Gateway heartbeat ACK timeout` → `01:12:42` `Gateway reconnect scheduled in 2000ms (zombie, resume=true)` ×2 → `01:12:51` 2 筆 `websocket closed code=1006` → **`01:12:51` `[health-monitor] [discord:charizard] health-monitor: restarting (reason: disconnected)`** ＋ **`[discord:mrmime] health-monitor: restarting (reason: disconnected)`** → `01:13:12` `client initialized` ×2 → **`01:13:12` 開始 `EAI_AGAIN`（discord.com / gateway.discord.gg / gateway-us-east1-c.discord.gg）共 16 行（01h 10 筆 + 01h 6 筆，24h 其餘 23h 為 0）** → `01:13:27` 起 **8 筆 `gateway READY wait timed out after 15000ms`（attempt 1→4，01:13:27 / :44 / :47 / 01:14:01 / :04 / :18 / :21 / :38）** → `01:13:32` 2 筆 `client initialized`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **恢復**：01:14:38 之後 **0 筆 READY-fail、0 筆 channel exited、0 筆 reconnect-exhausted**；`channels status` 現在 **8 個 enabled 帳號全部 running, connected**（greninja 為 disabled 殘留）。→ **DNS 解析層的暫時性全滅，約 2 分鐘內自癒**（gateway 全程未重啟）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️⭐⭐ **簽章變體教訓（量測方向性錯誤的另一例）**：本機 journal 的 READY 逾時簽章有 **兩種** —— `gateway READY wait timed out after 15000ms`（本輪 8 筆）與 `did not reach READY within 30000ms`（本輪 0 筆）。**只數後者 → 會把這場真實事故判成「零症狀」**；正確口徑＝**兩種都數**，且必須配 `health-monitor: restarting (reason: disconnected)` 判「channel 層真的掉了」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「沒有新的成功 READY」不等於「斷線」**：24h 內 `READY within`（成功握手）**22 筆、最後一筆 2026-11-25 04:54:40**；3h 窗 **0 筆**。但同一時窗 reconnect 28 筆、websocket closed 44 筆（1005×14 / 1006×22），reconnect 原因拆解＝`reconnect-opcode, resume=true` 12、`zombie, resume=true` 8、`close, resume=true` 5、`close, resume=false` 2 → **resume=true 的續連不會產生新的 `READY within` 簽章**（Discord session resume 成功）→ **「無成功 READY」不可單獨當斷線證據**，必須搭配 `websocket closed code` 分布 ＋ `channels status` 的 transport 新鮮度（現在全為 just now / 1m ago）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **乾淨段重算**：上一段的最後一筆 READY-fail ＝ **01:14:38** → 至 04:02 **連續 ≈1h48m 零 READY-fail / 零 channel exited**（前一段「≈20h11m」終止於 01:12 的事故，不是被 01:02 輪誤判）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **DNS root cause 候選（既有 open item「Link 2 無 scope」進階）**：`resolvectl status` 顯示 **Link 2 (enp43s0) Current Scopes: none**（有線網路完全沒有 DNS scope），DNS 全部來自 **Link 3 (wlp0s20f3)** 的 `1.1.1.1 / 8.8.8.8 / 2001:b000:168::1 / 2001:b000:168::2` ＋ tailscale 的 100.100.100.100；而 Link 3 的 IPv6 位址 `2001:b011:6c09:d415:64e5:1bf4:a7c6:7447` 標記為 **deprecated dynamic temporary**（ISP prefix 變動中）→ **IPv6 上游 DNS 在 prefix 跳動時失效 → getaddrinfo EAI_AGAIN** 是最合理的解釋（可驗證手段：把 `2001:b000:168::*` 從 Link 3 的 DNS 移除，或改用 `DNSStubListener`/單一 IPv4 resolver）。**本輪未改任何 DNS 設定**（需你點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ Provider：3h 窗只有 2 筆 429，但 **24h 配額牆真身＝11-25 09:00–12:59（211 筆）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **本窗（01:00–04:02）canonical 429 = 2 筆**：`03:01:07`（elapsedMs=**62,528**、dispatcher=reused）、`03:03:03`（elapsedMs=**77,451**）→ 兩者都屬 **`40e09cd1 Jormungand daily all-agent health`（03:00 槽，agent:mrmime）** 的 attempt 1 與 attempt 2（receipt dur 67,648ms / 85,790ms、cause=`rate_limit`），**attempt 3 於 03:04:03 收 ok（dur 195,552ms、ce=0）** → **又一個「receipt error ≠ 紅單」實例**（journal 沒有 `same-model retry` 行也能救回）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **本窗 `Token Plan usage limit reached: Upgra` = 0 筆**（配額牆連續第 7 輪 0 筆）、`status=529` = 0、`overloaded_error` 僅出現在 429 的 error envelope 內。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **24h 全貌（推翻「配額牆只在 07:29–07:59」的窄視角）**：24h `Token Plan usage limit reached: Upgra` = **211 筆，全部落在 11-25 的 09h×43 / 10h×66 / 11h×47 / 12h×55**（09:00–12:59 連續 4 小時）；canonical 429 逐時＝11-25 05×2/06×2/07×3/08×2/**09×18**/**10×21**/**11×14**/**12×19**/18×1/21×1、11-26 00×1/**03×2** → 24h 合計 **86 筆**。→ **「每日 09:00–13:00」才是主窗，07:29 那場是 11-23 的特例**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **跨廠 fallback 的第 5 種失效型別：「有憑證、但帳戶沒錢」**：`89e2cfe7 clean-code研究` 11-25 09:07:34 的 receipt 原文＝`All models failed (4): minimax-portal/MiniMax-M3: HTTP 429 Token Plan usage limit reached…(2056) | minimax/MiniMax-M3: HTTP 429…(2056) | minimax-portal/MiniMax-M2.7: HTTP 429…(2056) | **openai/gpt-5.4-mini: 429 You have no credits remaining…(billing)**` → **openai 候選不是「無 profile」而是「有 profile 但零額度」**（與 11-23 那次 `Explicit auth order for openai has no usable profiles` 是**不同**的失效型別）→ 判斷跨廠冗餘時，除了看 provider 名，還要看**該候選的憑證狀態**（profile 存在 ≠ 能用）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet 紅單：2 支，**無 +1**（ce 都沒動） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | ce | last run | next | 根因 |
|---|---|---|---|---|
| `89e2cfe7` clean-code研究（agent:charizard, `0 9 * * *`） | **3** | 11-25 09:07:34（dur 7,006ms） | **11-26 09:00** | 09:00 rate_limit → 09:05 rate_limit → 09:07 **billing**（3 個 MiniMax 候選全 429＋openai 無額度） |
| `c5352a84` skill-collection-review-roaringmoon | **1** | 11-20 03:56:21 | **11-27 03:56** | 11-20 DNS 舊因 |
| ~~`a94330a9` tmp-openai-probe~~ | ce=2 | — | — | **enabled=false 殘留，不算活紅單** |
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **更正 gengar lane 的前提**（gengar 01:02 輪寫「clean-code研究 連 6 天首跑死（第 7 天）」）：實測近 10 筆＝**11-19 ok / 11-20 error(timeout) / 11-21 ok / 11-22 ok / 11-23 ok / 11-24 ok / 11-25 error×3** → **不是連 6 天死，而是 11-20 與 11-25 兩天**；11-25 的 3 次失敗與配額牆窗完全對齊（09:00–12:59）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- fleet 總覽：53 jobs / **46 enabled**（ok 38、skipped 5、error 2、None 1）＋ 7 disabled。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ✅ dreaming 第 3 夜（04:25）前置檢查：**防線全在位** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion`：`expr=25 4 * * *`、timeout **2400s**、last **11-25 04:25:00 ok dur=1,793,022ms（29.9 分）**、再上一輪 11-24 ok 1,816,088ms → **連續 2 夜 ok**（11-23 那夜是被 gateway restart 腰斬的 error），**本夜 04:25 = 第 3 夜**。next=**11-26 04:25:00**（本輪 04:02 時點還有 23 分鐘）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `scripts/dreaming-running-check.py --prefix 36b493db` → **api / db / clock 三個獨立家族一致回 idle**（receipts 無 in-flight、cron-list idle、時鐘窗未入）→ **沒有任何 in-flight 遺留會卡住守門**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **selfheal 排程仍是 `13,43 0-3,5-23 * * *`（04 整點已排除，未被改回）**：last 11-26 03:43:00 ok dur=783ms、**next=05:13:00** → **04:25–05:05 dreaming 窗內沒有任何外部 restart arm**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **dreaming 窗的併發背景（本輪盤點新項）**：`04:24:59 heartbeat-charizard`（**比 dreaming 早 1 秒**）、`04:25:09 heartbeat-greninja`、`04:26:02 heartbeat-picturecat`、`04:26:19 heartbeat-roaringmoon`、`04:29:42 heartbeat-gengar`、`04:31:09 heartbeat-mrmime` ＝ **6 支 heartbeat 排在 dreaming 起跑後 6 分鐘內**；另有 `ca222989 OpenClaw 系統維護`（timeout 2700s＝45 分）自 04:04:48 起 → **可能壓到 04:49**。→ 這是 dreaming 造成 event-loop 飽和的既有背景，**本輪未改任何排程**（改 job 需你點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) lane / heartbeat 佔用：全窗無 600s 硬死 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `cron: job execution timed out` = **0 筆**、24h `lane wait exceeded` = **0 筆**、本窗 `lane task error` 6 筆 **全部是 `agent:gengar:main`（nested/session，durationMs 5–10）＝ Type A ping 噪音，非 heartbeat lane → 良性**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `superseded` 本窗 **8 行，全在 04:04:31**（= gengar KA 04:02 槽 ping `agent:gengar:main` 觸發的 generation 競態，附 2 行 `model-fallback/decision candidate_failed`）→ **本窗 0 筆 Type B（無 `*:main:heartbeat` lane 受損）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- heartbeat 收尾：`heartbeat-rowlet` 近 8 槽全 `skipped: no-route`、dur **262–512ms**；`heartbeat-mrmime` 近 8 槽全 ok、dur 4.2–8.5s（唯一較長者 01:01 = 82,067ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 三支 KA 本輪（01:02 槽）dur：picturecat **148,598ms** / gengar **328,071ms** / celesteela **151,267ms** → **全部 >30s，無降級輪**；gengar 11-25 22:02 槽 dur=**17,763ms（降級跑、零紀錄）** 是上一個降級輪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 本輪自身 dur <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 01:02 輪 receipt dur = **148,598ms**（2.5 分）。**本輪（04:02）dur 只能以 `openclaw cron runs --id 02eb0989-…` 最新一筆為準**，自報值不作數（本輪收尾時尚未寫入 receipt）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本次刻意沒動） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron 排程／payload／model／fallback／timeout、未動 `scripts/discord-selfheal.sh` 與 `dreaming-running-check.py` 守門、未改 config/provider/model/channel、未碰憑證、**未重啟 gateway**、**未動 DNS／網路設定**（含 Link 3 的 IPv6 DNS 上游）、未改 `elle.service`（現況 inactive、NRestarts=0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`journalctl --user/--since`、system journal、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`systemctl --user show`、`curl /health`、`resolvectl status`／`ip -6 addr`／`ip -6 route`／`dig`、`scripts/dreaming-running-check.py`（唯讀查詢模式）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（更新） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高】DNS：Link 3 的 IPv6 DNS 上游可能是 01:13 事故的根因**。證據＝Link 2 無 DNS scope、Link 3 同時掛 `1.1.1.1/8.8.8.8` 與 `2001:b000:168::*`、其 IPv6 位址為 **deprecated dynamic temporary**、事故簽章全是 `getaddrinfo EAI_AGAIN`（16 行／2 分鐘）。**建議（需你點頭）**：把 `2001:b000:168::1/::2` 從 Link 3 的 DNS 移除或改單一 IPv4 resolver，可把 2 分鐘級的 Discord 全滅變成 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【最高】跨廠 fallback 仍然等於 0，而且失敗型別比想像中多**：11-25 09:07 的鏈是「3 個 MiniMax 候選全 429（配額牆）＋ openai 候選 **有憑證但零額度**」→ 連 `minimax-portal/MiniMax-M2.7` 這個「唯一實測可用」的救回路徑都被配額牆一起打死。**需要的是第二廠商的有效額度憑證（憑證我不碰，需你提供）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】配額牆主窗＝每日 09:00–13:00（11-25 實際 4 小時、211 筆）**：今天 09:00 的 `89e2cfe7 clean-code研究`（ce=3）就是**同一時段的自然自癒驗證點**——若牆再來，它會連續第 2 天在 09:00 死；若牆沒來，它會歸 0。**建議把 09:00–13:00 的高負載 job 錯開或下移**（例：clean-code研究 → 14:00 後）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】紅單 2 支**：`89e2cfe7` ce=3（等 11-26 09:00 自癒）、`c5352a84` ce=1（等 11-27 03:56）→ 期間只需確認 ce 沒 +1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中】三支 KA anchor 疊窗第 35 次**（anchorMs 1780452122531 / 12570 / 12603，實跑 04:02:05 / 04:02:07 / 04:02:07 → 間隔 2s / 0s），且 picturecat 與 gengar **同跑 agent:rowlet lane** → 本窗 0 傷害但 lane 排隊風險仍在；建議拉開 **≥15 分鐘**（單輪實耗 148s–328s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中】17 支 skill 缺 description 第 15 輪仍未修**：3h 窗 **374 行**、24h **2,397 行**、唯一 **17 檔**（13 支 `description is required` ＋ 4 支 `BAD_INDENT`）→ 這 17 支在功能上「不存在」。**仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【方法論】本輪驗證四件事**：① **簽章有變體就會漏判**（READY 逾時 15000ms vs 30000ms，只數後者＝把事故判成零症狀）；② **「無成功 READY」≠ 斷線**（resume=true 不產生 `READY within`，要搭配 websocket code 分布＋transport 新鮮度）；③ **fallback 候選要看憑證狀態**（有 profile ≠ 有額度）；④ **配額牆要看 24h 全窗，不要只看 3h**（3h 窗 0 筆、24h 211 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 下一輪（11-26 07:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **04:25 dreaming 第 3 夜結果**：receipt dur ≥1,800,000ms 且 status=ok ＝**連續第 3 夜**；同時驗 `OpenClaw 系統維護`（04:04:48 起、timeout 2700s）與 6 支 04:2x–04:3x heartbeat 是否把 event loop 壓到飽和（看 `[fetch-timeout] … timer delayed`、`host timing gap`、`READY wait timed out` 三支簽章）。
2. **01:13 DNS 事故是否復發**：讀 04:00–07:00 的 `EAI_AGAIN` 與 `health-monitor: restarting`；若復發 → 建議立刻處理第 9 節第 1 項（IPv6 DNS 上游）。
3. **乾淨段重算**：新起點＝**01:14:38**（最後一筆 READY-fail），到 07:02 應為 ≈5h48m。
4. **配額牆是否再來**：讀 04:00–07:00 的 `Token Plan usage limit reached: Upgra` 與 canonical `model-fetch.*status=429`；寫法沿用「零星復發」，且 09:00 是今天的關鍵自癒點。
5. **紅單 ce 是否沒 +1**（`89e2cfe7` 等 09:00、`c5352a84` 等 11-27 03:56）。
6. **本輪自身 dur**：仍以 receipt dur 為準。

## 2026-11-26 07:02 — Picturecat Keep-Alive 第 10 輪：🟡 lane PASS、🔴 **04:27–05:13 dreaming 槽「結構性每日事件」第 4 代根因重現（509 筆 READY-fail、15 筆 channel exited、6 次 host timing gap）**、✅ **dreaming 連續第 3 夜 ok 且 selfheal 首次真正接手（未腰斬）**、✅ 紅單維持 2 支無 +1、⭐ **配額牆連續第 8 輪 0 筆（11-25 09:00–12:59 仍是最後一次）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `cc5c2e48-0187-45dc-9e06-6861b79daae8`、status=ok、回覆「pong — 無 active task，近幾小時無錯誤，Discord 收發正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-26 04:02）**ok / dur=368,188ms / ce=0**；姊妹 job `9d8b6001 Gengar KA` **ok/ce=0/251,906ms**、`880b5c17 Celesteela KA` **ok/ce=0/173,739ms** → **三支 KA 全綠**（本輪 07:02:05/07:02:07 同時起跑，間隔 2s，第 36 次 anchor 疊窗）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🔴 本輪最大事件：04:27–05:13 又是 dreaming 槽的 Discord 全線重連風暴（**不是 DNS**）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **簽章組（04:00–07:00 窗，3,307 行 journal）**：`READY wait timed out after 15000ms` **477 筆** ＋ `did not reach READY within 30000ms` **32 筆** ＝ **509 筆 READY-fail**；`channel exited` **15 筆**；`health-monitor: restarting (reason: disconnected/stopped)` **6 筆**（04:39 roaringmoon＋rowlet、04:45 charizard＋flaaffy＋mrmime(stopped)）；`host timing gap detected: process was frozen ~Nms` **6 筆**；`[fetch-timeout] … timer delayed Nms, likely event-loop starvation` **15 筆**（max 17,726ms）；`delaying provider startup 40s~70s` **32 筆**；`client initialized` 36、`channels resolved` 24。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **根因確認＝MEMORY 既載「第 4 代根因」**：`[admission] closed/reopened: suspend phase` **16 筆**（04:27:53、04:28:26、04:29:00、04:33:19、04:34:02、04:34:37、04:35:07、04:39:12…）與 6 筆 `host timing gap`（frozen **167,187 / 229,869 / 215,313 / 254,424 / 128,932 / 150,828ms**）**同秒出現** → dreaming 的 admission suspend 被 watchdog 記成「freeze」→ **Discord 30s READY 握手期限先到期** → channel exited → auto-restart 撞 Discord startup rate limit 而延遲 40–70s。**6 次 = 與近 7 天每天固定 6 次的結構性事件完全吻合**（本輪為第 7 夜）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **EAI_AGAIN = 0 筆**（本窗）、DNS 解析現在全正常 → **本輪不是 DNS 事故**（與上輪 01:12–01:14 那場不同根因）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **本輪差異：這次是 selfheal 真的接手（第一次）**——channel 層反覆重啟讓 `openclaw channels status` 出現 `startup-not-ready`，守門因此看見；`d4cd45bc` 於 **05:13:00**（slot `13,43 0-3,5-23`）觸發、**dur=4,164ms**、輸出「**discord broken and dreaming idle -> scheduling gateway restart in 10s**」→ stamp 寫 `1795641180` → `systemd-run --on-active=10s systemctl --user restart openclaw-gateway` → **05:13:04 / 05:13:46 兩次 restart 指令** → **新 pid 784503（ActiveEnter 05:13:49）** → 05:13:56–05:15:09 **8 帳號全數 `channels resolved` ＋ `client initialized` 回來**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ✅ **dreaming 沒有被腰斬**： dreaming 04:25:01 起跑、**04:55:16 結束**（dur 1,815,253ms）→ selfheal 的 clock 守門（`DREAMING_WINDOW_START=04:15` / `END=05:10`）＋ api/db 三重守門在 05:13 判定 idle → **重啟落在 dreaming 結束 18 分鐘後**＝**第 4 次避免 dreaming 被腰斬**（MEMORY 記的 11-19/11-23 三次之外新增一例）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⚠️ **量測教訓**：`journalctl` 的 `startup-not-ready` 在本窗 **0 筆**，但 selfheal 守門讀的是 **`openclaw channels status` 的輸出** → **journal 與守門不是同一個觀測面**，不能用 journal 簽章回溯「守門有沒有看見」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **04:54:56–04:58:56**：`[health] host thaw channel restart deferred: gateway still has active work` **10 筆**（dreaming 還在跑，watchdog 想重啟 channel 被擋）＋ `04:55:02 [celesteela] auto-restart attempt 1/10 in 5s`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **06:54:56** 又一次單點 `health-monitor: restarting (reason: disconnected)`（discord:roaringmoon）→ **06:55:57/58 已恢復** → 07:02 `channels status` **8/8 enabled, configured, running, connected**、transport 全 `just now`（greninja disabled/stopped ＝預期）、gengar in/out 1m、rowlet in/out 21m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **乾淨段重算**：最後一筆 READY-fail = **05:13:45**（舊 pid 收尾）→ 至 07:02 **連續 ≈1h48m 零 READY-fail**；**上輪推估的「01:14:38 起 ≈5h48m」被 04:33 這場新事故打斷**（不是誤判）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Gateway / host<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- MainPID **784503**、`ActiveEnterTimestamp=2026-11-26 05:13:49`（上輪的 4137629 已於 05:13:47 收 SIGTERM、05:13:48 `shutdown completed cleanly in 1874ms`）、**NRestarts=0**、`SubState=running`、`/health` **HTTP 200 in 2.1ms**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- host up **45d12h52m**、load 1.11/0.71/0.60、mem available **21GiB**、`/` 61%（175G free）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **24h gateway restart 指令＝1 筆**（05:13:04＋05:13:46，來自 selfheal 的 systemd-run，**不是人為**）：近 2h SSH `Accepted publickey` **37 次全部來自 192.168.50.2**（Linder 筆電，每 10 分鐘 3 次）→ **Linder 這 2 小時沒有下過 restart**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ✅ dreaming 第 3 夜：**連續第 3 夜 ok**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion`：lastRun **2026-11-26 04:25:01**、**status=ok**、**dur=1,815,253ms（30.3 分）**、**ce=0**；timeoutSeconds 2400s、`expr=25 4 * * *`；next=11-27 04:25。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 連續 3 夜 ok（11-24 1,816,088ms / 11-25 1,793,022ms / 11-26 1,815,253ms）→ **11-23 那夜被腰斬的舊錯未復發**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **selfheal 排程仍是 `13,43 0-3,5-23 * * *`（04 整點排除維持、未被改回）**：近 12 輪 00:13–03:43 全 no-action → **05:13 觸發重啟（ok, dur 4,164ms）** → 05:43 / 06:13 / 06:43 全 no-action（dur 769–785ms）→ next=**07:13**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Fleet 紅單：**2 支，無 +1**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | ce | last run | next | 根因 |
|---|---|---|---|---|
| `89e2cfe7` clean-code研究（`0 9 * * *`） | **3** | 11-25 09:07:34（dur 7,006ms） | **11-26 09:00** | 配額牆（billing：3 個 MiniMax 候選 429 ＋ openai 零額度）|
| `c5352a84` skill-collection-review-roaringmoon | **1** | 11-20 03:56:21 | **11-27 03:56** | 11-20 DNS 舊因 |
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- fleet 總覽：53 jobs / **46 enabled**（ok 38、skipped 5、error 2、None 1）＋ 7 disabled（`a94330a9 tmp-openai-probe` 等殘留，不計活紅單）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **`ca222989 OpenClaw 系統維護` 每小時全 ok**（00:04–06:04 連續 7 輪 dur 23.9s–95.5s，全「Gateway: OK / Crons: 0 failed last hour / Disk: 61% used」）→ **05:13 的 gateway 重啟沒有腰斬它**（05:04 那輪 dur 53,160ms ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Provider：配額牆連續第 8 輪 0 筆；本窗 429 = 7 筆<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **24h `Token Plan usage limit reached` = 211 筆，全部落在 11-25 的 09h/10h/11h/12h** → **11-26 至今 0 筆**（配額牆連續第 8 輪零現身，最後一次＝11-25 09:00–12:59）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h canonical `[provider-transport-fetch] … status=429` = **86 筆**；**11-26 至今 10 筆**：00:02:04、03:01:07、03:03:03、05:01:36、05:03:08、05:31:10、05:33:51、06:02:02、**07:02:02**、**07:02:11**（本窗 7 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本窗 429 都伴隨 `[discord] embedded run agent end … error=⚠️ API rate limit reached`，elapsedMs 69,679–150,540ms、dispatcher=new/reused 都有；`Token Plan` / `no credits remaining` / `billing` 在本窗 **全 0 筆** → **今天這 7 筆是併發型 overloaded，不是配額牆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **07:00 槽同時兩支起跑**：`58fe15dc 每日論文討論`（07:00 槽，上一輪 ok dur 762,215ms）＋ 三支 KA（07:02:05–07）→ 07:02:02 與 07:02:11 兩筆 429 落在這裡；**待觀察 58fe15dc 本輪 receipt 是否轉紅**（若紅則 ce=1）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **跨廠 fallback 仍等於 0**：`openai/*` 是「**有憑證但零額度**」型（11-25 實測 `429 You have no credits remaining`）→ 需要第二廠有效額度（**憑證我不碰，需你提供**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) lane / heartbeat / superseded<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `cron: job execution timed out` = **0 筆**；24h `lane wait exceeded` = **9 筆，全部在 11-25 08:19–08:31**（`agent:roaringmoon:roaringmoon-morning-pipeline` waitedMs 89,307 / 94,456 / 50,547 / 39,377 / 34,571 / 13,531 / 11,993 ＋ `agent:mrmime:discord:channel:…` 643ms）→ **不是本窗**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本窗 `lane task error` / `superseded` **10 行全在 04:04:31**（gengar KA 04:02 槽 ping 的 generation 競態，附 2 行 `model-fallback/decision candidate_failed`）＋ **07:03:57 2 行**（本輪 picturecat ping 噪音）→ **Type A ping 噪音、0 筆 Type B（無 `*:main:heartbeat` lane 受損）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- heartbeat 收尾：`heartbeat-rowlet` 06:38 **ok dur=436,676ms**（偏高，逼近 600s 上限，值得盯）、`heartbeat-charizard` 06:55 ok 11,768ms、`heartbeat-mrmime` 06:31 ok 44,780ms、celesteela/greninja/picturecat/roaringmoon/gengar 全 `skipped: no-route` 260–262ms（良性長態）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) DNS 現況（根因未除）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `resolvectl status`：**Link 2 (enp43s0) Current Scopes: none**（有線網路仍無 DNS scope）→ DNS 全靠 Link 3 (wlp0s20f3)＋tailscale；Link 3 目前 `Current DNS Server: 8.8.8.8`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 解析現在正常：`gateway.discord.gg` → 162.159.133–136.234（link wlp0s20f3）、`api.minimax.io` → 210.71.227.48 / .17 ＋ IPv6 `2001:b034:1c:200::d247:e36b`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron 排程／payload／model／fallback／timeout、未動 `scripts/discord-selfheal.sh` 守門與 `dreaming-running-check.py`、未改 config/provider/model/channel、未碰憑證、**未重啟 gateway**、**未動 DNS／網路設定**（含 Link 3 的 IPv6 DNS 上游）、未改 `elle.service`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪唯一「動作」＝**既有 selfheal 機制自行觸發的 05:13 gateway 重啟**（不是我 arm 的；我只做唯讀觀測）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user/--since`、system journal、`systemctl --user show`、`curl /health`、`resolvectl status/query`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 給 Linder 的待決事項（第 10 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高・新】dreaming 槽（04:25）幾乎每天炸 Discord 一次，本輪已第 7 夜**：根因＝**admission suspend 讓 30s READY 握手期限到期**（MEMORY 第 4 代根因）。今天靠 selfheal 在 **05:13**（dreaming 結束 18 分鐘後）做整個 gateway 重啟才收尾——**但 05:13 落點是巧合**：若 dreaming 再多跑 5 分鐘（04:25+30min 已到邊界），selfheal 會因 clock 守門（04:15–05:10）與 api 判定而**繼續 postpone**，Discord 可能一路瞎到 06:xx。**建議（需你點頭）**：把 `DREAMING_WINDOW_END` 從 05:10 拉長到 ≥05:45，或讓 dreaming 的 admission suspend 不中斷既有連線的 READY deadline（MEMORY 已列 (a)(b) 兩案）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【最高】跨廠 fallback 仍等於 0**（`openai/*` 有憑證但零額度）→ 需要第二廠有效額度憑證（我不碰憑證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】配額牆主窗＝每日 09:00–13:00**（11-25 實際 4 小時 211 筆；今天 0 筆＝連續第 8 輪零現身）。**今天 09:00 的 `89e2cfe7 clean-code研究`（ce=3）是自然自癒驗證點**：牆若再來 → 連續第 2 天死在 09:00；牆若沒來 → ce 歸 0。建議把 09:00–13:00 的高負載 job 下移（例：clean-code研究 → 14:00 後）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】DNS 根因仍在**（Link 2 無 DNS scope、Link 3 IPv6 上游 deprecated）→ 本輪沒有 DNS 事故，但上輪 01:13 那場是它造成的；建議把 `2001:b000:168::*` 從 Link 3 移除或改單一 IPv4 resolver。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中】三支 KA anchor 疊窗第 36 次**（07:02:05 / 07:02:07，間隔 2s）→ 本窗無傷害，但單輪實耗 174s–368s，建議拉開 ≥15 分鐘。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中】`heartbeat-rowlet` dur 436,676ms**（06:38 那輪）逼近 600s 硬死上限 → 建議改 `sessionTarget=isolated`（或照 charizard 加 `target:"none"`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【方法論・本輪新增】** ① **journal 的 `startup-not-ready` ≠ 守門是否看見**（守門讀 `openclaw channels status`）；② **「adapter 重啟後殘留 startup-not-ready」是 selfheal 唯一能接手的症狀型**——這解釋了 11-21 啞火 vs 本輪接手；③ **host timing gap 必配 `[admission] closed/reopened: suspend phase` 同秒出現**才判 dreaming suspend（否則可能是真 freeze）；④ **兩種 READY 逾時字串（15000ms / 30000ms）都要數**（沿用上輪教訓，本輪 477＋32 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 下一輪（11-26 10:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **09:00 槽**：`89e2cfe7 clean-code研究` receipt 是否轉綠（ce→0）或連續第 2 天紅（ce→4）；同時 `Token Plan usage limit` 是否在 09:00–13:00 重現（今天 0 筆）。
2. **07:00 槽**：`58fe15dc 每日論文討論` 本輪 receipt（07:02 兩筆 429 是否被同模型重試救回）。
3. **dreaming 槽是否又被炸**：讀 08:00–10:00 的 `host timing gap` / `READY wait timed out`（兩種）/ `channel exited`；**並確認 selfheal 是否在 05:13–07:13 之外又 arm 過重啟**（看 stamp 檔 `memory/discord-selfheal-last-restart.ts` 是否仍為 1795641180）。
4. **乾淨段重算**：起點＝**05:13:45** → 10:02 應為 ≈4h48m；若中間又有 READY-fail 則重算。
5. **紅單 ce 是否沒 +1**（`89e2cfe7` 等 09:00、`c5352a84` 等 11-27 03:56）。
6. **本輪自身 dur**：以 receipt `state.lastDurationMs` 為準（本輪 07:02:05 起跑）。
