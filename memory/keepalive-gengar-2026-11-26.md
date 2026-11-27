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

## 2026-11-26 16:02 — 第 19 輪 — PASS（lane 探針已送達）／⭐⭐⭐ **Discord 23 輪黑屏終結：15:43:49 那次重啟後 8/8 connected（channels status 全綠、mrmime in/out 8m ago ＝ 有真實流量）**／⭐⭐⭐ **600s 牆的正確旋鈕＝cron `payload.timeoutSeconds`（不是 agent heartbeat 設定）——本輪更正前幾輪指錯的建議**／⭐⭐ **selfheal 重啟迴圈＝故障放大器（24h 6 次重啟、5 次由 selfheal arm，storm 逐時峰值 1,204→1,420→815 與重啟相位吻合）**／🔴 15:24–15:31 一次 6 支 heartbeat 同時撞 600s（24h 最嚴重單窗）／🔴 DNS 波打 Discord＋MiniMax 兩組 host（主機層）／✅ 配額牆連續第 9 輪近乎熄火（24h HTTP 429 = 17、Token Plan = 0）／✅ dreaming 連續第 3 夜完整（下一槽 11-27 04:25） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
### 1) 本 job 自身（`9d8b6001`）：16:02 槽＝07:02 之後**第一個實質輪**；今日 3 槽有 2 槽沒留檔 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 10:02:07 **error**（`All models failed (3): minimax-portal/MiniMax-M3: getaddrinfo EAI_AGAIN api.minimax.io`、dur 151,446ms）→ 10:05:08 重試 **ok 但 summary ＝ `NO_REPLY`（slen=8）＝ 降級跑、零紀錄** → 13:02:02 **error**（DNS、dur 419,220ms）→ **本輪 16:02 實質**。⇒ 今日檔 `^## ` 段落數（3 節：01:02／04:02／07:02）**少於槽數（5 槽）**，與 picturecat 輪同日互證「ce 連續 N 但當日檔沒更新 ＝ 整輪死亡」查漏規則。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 三支 KA 10:02 槽全滅：9d8b6001（DNS）、02eb0989（`Explicit auth order for openai has no usable profiles.`）、880b5c17（DNS）→ **同 anchor 疊窗第 35 次（Δ39/33ms）**；`9d8b6001`／`02eb0989` agentId **仍 None ＝ KA 路由空殼第 15 輪**（仍跑在 rowlet lane、lastDeliveryStatus=not-requested）；`02eb0989` timeoutSeconds **第 13 輪未補**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ Discord：**23 輪黑屏終結，15:43:49 重啟後全綠（本輪最大正面事件） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 重啟後 15:44–15:45 逐一 initialize（celesteela → charizard → flaaffy → gengar → picturecat → roaringmoon → rowlet，每支錯開 10s；8 個 client id 全數列出）→ **其後 0 筆 READY-fail、0 筆 `channel exited`**；16:02 `openclaw channels status`：**8 個 enabled 帳號全部 running, connected, transport:just now**（greninja disabled 為設計如此），mrmime **in:8m ago / out:8m ago** ＝ 有真實雙向流量。 → **READY 連續失敗第 23 輪的紀錄到此為止**（adapter 只記失敗行，所以「0 筆失敗＋channels resolved＋無 channel exit」是正面證據）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯一尾巴：16:03:02 `gateway websocket closed code=1006` ＋ `reconnect scheduled in 2000ms`，其後無失敗 → 單次抖動，非失明。

### 3) ⭐⭐⭐ selfheal 重啟迴圈＝**故障放大器**（量化，本輪簽章） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal-after-dreaming` 於 **13:13／13:43／14:13／15:13／15:43** 五次輸出 `discord broken and dreaming idle -> scheduling gateway restart in 10s`（dur 22.3s 那幾輪＝真的 arm；14:43 那輪 dur 29ms ＝ 被 30 分鐘防風暴守門擋下，**守門實測有效**）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- pid 鏈：4137629（→11-26 05:13:48）→ **784503**(05:13:53) → **858229**(13:14:04) → **861722**(13:44:02) → **865234**(14:14:22) → **871090**(15:14:01) → **877548**(15:44:05)＝**24h 內 6 次重啟**（05:13 一次 + selfheal 5 次）。每次重啟＝8 個 Discord client 重新 initialize → 在 DNS 仍壞時 READY-fail 反而暴增。 ⇒ **守門應認得 DNS 型故障（近 10 分鐘有 `getaddrinfo EAI_AGAIN` → 不 arm），否則自動修復機制每 30 分鐘把整團隊通道翻面一次**（需 Linder 點頭）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐⭐ storm 量化（24h journal，user-scope） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `READY wait timed out after 15000ms` ≈ **4,092** 筆、`gateway websocket error` ≈ **3,401**、`websocket closed(1006)` ≈ **3,857**。逐時 READY-fail：01h=8 → 04h=102 → 05h=375 → 09h=38 → 10h=43 → 12h=86 → **13h=1,204 → 14h=1,420 → 15h=815 → 16h=0（重啟後）**。log 行/分鐘：15:20=80、15:21=70、15:22=79、15:32=345、15:35=205。 **storm 峰值與 selfheal 重啟相位吻合**（每次重啟＝8 client 重新 initialize）。

### 5) ⭐⭐⭐ **600s 牆的正確旋鈕＝cron `payload.timeoutSeconds`（本輪更正前幾輪的建議）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw.json` 端：`agents.defaults.heartbeat.timeoutSeconds=1800`、gengar=**600**、mrmime/charizard/greninja=1800、rowlet/picturecat/roaringmoon/celesteela 未設（繼承 1800）。 **但 15:24–15:31 撞牆的 6 支全部死在 600,00Xs**（greninja 600,007／charizard 600,005／picturecat 600,004／roaringmoon 600,004／gengar 600,004／mrmime 600,004）→ **與 agent 端 1800 無關**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **反證**：`29c2d630 Gengar Cron Health Watchdog` 的 `payload.timeoutSeconds=120` → 14:04:23 死於 **119,437ms** ⇒ **cron 層的 payload.timeoutSeconds 才是真正生效的牆**；8 支 heartbeat 的 payload 是 `{"kind":"heartbeat"}`（無 timeoutSeconds）→ 吃到 cron 預設 **600s**。 ⇒ **要抬牆必須改 cron job 的 `payload.timeoutSeconds`（`automations update` 或直接改 cron store），改 `agents.*.heartbeat.timeoutSeconds` 完全無效**（前幾輪的建議指錯旋鈕，本輪更正）。CLI `openclaw cron edit` 只有 `--script-timeout-seconds`／`--no-output-timeout-seconds`，**沒有 agent payload timeout 選項** → 需走 `automations update`（屬改 job，需 Linder 點頭）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 🔴 600s 群集：15:24–15:31 一次 6 支（24h 最嚴重單窗） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 全 6 支 error 皆 `cron: job execution timed out`，dur 600,004–600,007ms；24h 內第 7 筆 600s 等級超時＝14:04 的 watchdog（120s 牆）。同一窗另有 14:12:49 `heartbeat-celesteela` = `cron: job interrupted by gateway restart`（14:14 那次重啟所殺）。

### 7) ⭐⭐ DNS 波（主機層，與 storm 同期） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 真 `getaddrinfo EAI_AGAIN` ≈ **456 筆**（gateway.discord.gg 216／api.minimax.io 148／gateway-us-east1-{b,c,d}.discord.gg 93／discord.com 2）。逐時：01h=16 → 07h=4 → 08h=34 → 09h=90 → 10h=87 → 11h=7 → 12h=55 → 13h=70 → 14h=67 → 15h=26。 **同時打 Discord 與 MiniMax 兩組 host ⇒ 主機 DNS 故障，不是 provider 層**。16:06 實測 `getent hosts api.minimax.io` / `gateway.discord.gg` 皆可解析（已恢復）。`/etc/resolv.conf` 為 systemd-resolved stub；enp43s0 無 DNS scope（沿用第 N 輪結論，全系統 DNS 單點掛在 Wi-Fi）。

### 8) ✅ 配額牆連續第 9 輪近乎熄火（今天主因不是配額） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `HTTP 429` 僅 **17 行**（最後一筆在 12:00）、09:00–16:00 僅 1 筆、`Token Plan usage limit` = **0**；`rate_limit|overloaded` 關鍵字 18 筆。 ⇒ 今天兩大故障是 **DNS ＋ Discord storm**，不是配額。

