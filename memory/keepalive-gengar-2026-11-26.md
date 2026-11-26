# Gengar Keep-Alive 巡檢日誌（gengar 側自報，2026-11-26）

## Gengar lane 自報（gengar 01:02 台北）— PASS（lane 雙向通、idle）／📉 60m canonical provider 失敗全 0（附納入行數）／✅ dreaming 連續第二夜完整跑完（11-25 04:25 ok 1,793,022 ms、ce 0），下一槽 11-26 04:25<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_0102_26 = 12`
- **lane 狀態**：alive／idle，無進行中任務；6 支自有 cron 全 `ok`、`ce` 全 0。
- **① 近 60 分鐘 canonical provider 失敗統計**（口徑：系統前綴行 `node[…]`/`systemd[…]`，且排除 `[agent:nested]`/`[agent:side]`/`[agent/embedded]` 自報迴音；429 僅計 `[model-fetch] … response` 且 `status=` 為數值；窗用絕對時間邊界餵 journalctl）：
  視窗 **11-26 00:03:23 → 01:03:23**；**總行 1267、系統行 986、排除巢狀回音後 982** →
  **429 = 0、overloaded = 0、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0、usage-limit = 0**。
- **② 我自有 cron 的狀態**（ok/err / consecutiveErrors / dur / nextRunAt）：
  | id | 名稱 | status | dur | ce | nextRunAt |
  |---|---|---|---|---|---|
  | `29c2d630` | Gengar Cron Health Watchdog | ok | 3,014 ms | 0 | 11-26 02:04 |
  | `c29eca0f` | heartbeat-gengar | ok | 35,883 ms | 0 | 11-26 01:29 |
  | `ac9e7ada` | You are an English coach | ok | 7,961 ms | 0 | 11-26 05:00 |
  | `88810bfe` | BBC News Morning Discussion | ok | 217,387 ms | 0 | 11-26 07:00 |
  | `7767e03b` | skill-collection-review-gengar | ok | 86,815 ms | 0 | 11-28 07:32 |
  | `f5148ff0` | OpenClaw 版本檢查 | ok | 258,726 ms | 0 | 11-29 00:00 |
- **③ gateway**（`systemctl --user show openclaw-gateway.service`）：`MainPID=4137629`、`NRestarts=0`、`ActiveState=active`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → 連續運行約 **68h18m、0 次重啟**。
- **④ Discord**：**8 connected / 8 enabled** accounts（greninja disabled）；近 60 分鐘 ingress **12 筆**（深夜時段量低）。
- **⑤ dreaming `36b493db`**：上一槽 **11-25 04:25 → status ok、dur 1,793,022 ms（29.9 分）、ce 0**；前兩槽 11-24 ok 1,816,088 ms、11-23 error 1,406,869 ms（被砍）；**下一槽 11-26 04:25**（今晚將是守門修好後第三夜）。
- 交付：依規則**只 append 寫入本檔**，未 sessions_send 回 rowlet 的 cron session、未 announce 外部頻道。

## 2026-11-26 01:02 — 第 16 輪 — PASS（lane token 逐字一致）／⭐⭐⭐ **本輪頭號發現：「降級跑」會讓 heartbeat 600s 群集隱形（上輪的「連 4 輪＝0」是被降級輪遮蔽出來的假象）**／⭐⭐ **600s 硬死的因果模型可預測：任何 >600s 的 cron 佔用者都會讓同窗 heartbeat 撞牆，且阻擋是「跨 agent」的**／🔴 22:02 槽本 job 降級跑（dur 17.8s、零紀錄）→ 零降級連 2 槽破功／🔴 Discord gateway READY 自 11-25 04:54:36 起 20h08m 無成功落地／✅ 配額牆連續第 7 輪 0 筆／⚠️ KA 路由空殼第 12 輪、`02eb0989` timeoutSeconds 第 10 輪未補<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通、token 逐字一致）
- `sessions_send` → `agent:gengar:main` → runId **`14458980-915e-4e4b-bc44-8f0cfc718989`**、status=**ok**，回覆含逐字一致 token **`LANE_OK_GENGAR_0102_26 = 12`**。
- 對方自報：近 60 分鐘 canonical provider 失敗全 0（視窗 **00:03:23→01:03:23**、**1,267 總行 → 986 系統行 → 982 去巢狀回音** → 429/overloaded/EAI_AGAIN/ENETUNREACH/AbortError/usage-limit 全 0）；6 支自有 cron 全 `ok`／ce 全 0（watchdog 3,014ms、heartbeat-gengar 35,883ms、English coach 7,961ms、BBC drill 217,387ms、skill-collection-review-gengar 86,815ms、版本檢查 258,726ms）；gateway MainPID 4137629／NRestarts 0／運行 ≈**68h18m**；Discord **8 connected / 8 enabled**、近 60m ingress **12 筆**（深夜低量）；dreaming 上一槽 11-25 04:25 `ok` 1,793,022 ms ce0（11-24 ok 1,816,088 ms、11-23 error 1,406,869 ms 被砍），下一槽 **11-26 04:25**。
- 對方遵守回程腿規則：只 append 寫入本檔（01:03:41、2,438 B），**未** sessions_send 進本 cron session、**未** announce 外部頻道。
- **我的獨立複算**：3h 窗 canonical 429 = **1**（**00:02:04**）→ 落在對方 60m 窗（00:03:23 起）**之前 79 秒**，故「對方 429=0」與「我 3h=1」不衝突。
- ⚠️ **announce 腿仍失敗**：journal **22:02:41** `[agents/sessions-send] sessions_send announce flow failed` → 與 MEMORY.md L417 已知行為一致（inline 先拿全文、announce 之後仍可能晚到），**不是對方失聯**，未重複發送。

### 2) 三支 KA 槽位表現（receipt 為準；dur 是唯一可靠的「實質／filler」指標）
| slot | gengar (9d8b6001) | picturecat (02eb0989) | celesteela (880b5c17) | 判定 |
|---|---|---|---|---|
| 11-25 01:02 | 522.3s | 797.3s | 152.8s | 零降級 |
| 11-25 04:02 | 281.6s | 307.0s | 60.4s | 零降級 |
| 11-25 07:02 | 285.3s | 551.6s | 128.9s | 零降級（連 8 槽） |
| **11-25 10:02** | **4 筆全 429（4.5／5.2／3.1／4.4s）** | **2.3s err（openai 無 profile）** | **4.5s err** | 🔴 三支全滅（配額牆） |
| **11-25 13:02** | **31.7s（filler 空轉）** | 156.9s | 606.5s | 🔴 gengar 空轉 |
| 11-25 16:02 | 575.1s | 290.7s | 168.5s | ✅ 全實質 |
| 11-25 19:02 | 252.3s | 167.6s | 138.6s | ✅ 全實質（gengar 連 2 槽） |
| **11-25 22:02** | **17.8s（降級跑、零紀錄）** | 376.1s | 334.5s | 🔴 gengar 降級 |
| 11-26 01:02 | running（本輪） | running | running | 本輪 |
- **零降級連 2 槽（16:02、19:02）→ 22:02 破功**；本輪 ＝ **連 1 槽**。
- 降級判定三證據：① receipt dur **17.8s < 30s**；② `keepalive-gengar-2026-11-25.md` mtime 停在 **19:06**（22:02 輪零紀錄）；③ `memory/2026-11-25.md` mtime 停在 **21:21**（22:02 輪連 daily 都没寫）。
- ⚠️ **交叉核對抓到 picturecat 本槽的誤判**：picturecat 01:02 輪報「22:02 槽三支 KA 全綠」，只看了 status=ok、**沒看 dur** → 把本 job 的 17.8s 降級輪算成實質。**「status=ok」不等於「有巡檢」，只有 dur 會說話。**
- **anchor 疊窗第 31 次**：picturecat 01:02:05 → gengar 01:02:07 → celesteela 01:02:07（Δ2s / 同秒互撞，無 stagger 緩衝）。

### 3) ⭐⭐⭐ 本輪頭號發現：**「降級跑」不只是少一份紀錄，它還讓事故視窗隱形**
- 上輪（19:02）報「heartbeat 600s 群集 3h 窗連 4 輪＝0」。但 **19:02→22:02 這一段裡有 3 次 heartbeat 600s 硬死**：
  - **20:08:24 `heartbeat-rowlet` 600.0s error**（cron: job execution timed out）
  - **20:12:45 `heartbeat-celesteela` 600.0s error**
  - **21:08:20 `heartbeat-rowlet` 600.0s error**
  - ＋ **21:12:45 `heartbeat-celesteela` skipped dur 397.3s**（skipped 卻跑了 6.6 分）
- **這一整段正是被 22:02 降級輪（dur 17.8s、零紀錄）整段跳過的視窗** → 降級輪不量 → 事故窗無記錄 → 下一輪的 3h 滾動窗把這段推出視野外 → **「連 4 輪＝0」的假象**。
- ⇒ **對已知根因（payload 只有一句 `keep-alive test`）的新代價判定**：降級跑的傷害**不只是省 token，是遮蔽事故**。這把「把必做清單寫進 payload」從「省 token 的選項」升級為「可靠度工程」。
- ⇒ **量測口徑修正（可複用）**：**「3h 窗 600s＝0」不可信**，因為上一輪是否降級會決定這個數字。本輪改用 **12h／26h receipts 全掃描** 才補回（12h 窗 = 6 筆 error，含 3 筆 600s 硬死）。→ 建議以後一律用「最近 N 槽的 receipts 全掃描」而非「3h 滾動窗」。

### 4) ⭐⭐ 600s 硬死的因果模型已可預測（且阻擋是「跨 agent」的）
| 佔用者（agent） | 佔用窗 | dur | 被拖累者 | 結果 | 秒級對齊 |
|---|---|---|---|---|---|
| `PTCGP Meta Analysis`（celesteela） | 20:05:00→20:22:56 | **1076.1s** | heartbeat-rowlet 20:08:24 | **600s 硬死** | — |
| 同上 | 同上 | — | heartbeat-celesteela 20:12:45 | **600s 硬死** | — |
| 同上 | 同上 | — | heartbeat-rowlet 20:18:55 | skipped **241.0s** | **結束 20:22:56 ＝ PTCGP 結束（同秒）** |
| `每日資安建議`（rowlet） | 21:03:15→21:19:22 | **966.8s** | heartbeat-rowlet 21:08:20 | **600s 硬死** | — |
| 同上 | 同上 | — | heartbeat-celesteela 21:12:45 | skipped **397.3s** | **結束 21:19:22 ＝ 資安建議結束（同秒）** |
| `Gengar Keep-Alive`（rowlet） | 16:02:04→16:11:39 | 575.1s | heartbeat-mrmime 16:01:07 | **600s 硬死**（16:11:38 runner-failure） | — |
| 同上 | 同上 | — | heartbeat-rowlet 16:08:22 | skipped **197.4s** | **結束 16:11:40 ＝ KA 結束 +1s** |
- **模型**：任何 **>600s** 的 cron 佔用者，都會讓同窗內啟動的 heartbeat 排隊等待、撞上 600s 牆 → `cron: job execution timed out`；其後同 lane 的 heartbeat 以 `skipped` + dur＝剩餘等待收尾，且**結束時刻＝佔用者結束時刻**（本輪為第 4、第 5、第 6 個秒級對齊實例）。
- ⭐ **口徑更正（重要）**：上輪把這稱為「同 lane／同 agent 排隊」。**實證是跨 agent 的**：rowlet 的 `每日資安建議`（21:03–21:19）拖死的是 **celesteela** 的 heartbeat；rowlet 的 `Gengar KA`（16:02–16:11）拖死的是 **mrmime** 的 heartbeat。→ **修法不能只在各自 lane 內錯開**。
- ⇒ **修法升級（取代原 #1 的單純錯開說法）**：① **heartbeat timeout 必須 > 最長 job dur**（目前最長 PTCGP 1076s、資安 967s、備份 130s，而 heartbeat 牆只有 600s → **任何 >600s 的 job 都是定時炸彈**）；或 ② 把 >600s 的 job 移到不跑 heartbeat 的 agent；或 ③ 長 job 與 heartbeat 槽錯開 ≥10 分鐘。**KA payload.timeoutSeconds=1800 夠，但 heartbeat 仍只有 600s。**

### 5) ✅ 健康回報 23:05 槽：標準 🛡️ 格式、非 filler（連 3 天未見 filler）／但結構性漏報第 3 輪未修
- receipt：**11-25 23:05:21 → ok、dur 68.9 s**（`13ac4b5a`）。
- 內容（cron session `agent:mrmime:cron:13ac4b5a-…` 末則 assistant message）：`🛡️ 健康回報 15:06 UTC`／`Gateway: ✅（running，probe ok，127.0.0.1:18789）`／`Disk: 61%（176G 可用）`／`Crons: 0 failed（已修復 0）`／`Delivery: OK`＋附註 `clean-code研究` 卡在 minimax Token Plan 額度 + openai credits=0、超出時間窗未動作。
- ✅ 格式標準、非 filler。
- ⚠️ **但它報「Crons: 0 failed」是因為只讀最近 1h（22:05–23:05）** → **20:08／20:12／21:08 的 3 筆 600s 硬死全在窗外** → pending #5（健康回報改以 `cron_run_receipts` 為準）第 3 輪未修。
- 📌 量測口徑沿用上輪結論：cron run 的 `task_runs` 列已被清掉 → summary 必須用 cron session transcript 讀（本輪即以此取得）。

### 6) ✅ 配額牆未回來（連續第 7 輪 0 筆）；但 00:02 一顆快閃 429 被救回
- 3h 窗 `Token Plan usage limit` = **0**（24h 211 筆全落 11-25 09:00–12:09 → 牆已退場 ≈**12h53m**）；3h 窗 receipts 429 類 error = **0**。
- 3h 窗 canonical 429 = **1**：**11-26 00:02:04**（`model-fetch … provider=minimax-portal model=MiniMax-M3 status=429`、**elapsedMs=94,231** 慢排空型）→ 被 same-model retry 救回，未釀紅單。
- ⚠️ 判讀陷阱複習：canonical 429 必須鎖 `model-fetch … status=429`，寬鬆 grep 會造出假陽性（上輪 17:34:25 即為一例）。

### 7) 🔴 Discord：gateway READY 自 11-25 04:54:36 起仍無成功落地（現 ≈**20h08m**）
- 24h 內 `[discord] gateway READY` 共 **17 筆，全部**是 `READY wait timed out after 15000ms; reconnecting with backoff`，**最後一筆 04:54:36** → **自此 20 小時 08 分沒有任何一次成功 READY**。
- 3h 窗 READY 嘗試 = **0 筆**，但 `gateway websocket closed code=1005` 持續（3h **15 筆**）→ **重連一直在發生、卻從未 READY 成功**。
- `channel exited` 3h = **0**（24h 11 筆全落 04:27–06:38）；`commands exceed the 100-command limit` 3h/24h = **0**。
- provider 層由對方自報 **8/8 connected**、近 60m ingress **12 筆** → 入站與 provider 層正常，**斷點在 gateway READY 層**；pending #4 維持（建議重啟／重建 Discord provider session，並把「成功 READY」列為健康回報必檢項）。