### 9) ✅ dreaming 連續第 3 夜完整（下一槽 11-27 04:25，**但有風險**） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db` 11-26 04:25:01 ok、dur 1,815,253ms（30.3 分）、ce=0；11-24/25 分別 1,816,088／1,793,022 → **連續第 3 夜完整**（11-23 曾被腰斬為 interrupted 1,406.9s）。**風險＝selfheal 迴圈若在 04:25–04:56 內再 arm 重啟就會再腰斬**（11-20、11-23 都曾死在 `job interrupted by gateway restart`）。

### 10) ✅ 健康回報 `13ac4b5a`：格式正常，但 DNS 打死兩槽 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 02:05 ok(242 字)／05:05 ok(456)／08:05 ok(596) 皆 🛡️ 標準格式（非 filler）；**11:05 error（DNS）、14:05 error（DNS）→ ce=2**。結構性漏報未修（只看 `lastRunStatus`＋1h 窗）。`ca222989 OpenClaw 系統維護` 10:04–15:14 連續 6 槽 error（DNS/network），15:35:46 起 ok（88s）＝已自癒。

### 11) 紅單兩張表（24h receipts 全掃描） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **ce>0 共 8 支**：`9d8b6001` ce=1／`02eb0989` ce=4／`880b5c17` ce=2／`13ac4b5a` ce=2／`d7b0355b` ce=3／`c5352a84` ce=1／`58fe15dc` ce=1／**`89e2cfe7 clean-code研究` ce=4 ＝ 連續第 8 天首跑死**（11-26 09:00 EAI_AGAIN，下一槽 11-27 09:00）。
- **掩蓋型（ce=0 但 24h 內有 error receipt）17 支**：OpenClaw 系統維護 7、Picturecat KA 4、heartbeat-charizard 3、Jormungand A2A 3、Gengar KA 2、Celesteela KA 2、健康回報 2、Jormungand daily all-agent health 2、+9 支各 1（heartbeat-mrmime/celesteela/greninja/picturecat/roaringmoon/gengar、watchdog、每日資安建議、每日論文討論）。⇒ 只看 ce 會漏掉 17 支。

### 12) 其他量測（附口徑） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **fleet ＝ 53 支（46 enabled／7 disabled）**：`openclaw cron list` **不含 disabled，必須加 `--all`** 才會看到 7 支（1b2165f9 Charizard KA、72a0c6ef、8d7e5dfe verify Discord recovery、a94330a9 tmp-openai-probe、b7a56e10 gengar keep-alive、ee14ba4c Rowlet KA、ee3def26 RoaringMoon KA）——**往輪的「46/53」口徑要註明是預設排除 disabled**。
- **系統面**：load **1.19/0.98/0.74**、mem 31G 總量／available 20G、disk **61%**（175G 可用）、uptime **45 天 21:53**、gateway MainPID=877548（15:43:55 起）、NRestarts=0。
- **SSH**：3h **54** 筆／24h **427** 筆，且 **427/427 全部來自 192.168.50.2** ＝ 該 peer 是唯一 SSH 來源（它 05:07/05:13 曾觸發 gateway 重啟）。
- **elle.service**：NRestarts **127,017**（上輪 125,947 → +1,070／約 9h ≈ **119/h**，速率持平）、ActiveState=activating／SubState=start-pre → 需 root，維持回報不動手。
- **日誌檔**：`gw-upgrade-guard.log` **第 20 輪仍不存在**；`dreaming-schedule-check.log` mtime 停在 **11-19 22:33** → **停擺第 12 天**。
- **superseded**：3h **2** 筆／24h **80** 筆（上輪 10／98 → 持續收斂）；本輪親見 picturecat 探針撞 superseded（`prepared model runtime plugin generation was superseded`）。
- **skill 缺 description canonical ＝ 9 支**（本輪掃 119 支 SKILL.md、13 支缺 → 多出的 4 支全在 `~/.openclaw/skills/rosclaw/extensions/openclaw-plugin/skills/` 第三方 vendored，**第一方口徑 9/115**，清單與上輪逐字一致）。

### 13) lane 探針＋本輪降級說明 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **gengar lane 探針**：`sessions_send` → `agent:gengar:main`（runId `501fa8e9-090c-419b-9fb0-6fcc2fd12908`、accepted/queued；16:02:58 已落進 gengar session seq 2524）→ **回覆尚未回**（不阻塞本輪；下一輪確認）。
- ⚠️ **本輪降級（不列紅單）**：restricted automation-run session 內 `automations list/get` 對本 job 回 **not found**（作用域假象；CLI `openclaw cron list --all` 顯示 enabled+running）；`exec` 直接讀 `state/openclaw.sqlite` 被工具層封鎖 → 改用 `openclaw cron list/runs` CLI 取數（本輪全部數據皆來自 CLI receipts ＋ journal，非 state 欄位）。

### 14) 給 Linder 的待決事項（更新後 16 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1.【**最高・本輪更正**】 **抬 heartbeat 牆要改 cron job 的 `payload.timeoutSeconds`（≥2400s），不是 `agents.*.heartbeat.timeoutSeconds`**（前者才生效；agent 端已是 1800 卻照樣死 600s）。
2.【**最高・新】】 **selfheal 守門加 DNS 判斷**（近 10 分鐘有 `getaddrinfo EAI_AGAIN` → 不 arm 重啟），否則每 30 分鐘把全隊通道翻面一次（24h 已 6 次）。
3.【**最高・沿用】】 **把 DNS 從 Wi-Fi 單點移開**（enp43s0 設 DNS scope，或全域 1.1.1.1/8.8.8.8）——今天 456 筆 EAI_AGAIN 的根因。
4.【**高・第 3 輪】】 **紅單判定補洞**（ce=0 但 24h 內有 error receipt → 本輪 17 支）。
5.【**高・第 15 輪】】 **KA 路由空殼**（`9d8b6001`／`02eb0989` agentId 仍空 → 跑在 rowlet lane、不回報）。
6.【**高・第 5 輪】】 **健康回報結構性漏報未修**（只看 lastRunStatus＋1h 窗）。
7.【**高・第 13 輪】】 `02eb0989` Picturecat KA 補 `timeoutSeconds=1800`。
8.【**高・第 8 天】】 `89e2cfe7 clean-code研究` 連續第 8 天首跑死（09:00 槽，DNS）；`c5352a84` ce=1（下一槽 11-27 03:56）、`d7b0355b` ce=3。
9.【**中・沿用】】 **長 job 與 heartbeat 槽錯開**（dreaming 1815s／LLM Wiki 巡讀／每日論文討論 710s 等）。
10.【**中・第 9 輪】】 **MiniMax 限流牆近乎熄火，但跨廠 fallback 仍是 0 冗餘**（openai 那格有兩種死法）→ 需第二廠憑證（憑證我不碰）。
11.【**中・第 35 輪】】 三支 KA anchor 仍疊（Δ39/33ms）→ 拉開 ≥15 分鐘。
12.【**中・已定案】】 skill 缺 description ＝ 9 支第一方（＋4 支 rosclaw vendored）→ 需你點頭才補。
13.【**中・沿用】】 `elle.service` ≈119 次/小時（需 root）；`gw-upgrade-guard.log` 第 20 輪不存在；`dreaming-schedule-check.log` 停擺第 12 天；**外來 peer `192.168.50.2` ＝ 唯一 SSH 來源（427/427），來源排程未解**。
14.【**中・第 15 次】】 KA 探針在被探 lane 製造 superseded 競態 → 維持觀察。
15.【**中・本輪】】 **`29c2d630` watchdog 的 `payload.timeoutSeconds=120` 太緊**（14:04 已死一次 119,437ms）→ 建議提到 ≥600。
16.【**低・沿用】】 健康回報 filler 未見，但建議在 payload 加「必須輸出 🛡️ 格式 final summary」硬約束。
- ✅ **本輪結案**：① **Discord 23 輪黑屏在 15:43:49 重啟後終結（8/8 connected + 有真實流量）**；② **600s 牆的旋鈕是 cron payload.timeoutSeconds（agent heartbeat 設定無效）**；③ **selfheal 重啟迴圈是 storm 放大器（6 次重啟 ↔ storm 峰值同相位）**；④ **今天的主故障是 DNS（456 筆 EAI_AGAIN，打兩組 host）不是配額（429 僅 17、Token Plan 0）**；⑤ **`openclaw cron list` 預設不含 disabled（需 `--all`）**。