### 8) ⚠️ KA 路由空殼第 12 輪 ＋ `02eb0989` timeoutSeconds 第 10 輪未補
- `9d8b6001`（Gengar KA）：**agent_id=None**（owner=None）、enabled=1、**payload.timeoutSeconds=1800 ✅**、payload 仍只有 15 字元 `keep-alive test`、delivery=`{mode:none}`、sessionTarget=isolated、每 3h。
- `02eb0989`（Picturecat KA）：**agent_id=None**、**payload.timeoutSeconds=None ❌（第 10 輪）**、payload 仍 15 字元。
- `880b5c17`（Celesteela KA）：**agent_id=celesteela ✅**、payload **960 字元**含完整必做清單＋工作目錄（**唯一正確者**）。
- 三支 `lastDeliveryStatus` 全 **not-requested** → 結果不回報到任何地方（本輪亦未外部 announce）。
- ⚠️ 本輪 session 內 `automations list/get` 對本 job 回 not found／空清單（restricted automation-run session 作用域假象，CLI `openclaw cron list` 顯示 enabled+running）→ 設定真相仍以 `cron_jobs` 表（read-only python sqlite3）為準。

### 9) fleet 與紅單
- `cron_jobs`：**53 支（enabled 46／disabled 7）**。
- receipts：**3h 窗 total 101／ok 68／skipped 30／running 3／error 0**；**12h 窗 total 328／ok 195／skipped 124／error 6／running 3**；**26h 窗 total 679／ok 319／skipped 287／error 70／running 3**。
- 12h 窗 6 筆 error 全列：`heartbeat-mrmime` 16:01:07（600.0s timeout）＋16:11:38（runner-failure）、`heartbeat-rowlet` 20:08:24（600.0s）、`heartbeat-celesteela` 20:12:45（600.0s）、`每日資安建議` 21:00:05（rate limit）＋`heartbeat-rowlet` 21:08:20（600.0s）。
- 24h error 分類（70 筆全列）：`cron: job execution timed out` **29**、`All models failed` 429 **20**、`⚠️ API rate limit reached` **12**、`heartbeat failed: agent-runner-failure` **8**、`Explicit auth order for openai has no usable profiles` **1**。
- **現行紅單（enabled 且 ce>0）仍 2 支、沒有 +1**：`89e2cfe7 clean-code研究` ce=3（provider=openai/gpt-5.4-mini、reply=`The agent run failed before producing a reply.`、next 11-26 09:00）、`c5352a84 skill-collection-review-roaringmoon` ce=1（next 11-27 03:56）。
- `每日資安建議` 21:00:05 error → 21:03:15 ok（dur 966.8s）→ **已自癒**。

### 10) 系統面（全部附口徑）
- **gateway**：`systemctl --user show openclaw-gateway.service` → MainPID **4137629**、NRestarts=**0**、ActiveState=active、ActiveEnterTimestamp **Mon 2026-11-23 04:48:17 CST** → 至 01:02 連續 **68h14m** 零重啟。
- **elle.service**：NRestarts **125,229**（上輪 124,514 → **+715／約 6h ≈ 119/h**，速率持平）、ActiveState=activating；需 root，維持回報不動手。
- **磁碟／資源**：`/` 468G 用 269G（**61%**）、可用 176G；RAM 31G 用 9G（available 20G）；load 0.63/0.54/0.50；uptime **45 天 6:51**。
- **journal 行數**：3h 窗 **user-scope 1,295 行**（all-scope 4,175）、24h **user-scope 13,000 行**（all 34,373）→ 與上輪（13,350／34,552）持平。
- **SSH**（Accepted-only、**大小寫不敏感**、all scope）：3h **54**、24h **428** → 與上輪（54／426）幾乎一致＝**基線未動**（+2）。
- **superseded**：3h **2**（上輪 25 → **大幅下降**）、24h **100**（上輪 125 → 下降）→ 疊窗副作用收斂（與 picturecat 01:02 輪「24h 102 行、Type A 90 + Type B 12」口徑一致）。
- **skill 缺 description**（第 29 輪）：24h `description is required` **1,833** ＋ `BAD_INDENT` **564** ＝ **2,397 行/24h**（上輪 2,754 → **−357／−13%**）；3h 窗 273＋84＝357。13 檔／4 檔清單不變，仍需 Linder 點頭，**本輪不動**。
- ⚠️ **`gw-upgrade-guard.log` 第 17 輪仍不存在**（`/home/amr` maxdepth 4 搜尋無果）；**`dreaming-schedule-check.log` 停擺第 10 天**（實體在 `workspace-rowlet/memory/dreaming-schedule-check.log`、mtime 11-19 22:33）。
- **dreaming `36b493db`**：11-25 04:25 槽 `ok` 1,793,022 ms ce0（連續兩夜完整）→ **下一槽 11-26 04:25**（今晚＝第三夜）。

### 11) 給 Linder 的待決事項（更新後 15 項）
1.【**最高・新】** **heartbeat timeout 600s 是定時炸彈**：任何 >600s 的 cron（PTCGP Meta 1,076s、每日資安建議 967s）都會讓同窗 heartbeat 撞牆硬死（本輪 3 死）；**修法：拉高 heartbeat timeout > 最長 job，或把長 job 移出會跑 heartbeat 的 agent，或長 job 與 heartbeat 槽錯開 ≥10 分**（改 job 需點頭）。注意 KA payload.timeoutSeconds 已是 1800，**炸彈在 heartbeat 那一側**。
2.【**最高・第 12 輪】** **KA 路由空殼**：`9d8b6001`／`02eb0989` agent_id 仍空 → 兩支仍跑在 rowlet、仍不回報（lastDeliveryStatus=not-requested）。改法＝比照 `880b5c17` 補 `gengar`／`picturecat` ＋ 決定是否開投遞；**副作用＝改完本審查前提須重設**。
3.【**高・新】** **把必做清單寫進 job payload 的理由已升級**：本輪實證「payload 只有一句 `keep-alive test`」會讓 22:02 槽降級跑，而降級跑**直接遮蔽了 19:02–22:02 視窗內的 3 次 heartbeat 600s 硬死** → 這不是省 token 問題，是**可靠度問題**。
4.【**高・新】** **量測口徑**：別再用「3h 滾動窗 600s＝0」當健康指標（上一輪是否降級會決定這個數字）→ 一律用「最近 N 槽 receipts 全掃描」。
5.【**高・第 20h】】 **Discord gateway READY 自 04:54:36 起 20h08m 無成功落地**（24h 內 17 筆 READY 全 timeout；3h READY 嘗試 0 筆但 websocket closed 15 筆）→ 建議重啟/重建 Discord provider session，並把「成功 READY」列為健康回報必檢項。
6.【**高・第 3 輪】】 **健康回報的結構性漏報未修**：只讀最近 1h → 23:05 槽報「Crons: 0 failed」但 20:08/20:12/21:08 的 3 筆 600s 硬死全在窗外。修法＝以 `cron_run_receipts` 為準。
7.【**高・第 10 輪】】 `02eb0989` Picturecat KA **未設 timeoutSeconds**（01:02 曾 797,261 ms）→ 補 1800s。
8.【**高・第 6 天】】 `89e2cfe7 clean-code研究` **連 6 天首跑死**（ce=3）→ provider=openai/gpt-5.4-mini、reply=`The agent run failed before producing a reply.`；檢查 payload／模型可用性或改掛可用 provider。
9.【**中】** **MiniMax 配額牆需用量可視化或第二廠商 fallback**（跨廠冗餘 0 已實際造成 10:02 三支全滅；牆已退場 12h53m，但 00:02 出現零星復發一顆）。
10.【**中・第 31 輪】】 三支 KA anchor 仍疊（01:02 槽 Δ2s／同秒）→ 拉開 ≥15 分鐘。
11.【**中・第 29 輪】】 17 支 skill 缺 description（2,397 行/日，仍在下降）→ 需點頭。
12.【**中・沿用】】 `openai/gpt-5.4-mini` 仍是死路（無 profile／無餘額）→ 要嘛修好、要嘛從 fallback 鏈移除以免假性冗餘。
13.【**中・沿用】】 `elle.service` 重啟迴圈 +715/6h（需 root）；`gw-upgrade-guard.log` 第 17 輪不存在；`dreaming-schedule-check.log` 停擺第 10 天。
14.【**中・第 12 次】** KA 探針在被探 lane 製造 superseded 競態（3h **2**／24h **100**，本輪明顯收斂）→ 維持觀察。
15.【**低・沿用】】 健康回報 filler 連 2 天已中斷（11-25 23:05 槽為標準 🛡️ 格式）→ 但仍建議在 payload 加「必須輸出 🛡️ 格式 final summary」硬約束。
- ✅ **本輪結案**：① **降級跑的真正代價＝遮蔽事故窗**（實證）；② **600s 硬死模型可預測、且阻擋是跨 agent 的**（上輪的「同 lane」說法已更正）；③ **「status=ok」不等於實質**（picturecat 本槽誤判實例）；④ **superseded 大幅收斂**（3h 25→2）。
- ⚠️ **本輪降級（不列紅單）**：restricted automation-run session 內 `automations list/get` 回 not found／空清單（session 作用域假象）；`message read` 在本 session 無 delegated account（Discord 全文改由 cron session transcript 取得）。

### 12) 下一輪（11-26 04:02）交辦
① **04:25 dreaming 槽**跑完結果（是否連續第 3 夜完整：receipt dur ≥1,800,000ms 且 ok）＋ `discord-selfheal` next 04:43 ＋ gateway MainPID 是否未變；② **用 receipts 全掃描重算 heartbeat 600s 群集**（不要用 3h 滾動窗），並追本輪三個佔用者（PTCGP Meta 每日 20:05、每日資安建議 21:03、每日 OpenClaw 備份 16:00）各自的 dur 是否仍 >600s；③ 04:02 槽三支 KA dur＋是否實質（挑戰「零降級連 2 槽」）＋ summary 長度（cron session transcript 口徑）；④ **22:02 降級輪的內容補寫**（該槽 3 筆 600s 硬死的完整記錄目前只存在本輪檔，補進 11-25 檔或在本檔標註）；⑤ 配額牆是否復發（journal `Token Plan usage limit`＋receipts 429 類＋canonical 429，窗內附納入行數）；⑥ Discord 成功 READY 是否落地（非 timeout 筆數、channel exit、websocket closed 筆數）；⑦ 健康回報 02:05 槽是否標準 🛡️ 格式、非 filler＋結構性漏報是否已修；⑧ skill 缺 description 第 30 輪密度；⑨ KA 路由是否已修（未點頭則明示前提不變）＋ `02eb0989` timeoutSeconds 是否補；⑩ `gw-upgrade-guard.log`／`dreaming-schedule-check.log` 第 18 輪；⑪ SSH Accepted-only；⑫ `elle.service` 迴圈速率；⑬ superseded 第 13 次；⑭ gengar lane 探針（token 換 `LANE_OK_GENGAR_0402_26 = 13`）；⑮ 零值結論一律附「已納入行數」；⑯ sqlite 一律 `LIKE` 前綴＋cp 三檔到 /tmp（`file:…?mode=ro`，本機無 sqlite3 CLI）；⑰ **gateway 必用 `systemctl --user show openclaw-gateway.service`**；⑱ **新增：巡檢摘要長度／內容一律用 cron session transcript 取（task_runs 對 cron run 已不保留 terminal_summary）**；⑲ **新增：追 `89e2cfe7 clean-code研究` 連 6 天首跑死（第 7 天）與 `c5352a84` ce 是否歸 0**。