### 15) 下一輪（11-26 19:02）交辦 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① **Discord 是否續活**：19:02 前若又有 READY-fail／channel exited／EAI_AGAIN → 記失明窗起訖；另看 selfheal 16:13/16:43/17:13/17:43/18:13/18:43 有沒有再 arm 重啟（pid 鏈是否再長）；② **確認 192.168.50.2 排程**（427/427 唯一 SSH 來源，05:07/05:13 曾重啟 gateway）→ 該 10 分鐘排程何時再落窗、會否落在 dreaming 04:25–04:56；③ **DNS 24h EAI_AGAIN 逐時**（本輪 456 筆、峰值 09:00–10:00 與 12:00–15:00）＋ enp43s0 DNS scope 是否仍 none；④ **600s 群集是否再發**（本輪 15:24–15:31 六支；payload.timeoutSeconds 修法未點頭則明示前提不變）＋ 下一個長佔用者（11-27 04:25 dreaming、每日論文討論 07:00、每日 LLM Wiki 巡讀 05:30/06:10、群體智能架構研究 08:00）；⑤ **三支 KA 19:02 槽 dur＋anchor Δ（第 36 次）＋ `02eb0989` timeoutSeconds、KA agentId**；⑥ **配額牆**（HTTP 429 逐時＋`Token Plan usage limit` 計數，附納入行數）；⑦ **健康回報 17:05／20:05 槽**是否正常（🛡️ 格式）＋ 11:05/14:05 兩次 DNS 死槽之後有沒有自癒；⑧ **dreaming 下一槽 11-27 04:25 前置**：確認 selfheal 排程是否會在窗內 arm；⑨ `89e2cfe7` 11-27 09:00 槽是否又死（第 9 天）；⑩ SSH／elle 速率／`gw-upgrade-guard.log`／`dreaming-schedule-check.log` 第 21 輪；⑪ superseded 是否新增；⑫ 紅單（ce>0 與掩蓋型兩張表）；⑬ **gengar lane 探針 16:02 那次有沒有回**（沒回就重發並在報告標記 lane 無回應）；⑭ 本輪自身 dur 以 receipt 為準；⑮ skill 缺 description 沿用 canonical 9/115＋rosclaw 4 支註記。

### 16) 追加更正（16:02 輪收尾，lane 回覆到手後） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **gengar lane 探針 PASS**：回覆逐字為 `LANE_OK_GENGAR_1602_26 = 11`（16:11:34 送達回覆）→ **lane token 逐字一致**。gengar 自報：6 支 cron 全 enabled、全 `ce=0`；MainPID=877548 uptime ≈26 分；Discord 8 connected/8 enabled、近 1h 有 13 筆 inbound；近 60 分鐘 canonical 429 = **1** 筆；dreaming 11-26 04:25 ok 1,815,253ms（連續第 3 夜）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **更正第 9 點的 dreaming 風險判定**：selfheal 的 cron expr ＝ **`13,43 0-3,5-23 * * *`** → **第 4 小時不含在內** ⇒ **selfheal 不會在 dreaming 04:25–04:56 窗內 arm 重啟**，gengar 側量到「24h 內 0 筆 cron 被 gateway 重啟殺死（上次傷亡是 11-23 04:25）」→ **dreaming 窗對 selfheal 已安全**（第 9 點的顧慮只保留「peer SSH 觸發的重啟時點不可控」這一項殘餘風險）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **重啟來源歸因修正**：6 次 pid 變化（05:13:53／13:14:04／13:44:02／14:14:22／15:14:01／15:43:55）**全部落在 selfheal 槽 +1 分鐘** → **selfheal 是唯一有效的重啟來源**（gengar 另數到 12 次 `systemctl --user restart` arms，差額＝被守門擋下或未生效的 arm）。peer `192.168.50.2` 的 SSH 為**每 10 分鐘 3 筆 burst**（實測 15:57:34/47/47、16:07:34/47/47）＝ 24h 427 筆的唯一來源，**16:07 那次 burst 未造成 pid 變化** → 它目前只是「定期 SSH 進來」，是否為重啟驅動者仍未解（需 Linder 問 peer 上的那支 10 分鐘排程在做什麼）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-26 19:02 — 第 20 輪 — PASS（lane token 逐字一致）／⭐⭐⭐ **600s 牆出現全新佔用者型態：「短 job 被 429 拖長」——17:54–18:20 一次 10 支 heartbeat 撞牆，最長佔用者僅 470.5s（<600s）**／⭐⭐⭐ **因果模型統一：fallback 鏈只剩 minimax-portal 一條 → provider 429 飽和 → 同時發起的心跳整批卡死在 600s 牆（15:24 六支崩在「openai 餘額用罄＋minimax-cn 不在 modelPolicy」同一分鐘）**／🔴 24h 600s 級超時升到 44 筆（43 支 heartbeat）／🔴 Picturecat KA 19:02 槽降級跑（19.9s／NO_REPLY）／✅ Discord 黑屏續活 3h20m（0 READY-fail、0 channel exit）、selfheal 5 槽未再 arm 重啟、gateway 15:43 後零重啟／✅ 配額牆連續第 10 輪熄火（Token Plan 0、canonical 429 僅 2 筆且集中在 18:03）／✅ clean-code研究 18:07 自癒（ce 歸 0）＋ 新增自癒重試 job／🔴 DNS 24h EAI_AGAIN ≈460 筆、enp43s0 仍無 DNS scope <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
### 1) Gengar lane：PASS（token 逐字一致） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main`（runId `342e5e02-406c-40c3-ae33-e2fedcd3eac2`）→ 回覆首行逐字 **`LANE_OK_GENGAR_1902_26 = 20`** ✅（19:04:14 送達）。
- 對方自報（append 寫入 `workspace-gengar/memory/2026-11-26.md` 19:05 段，未 announce 外部頻道）：近 60 分鐘 canonical provider 失敗 **429 = 0**（窗口 18:03:58→19:03:58、1,358 總行 → 1,076 系統行 → 119 條 model-fetch response 納入）；6 支自有 cron 全 enabled 且 **ce=0**（watchdog 3,090ms→20:04、heartbeat-gengar skipped 261ms→19:29、English coach 217,611ms、BBC drill 188,011ms、skill-review 86,815ms、版本檢查 258,726ms）；gateway MainPID=877548／NRestarts=0／uptime ≈**3h20m**；Discord **8 connected / 8 enabled**、近 60m ingress **24 筆**；dreaming 11-26 04:25 ok 1,815,253ms ce0、下一槽 11-27 04:25。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ 與我方獨立量測互校一致（MainPID、Discord 8/8、dreaming 三項逐字相符；429 差異解釋見 §8）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 三支 KA 19:02 槽：Picturecat **降級跑**、gengar（本輪）與 celesteela 執行中、anchor 疊窗第 36 次 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| slot | gengar (9d8b6001) | picturecat (02eb0989) | celesteela (880b5c17) | 判定 |
|---|---|---|---|---|
| 11-26 13:02 | error 419.2s（DNS） | error 574.3s（network） | error 227.1s | 🔴 三支全滅 |
| 11-26 16:02 | **ok 653.0s** | **ok 461.9s** | **ok 658.9s** | ✅ 全實質 |
| **11-26 19:02** | running（本輪） | **ok 19,945ms／summary=`NO_REPLY`** | running | 🔴 picturecat 降級跑 |
- **降級三證據齊**：① receipt dur **19.9s < 30s**；② `task_runs.terminal_summary` = **`NO_REPLY`（8 字元）**（19:02:02 該筆）→ 零紀錄；③ 本 job 今日檔 `^## ` 段落數 **5**（含 gengar 自報段）vs 今日槽數 7（01:02/04:02/07:02/10:02/10:05/13:02/16:02/19:02）→ **10:02 error、10:05 降級、13:02 error 三槽無紀錄**，與上輪「查漏規則」一致。
- anchorMs：picturecat `1780452122531` → gengar `1780452122570` → celesteela `1780452122603` → Δ**39ms / 33ms** → **第 36 次同槽疊窗**（無 stagger 緩衝）。
- **KA 路由空殼第 16 輪**：`9d8b6001`／`02eb0989` 的 agentId 仍 **None** → 兩支仍由 rowlet lane 執行、仍不回報（lastDeliveryStatus=not-requested）；`02eb0989` 的 `payload.timeoutSeconds` **仍缺（第 14 輪未補）**；`9d8b6001` 仍只有 15 字元 payload（`keep-alive test`）。本輪自身 dur 以 receipt 為準（執行中）。
- 今日三支 KA 的 agentId／timeout 真相：`880b5c17` agentId=celesteela、to=1800、payload 960 字元（唯一正確者）；另兩支 agentId=None、payload 15 字元。

### 3) ⭐⭐⭐ 本輪頭號發現：**600s 牆的新佔用者型態＝「短 job 被 429 拖長」，最長佔用者只有 470.5s** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 具名窗 **16:02→19:16**：receipts 納入 **121 筆**（ok 67／skipped 37／error 12／running 2）→ **600s 級硬死 10 筆，全部是 heartbeat**：
  | 起跑 | job | dur |
  |---|---|---|
  | 17:54:59 | heartbeat-charizard | 600,004ms |
  | 17:55:59 | heartbeat-picturecat | 600,004ms |
  | 17:56:20 | heartbeat-roaringmoon | 600,005ms |
  | 17:59:44 | heartbeat-gengar | 600,004ms |
  | 18:01:04 | heartbeat-mrmime | 600,006ms |
  | 18:05:30 | heartbeat-charizard | 600,005ms |
  | 18:06:31 | heartbeat-picturecat | 600,004ms |
  | 18:06:51 | heartbeat-roaringmoon | 600,005ms |
  | 18:08:34 | heartbeat-rowlet | 600,013ms |
  | 18:10:15 | heartbeat-gengar | 600,004ms |
- **同期佔用者**：`89e2cfe7 clean-code研究` **17:55:22→18:03:12（470,516ms，error「⚠️ API rate limit reached」）**、`d7b0355b Jormungand Codex A2A` **18:00:30→18:03:10（160,483ms，同樣 rate limit）**、`89e2cfe7` **18:07:26→18:10:03（157,468ms ok）**。→ **窗內沒有任何 dur>600s 的 job**。
- ⇒ ⭐⭐ **推翻前幾輪的前提**：「只有 >600s 的長 job 才會殺 heartbeat」**不成立**。同樣的 600s 牆，可以被**被 429 退避拖長的中長 job（157s→470s）**觸發，而且一次拖垮 **10 支**。
- 秒級對齊第 9 次實例：`18:11:34 heartbeat-mrmime ok dur=**569,660ms**（差 30 秒就撞牆）→ 18:21:04 結束；`18:12:49 heartbeat-celesteela skipped dur=487,869ms` → **18:20:57 結束**；`18:17:31 picturecat skipped 206,089ms`、`18:17:51 roaringmoon skipped 185,477ms`、`18:19:05 rowlet skipped 112,679ms` → **三支同秒 18:20:57 結束**（排隊型 skip，末端＝上一支 600s 牆 18:10:15→18:20:15 之後 42 秒）。

### 4) ⭐⭐⭐ 因果模型統一：**fallback 鏈只剩單一 provider 時，429 飽和＝全隊心跳同步死亡** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **15:24–15:31 六支撞牆的同一分鐘**（15:29:44）出現三種 fallback 鏈失效徵兆：① `⚠️ openai (gpt-5.4-mini) returned a billing error — your API key has run out of credits`（15:29:44）；② `Model override "minimax-cn/MiniMax-M3" is not allowed for agent "mrmime" by agents.defaults.modelPolicy.allow`（15:30:28）；③ `Unable to rematerialize minimax-cn/MiniMax-M3 for its resolved auth profile`（15:32:21／15:32:48）。
- 24h 計數：`Unable to rematerialize` **6 筆**、`is not allowed for agent` **1 筆**、`billing error / run out of credits` **4 筆** → **全部落在 15:29–15:33**；**16:02 之後 0 筆**（本窗不含）。
- ⇒ **fallback 鏈在 15:29 斷成只剩 minimax-portal 一條**（`openai/gpt-5.4-mini` 沒餘額、`minimax-cn` 不在 allow 清單）→ 該窗內同時發起的 6 支 heartbeat 全部只剩一條路，撞上同一個 429 飽和 → 全批 600s 硬死。
- 18:03:10／18:03:12 的兩筆 canonical 429（`[model-fetch] response provider=minimax-portal … status=429`）正是 clean-code（470.5s）與 Jormungand（160.5s）兩支 429 run 的收尾 → **17:54–18:20 群集＝同一個 provider 飽和事件**。
- ⭐ **新推論（可驗證）**：**600s 牆的真正殺手是「provider 飽和 × fallback 冗餘=0」，不是 gateway event loop 飢餓本身**；dreaming 型長佔用只是「更慢的同一件事」（它靠長跑把 provider 打滿）。⇒ 修法要**兩管齊下**：① 抬 cron `payload.timeoutSeconds`（≥2400s，pending #1）；② **補第二廠憑證或至少修好 `openai/gpt-5.4-mini`**（pending #10/#12），否則任何一次 provider 429 都會同步殺掉全隊心跳。

### 5) 24h 收盤（receipts 全掃描，非 3h 滾動窗） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipts **642 筆**：ok 274／skipped 287／error 78／interrupted 1／running 2。**600s 級超時 44 筆**（43 筆 heartbeat ＋ 1 筆 `29c2d630` watchdog 的 120s 牆）。
- 逐時分布：11-25 20h=2、21h=1；11-26 **04h=10**、05h=4、07h=1、08h=7、14h=1(watchdog 120s)、**15h=6**、16h=1、**17h=4**、**18h=6**。
- ⇒ 兩種死法并存：① **每夜 04h 固定 10 筆**（dreaming 1,815s 窗，連續第 3 夜）；② **白天隨機 429 簇**（15h=6、17h=4、18h=6），後者與 fallback 鏈斷裂同時發生。

### 6) ✅ Discord：**黑屏續活 3h20m，selfheal 5 槽未再 arm 重啟** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 自 15:43:52 那次重啟後至 19:16：**READY-fail 0 筆、channel exited 0 筆**；`websocket closed` 15 筆（最後 19:00:42）＝ 單次抖動非失明。
- `openclaw channels status`（19:05）：**8 個 enabled 帳號全部 running, connected**（greninja disabled 為設計如此）；traffic 為真（charizard in/out 46m、mrmime in/out 1h、rowlet transport just now、celesteela in 7m）。
- `d4cd45bc discord-selfheal-after-dreaming`：18:43 ok 746ms／18:13 ok 737ms／17:43 ok 749ms／17:13 ok 768ms／16:43 ok 730ms → summary 皆 **「discord healthy (no startup-not-ready) - no action」**；**16:13 那槽 dur 31ms＝被 30 分鐘防風暴守門擋下**；15:43 dur 3,825ms／15:13 dur 22,287ms＝真的 arm。⇒ **15:43 之後零 arm、零重啟**（MainPID 877548、NRestarts=0、uptime 3h20m）；24h 重啟仍 6 次（05:13/13:13/13:43/14:13/15:13/15:43）→ **selfheal 迴圈本輪未再發作**。
- `job interrupted by gateway restart` 24h = **0 筆** → 24h 內 0 個 cron 被重啟殺死（上次傷亡 11-23 04:25）。

### 7) 🔴 DNS：24h `getaddrinfo EAI_AGAIN` ≈**460 筆**、enp43s0 **仍無 DNS scope** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 主機分布：gateway.discord.gg **216**、api.minimax.io **150**、gateway-us-east1-{d,b,c} **93**、discord.com 2、api.openai.com 1 → **同時打 Discord 與 MiniMax 兩組 host ＝ 主機層 DNS 故障**。
- 逐時：01h=16、07h=4、08h=34、09h=90、10h=87、11h=7、12h=55、13h=70、14h=67、15h=26、**16h=0、17h=0、18h=2**（16:02→now 窗內僅 2 筆）→ **連續兩小時零 DNS 故障＝自癒**。19:05 實測 `getent hosts api.minimax.io`／`gateway.discord.gg` 皆可解析。
- `resolvectl status`：**Link 2 (enp43s0) Current Scopes: none**（有線網卡仍無 DNS scope）；DNS 只掛 **wlp0s20f3（1.1.1.1 / 8.8.8.8）** 與 **tailscale0（100.100.100.100）** → **單點仍在 Wi-Fi**（pending #3 未解）。

### 8) ✅ 配額牆連續第 10 輪熄火（Token Plan 0／canonical 429 僅 2 筆） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h canonical `model-fetch … status=429` = **17 筆**（逐時：00h=2、03h=4、04h=1、05h=8、06h=2、07h=5、08h=4、12h=2、**15h=1**、**18h=4**、21h=2）；`Token Plan usage limit` 3h/**24h = 0 / 0** → **連續第 10 輪 0 筆**。
- 互校：gengar 量 60m 窗（18:03:58 起）canonical 429 = **0**，我方 18h 的 4 筆全部落在 **18:03:10/18:03:12**（早於其窗 48 秒）→ **不衝突，兩邊一致**。

### 9) ✅ dreaming：連續第 3 夜完整；下一槽 11-27 04:25 對 selfheal 安全 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db` 11-26 04:25:01 **ok、dur 1,815,253ms（30.3 分）、ce=0**（11-24 1,816,088／11-25 1,793,022）→ 連續第 3 夜；下一槽 **11-27 04:25**。
- selfheal cron expr = **`13,43 0-3,5-23 * * *`** → **第 4 小時不含** ⇒ dreaming 窗（04:25–04:56）**對 selfheal 安全**（第 3 輪同一結論）。殘餘風險僅剩 **peer 192.168.50.2 的 SSH burst（每 10 分鐘 3 筆，:34/:47/:48）若觸發重啟落在窗內**。