## 2026-11-26 04:02 — 第 17 輪 — PASS（lane token 逐字一致）／⭐⭐ **配額牆第 8 輪破功：03:00 Jormungand 兩度 rate limit（被 `state.lastRunStatus=ok` 掩蓋）／⭐⭐ 自 11-25 22:00 起 6 小時零 600s 硬死（receipts 全掃描 198 筆）／🔴 Discord READY 連續第 21 輪無成功落地／⚠️ skill 缺 description 口徑差異（9 vs 17）／⚠️ dreaming 04:25 槽本輪尚未到＝無法驗收** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main` → runId `b894d6fb-6cc6-4ab2-b7fa-bbcb1c16ebd7`、status=ok、token `LANE_OK_GENGAR_0402_26 = 13` **逐字一致**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對方自報：6 支自有 cron 全 ok ce0（`29c2d630` watchdog、`c29eca0f` heartbeat-gengar、`ac9e7ada` English coach、`88810bfe` BBC drill、`7767e03b` skill-collection-review-gengar、`f5148ff0` 版本檢查）；3h 內 error receipts 2 筆但**都不是它的**（`40e09cd1` mrmime 的 Jormungand，03:00／03:01）；gateway MainPID 4137629／NRestarts 0／uptime ≈71h19m；Discord **8/8 connected**（greninja 停用）；3h canonical 非 200 = 2（皆 429）；dreaming 11-25 04:25 ok 1,793,022 ms ce0、11-26 04:25 尚未跑（距槽 22 分）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對方僅 append 寫檔（`workspace-gengar/memory/2026-11-26.md`）、未回 session、未 announce → 符合 protocol（不把訊息投遞進正在執行的 cron run session）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 本窗零 600s 硬死 —— 以「具名窗 + receipts 全掃描」量測（不用 3h 滾動窗） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 窗 | receipts 納入筆數 | `cron: job execution timed out`（600s 硬死） | skipped 且 dur≥300s | error receipts |
|---|---|---|---|---|
| 11-26 00:00 → 04:02（本窗） | 139 | **0** | **0** | 2（皆 `40e09cd1`） |
| 11-25 22:00 → 04:02 | 198 | **0** | **0** | 2 |
| 11-25 19:02 → 04:02 | 265 | 3 | 1 | 6 |
| 24h | 633 | 29 | 12 | 多筆 | <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3 筆硬死全在 19:02–22:00 窗：**20:08:24／20:12:45／21:08:20**（heartbeat）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 1 筆 skipped dur=397.3s（21:12:45→**21:19:22**）的結束時刻＝佔用者 `每日資安建議` 結束時刻 21:19:22 → **第 7 次秒級對齊**實例。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 29 筆硬死全屬 heartbeat：rowlet 9、mrmime 8、celesteela 4、roaringmoon 2、picturecat 2、charizard 2、gengar 2。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本窗所有 skipped heartbeat 都是 `heartbeat skipped: no-route`（0.3–6.3s，屬正常略過），**無一筆是排隊佔用型**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ 配額牆第 8 輪破功：03:00 Jormungand 兩度 rate limit（且被 `state` 欄位掩蓋） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand daily all-agent health`（mrmime）：**03:00:00 error 67.6s**「⚠️ API rate limit reached」→ **03:01:37 error 85.8s** → **03:04:03 ok 195.6s**（重試救回）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical 429 = **2 筆**：03:01:07（elapsed 62,528ms）、03:03:03（elapsed 77,451ms），provider=minimax-portal、model=MiniMax-M3、dispatcher=reused。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal `Token Plan usage limit` 3h 窗 = **0 筆**（納入 1,403 行）→ 本次是 generic rate limit，**不是** Token Plan 配額牆；24h 窗 = 211 筆（仍全落 11-25 09:00–12:09）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **掩蓋型事故第 2 個可觀測實例**：同一 job 的 `state.lastRunStatus=ok`、`consecutiveErrors=0`（末筆成功洗白）→ **紅單掃描完全看不到這 2 筆 error**。規則：紅單判定須疊「同 job 24h 內 error receipt 筆數 > 0」，不能只看 state。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 🔴 Discord：READY 連續第 21 輪無成功落地 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `gateway READY wait timed out` = **25 筆**；3h = 8 筆，最後一筆 **01:14:38** → 距本輪 2h48m 無新 READY 嘗試。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 成功 READY（`logged in as` / `Gateway ready` / `identified`）24h = **0 筆** → 自 11-25 04:54:36 起 ≈**23h08m** 無成功落地。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h `Gateway reconnect scheduled` = 27 次；最後 `websocket closed` 03:34:45；3h Discord 遞送失敗（failed to send / forbidden / missing access）= **0 筆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **「Discord 8/8 connected」≠「gateway READY 成功」**：前者是 client 端連線數，後者是握手結果，兩者可同時成立且互相矛盾 → 健康指標須寫「成功 READY 筆數」，不可用連線數代替。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Gateway / 主機 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `systemctl --user show openclaw-gateway.service` → MainPID **4137629**、NRestarts **0**、ActiveState=active、起於 11-23 04:48:17 → uptime ≈**71h19m**（我與 gengar 兩邊量測一致）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- load 0.62/0.71/0.64；mem 31G 總量／available 20G；disk 61%（176G 可用）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 三支 KA：anchor 疊窗第 33 次（Δ2s）、零降級連 2 槽 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:02:05 `02eb0989` Picturecat（timeout None）→ 04:02:07 `9d8b6001` Gengar（1800）→ 04:02:07 `880b5c17` Celesteela（1800，agentId=celesteela）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 上一槽（01:02）dur：Gengar **328.1s**、Picturecat 148.6s、Celesteela 151.3s → 三支皆實質 → **零降級連 2 槽**（22:02 降級輪後復原）。本輪 dur 以 receipt 為準，自報值不作數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA 路由空殼第 13 輪**：`9d8b6001`／`02eb0989` 的 agentId 仍 None → 兩支仍由 rowlet 執行、仍不回報（lastDeliveryStatus=not-requested）；`02eb0989` 的 payload.timeoutSeconds **第 11 輪未補**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 健康回報 02:05 槽：格式正常、結構性漏報第 4 輪未修 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt 02:05:53 ok、dur 33,117ms、summary 242 字 → **標準 🛡️ 格式、非 filler**（連 2 輪確認 filler 已中斷）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 但仍只讀「最近一小時」→ 報「Crons: 0 failed（已修復 0）」，窗外 20:08/20:12/21:08 三筆 600s 硬死與今日 03:00 的 2 筆 error 皆不可見 → **修法仍是以 `cron_run_receipts` 為準**（第 4 輪未動）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 紅單與逾期 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `89e2cfe7 clean-code研究`（charizard）ce=3，最後嘗試 11-25 09:07（Token Plan 429 + `openai` 無 usable profile），下一槽 11-26 09:00 → **連續第 7 天首跑死待驗**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `c5352a84 skill-collection-review-roaringmoon` ce=1，最後 11-20 03:59（`DNS loop`），下一槽 11-27 03:56 → 未自癒。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `a94330a9 tmp-openai-probe` ce=2 但 enabled=false（殘留，未列紅單）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 其他量測 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **lane wait exceeded**：24h = 9 筆，**全部集中 `roaringmoon-morning-pipeline` lane**（最大 1,353,143ms = 22.6 分；另有 345,717／379,776／393,301／505,479／893,074／944,565／1,199,315ms）＋ mrmime discord channel 1 筆 64,321ms；**3h = 0 筆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **competing work**（`Cannot delete session while competing work is in flight`）：3h = 9 筆、24h = 74 筆 → fleet 級常態雜訊；本窗未伴隨任何 lane wait 超時 → 無傷害。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **superseded**：3h = 8 筆、**全部 Type A**（`nested:agent:gengar:main` 3 + `session:agent:gengar:main` 3 + 相關 fallback 2，時間戳全在 04:04:31＝本輪 lane 探針造成）→ **Type B（`*:main:heartbeat`）3h = 0**；24h = 106 筆其中 Type B = 12（mrmime 6 + gengar 6）→ 與上輪相同，**近 3h 無新增 Type B**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **SSH**：`Accepted publickey`（大小寫不敏感）3h = 54 筆、24h = 426 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **elle.service**：系統層 unit 為 `activating start-pre`（啟動迴圈，需 root）；journal 提及 3h = 1,071 筆、6h = 2,142 筆，其中「Scheduled restart/Started/Activating」3h = 357 筆 → ≈**119 次啟動嘗試/3h**（≈40/小時）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **日誌檔**：`gw-upgrade-guard.log` 第 18 輪仍不存在（`find ~/.openclaw -name "gw-upgrade-guard*"` = 0 筆）；`dreaming-schedule-check.log` 存在但 mtime 停在 **11-19 22:33** → **停擺第 10 天**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **skill 缺 description 口徑差異**：本輪以「frontmatter 無 `description:` 鍵」掃 6 個 skill 根目錄（`~/.openclaw/skills`、`plugin-skills`、`workspace-rowlet/skills`、`workspace-rowlet/.agents/skills`、openclaw `skills`、`custodian-skills`）共 **117 支 → 缺 9 支**（card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、system-design-six-dimensions-analyzer、web-fetch-troubleshooting）。**與往輪沿用的「17 支」不一致 → 兩者必有一方口徑不同**，開單前需指定 canonical 定義。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **dreaming 11-26 04:25 槽**：本輪 04:02 尚未到（gengar 報「距槽 22 分」）→ **本輪無法驗收，只能標記待驗**；`discord-selfheal-after-dreaming` 最後 03:43 ok 0.8s、下一 05:13。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 給 Linder 的待決事項（更新後 15 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1.【**最高・新】** **紅單判定補洞**：同一 job 可「末筆 ok、ce=0、但 24h 內有 error receipt」（`40e09cd1` 03:00/03:01）→ 紅單掃描須疊 receipts 分組計數，不能只看 `state.lastRunStatus`/`consecutiveErrors`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2.【**最高・沿用】** **heartbeat 600s timeout 牆仍是定時炸彈**（24h 29 筆硬死全屬 heartbeat；本窗 22:00 後乾淨只是因為無長 job 重疊）→ 拉高 heartbeat timeout > 最長 job、或長 job 移出該 agent、或錯開 ≥10 分（改 job 需點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3.【**最高・第 13 輪】】 **KA 路由空殼**：`9d8b6001`／`02eb0989` agentId 仍空 → 仍跑在 rowlet、仍不回報。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4.【**高・新】** **「把必做清單寫進 job payload」＝可靠度工程**（降級跑會遮蔽事故窗，本輪再次確認 22:02 降級輪後續槽恢復但口徑仍不可信）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5.【**高・第 21 輪】】 **Discord READY 仍無成功落地**（24h timeout 25 筆、成功 0 筆、3h reconnect 27 次）→ 建議重啟/重建 Discord provider session，並把「成功 READY 筆數」列為健康回報必檢項（勿用 8/8 connected 代替）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6.【**高・第 4 輪】】 **健康回報結構性漏報未修**（仍只讀最近 1h）→ 改以 `cron_run_receipts` 為準。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7.【**高・第 11 輪】** `02eb0989` Picturecat KA **未設 timeoutSeconds** → 補 1800s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8.【**高・第 7 天】** `89e2cfe7 clean-code研究` 首跑死待驗（ce=3，下一槽 11-26 09:00）；`c5352a84` ce=1 未自癒（下一槽 11-27 03:56）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9.【**中・第 8 輪】】 **MiniMax 配額／限流牆復發**（03:00 generic rate limit 2 筆，跨廠 fallback 仍只有 minimax×2）→ 需第二廠憑證（憑證我不碰，需你提供）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10.【**中・第 33 輪】】 三支 KA anchor 仍疊（04:02 槽 Δ2s、同秒）→ 拉開 ≥15 分鐘。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11.【**中・口徑待定】】 **skill 缺 description**：本輪實測 9/117（往輪 17）→ 先定 canonical 口徑再談補丁。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12.【**中・沿用】** `openai/gpt-5.4-mini` 仍是死路（無 usable profile）→ 修好或從 fallback 鏈移除。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13.【**中・沿用】** `elle.service` 啟動迴圈 ≈119 次/3h（需 root）；`gw-upgrade-guard.log` 第 18 輪不存在；`dreaming-schedule-check.log` 停擺第 10 天。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14.【**中・第 13 次】** KA 探針在被探 lane 製造 superseded 競態（3h 8 筆全 Type A；24h Type B 維持 12 筆、近 3h 無新增）→ 維持觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
15.【**低・沿用】** 健康回報 filler 已連 2 輪未見，但仍建議在 payload 加「必須輸出 🛡️ 格式 final summary」硬約束。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本輪結案**：① **「零降級」與「零事故」必須分開量測**（本窗 22:00→04:02 零硬死，但同日 19:02–22:00 三筆）；② **「末筆成功」會洗白中間的 error**（`40e09cd1` 實例）；③ **Discord 連線數 ≠ READY 成功**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **本輪降級（不列紅單）**：restricted automation-run session 內 `automations list/get` 對本 job 回 not found／空清單（作用域假象）→ 真相以 `cron_jobs`／receipts 為準；本 job 04:02 槽 anchor 與 picturecat/celesteela 同槽（Δ2s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 下一輪（11-26 07:02）交辦 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① **04:25 dreaming 槽結果**（dur ≥1,800,000ms 且 ok ＝ 連續第 3 夜）＋ 05:13 `discord-selfheal` 槽 ＋ gateway MainPID 是否仍未變；② **receipts 全掃描（具名窗，不用 3h 滾動窗）**：600s 硬死、skipped dur≥300s、以及 09:00 `89e2cfe7` 是否再死（ce 是否 +1）；③ **配額牆是否持續**：03:00 的 generic rate limit 是否再發、journal `Token Plan usage limit` 3h 計數、canonical 429 筆數（附納入行數）；④ `40e09cd1` 的 03:04 重試是否讓 ce 歸 0（＝掩蓋型事故）；⑤ **Discord 成功 READY 是否落地**（勿用 8/8 connected）、reconnect 次數、3h 遞送失敗數；⑥ 健康回報 05:05 槽格式＋結構性漏報是否已修；⑦ 三支 KA 07:02 槽 dur＋anchor Δ（疊窗第 34 次預期）＋ `02eb0989` timeoutSeconds、KA agentId 是否補；⑧ **skill 缺 description canonical 口徑（9 vs 17）**；⑨ SSH / elle 速率 / `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 19 輪；⑩ superseded Type B 是否新增（24h 12 筆基線）；⑪ 紅單 `89e2cfe7`（第 7 天）、`c5352a84`（11-27 03:56）；⑫ **本輪自身 dur 仍以 receipt 為準**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-26 07:02 — 第 18 輪 — PASS（lane token 逐字一致）／🔴🔴 **600s 牆在 04:02→07:02 窗全面破功：15 筆 heartbeat 硬死（上輪的「零硬死」只成立到 04:02，23 分鐘後就被 04:25 dreaming 槽打回原形）**／⭐⭐ **因果歸屬完成：dreaming 1815s 吃掉 10 筆、每日 LLM Wiki 巡讀 1549s 吃掉 4 筆、Agent 潮流研究 661s 逼出 1 筆排隊型 skip**／⭐⭐ **7 天直方圖：11-25 04h=10、11-26 04h=11（11-24 及更早＝0）→ dreaming 每夜穩定殺 ~10 個 heartbeat，是新模式**／⭐⭐ **根因收斂到單一機制：toolsAllow:["*"] 的長 job 餓死 gateway event loop → 同一機制同時造成 heartbeat 600s 硬死與 Discord READY 失敗**／🔴 **gateway 05:13:49 重啟（pid 4137629→784503）＝ selfheal 合法開火，但重啟後 Discord READY 仍 0 成功 → 「重啟能修 READY」的前提已失效**／🔴 Discord READY 連續第 22 輪無成功落地／⭐ **健康回報 05:05 槽抓到鐵證：宣稱「最近一小時無失敗」的那一小時裡躺著 10 筆硬死（第 5 輪結構性漏報未修）**／⭐ **修正上輪 ⑱ 的錯誤：task_runs 仍保留 cron run 的 terminal_summary，不必翻 transcript** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（token 逐字一致） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main` → runId `bd3034e4-786d-4646-8b02-ae10eee316db`、status=ok、token **`LANE_OK_GENGAR_0702_26 = 14`** **逐字一致**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對方自報：6 支自有 cron 全 enabled 且 ce=0（`29c2d630` watchdog ok 3,037ms→08:04、`c29eca0f` heartbeat-gengar skipped(no-route) 258ms→07:29、`ac9e7ada` English coach ok 217,611ms、`88810bfe` BBC drill ok 188,011ms、`7767e03b` skill-collection-review-gengar ok 86,815ms、`f5148ff0` 版本檢查 ok 258,726ms）；Discord 8/8 connected（greninja 停用）；3h canonical 429 = **7**（與我方量測同數）；近 6h **無任何成功 READY 紀錄**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對方僅 append 寫檔（`workspace-gengar/memory/2026-11-26.md`）、未回 session、未 announce → 符合 protocol。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🔴🔴 本窗 15 筆 600s 硬死 —— 逐筆歸因到具名佔用者 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 窗 | receipts 納入 | 600s 硬死 | skipped dur≥300s | error receipts | <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
|---|---|---|---|---|
| 04:02→07:02（本窗） | 120 | **15** | 3 | 15 | <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 01:02→07:02（3 槽） | 212 | **15** | 3 | 17 | <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 22:02→07:02 | 277 | **15** | 3 | 17 | <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 24h | 633 | 29 | 8 | 69 | <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **全部 15 筆都是 heartbeat**（picturecat 2、roaringmoon 2、greninja 2、mrmime 3、gengar 2、rowlet 2、celesteela 2）→ 與上輪 24h 的「29 筆硬死全屬 heartbeat」一致。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **佔用者對照（receipt dur ≥400s 的 ok run）**： <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `36b493db Memory Dreaming Promotion` **04:25:01→04:55:17（1815.3s）** → 吃掉 **10 筆**（04:27:53 picturecat/roaringmoon/greninja、04:33:19 mrmime/gengar、04:39:12 rowlet、04:39:46 三支、04:45:11 celesteela、04:45:48 gengar）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `ae91b967 每日 LLM Wiki 巡讀與擴寫` **05:30:00→05:55:48（1548.6s）** → 吃掉 **4 筆**（05:31:06 mrmime、05:38:21 rowlet、05:41:37 mrmime、05:42:46 celesteela）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `a72cb46b 每日 Agent × 軟體開發潮流研究` 06:10→06:21:00（660.8s）→ `heartbeat-celesteela` 06:12:45→06:21:01 **skipped dur=495.6s（排隊型，非硬死）**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **秒級對齊第 8 次實例**：`heartbeat-rowlet` 05:48:51 起跑 → 05:55:59 **ok**（dur 427.7s）＝佔用者 `ae91b967` 結束時刻 05:55:48 + 11 秒；另一支 06:38:19→06:45:35 ok 436.7s（`a72cb46b` 06:21:00 結束後）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **heartbeat 7 支（celesteela/charizard/gengar/greninja/mrmime/picturecat/roaringmoon/rowlet）payload.timeoutSeconds 全部 = None** → 一律走預設 600s 牆 → **只要落在任何 >600s 的 job 窗裡就必死**。修法：把 heartbeat timeoutSeconds 拉到 ≥2400s（> 最長佔用者 dreaming 1815s + 餘裕），或把長 job 移出會跑 heartbeat 的 agent 槽。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ 7 天直方圖：dreaming 每夜穩定殺 ~10 個 heartbeat <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 11-19 00:00 → 11-26 07:05 全掃描：`cron: job execution timed out` 共 **51 筆**，逐小時分布：11-25 04h=**10**、11-26 04h=**11**、11-25 08h=**10**、11-26 05h=4、11-25 05h/06h=2+2，其餘 07h/08h/16h/20h/21h/23h 各 1–2。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **dreaming 各夜 × 窗內硬死數**（窗＝dreaming 起訖區間）：11-19（03:00 槽、1922s ok）0、11-20（675.7s interrupted）0、11-21（1918.8s ok）0、11-22（1852.4s ok）0、11-23（1406.9s interrupted）0、11-24（1816.1s ok）**0**、11-25（1793.0s ok）**10**、11-26（1815.3s ok）**11**。 → **11-25 起是全新模式**（dreaming 本身一樣完整、dur 也一樣，但 heartbeat 開始大批死在窗內）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **根因收斂到單一機制**：`scripts/discord-selfheal.sh` 檔頭註解早就寫明 dreaming（`toolsAllow: ["*"]`、timeout 2400s）會「starve the gateway event loop」→ enabled Discord client 到不了 READY。**本輪證明同一個 event-loop 飢餓，同時讓 heartbeat 的 agent run 排不進去 → 撞 600s 牆**。兩個症狀、一個病因。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 🔴 Gateway 於 05:13:49 重啟（pid 4137629 → **784503**）／但 Discord READY 仍 0 成功 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `systemctl --user show openclaw-gateway.service` → MainPID **784503**、NRestarts **0**、ActiveState=active、ExecMainStartTimestamp **11-26 05:13:49 CST** → uptime ≈**1h53m**（上輪的「連續 4 天零重啟」指標自此重置）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **重啟來源＝`d4cd45bc discord-selfheal-after-dreaming` 的 05:13 槽**：dur **4.164s**（其餘槽 0.769–0.785s、05:43 0.769s、06:13 0.771s、06:43 0.785s）→ 這一支才是真正 arm restart 的那一次。合法性：dreaming 04:55:17 結束、已離開 script 的 `DREAMING_WINDOW_START=04:15`/`END=05:10` 保護窗 → 合法開火。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **但重啟沒有治好 READY**：24h 內 `logged in as` = **0**、3h 內 = **0** → 自 11-25 04:54:36 起 **≈26h** 無成功 READY，而 05:13:49 之後是一個全新 gateway（1h53m uptime）。→ **「重啟可修 READY」這個寫在 selfheal script 設計前提裡的假設已失效**（第 22 輪）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗 Discord：READY 失敗形狀 `gateway READY wait timed out after 15000ms` + `gateway opened but did not reach READY within 30000ms` + `channel exited`（3h user-scope 納入 **3,698 行**）；`Gateway reconnect scheduled` 持續。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 另：`sshd: Accepted publickey for amr from 192.168.50.2` 05:07:34 / 05:07:48 → 外部 peer 在 restart 前 6 分鐘進來過。**這條 peer SSH 是誰排的仍未解**，且若落在 04:25–05:05 就會腰斬 dreaming（gengar 已在自報裡提出同一疑問）。

### 5) 配額牆：canonical 429 = 7（3h）／Token Plan = 0（3h）／211（24h） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical `model-fetch.*status=429` 3h 窗（user scope，納入 **3,698 行**）= **7 筆**：**05:01:36、05:03:08、05:31:10、05:33:51、06:02:02、07:02:02、07:02:11**，provider=minimax-portal、model=MiniMax-M3。**與 gengar 獨立量到的 7 筆完全一致**（互校通過）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal `Token Plan usage limit` 3h = **0 筆**；24h = **211 筆**（仍全落在 11-25 09:00–12:09）。 → 今日是 generic 429 零星復發，**不是** Token Plan 配額牆。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 07:02:02 與 07:02:11 兩筆 429 正是本輪三支 KA 的起跑時刻（07:02:05/07:02:07）→ 三支同時撞限流。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) ⭐ 健康回報 05:05 槽：抓到「同一小時內 10 筆硬死卻報 0 failed」的鐵證（結構性漏報第 5 輪未修） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt 05:05:20 ok、dur **51,773ms**（上輪 02:05 為 33,117ms）；terminal_summary（**task_runs 仍保留 cron run 的 summary**）原文： <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  > 🛡️ 健康回報 21:06 UTC ／ Gateway: ✅ (running pid 4137629, probe ok) ／ Disk: 61% ／ **Crons: 0 failed（已修復 0）** ／ Delivery: OK ／ 「最近一小時無失敗 — 46 個 job 中 12 個有執行紀錄，狀態皆為 ok/skipped」
- 🔴 **矛盾**：它宣稱的「最近一小時」（約 04:05→05:05）內躺著 **10 筆 heartbeat 600s 硬死**（04:27:53→04:45:48 全部落在窗內）→ **它只看 job `state`，不看 receipts**。第 5 輪未修，且本輪有了可量化反例。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 另：它報的 `pid 4137629` 在 05:13:49 之後已失效（現為 784503）→ 健康回報的 gateway 指標也有滯後。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **修正上輪 ⑱ 的錯誤結論**：「task_runs 對 cron run 已不保留 terminal_summary」**不成立** —— `task_runs.terminal_summary` 欄位存在且對本 cron run 有完整內容。→ 巡檢摘要長度/內容**直接從 task_runs 取**，不必翻 session transcript（省一次 transcript 讀取）。

### 7) ✅ dreaming：連續第 3 夜完整跑完 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion` 11-26 04:25:01 → **ok、dur 1,815,253ms（30.3 分）、ce=0**；11-25 1,793,022ms、11-24 1,816,088ms 均 ok → **連續第 3 夜完整**（11-23 曾被腰斬為 interrupted 1,406.9s）。下一槽 **11-27 04:25**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal-after-dreaming`：05:13 ok 4.164s（真正重啟那一次）、05:43 ok 0.769s、06:13 ok 0.771s、06:43 ok 0.785s → **下一槽 07:13**；ce=0。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 三支 KA：anchor 疊窗第 34 次（Δ2s）／零降級連 3 槽／路由空殼第 14 輪 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本槽起跑：**07:02:05 `02eb0989` Picturecat（timeout=None）→ 07:02:07 `9d8b6001` Gengar（timeout=1800）→ 07:02:07 `880b5c17` Celesteela（timeout=1800、agentId=celesteela）**。anchorMs 1780452122531 / 1780452122570 / 1780452122603 → 差 39ms / 33ms → **第 34 次同槽疊窗**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 前兩槽 dur（receipt 為準）：01:02 槽 gengar **328s** / picturecat 149s / celesteela 151s；04:02 槽 gengar **252s** / picturecat **368s** / celesteela **174s** → **三支皆實質 → 零降級連 3 槽**（22:02 降級輪後未再復發）。本輪 07:02 以 receipt 為準。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA 路由空殼第 14 輪**：`9d8b6001`／`02eb0989` 的 agentId 仍 **None** → 兩支仍由 rowlet lane 執行、仍不回報（lastDeliveryStatus=not-requested）；`02eb0989` payload.timeoutSeconds **仍缺（第 12 輪未補）**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 紅單：2 支（無 +1）＋ 掩蓋型紅單第 3 個實例（9 支 ce=0 卻有 error receipt） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `89e2cfe7 clean-code研究`（charizard）ce=**3**、lastRunStatus=error、下一槽 **11-26 09:00** → **連續第 7 天首跑死待驗**（本輪 07:02 尚未到槽）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `c5352a84 skill-collection-review-roaringmoon` ce=**1**、lastRunStatus=error、下一槽 **11-27 03:56** → 未自癒。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `a94330a9 tmp-openai-probe` ce=2 但 enabled=false（殘留，不列紅單）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🔴 **掩蓋型紅單（ce=0 但 24h 內有 error receipt）**：heartbeat-mrmime **10**、heartbeat-rowlet **9**、`ca222989` OpenClaw 系統維護 **7**、heartbeat-celesteela 5、健康回報 4、Gengar KA 4、skill-collection-review-mrmime 4、heartbeat-gengar 4、Jormungand Codex A2A 4、heartbeat-roaringmoon 3、clean-code研究 3、Jormungand daily all-agent health 2、heartbeat-picturecat 2、heartbeat-greninja 2、heartbeat-charizard 2、Picturecat KA 1、Celesteela KA 1、每日資安建議 1、群體智能架構研究 1。 → **只看 `state.consecutiveErrors` 會漏掉 18 支**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 其他量測（附口徑） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **系統面**：load **1.13/0.78/0.63**、mem 31G 總量／available 21G、disk **61%**（175G 可用）、uptime **45 天 12:53**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **journal 行數**：3h user-scope **3,698 行**／all-scope 6,260 行；24h user-scope 13,000 行（上輪）→ 持平。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **SSH**（Accepted publickey、大小寫不敏感、all scope）：3h **49** 筆、24h **427** 筆（上輪 54／426）→ 基線未動。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **superseded**：3h **10** 筆、24h **98** 筆（上輪 106）→ 持續收斂。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **elle.service**：NRestarts **125,947**（上輪 125,229 → **+718／約 6h ≈ 120/h**，速率持平）、ActiveState=activating / SubState=start-pre；journal 提及 3h = 1,071 筆 → **需 root，維持回報不動手**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **skipped 筆數**：3h 窗 skipped 33 筆（heartbeat-roaringmoon 6、celesteela 6、picturecat 6、greninja 5、gengar 4、rowlet 4、mrmime 2），其中 dur≥300s 者 3 筆全為 `heartbeat skipped: no-route`（311.2s／337.1s／495.6s）→ **排隊型佔用，非硬死**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **日誌檔**：`gw-upgrade-guard.log` **第 19 輪仍不存在**（`find /home/amr -maxdepth 4 -name "gw-upgrade-guard*"` = 0 筆）；`dreaming-schedule-check.log` 存在但 mtime 停在 **11-19 22:33** → **停擺第 11 天**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **skill 缺 description canonical 口徑＝9/117**（本輪以 6 個 skill 根目錄 + 3 個子路徑掃描 **117 支 SKILL.md** → frontmatter 無 `description:` 鍵者 **9 支**：card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、system-design-six-dimensions-analyzer、web-fetch-troubleshooting）。**清單與上輪逐字一致 → 上輪的 9 才是對的，往輪的「17 支」口徑有誤，可停止爭議。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 給 Linder 的待決事項（更新後 15 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1.【**最高・新】】 **把 8 支 heartbeat 的 `timeoutSeconds` 從 None 拉到 ≥2400s**（> 最長佔用者 dreaming 1815s + 餘裕）。本輪實證：dreaming 窗內 10 死、LLM Wiki 窗內 4 死 → **每夜固定 ~10 筆心跳被殺，7 天累計 51 筆**。這是**單一參數**就能修好的可預測故障。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2.【**最高・沿用】】 **長 job 與 heartbeat 槽錯開**（`ae91b967` 05:30、`a72cb46b` 06:10、`b37129c0` 08:00、`911eee45` 21:00、`58fe15dc` 07:00 皆 660–1648s）→ 建議把每日長研究 job 排到 heartbeat 空檔，或把 dreaming 移出 04:25。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3.【**最高・沿用】】 **紅單判定補洞**（第 3 輪）：同一 job 可「ce=0、末筆 ok、但 24h 內有 error receipt」→ 本輪 **18 支**符合；須疊 receipts 分組計數。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4.【**最高・第 14 輪】】 **KA 路由空殼**：`9d8b6001`／`02eb0989` agentId 仍空 → 仍跑在 rowlet lane、仍不回報。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5.【**高・新】】 **「把必做清單寫進 job payload」＝可靠度工程**：降級跑會遮蔽事故窗；本輪再次實證。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6.【**高・第 22 輪】】 **Discord READY 22 輪無成功落地**，且 **05:13 重啟後仍未成功** → selfheal 的「重啟可修 READY」前提已失效（gateway 全新 1h53m、仍 0 成功）→ 建議改查 Discord token／網路層（DNS/代理），而非繼續重啟。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7.【**高・第 5 輪】】 **健康回報結構性漏報未修**，且本輪有鐵證：05:05 槽報「最近一小時無失敗」，而同一小時內有 10 筆硬死 → 必須改以 `cron_run_receipts` 為準。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8.【**高・第 12 輪】】 `02eb0989` Picturecat KA 未設 timeoutSeconds → 補 1800s。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9.【**高・第 7 天】】 `89e2cfe7 clean-code研究` 首跑死待驗（ce=3，下一槽 **今日 09:00**）；`c5352a84` ce=1 未自癒（下一槽 11-27 03:56）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10.【**中・第 9 輪】】 **MiniMax 限流牆零星復發**（3h canonical 429 = 7、Token Plan 3h = 0；跨廠 fallback 仍只有 minimax×2，`openai/gpt-5.4-mini` 仍是死路）→ 需第二廠憑證（憑證我不碰，需你提供）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11.【**中・第 34 輪】】 三支 KA anchor 仍疊（07:02 槽 Δ2s）→ 拉開 ≥15 分鐘。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12.【**中・已定案】】 **skill 缺 description canonical = 9/117**（往輪的 17 支口徑作廢）→ 需你點頭才補。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13.【**中・沿用】】 `elle.service` 啟動迴圈 ≈120 次/小時（需 root）；`gw-upgrade-guard.log` 第 19 輪不存在；`dreaming-schedule-check.log` 停擺第 11 天；**外來 peer `192.168.50.2` 於 05:07 SSH 進來、05:13 觸發 gateway 重啟 — 來源排程未解**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14.【**中・第 14 次】】 KA 探針在被探 lane 製造 superseded 競態（3h 10 筆、24h 98 筆，持續收斂）→ 維持觀察。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
15.【**低・沿用】】 健康回報 filler 連 3 輪未見；但建議在 payload 加「必須輸出 🛡️ 格式 final summary」硬約束。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本輪結案**：① **600s 牆與 Discord READY 是同一個病因**（gateway event loop 飢餓）；② **「零硬死」只在窗內為真**——上輪的乾淨窗結束 23 分鐘後就被 04:25 槽打回原形；③ **健康回報可以在自己宣稱的一小時裡漏掉 10 筆硬死**；④ **task_runs 仍留有 cron run 的 terminal_summary**（上輪結論有誤，已更正）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **本輪降級（不列紅單）**：restricted automation-run session 內 `automations list` 回空清單（作用域假象）→ 真相以 `cron_jobs`／`cron_run_receipts` 為準；`message read` 在本 session 無 delegated account。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 12) 下一輪（11-26 10:02）交辦 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① **09:00 `89e2cfe7 clean-code研究` 槽**結果（ce 是否 +1、是否第 8 天首跑死）；② **receipts 全掃描（具名窗 07:02→10:02 + 前推 3 槽）**：600s 硬死逐筆歸因到具名佔用者（今天已知佔用者：`ae91b967` 05:30、06:10 `a72cb46b`、07:00 `58fe15dc` 每日論文討論 762s、08:00 `b37129c0` 群體智能架構研究 1647s、16:00 `af94aa92` 備份）；③ **heartbeat timeoutSeconds 是否已被拉高**（未點頭則明示前提不變）＋ 下一次 dreaming（11-27 04:25）窗內是否仍死 ~10 個；④ 配額牆是否持續（canonical 429 筆數＋附納入行數、Token Plan 3h 計數）；⑤ **Discord 成功 READY 是否落地**（勿用 8/8 connected）、重啟後仍失敗要改查 token／DNS；⑥ 健康回報 08:05 槽格式＋**本輪那 10 筆硬死有沒有被它看見**；⑦ 三支 KA 10:02 槽 dur＋anchor Δ（第 35 次預期）＋ `02eb0989` timeoutSeconds、KA agentId；⑧ **外來 peer 192.168.50.2 的 SSH 來源是否查清**（journal 有無新 Accepted + 對應 restart）；⑨ SSH / elle 速率 / `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 20 輪；⑩ superseded 是否新增；⑪ 紅單（ce>0 與掩蓋型兩張表都要）；⑫ **本輪自身 dur 以 receipt 為準**；⑬ **巡檢摘要長度/內容改從 `task_runs.terminal_summary` 取**（已實測可用）；⑭ skill 缺 description 沿用 canonical 9/117。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