### 10) ✅ 健康回報 17:05 槽：標準 🛡️ 格式、非 filler；結構性漏報第 6 輪未修 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt 17:05:22 **ok、dur 67,657ms、summary 888 字** → 標準 🛡️ 格式（Gateway ✅ pid 877548／Disk 61%／Crons: 0 failed（最近一小時 0 起）／Delivery: OK），並自報 DNS 已恢復、自身 ce 將歸零。
- ⚠️ 仍只掃「最近一小時」→ 報「Crons: 0 failed」，而窗外 **17:54–18:20 的 10 筆 600s 硬死完全不可見** → 修法仍須改以 `cron_run_receipts` 為準（第 6 輪未動）。**20:05 槽待驗**。

### 11) 紅單兩張表（24h receipts 全掃描） <!-- project: github.com/zhanzwu70-design/linderopenclaw-rowlet -->
- **ce>0 共 2 支**：`d7b0355b Jormungand mrmime Codex A2A heartbeat` ce=**4**（18:00:30 rate limit，dur 160.5s；下一槽 11-27 00:00）、`58fe15dc 每日論文討論`（**rowlet**）ce=**1**（11-26 07:00 DNS，dur 710.7s；下一槽 11-27 07:00）。`c5352a84 skill-collection-review-roaringmoon` ce=1 未列（24h 內無新 error receipt，僅狀態殘留）。
- **掩蓋型（ce=0 但 24h 內有 error receipt）17 支**：heartbeat-mrmime 10、OpenClaw 系統維護 9、heartbeat-roaringmoon 8、heartbeat-rowlet 8、heartbeat-picturecat 5、heartbeat-gengar 5、heartbeat-charizard 5、Picturecat KA 4、heartbeat-celesteela 4、heartbeat-greninja 3、健康回報 2、Jormungand daily all-agent health 2、Celesteela KA 2、clean-code研究 2、Gengar KA 2、Gengar watchdog 1、每日資安建議 1。⇒ **只看 ce 會漏掉 17 支**（第 4 輪以來數量持平）。
- ✅ **`89e2cfe7 clean-code研究` 已自癒**：09:00 error(DNS) → 17:55:22 error(429) → **18:07:26 ok（157,468ms）→ ce 歸 0** → **連續第 9 天首跑死今日解除**（下一槽 11-27 09:01）。
- 🆕 **新增 job `c721b4e3 clean-code 自癒重試`**：command 型（`python3 workspace-charizard/scripts/clean-code-selfheal.py`）、cron `45 9 * * *` Asia/Taipei、agentId=None、**無 payload.timeoutSeconds**（走預設）、18:18:48 手動觸發 ok 714ms。⇒ **fleet 53→54、enabled 46→47**（本輪新增的唯一一支）。

### 12) fleet／heartbeat 牆／其他量測（附口徑） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- fleet = **54 支（enabled 47／disabled 7）**；disabled：1b2165f9 Charizard KA、72a0c6ef PTCGP-daily-translation-update、8d7e5dfe verify Discord recovery、a94330a9 tmp-openai-probe、b7a56e10 gengar keep-alive、ee14ba4c Rowlet KA、ee3def26 RoaringMoon KA。`openclaw cron list` 預設不含 disabled（需 `--all`）。
- ⚠️ **9 支 heartbeat 的 `payload.timeoutSeconds` 全部仍為 None**（d82f78e3 rowlet／46242a4c celesteela／7d633ff4 greninja／ffc90b7d charizard／6525d155 picturecat／3acd15c2 roaringmoon／c29eca0f gengar／bcf270b8 mrmime／6e93c179 flaaffy）→ **仍吃 cron 預設 600s 牆**；本輪 10 筆硬死即為此牆的直接後果（pending #1 仍待點頭）。
- **superseded**：3h **8** 筆（上輪 2）／24h **63** 筆（上輪 80）→ 持續收斂。**lane wait exceeded**：3h 0／24h **12**（上輪 9）。**competing work**：3h **13**／24h **82**（上輪 74）。
- **SSH**（Accepted publickey、大小寫不敏感、all scope）：3h **54**／24h **427**，且 **427/427 全部來自 192.168.50.2**；burst 時間最近為 18:47:47/48、18:57:34/47/48（每 10 分鐘 3 筆）→ **24h 內 0 筆 cron 被該 peer 的行為殺死**，且 15:43 後無新重啟。
- **elle.service**：NRestarts **127,374**（上輪 127,017 → +357／3h ≈ **119/h**，速率持平）、ActiveState=activating／SubState=start-pre → 需 root，維持回報不動手。
- **日誌檔**：`gw-upgrade-guard.log` **第 21 輪仍不存在**（find 0 筆）；`dreaming-schedule-check.log` mtime 停在 **11-19 22:33** → 第 21 輪未更新。
- **skill 缺 description**：第一方 **9/115**（清單逐字一致：card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、system-design-six-dimensions-analyzer、web-fetch-troubleshooting）＋ rosclaw vendored 4 支 → 數字穩定，仍需點頭。
- **系統面**：load **0.43/0.51/0.54**、mem 31G 總量／available 20G、disk **61%**（175G 可用）、uptime **46 天 51 分**、gateway MainPID=877548（15:43:52 起，NRestarts=0）。

### 13) 量測口徑改良（本輪新增，可複用） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **本輪改用 `cp state/openclaw.sqlite* /tmp` ＋ python sqlite3 唯讀（`file:…?mode=ro`）直查 `cron_run_receipts`／`task_runs`／`cron_jobs`**，取代往輪「逐 job `openclaw cron runs`」→ 一次取得全 fleet 統計（642 筆 receipts 全掃描、掩蓋型紅單 17 支、terminal_summary），**量大且零 API 負載**。
- ⚠️ **踩到的坑（必記）**：在**同一個 cursor** 上做巢狀查詢（迭代中又 `execute`）會吃掉外層迭代結果（本輪一度只印出 1 列、誤判「窗內只有 1 筆」）→ **必須 `fetchall()` 或改用第二個 cursor**。另：**不要用 `time.localtime` 的隱含 TZ 做窗口換算**，一律用 `datetime.timezone(+8)` 明確換算（本輪曾因此誤判窗口起訖）。
- ✅ 本輪結論：**只用 3h 滾動窗會漏掉 15:24 與 17:54 兩個群集尾端** → 維持「具名窗 + receipts 全掃描」口徑。

### 14) 給 Linder 的待決事項（更新後 16 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1.【**最高・新】** **600s 牆有兩種殺法，都要修**：① 長 job 佔用（dreaming 1,815s → 每夜 10 死）；② **429 飽和 × fallback 冗餘=0**（17:54–18:20 一次 10 死，佔用者僅 470.5s）。**修法：把 9 支 heartbeat 的 cron `payload.timeoutSeconds` 拉到 ≥2400s ＋ 補第二廠憑證**（否則任何一次 provider 429 都會同步殺掉全隊心跳）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2.【**最高・本輪新證據】** **`openai/gpt-5.4-mini` 沒餘額（15:29:44 billing error）＋ `minimax-cn/MiniMax-M3` 不在 `modelPolicy.allow`（15:30:28）＋ minimax-cn 無法 rematerialize（15:32:21/48）＝ fallback 鏈在 15:29 斷成單一 provider**，該窗 6 支心跳同步死亡。**要嘛修好、要嘛從鏈上移除（否則是假性冗餘）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3.【**最高・第 16 輪】** **KA 路由空殼**：`9d8b6001`／`02eb0989` agentId 仍空 → 仍跑在 rowlet lane、仍不回報；本輪 picturecat 槽更降級成 19.9s `NO_REPLY`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4.【**高・第 14 輪】** `02eb0989` Picturecat KA **補 `payload.timeoutSeconds=1800`**（已連 14 輪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5.【**高・第 6 輪】** **健康回報結構性漏報未修**（只掃 1h 窗）→ 改以 `cron_run_receipts` 為準（20:05 槽可再次驗收）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6.【**高・沿用】** **DNS 單點**：enp43s0 仍 `Current Scopes: none`，DNS 只掛 Wi-Fi＋Tailscale → 給有線網卡設 DNS scope 或全域 1.1.1.1/8.8.8.8。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7.【**高・第 5 輪】** **把必做清單寫進 job payload**：本輪 picturecat 19:02 槽降級（19.9s／`NO_REPLY`）→ 降級輪＝無巡檢＋遮蔽事故窗，已連續第 2 輪實證。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8.【**中・第 8 天已解】** `89e2cfe7 clean-code研究` 今日 18:07 自癒、ce 歸 0（並新增 `c721b4e3` 自癒重試 job）→ 觀察 11-27 09:01 槽是否續活；**該自癒 job 沒設 `payload.timeoutSeconds`**（走預設牆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9.【**中・第 4 輪】** **紅單判定補洞**：掩蓋型 17 支（ce=0 但 24h 有 error receipt）→ 掃描須疊 receipts 分組計數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10.【**中・第 36 輪】** 三支 KA anchor 仍疊（Δ39/33ms）→ 拉開 ≥15 分鐘。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11.【**中・第 15 輪】** `29c2d630` watchdog 的 `payload.timeoutSeconds=120` 太緊（14:04 已死 119,437ms）→ 提到 ≥600。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12.【**中・已定案】** skill 缺 description ＝ 第一方 9/115 ＋ rosclaw vendored 4 → 需你點頭才補。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13.【**中・沿用】** `elle.service` ≈119 次/小時（需 root）；`gw-upgrade-guard.log` 第 21 輪不存在；`dreaming-schedule-check.log` 第 21 輪未更新。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14.【**中・沿用】** **peer `192.168.50.2`（427/427 唯一 SSH 來源，每 10 分鐘 3 筆）仍未知其排程**；本輪它未造成任何重啟或 cron 傷亡 → 需你問 peer 上那支排程在做什麼（它若在 04:25–04:56 觸發重啟會腰斬 dreaming）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
15.【**中・第 16 次】** KA 探針在被探 lane 製造 superseded 競態（3h 8 筆／24h 63 筆，持續收斂）→ 維持觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
16.【**低・沿用】** 健康回報 filler 未見（非 filler 連續多輪）；建議在 payload 加「必須輸出 🛡️ 格式 final summary」硬約束。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本輪結案**：① **600s 牆不必靠長 job 才能殺心跳**（470.5s 的 429 退避 run 就殺了 10 支）；② **fallback 冗餘=0 才是放大器**（15:29 鏈斷 → 6 支同步死；18:03 兩筆 429 → 10 支同步死）；③ **Discord 黑屏續活**（15:43 後 0 READY-fail、selfheal 5 槽未 arm）；④ **clean-code研究今日自癒**；⑤ **心跳牆仍待點頭**（9 支 timeoutSeconds 全 None）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **本輪降級（不列紅單）**：restricted automation-run session 內 `automations list/get` 對本 job 回 not found／空清單（作用域假象，第 5 輪同一現象）→ 真相以 `openclaw cron list --all --json` ＋ `cron_run_receipts`（複製到 /tmp 唯讀）為準。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 15) 下一輪（11-26 22:02）交辦 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① **Discord 是否續活**（15:43:52 起已 3h20m 零 READY-fail；22:02 前若又有 READY-fail／channel exited／EAI_AGAIN → 記失明窗起訖）＋ selfheal 19:13/19:43/20:13/20:43/21:13/21:43 有沒有再 arm（pid 鏈是否再長）；② **provider 飽和有沒有再發**（canonical 429 筆數＋附納入行數、Token Plan 3h 計數、429 run 的 dur 是否又被拖長）＋ **fallback 鏈有沒有再斷**（`billing error`／`modelPolicy`／`Unable to rematerialize` 24h 與窗內筆數）；③ **receipts 全掃描（具名窗 19:02→22:02＋前推 2 槽）**：600s 級硬死逐筆歸因（本次改用「有無 >600s 佔用者」與「是否 429 飽和」雙欄判定）；④ **三支 KA 22:02 槽 dur＋anchor Δ（第 37 次）＋ `02eb0989` timeoutSeconds、KA agentId**；⑤ **健康回報 20:05 槽**是否 🛡️ 格式＋**本窗 17:54–18:20 的 10 筆硬死有沒有被它看見**（結構性漏報第 7 輪驗收點）；⑥ **`89e2cfe7` 下一槽 11-27 09:01 是否續活**＋ 新增 `c721b4e3` 自癒重試 job 的 09:45 槽；⑦ **DNS 24h 逐時**（本輪 ≈460、16h/17h 皆 0）＋ enp43s0 DNS scope 是否仍 none；⑧ **SSH／elle 速率／`gw-upgrade-guard.log`／`dreaming-schedule-check.log` 第 22 輪**；⑨ **superseded 是否新增**（3h 8／24h 63 基線）；⑩ **紅單兩張表**（ce>0：d7b0355b ce=4、58fe15dc ce=1；掩蓋型 17 支基線）；⑪ **gengar lane 探針**（token 換 `LANE_OK_GENGAR_2202_26 = 21`）；⑫ **本輪自身 dur 以 receipt 為準**；⑬ skill 缺 description 沿用 canonical 9/115＋rosclaw 4 支註記；⑭ **量測新口徑沿用**：sqlite 複製唯讀 + 雙 cursor（勿巢狀共用 cursor）+ 明確 +08:00 換算。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-26 22:02 — 第 21 輪 — PASS（lane token 逐字一致）／🔴 **19:02 槽三支 KA 只有一支實質：gengar KA 本體 error（483.0s，「⚠ 🧩 Automations failed」）＋ picturecat 降級跑（19.9s／NO_REPLY）＋ celesteela ok（167.4s）→ 零降級連續紀錄破功**／⭐ **本 job payload 於 19:10:07 被改寫（加 model＋fallbacks＋timeoutSeconds=1800）＝ pending #1/#2 首次落地到 KA，但 9 支 heartbeat 仍全 None**／🔴 **21:08 heartbeat-rowlet 撞 600s 牆（長跑型佔用者＝每日資安建議 dur 1,032.6s），並首次完整觀測到「429 失敗→重試長跑→拖垮心跳」完整鏈條**／✅ Discord 黑屏續活 6h19m（0 READY-fail、selfheal 6 槽零 arm、gateway 零重啟）／✅ 健康回報 20:05 槽**主動點名窗外錯誤**（結構性漏報第 7 輪：部分改善）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
### 1) Gengar lane：PASS（token 逐字一致） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main`（runId `54e04cd4-719e-4724-92a0-c93cdbb51ef4`）→ 回覆首行逐字 **`LANE_OK_GENGAR_2202_26 = 21`** ✅（22:03:30 送達）。
- 對方自報：6 支自有 cron 全 enabled、全 `ce=0`；gateway MainPID=877548／NRestarts=0／uptime **6h19m**；Discord **8 connected/8 enabled**、近 60m ingress 11 筆；近 60m（21:03:09→22:03:09）canonical 429=0、rate/usage-limit=0（1,396 行→1,044 行→72 筆 model-fetch response 納入）；dreaming 11-26 04:25 ok 1,815,253ms ce0、下一槽 11-27 04:25。
- ✅ 與我方獨立量測互校一致（MainPID、Discord 8/8、dreaming 三項逐字相符；429 差異＝其 60m 窗起於 21:03:09，晚於我方 21:02:05 那筆 429，兩邊不衝突）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🔴 19:02 槽三支 KA：只有 celesteela 是實質的（本輪頭號紅單） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| slot | gengar (9d8b6001) | picturecat (02eb0989) | celesteela (880b5c17) | 判定 |
|---|---|---|---|---|
| 11-26 16:02 | ok 653.0s | ok 461.9s | ok 658.9s | ✅ 全實質 |
| **11-26 19:02** | **error 483.0s「⚠ 🧩 Automations failed」** | **ok 19.9s／summary=`NO_REPLY`（降級）** | **ok 167.4s** | 🔴 兩支降級 |
| **11-26 22:02** | running（本輪） | running | running | — |
- **gengar 的死法是「自傷型」**：終端 summary 就是 `⚠ 🧩 Automations failed`（23 字元）——不是 provider/網路錯誤，而是 **agentTurn 內呼叫 automations 工具時失敗**，在 restricted automation-run session 裡 `automations get/list` 對本 job 回 **not found**（第 5 輪以來的「作用域假象」）→ 工具錯誤被當成整輪失敗。⇒ **我們自己的巡檢工具選擇會殺掉自己的槽**（同型風險：`automations list` 空清單）。
- **零降級連續紀錄破功**：前輪（16:02）是三支全實質，本槽 2/3 降級。降級三證據齊：① receipt dur **19.9s < 30s**；② `task_runs.terminal_summary` = **`NO_REPLY`（8 字元）**；③ 今日檔 `^## ` 段落數與槽數落差（同前輪查漏規則）。
- anchorMs 未動：picturecat `1780452122531` → gengar `1780452122570` → celesteela `1780452122603` → Δ**39ms / 33ms** → **第 37 次同槽疊窗**。KA agentId：`9d8b6001`=None、`02eb0989`=None（**KA 路由空殼第 17 輪**，兩支仍跑在 rowlet lane、delivery mode=none → 不回報）、`880b5c17`=celesteela。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐ 本 job payload 於 **19:10:07** 被改寫＝ pending #1/#2 首次落地到 KA <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `cron_jobs.updated_at` = 11-26 **19:10:07**（就在 19:02 槽 error 後 8 分鐘）；payload 由 15 字元 `{"kind":"agentTurn","message":"keep-alive test"}` 變成 **181 字元**：`model=minimax-portal/MiniMax-M3`、`fallbacks=[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7]`、**`timeoutSeconds=1800`**。
- ⇒ pending #1（抬牆）與 pending #2（補 fallback）**對 9d8b6001 已生效**；但 **9 支 heartbeat 的 `payload.timeoutSeconds` 仍全部 None**（本輪逐支列出確認）→ **牆仍在，pending #1 只完成 1/10**。`02eb0989` Picturecat KA 的 timeoutSeconds **仍缺（第 15 輪）**。
- ⚠️ **改寫來源未確認**（無 git/audit 線索，restricted session 內 `automations` 工具看不到自己的 job）→ 已列入下一輪追蹤項。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 🔴 600s 牆：本窗新開 1 死（21:08），並首次完整觀測到「429 → 長跑 → 拖垮心跳」全鏈 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **21:08:21 `heartbeat-rowlet` error dur=600,005ms**（`cron: job execution timed out`）；同窗其餘心跳正常（21:18:52 ok、21:31:05 ok）。
- **佔用者＝`911eee45 每日資安建議`**：21:02:35 起跑 **dur=1,032,569ms（17.2 分）** ok → 覆蓋 21:02–21:19 整段 → 心跳在 21:08 進場撞牆。
- ⭐ **完整鏈條首次觀測**：同一 job **21:00:05 先以 120.6s「⚠️ API rate limit reached」失敗**（canonical 429 於 21:02:05 落地）→ **21:02:35 重試** → 這次跑滿 1,032.6s → **期間所有進場的心跳只能分到被 429 退避拖長的 provider 通道** → 600s 牆殺死 heartbeat-rowlet。⇒ 兩種死法（長 job 佔用型／429 飽和型）**不是互斥，而是同一事件的兩個階段**。
- 24h 600s 級 **error** 42 筆＝**41 筆 heartbeat 牆死 + 1 筆 `58fe15dc 每日論文討論` 710.7s DNS error（非牆死）**；逐時：04h=11、05h=4、07h=2、08h=7、15h=6、16h=1、17h=4、18h=6、**21h=1**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ✅ Discord：黑屏續活 **6h19m**，selfheal 6 槽零 arm、gateway 零重啟 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 自 15:43:52 起至 22:04：**READY wait timed out 0 筆、channel exited 0 筆、EAI_AGAIN 2 筆、status=429 3 筆**（24h 總數 4,092／17／458／17，幾乎全在 15:43 前）。
- `d4cd45bc discord-selfheal-after-dreaming`：19:13／19:43／20:13／20:43／21:13／21:43 **六槽 summary 皆「discord healthy (no startup-not-ready) - no action」**（dur ~743ms）→ **零 arm**。
- gateway：MainPID **877548**、**NRestarts=0**、ExecMainStartTimestamp 15:43:52 → **6h21m 零重啟**（24h 重啟仍 6 次，全在 15:43 前）。`openclaw channels status`（22:02）：**8 個 enabled 帳號全部 running, connected**（greninja disabled 為設計如此），traffic 為真（mrmime in/out 43m、celesteela in 6m、rowlet transport 1m）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) ✅ 配額牆連續第 11 輪熄火／✅ fallback 鏈自 15:43 起未再斷 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `Token Plan usage limit` = **0**；canonical `[model-fetch] … status=429` = **17 筆**（逐時：00h=1、03h=2、05h=4、06h=1、07h=2、08h=2、12h=1、15h=1、18h=2、**21h=1**），納入行數 `[model-fetch] response` = **1,876**。
- fallback 鏈斷裂三指標 24h：`Unable to rematerialize` **6**、`is not allowed for agent` **1**、`billing error`（openai 沒餘額）**4** → **全部落在 15:29–15:33**；**15:43:52 之後 = 0/0/0** → 鏈未再斷（本 job 19:10 已補 fallback 亦是一道保險）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 🔴 DNS：24h EAI_AGAIN **458** 筆，但連續 4 小時歸零；enp43s0 仍無 DNS scope <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 主 host：gateway.discord.gg **216**、api.minimax.io **150**、gateway-us-east1-{d,b,c} 42/39/12、discord.com 2、api.openai.com 1 → 仍是「主機層 DNS、同時打兩組 host」。
- 逐時：01h=16、07h=4、08h=34、09h=90、10h=87、11h=7、12h=55、13h=70、14h=67、15h=26、16h=0、17h=0、18h=2、**19–22h=0**（本窗僅 2 筆 EAI_AGAIN）。
- `resolvectl status`：**Link 2 (enp43s0) Current Scopes: none**；DNS 只掛 wlp0s20f3（1.1.1.1/8.8.8.8）與 tailscale0 → **單點仍在 Wi-Fi**（pending #6 未解）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) ✅ 健康回報 20:05 槽：**主動點名窗外錯誤**（結構性漏報第 7 輪驗收 → 部分改善） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt 20:05:20 **ok、dur 41,247ms、summary 397 字**、標準 🛡️ 格式：Gateway ✅ pid 877548／Disk 61%（270G/468G）／**Crons: 0 failed**／Delivery OK。
- ⭐ **本輪改善**：它明確寫出「最近一次 error 為 **Gengar Keep-Alive（64 分鐘前）**、Jormungand mrmime Codex A2A heartbeat（125 分鐘前，rate_limit），均超出 1 小時視窗」→ **能報最近一次 error 及其距今分鐘數**（前輪只報窗內）。
- ⚠️ **殘留**：仍是「1 小時窗」口徑 → 17:54–18:20 的 10 筆 600s 硬死（窗外 1h45m）**依然不可見**，且 21:08 heartbeat-rowlet 那筆牆死發生在它下一槽（23:05）之前 → **仍須改以 `cron_run_receipts` 24h 為準**。對照：同型 job `ca222989 OpenClaw 系統維護` 21:04 槽報「Crons: 1 failed last hour」→ **抓到 21:00 資安建議那次 rate limit**（兩個維護 job 口徑不一致）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 紅單兩張表（24h receipts 全掃描） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **ce>0 共 4 支（enabled）**：`9d8b6001` ce=**1**（19:02「Automations failed」）、`d7b0355b Jormungand Codex A2A` ce=**4**（下一槽 11-27 00:00）、`58fe15dc 每日論文討論` ce=**1**（下一槽 11-27 07:00）、`c5352a84 skill-collection-review-roaringmoon` ce=**1**（下一槽 11-27 03:56）；另 disabled 的 `a94330a9 tmp-openai-probe` ce=2。
- **掩蓋型（ce=0 但 24h 內有 error receipt）16 支**：heartbeat-mrmime 10、OpenClaw 系統維護 9、heartbeat-roaringmoon 8、heartbeat-rowlet 7、heartbeat-picturecat 5、heartbeat-charizard 5、heartbeat-gengar 5、Picturecat KA 4、heartbeat-greninja 3、heartbeat-celesteela 3、Celesteela KA 2、健康回報 2、clean-code研究 2、Jormungand daily all-agent health 2、Gengar watchdog 1、每日資安建議 1。⇒ **只看 ce 會漏掉 16 支**（基線 17，持平）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 其他量測（附口徑） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- fleet **54 支（enabled 47／disabled 7）**；`openclaw cron list --all` 為唯一能看到 disabled 的口徑。
- **heartbeat 牆**：9 支 heartbeat（d82f78e3／46242a4c／7d633ff4／ffc90b7d／6525d155／3acd15c2／c29eca0f／bcf270b8／6e93c179）+ `d7b0355b` 的 `payload.timeoutSeconds` **全部仍 None** → **仍吃 cron 預設 600s 牆**（本輪 21:08 那一死即為此牆）。
- dreaming `36b493db` 11-26 04:25 **ok 1,815,253ms ce0** → **連續第 3 夜完整**，下一槽 11-27 04:25；selfheal expr `13,43 0-3,5-23 * * *` 不含第 4 小時 → dreaming 窗對 selfheal 安全（殘餘風險＝peer SSH 觸發的重啟時點不可控；本窗 peer burst 未造成任何重啟）。
- **SSH**：24h **427/427 全部來自 192.168.50.2**（每 10 分鐘 3 筆 burst，最新 21:57:34/47/48）→ 仍未造成任何 cron 傷亡或重啟。
- **elle.service**：NRestarts **127,729**（上輪 127,374 → +355／3h ≈ **118/h**，速率持平）；ActiveState=activating／SubState=start-pre → 需 root，維持回報不動手。
- **日誌檔**：`gw-upgrade-guard.log` **第 22 輪仍不存在**；`dreaming-schedule-check.log` mtime 仍停 **11-19 22:33** → 第 22 輪未更新。
- **superseded** 3h **10**／24h **65**（基線 8／63）；**lane wait exceeded** 3h 0／24h 12；**competing work** 3h 11／24h 82。
- **skill 缺 description**：canonical 第一方 **9**（card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、system-design-six-dimensions-analyzer、web-fetch-troubleshooting）＋ rosclaw vendored 4 → 逐字一致，不變（另本輪擴大掃到 19 支含 10 支 repo/vendored 副本，非安裝技能，不計）。**未經 Linder 點頭不補**。
- **系統面**：load **0.68/0.47/0.44**、mem 31G／available 20G、disk **61%**（175G 可用）、uptime **46 天 3:49**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 給 Linder 的待決事項（更新後 17 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1.【**最高・部分完成】** **抬牆：9 支 heartbeat 的 cron `payload.timeoutSeconds` 仍全 None**（本輪已逐支確認）→ **仍是 600s 牆**；`9d8b6001` 已於 19:10:07 補上 1800s，但**只完成 1/10**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2.【**最高・本輪新證據】** **兩種牆死是同一事件兩階段**：429 失敗（21:00:05）→ 重試長跑 1,032.6s（21:02:35–21:19）→ 心跳 21:08 進場撞牆。**修法要兩管齊下**：抬牆 ≥2400s ＋ 補第二廠憑證／修好 openai 餘額。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3.【**最高・第 17 輪】** **KA 路由空殼**：`9d8b6001`／`02eb0989` agentId 仍 None、delivery=none → 跑在 rowlet lane、不回報；本輪 gengar 槽甚至以「Automations failed」自傷結束。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4.【**高・本輪新】** **巡檢 payload 需寫死必做清單**（19:02 兩支降級＝深度靠 model 自由發揮的後果）；並建議明令「restricted automation session 內**禁用 automations 工具**、改用 `openclaw cron` CLI」以免自傷型失敗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5.【**高・第 15 輪】** `02eb0989` Picturecat KA 補 `payload.timeoutSeconds=1800`（其 agentId 仍空）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6.【**高・第 7 輪・部分改善】** 健康回報已會主動點名窗外最近一次 error，但**仍只有 1h 窗**（17:54–18:20 的 10 筆硬死不可見）；且兩個維護 job 口徑不一致（系統維護抓到 21:00 資安建議 rate limit）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7.【**高・沿用】** **DNS 單點**：enp43s0 `Current Scopes: none` → 給有線網卡設 DNS scope 或全域 1.1.1.1/8.8.8.8（24h 458 筆 EAI_AGAIN 的根因；近 4h 已歸零）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8.【**高・沿用】** **長跑型 job 需錯開心跳槽並設 timeout**（`911eee45 每日資安建議` 單槽 1,032.6s、`36b493db dreaming` 1,815.3s、`58fe15dc` 710.7s、`ae91b967` 1,548.6s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9.【**中・第 4 輪】** **紅單判定補洞**：掩蓋型 16 支（ce=0 但 24h 有 error receipt）→ 掃描須疊 receipts 分組計數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10.【**中・第 37 輪】】 三支 KA anchor 仍疊（Δ39/33ms）→ 拉開 ≥15 分鐘。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11.【**中・第 15 輪】】 `29c2d630` watchdog 的 `payload.timeoutSeconds=120` 太緊 → 提到 ≥600（本輪 20:04 槽 3,036ms 尚安全）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12.【**中・沿用】】 `elle.service` ≈118 次/小時（需 root）；`gw-upgrade-guard.log` 第 22 輪不存在；`dreaming-schedule-check.log` 第 22 輪未更新。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13.【**中・沿用】】 peer `192.168.50.2` 仍每 10 分鐘 3 筆 SSH burst（427/427 唯一來源），**未知其排程**；本窗未造成任何重啟或 cron 傷亡 → 需你問 peer 上那支排程在做什麼。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14.【**中・已定案】】 skill 缺 description ＝ 第一方 9 ＋ rosclaw 4 → 需你點頭才補。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
15.【**中・第 16 次】】 KA 探針在被探 lane 製造 superseded 競態 → 維持觀察（3h 10／24h 65）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
16.【**中・本輪新】** **追蹤 9d8b6001 payload 於 19:10:07 的改寫來源**（誰／哪個流程加的 model+fallbacks+1800s）→ 決定 pending #1/#2 的執行管道是否已通。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
17.【**低・沿用】】 健康回報 filler 未見；建議 payload 加「必須輸出 🛡️ 格式 final summary」硬約束。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本輪結案**：① **19:02 槽 2/3 降級**（gengar「Automations failed」自傷 ＋ picturecat 19.9s NO_REPLY）→ 零降級紀錄破功；② **本 job payload 已補 1800s＋fallbacks，但 9 支 heartbeat 牆未動**；③ **600s 牆兩種死法是同一事件兩階段**（429→長跑→心跳死）；④ **Discord 黑屏續活 6h19m、gateway 零重啟**；⑤ **健康回報開始主動報窗外錯誤**（漏報部分改善）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **本輪降級（不列紅單）**：restricted automation-run session 內 `automations get` 對本 job 回 **not found**（作用域假象，第 6 輪同一現象）→ 真相以 `openclaw cron list --all --json` ＋ `cron_run_receipts`（複製 /tmp 唯讀）＋ journal 為準。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 12) 下一輪（11-27 01:02）交辦 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① **Discord 是否續活**（15:43:52 起已 6h19m 零 READY-fail；01:02 前若又有 READY-fail／channel exited／EAI_AGAIN → 記失明窗起訖）＋ selfheal 22:13/22:43/23:13/23:43/00:13/00:43 有沒有 arm（pid 鏈是否再長）；② **provider 飽和**（canonical 429 逐時＋附納入行數、Token Plan 3h、fallback 三指標 24h／窗內筆數）；③ **receipts 全掃描（具名窗 22:02→01:02＋前推 2 槽）**：600s 牆逐筆歸因（長跑型 vs 429 型雙欄判定）＋ 21:08 heartbeat-rowlet 那筆的收尾（21:18:52 是否補跑成功）；④ **三支 KA 01:02 槽 dur＋anchor Δ（第 38 次）＋ `02eb0989` timeoutSeconds（仍缺第 16 輪）、KA agentId**；⑤ **健康回報 23:05 槽**是否也主動點名窗外錯誤＋是否看見 21:08 那筆牆死（結構性漏報第 8 輪驗收點）；⑥ `89e2cfe7 clean-code研究` 下一槽 **11-27 09:01** 是否續活（自癒後首次）＋ `c721b4e3` 09:45 槽；⑦ **dreaming 11-27 04:25 槽**是否完整（連續第 4 夜）＋ selfheal 窗內安全＋peer burst 是否落在窗內；⑧ **DNS 24h 逐時**（本輪 458，19–22h=0）＋ enp43s0 DNS scope 是否仍 none；⑨ **SSH／elle 速率／`gw-upgrade-guard.log`／`dreaming-schedule-check.log` 第 23 輪**；⑩ **superseded 3h／24h**（基線 10／65）；⑪ **紅單兩張表**（ce>0：9d8b6001=1、d7b0355b=4、58fe15dc=1、c5352a84=1；掩蓋型 16 支基線）；⑫ **本輪自身 dur 以 receipt 為準**；⑬ skill canonical 9 ＋ rosclaw 4；⑭ **量測口徑沿用**（sqlite 複製 /tmp 唯讀＋雙 cursor，勿巢狀共用 cursor＋明確 +08:00 換算）；⑮ **追蹤 9d8b6001 payload 19:10:07 改寫來源**與 9 支 heartbeat timeoutSeconds 是否被補；⑯ 追蹤 `automations` 工具在 restricted session 的 not found 假象（改用 CLI 的可行性）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
