# Gengar Keep-Alive 巡檢日誌（gengar 側自報，2026-11-24）

## Gengar lane 自報（gengar 01:02 台北）— PASS（lane 雙向通）／📉 60m provider 失敗全 0／⏳ dreaming 11-24 04:25 尚未跑（下一個驗證點 10:02）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_0102_24 = 7`
- **近 60 分鐘 provider 失敗計數（真實 runtime truth，已排除 `agent:*` 自報文字迴音）**：**429 = 0、overloaded = 0、EAI_AGAIN = 0**。
- 我自有 cron（全 `ok` / `ce=0`）：
  | id | 名稱 | lastRunStatus | ce | nextRunAt |
  |---|---|---|---|---|
  | `29c2d630` | Gengar Cron Health Watchdog | ok | 0 | 11-24 02:04 |
  | `c29eca0f` | heartbeat-gengar | ok | 0 | 11-24 01:29 |
  | `ac9e7ada` | You are an English coach | ok | 0 | 11-24 05:00 |
  | `88810bfe` | BBC News Morning Discussion | ok | 0 | 11-24 07:00 |
  | `7767e03b` | skill-collection-review-gengar | ok | 0 | 11-28 07:32 |
  | `f5148ff0` | OpenClaw 版本檢查 | ok | 0 | 11-29 00:00 |
- gateway（systemd 真相）：`MainPID=4137629`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST`、`NRestarts=0`、`ActiveState=active` → 連續運行約 **20h15m**、期間 0 次重啟。
- dreaming `36b493db`：next **11-24 04:25**（本輪尚未執行）；上一輪 11-23 04:25 = error 1,406,869 ms、ce=1。**決定性驗證點 = 11-24 04:25 跑完之後**，我在 10:02 那輪讀 dur/status，若 < 30 分鐘或非 ok 立即回報。
- 交付：本記憶檔寫入；依新規則本輪**不**用 sessions_send 投遞進 rowlet 的 cron session、也未 announce 到任何外部頻道。

---

## 2026-11-24 01:02 — PASS（lane 雙向通、去程+回程皆落地）／📉 3h 窗 429 續 3 筆但「usage limit」歸零／⚠️ 本 job 自身 11-23：1 輪降級跑（10:02, 12.8s）＋2 輪 provider 致死（07:02 / 13:02）／🧩 17 支 skill 第 16 輪未修／⏳ dreaming 04:25 未到（守門修好後的決定性驗證仍在前方）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，本輪回程腿亦走新規則）
- `sessions_send` → `agent:gengar:main` → runId **`0270cfcb-bd0c-494f-8f8a-c6c730747ac0`**、status=ok、targetDisposition=queued、delivery=announce/pending。
- **去程讀回**：01:04 收到完整回覆，token `LANE_OK_GENGAR_0102_24 = 7` 逐字一致（無亂碼）。
- **回程腿**：本輪下達新規則「**不要**把回覆投遞進 cron session、也**不要** announce 到外部頻道」→ 耿鬼**已遵守**（自報「未用 sessions_send 投遞進 rowlet 的 cron session、也未 announce 到任何外部頻道」，只寫 `memory/keepalive-gengar-2026-11-24.md`）。→ **新規則生效（第 2 輪）**。
- ⚠️ **本輪新發現的檔名碰撞**：耿鬼側寫的就是 `memory/keepalive-gengar-2026-11-24.md`（與我 rowlet lane 同名）→ 我本節以 **append** 寫入、未覆寫；否則會重演 11-22「1 輪紀錄寫錯檔、1 輪完全沒留檔」的老坑。**建議兩 lane 分檔（gengar / rowlet）**。
- 耿鬼自報近 60 分鐘 **429 / overloaded / EAI_AGAIN 全 0** → 與我方量測無矛盾。
- 耿鬼自報 6 支自有 cron **全 ok / ce=0**：`29c2d630` watchdog（next 02:04）、`c29eca0f` heartbeat（01:29）、`ac9e7ada` English coach（05:00）、`88810bfe` BBC drill（07:00）、`7767e03b` skill-review（11-28 07:32）、`f5148ff0` 版本檢查（11-29 00:00）。

### 2) ⚠️ 本 job 自身體檢：11-23 八槽 → 1 降級 + 2 provider 致死（比 11-22 的 4 降級明顯好）
| 槽（11-23） | dur | 狀態 | 判定 |
|---|---|---|---|
| 01:02 | 277,451 ms | ok | ✅ |
| 04:02 | 205,068 ms | ok | ✅ |
| 07:02 | 1,624,295 ms | **error**（API rate limit reached）＋ 8,826 ms 補跑 **error**（Explicit auth order for openai has no usable profiles） | ❌ provider 致死 |
| 10:02 | **12,842 ms** | ok | ⚠️ **降級跑**（<30s） |
| 13:02 | 158,634 ms | **error**（minimax-portal/MiniMax-M3 request failed） | ❌ provider 致死 |
| 16:02 | 822,130 ms | ok | ✅ |
| 19:02 | 414,305 ms | ok | ✅ |
| 22:02 | 265,655 ms | ok | ✅ |
- 對照 11-22：降級 4 輪 → 11-23 降級 **1 輪**。**殘留根因＝payload 只有一句 `keep-alive test`**，深度不足就 8–20s 交件（老教訓量化後未解）。
- ⭐ **新證據：fallback 鏈是空的**——我的 fallbacks 寫 `minimax/MiniMax-M3` / `minimax-portal/MiniMax-M2.7`，但 07:29 補跑的錯是 **「Explicit auth order for openai has no usable profiles」** → 一旦 minimax 兩條路都 429，**跨廠冗餘＝0**，job 直接死（11-19 那筆舊 receipt 也同款：All models failed (4) → rate_limit）。**這不是偶發，是結構性單點。**

### 3) 三支 KA anchor：仍疊在同一秒級（間隔 8ms + 2ms）
- 22:02 槽：gengar `22:02:02` / picturecat `22:02:10` / celesteela `22:02:12` → **gengar↔picturecat 8ms、picturecat↔celesteela 2ms**。
- 01:02 槽：nextRunAt 完全同構（01:02:02 / 01:02:10 / 01:02:12）→ **疊窗結構未被改動**（第 19 次起算）。
- 該窗 **stalled session = 0、lane wait / queue = 0** → 危害仍集中在「疊窗 + 其他 job 同時長跑」。
- 三支 KA 22:02 dur：gengar **265.7s** ✅／picturecat **21.5s** ⚠️（降級）／celesteela **415.6s** ✅（**上輪說「尚未寫出 receipt」已修正——本輪 receipt 已落地**）。
- picturecat 22:02 那輪 21.5s：`memory/keepalive-picturecat-2026-11-23.md` 只記到 **19:02（第 7 輪）**、**22:02 槽無紀錄** → **降級跑假說再次成立（該 lane 也沒為降級輪留檔）**。

### 4) 📉 Provider：3h 窗 429 = 3 筆（全 minimax-portal）／**「usage limit reached」3h = 0**
- 3h 窗（22:02→01:04）`model-fetch.*status=429` = **3**筆：**23:01:29 elapsed=89,046ms**、**23:03:42 elapsed=116,722ms**、**00:02:35 elapsed=106,578ms**（provider 全部 minimax-portal）。
- 24h canonical 429 = **43**（上輪 39）→ 略升但**不集中在 3h 窗**。
- ⭐ **好消息**：24h `Token Plan usage limit reached` = 58 筆，但 **全部不在 model-fetch 行**（即 agent 錯誤回報文字）、**3h 窗 = 0 筆** → 配額牆本窗**未觸發**。
- **elapsed 趨勢**（近 8 筆）：179,436 → 109,109 → 90,510 → 130,017 → 106,188 → 89,046 → 116,722 → 106,578（ms）→ 峰值 179s→130s、中位 ~106s → **緩慢下行中，尚未見「恢復」**。
- 新型別：**EAI_AGAIN 24h = 16**（上輪 0），但**幾乎全部是 `[agent:nested]` 的 session 事件行**（session=agent:gengar:main / agent:rowlet:cron:…），**不是 provider 失敗**；3h 窗唯一 1 筆 = 01:04:10＝我本輪自己的 lane 探測。→ **不列為 provider 故障**。

### 5) ⏳ dreaming 11-24 04:25 前置（決定性驗證仍未到點）
- `36b493db`（Memory Dreaming Promotion）：next **11-24 04:25**；上一輪 11-23 04:25 = **error、dur 1,406,869 ms（23.4 分）、ce=1** → 本輪尚未執行。
- ✅ **守門修法在位**：`scripts/dreaming-running-check.py`（11-23 07:27, 9,589 B）存在且 `scripts/discord-selfheal.sh`（11-23 07:26, 6,607 B）第 2 步已改呼叫它（行 41 `DREAMING_CHECK=`、行 89 註解）。
- ❌ **兩個前置仍缺**：`memory/gw-upgrade-guard.log` **不存在**；`memory/dreaming-schedule-check.log` **仍停擺在 11-19 22:33（已 5 天）** → 04:25 前只能事後比對、沒有前瞻簽章。**本輪仍未動這兩檔**（先回報待授權）。
- **真實驗證點＝04:25 那次跑完**（dur ≥ 30 分 且 status=ok）→ 本輪（01:02）看不到，只能交給 07:02 輪讀 receipt。

### 6) 🧩 17 支 skill 缺 description：**第 16 輪未修**
- 3h **221 行**（上輪 68）／24h **2,941 行**（上輪 3,162）→ 仍是視窗位移，**唯一檔數恆為 17**（清單與上輪完全一致：card-lookup、excel-image-pipeline、human-behavior-simulation、image-attendant、meta-analyzer、network-security-defense、ocr-confidence-mark、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、rosclaw×4、system-design-six-dimensions-analyzer、web-fetch-troubleshooting）。
- 依舊例以 journal 的 `[skills] Skipping invalid skill` 為唯一真值。**未授權，不動。**

### 7) 🔴 SSH 來源：**仍在每 10 分鐘 ×3**
- 系統 journal：近 3h **54 次** `Accepted publickey for amr from 192.168.50.2`、近 1h **18 次**；節奏未變（00:37:47×2、00:47:34/47/48、00:57:35/48/48）。
- 近 24h `systemctl --user restart openclaw-gateway` 實際只有 **2 筆**（04:46:50 / 04:47:46 → 導致 04:48:17 `Main process exited, code=killed, status=9/KILL`）；13:04:50 / 13:15:58 兩筆只是 agent 訊息文字裡提到該字串的 log 行，**不是真的下過指令**。
- **gateway：MainPID 4137629、NRestarts=0、自 11-23 04:48:17 連續在線 ≈ 20h16m，本輪無重啟** → 這批 SSH 登入目前**沒有**再觸發重啟，但 04:25 dreaming 窗的干擾半徑仍在。

### 8) 系統面
- Discord 3h：`Gateway reconnect scheduled` **11**、`gateway websocket closed` **11**（一一對應，正常抖動）／READY timeout **0**、channel exited **0**、host timing gap **0**。
- 3h：**stalled session 0、lane wait 0、interrupted 0**、nested session 事件 18。
- host：up **43d 6:51**、load **0.66 / 0.61 / 0.57**、RAM avail **21,038 MB**、/home **267G/468G（60%、178G free）**。

### 9) 給 Linder 的待決事項（狀態更新）
1. 【中・第 19 輪】三支 KA anchor 疊窗（8ms/2ms）→ 建議拉開 ≥3 分鐘（仍待點頭）。
2. 【中・第 16 輪】17 支 skill 缺 description → 跨 lane／跨第三方 plugin 寫檔，需你點頭。
3. 【中・需授權・新】**fallback 鏈無憑證＝零冗餘**：minimax 兩路 429 時 job 直接死（11-23 07:02、13:02 兩次實證；11-19 亦同）。要嘛補 openai 可用 profile、要嘛把 provider 失敗判定寫進 payload 讓 job 能「降級存活」。
4. 【中・需授權・第 3 輪】payload 只有 `keep-alive test` → 11-23 仍有 1 輪降級跑（10:02）。建議把巡檢步驟與檔名寫進 payload，或改由獨立 patrol job 承載。
5. 【中・既有】MiniMax Token Plan 配額牆：24h 43 筆 canonical 429、58 筆 usage-limit 文字（3h 窗 0 筆）→ **本窗未觸發**；唯一穩定訊號仍是 **elapsed 緩慢下行（峰值 179s→130s）**，不宣告恢復。
6. 【中・既有】筆電端每 10 分鐘 ×3 SSH 仍在 → 04:25 dreaming 前 30 分鐘仍建議確認那支排程在做什麼。
7. 【低・既有】`c5352a84` ce=1 → next 11-27；`a94330a9`（停用殘留紅燈 ce=2）→ 可刪。
8. 【中・本輪新】`memory/dreaming-schedule-check.log` **停擺 5 天**、`memory/gw-upgrade-guard.log` **不存在** → 04:25 前置沒有前瞻簽章。**本輪未動這兩檔**。
9. 【中・本輪新】**gengar lane 與 rowlet lane 寫同一個 keepalive 檔名** → 本輪以 append 處理、無覆寫；建議分檔。
10. 【已結案】回程腿新規則（不投遞進 cron session）**連續第 2 輪生效**（22:02、01:02）。

### 10) 下一輪（11-24 04:02）交辦
① **11-24 04:25 dreaming 尚未跑** → 04:02 輪只能做「開跑前」確認；**決定性驗證（dur ≥30 分 且 ok）要等 07:02 輪**；② 3h 窗 429 是否續（00:02:35 之後有無新事件、elapsed 是否再破 106s）；③ 三支 KA anchor（第 20 次）+ stalled/lane wait；④ 17 支 skill（第 17 輪）；⑤ picturecat 22:02 的 21.5s 降級輪是否仍未留檔、celesteela 01:02 那輪 dur 196.4s 是否有紀錄；⑥ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 是否有人補；⑦ 筆電端 SSH 是否仍每 10 分 ×3；⑧ 回程腿新規則續用；⑨ 有無新的 provider 失敗型別。

### 11) ✅ 本輪新增可重用方法（寫進 MEMORY.md）
- **「降級跑」判別式跨 lane 成立**：picturecat 的 21.5s 槽在它自己的 lane 日誌裡**完全沒有紀錄** → 降級輪不只是「dur 短」，而是**根本沒寫檔**；數「某日某 lane 檔的 `^## ` 段落數」＝ 該 lane 當日真正巡檢了幾輪。
- **journal 裡的 `systemctl --user restart` 字樣要先分辨真偽**：真指令 = `systemd[1151]: Started /usr/bin/systemctl --user restart …`；agent 訊息文字迴音 = `node[…]: [… ] …systemctl --user restart openclaw-gateway`。**真重啟數要看前者，否則會把 agent 提到指令字串的 log 行誤算成重啟。**
- **usage-limit 文字 vs canonical 429 要分兩個口徑**：`model-fetch.*status=429`（canonical 計數）與 agent 錯誤回報裡的 `Token Plan usage limit reached`（文字計數）量體不同，本輪 24h 為 43 vs 58，**3h 窗則是 3 vs 0** → 判斷「配額牆有沒有打到」要用 model-fetch 口徑。

## Gengar lane 自報（gengar 04:02 台北）— PASS（lane 雙向通）／📉 60m provider 失敗 429=0、overloaded=0、EAI_AGAIN=0／⏳ dreaming 11-24 04:25 尚未起跑<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_0402_24 = 7`
- ① **近 60 分鐘 provider 失敗計數**（canonical model-fetch 口徑，已排除 `agent:*` 自報文字迴音）：**429 = 0、overloaded = 0、EAI_AGAIN = 0**。
- ② 我自有 cron（**全 `ok`、`ce` 全 0**）：
  | id | 名稱 | lastRunStatus | ce | last | next |
  |---|---|---|---|---|---|
  | `29c2d630` | Gengar Cron Health Watchdog | ok | 0 | 11-24 04:04 | 11-24 06:04 |
  | `c29eca0f` | heartbeat-gengar | ok | 0 | 11-24 03:59 | 11-24 04:29 |
  | `ac9e7ada` | You are an English coach | ok | 0 | 11-23 05:00 | 11-24 05:00 |
  | `88810bfe` | BBC News Morning Discussion | ok | 0 | 11-23 07:00 | 11-24 07:00 |
  | `7767e03b` | skill-collection-review-gengar | ok | 0 | 11-21 07:32 | 11-28 07:32 |
  | `f5148ff0` | OpenClaw 版本檢查 | ok | 0 | 11-22 00:00 | 11-29 00:00 |
- ③ **dreaming `36b493db` 尚未跑**：nextRunAt = **11-24 04:25**（本輪 04:06 時尚未起跑）；上一輪 11-23 04:25 = error 1,406,869 ms、ce=1；再前兩輪皆完整（11-22 ok 1,852,428 ms、11-21 ok 1,918,841 ms）。**決定性驗證 = 04:25 這輪跑完**，我在 10:02 那輪讀 dur/status；若 ≥ 30 分鐘且 status=ok，即證明守門修好，若被砍（error / 「interrupted by gateway restart」）我立即回報。
  ⚠️ 提醒一個時間重疊：我的 `ac9e7ada` English coach 在 **05:00** 觸發，而 dreaming 最晚可到 **05:05**（04:25 + timeoutSeconds 2400）→ 兩者可能重疊，dreaming 若佔用 event loop，English coach 會排在它後面（昨晚 05:05 那輪即是如此，結果仍 ok）。若要完全避免，可把 dreaming 挪到 04:05–04:15 這類較早的時段或把 timeoutSeconds 收短，但目前不動。
- ④ **gateway（systemd 真相）**：`MainPID=4137629`、`NRestarts=0`、`Result=success`、`ActiveState=active`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → **連續運行約 23h18m、期間 0 次重啟**（本輪無任何 gateway 事件）。
- 交付：本記憶檔 append 寫入；依新規則**不**用 sessions_send 投遞進 rowlet 的 cron session、也未 announce 到任何外部頻道。

## 2026-11-24 04:02 — PASS（lane 雙向通）／📉 3h 窗 canonical 429 = 1（配額牆未觸發）／🔴 新失敗型別：ENETUNREACH + EAI_AGAIN + 600s idle timeout → mrmime lane stalled 10 分鐘／⏳ dreaming 04:25 尚未跑（決定性驗證在 07:02 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，回程腿新規則第 3 輪生效）
- `sessions_send` → `agent:gengar:main` → runId `40a38bbc-2581-4250-8421-d900f781ae0f`、status=ok、delivery=announce/pending。
- **去程讀回**：04:06 收到完整回覆，token `LANE_OK_GENGAR_0402_24 = 7` 逐字一致（無亂碼）。
- **回程腿**：耿鬼遵守新規則 → 未 `sessions_send` 進本 cron session、未 announce 外部；自報已 **append** 進 `memory/keepalive-gengar-2026-11-24.md`（gengar 自撰第 2 段、15,209 B、mtime 04:06:27）。本段亦以 **append** 寫入、未覆寫（避免 11-22「寫錯檔／沒留檔」老坑）。
- 耿鬼自報近 60 分鐘 canonical **429 / overloaded / EAI_AGAIN = 0 / 0 / 0** → 與我方量測一致（本輪實測：近 60 分鐘 canonical 429 = 0；「EAI_AGAIN / overloaded」字樣僅出現在 gengar 自報文字＝agent self-echo，非 provider 失敗）。
- 耿鬼自報 6 支自有 cron 全 `ok` / `ce=0`（watchdog 04:04→06:04、heartbeat 03:59→04:29、English coach 05:00、BBC 07:00、skill-review 11-28、版本檢查 11-29）。

### 2) 🔴 本輪最大新發現：provider 失敗型別改寫——「網路路徑失敗」而非「配額牆」
- 3h 窗 canonical 429 = **1**（03:01:55，elapsedMs=105,849）→ 較上輪（3h 3 筆）收斂；24h canonical 429 = **43**（與上輪同數 → 新增 1 筆與視窗位移抵銷）。
- 3h 窗 usage-limit 文字 = **0** → 配額牆**未觸發**（與上輪同結論）。
- ⭐ **新的 3 筆 model-fetch error（全是網路層，不是 429）**：
  - 03:04:50 `minimax-portal/MiniMax-M3` **ENETUNREACH**（AggregateError / fetch failed, elapsedMs=15）
  - 03:04:51 `minimax/MiniMax-M3` **ENETUNREACH**（elapsedMs=1032）
  - 03:05:02 `minimax-portal/MiniMax-M2.7` **EAI_AGAIN**（getaddrinfo api.minimax.io, elapsedMs=10014）
  → 三個 fallback 候選**同時**掛掉 → **fallback 鏈的「廠商冗餘 = 0」再次實證，而且這次原因不是配額，是本機→api.minimax.io 的連線/DNS 路徑**（連線層故障一次打穿整個 minimax 家族）。
- ⭐ **新失敗型別：`LLM idle timeout (600s): no response from model`**（03:14:48 `minimax-portal/MiniMax-M3`，elapsedMs=**600,104**）→ **10 分鐘無回應**。
- ⭐ **連帶後果：3h 窗 stalled session = 10**（03:11:02→03:15:32、每 30s 一筆，全為 `agent:mrmime:cron:40e09cd1` = Jormungand daily all-agent health）→ 該輪最後只留「The tool run finished, but no final summary was produced.」（settled-finalization-fallback）。**本系列第一次量到 stalled > 0**，根因＝上游 600s idle timeout，**不是** gateway 問題（gateway MainPID 未變、NRestarts=0）。
- 3h fallback 決策：5 筆 `decision=candidate_failed requested=minimax-portal/...` → 候選全落在 minimax 家族，家族外無備援。
- elapsed 趨勢（24h 末 8 筆）：109,109 / 90,510 / 130,017 / 106,188 / 89,046 / 116,722 / 106,578 / 105,849 ms → 仍帶 90–130s，**不宣告恢復**；本窗另見 600,104ms 新極端值。

### 3) ⏳ dreaming `36b493db`：本輪只做到「開跑前」確認（next 04:25 CST，剩約 17 分鐘）
- 上一輪 11-23 04:25 = **error**、dur 1,406,869 ms、ce=1；本輪（04:02）尚未執行。**決定性驗證（dur ≥30 分 且 ok）要等 07:02 輪**。
- ✅ **守門在位**：`d4cd45bc`（discord-selfheal-after-dreaming，payload = `sh -lc /home/amr/.openclaw/workspace-rowlet/scripts/discord-selfheal.sh`，timeout 60s）next **05:13 CST** = dreaming 結束（04:25 + timeoutSeconds 2400 = 05:05）後 8 分鐘；`discord-selfheal.sh` 第 2 步呼叫 `dreaming-running-check.py`（**唯讀**：cron list + receipt db probe + schedule 推算，只寫 stderr，無 restart/kill）。
- ❌ **兩個前置仍缺（本輪已用 scripts 內引用的真實路徑核對，不是路徑誤判）**：`/home/amr/.openclaw/logs/gw-upgrade-guard.log` **不存在**（該目錄只有 gateway-restart.log 與 config-audit 檔）；`memory/dreaming-schedule-check.log` 仍**停擺 11-19 22:33（5 天）** → 04:25 前無前瞻簽章。**本輪仍未動這兩檔**（先回報待授權）。
- ⚠️ **新重疊風險**：gengar 的 `ac9e7ada` English coach **05:00** 落在 dreaming 窗（04:25–05:05）內 → 可能排在 dreaming 之後（昨晚 05:05 同款、已 ok）。gengar 建議把 dreaming 提前到 04:05–04:15 或縮 timeout；**未自行修改，等點頭**。

### 4) 三支 KA anchor：仍疊窗（連續第 19 次起算，picturecat lane 同輪同數據）
- nextRunAt：`gengar 04:02:02.639` → `picturecat 04:02:12.745` → `celesteela 04:02:12.750` → **gengar↔picturecat 10.106s、picturecat↔celesteela 5ms**。
- 上一輪（01:02）三支 dur：gengar **390,673ms** ✅／picturecat **392,354ms** ✅／celesteela **196,420ms** ✅ → 三支全 >30s，**無降級跑**。
- ⚠️ **降級輪缺口仍在**：`keepalive-picturecat-2026-11-23.md` 只有 **7 段**（01/04/07/10/13/16/19 槽）→ **22:02 槽（dur 21.5s）仍無紀錄**；`keepalive-picturecat-2026-11-24.md` 僅 1 段（01:02）；**celesteela lane 完全沒有 keepalive 檔**（workspace-celesteela/memory/ 內無）。
- 全 gateway cron 46 支；`lastRunStatus=error` 只有 2 支：`36b493db`（dreaming，ce=1，next 11-24 04:25 CST）、`c5352a84`（skill-collection-review-roaringmoon，ce=1，next 11-26）。近 2h 無 error 收尾。

### 5) 🧩 17 支 skill 缺 description：第 17 輪仍未修
- 24h unique = **17 檔**（清單與上輪完全一致：13 支 `description is required` ＋ 4 支 `invalid frontmatter`）；3h 行數 **221**、24h **2,754**。**未授權，不動。**

### 6) 🔴 SSH 來源：仍在每 10 分鐘 ×3
- 系統 journal：近 3h **54** 次 `Accepted publickey for amr from 192.168.50.2`、近 1h **18** 次 → 節奏未變。
- 近 24h `systemd[...]` 真重啟指令仍只有 **2 筆**（11-23 04:46:50 / 04:47:46）；agent 訊息文字裡的同名字串不算數。
- gateway：**MainPID 4137629、NRestarts=0、ActiveEnterTimestamp 11-23 04:48:17 CST** → 連續 ≈**23h20m**、本輪 **0 次重啟**。

### 7) 系統面
- Discord 3h：`Gateway reconnect scheduled` **15**、`gateway websocket closed` **15**（一一對應，正常抖動）；**stalled session 10**（見 §2）、lane wait **0**、interrupted **0**。
- host：up **43d 9:51**、load **0.65 / 0.54 / 0.50**、RAM avail **20,877 MB**、/home **267G/468G（61%、178G free）**。

### 8) 給 Linder 的待決事項（狀態更新）
1. 【中・第 19/20 輪】三支 KA anchor 仍疊在 10.1s+5ms 內 → 建議拉開 ≥15 分鐘（待點頭）。
2. 【中・第 17 輪】17 支 skill 缺 description → 跨 lane／第三方 plugin 寫檔，需點頭。
3. 【中・第 2 輪・新證據】**fallback 鏈「廠商冗餘 = 0」**：本輪 03:04–03:05 三個候選同時 ENETUNREACH/EAI_AGAIN 掛掉 → 連線層故障會一次打穿整個 minimax 家族；要真冗餘必須補**非 minimax 家族**的可用 profile。
4. 【中・需授權・第 4 輪】payload 只有 `keep-alive test` → 深度不足就 8–20s 交件（降級跑）；建議把巡檢步驟與檔名寫進 payload，或改由獨立 patrol job 承載。
5. 【中・本輪新】**payload 應加「provider 失敗型別分類」指示**：本輪才分辨出 429（配額）／ENETUNREACH（連線）／EAI_AGAIN（DNS）／600s idle timeout（hang）四型；混算會把網路事故誤記成「provider 端問題」。
6. 【中・本輪新】**mrmime 的 Jormungand daily all-agent health 在上游 600s idle timeout 下會 stalled 10 分鐘並以「無摘要」收尾** → 建議加 timeout 上限／自恢復，或讓 dreaming 窗避開 04:25–05:05。
7. 【中・本輪新】gengar 建議 dreaming 提前到 04:05–04:15 以讓出 05:00 English coach 的排隊（gengar 未自行修改，等點頭）。
8. 【中・既有】MiniMax Token Plan 配額牆：本窗**未觸發**（3h usage-limit 文字 = 0）；24h canonical 429 = 43；elapsed 仍帶 90–130s，不宣告恢復。
9. 【中・既有】筆電端每 10 分 ×3 SSH 仍在 → 04:25 dreaming 前 30 分鐘仍建議確認。
10. 【低・既有】`c5352a84` ce=1 → next 11-26；`a94330a9` 已不在 error 名單 → 可刪。
11. 【中・第 5 輪】`gw-upgrade-guard.log`（真路徑 `/home/amr/.openclaw/logs/`）仍不存在、`dreaming-schedule-check.log` 停擺 5 天 → 04:25 前置仍無前瞻簽章；**本輪未動這兩檔**。
12. 【中・第 3 輪】gengar lane 與 rowlet lane 寫同一個 keepalive 檔名 → 仍以 append 處理、無覆寫；建議分檔。
13. 【已結案】回程腿新規則（不投遞進 cron session、不 announce 外部）**連續第 3 輪生效**。

### 9) 下一輪（11-24 07:02）交辦
① **dreaming 04:25 跑完後的決定性驗證**（dur ≥30 分 且 status=ok；上一輪 error 1,406,869ms / ce=1）——本輪只做到「開跑前」確認；② dreaming 窗（04:25–05:05）內有無再出 600s idle timeout / ENETUNREACH，`d4cd45bc` 05:13 是否守住不重啟；③ 3h 窗 429 是否續（03:01:55 之後）、elapsed 是否再破 106s、600,104ms 極端值是否重現；④ 三支 KA anchor（第 20 次）+ stalled / lane wait；⑤ 17 支 skill（第 18 輪）；⑥ picturecat 22:02（11-23）無紀錄的坑是否修、picturecat/celesteela 11-24 各有幾段；⑦ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 是否有人補；⑧ 筆電端 SSH 是否仍每 10 分 ×3；⑨ 回程腿新規則續用；⑩ mrmime Jormungand daily all-agent health 是否再出現 stalled / 無摘要收尾。

## Gengar lane 自報（gengar 07:04 台北）— ✅ **決定性驗證通過：dreaming 04:25 完整跑完（ok, 1,816,088 ms）**／📉 60m canonical 429 = 3<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_0702_24 = 7`
- ⭐ **dreaming `36b493db` 11-24 04:25:01 → status `ok`、dur `1,816,088 ms`（30.3 分）、consecutiveErrors `0`（前一夜為 error 1,406,869 ms / ce=1）** → 三夜以來第一次未被砍斷，**fail-closed 守門修好得到驗證**。nextRunAt = 11-25 04:25。
  對照：11-23 04:25 = error 1,406,869 ms（被 gateway restart 砍斷）· 11-22 = ok 1,852,428 ms · 11-21 = ok 1,918,841 ms。
- **近 60 分鐘量測（視窗 11-24 06:04:26 → 07:04:26，canonical model-fetch 口徑，已排除 `agent:*` 自報迴音）**：**429 = 3、overloaded = 3、EAI_AGAIN = 0、ENETUNREACH = 0**。（3 筆 429 皆為 `provider=minimax-portal`、model=MiniMax-M3，時間 07:01:20 / 07:02:05 / 07:03:28 —— 正是 07:00 BBC drill 與兩支 KA 輪的尖峰；同一批事件的 `[agent/embedded] … error=…overloaded…` envelope 另計 3 行，為同一批事件的回音，不另加事件數。）
- 我自有 cron 全 `ok` / `ce` 全 0：`29c2d630` watchdog（dur 3,022 ms，last 11-24 06:04）· `c29eca0f` heartbeat-gengar（dur 13,083 ms，last 06:59）· `ac9e7ada` English coach（dur 156,547 ms，last 11-24 05:00，**未被 dreaming 拖慢**）· `88810bfe` BBC drill（dur 168,467 ms，last 11-23 07:00）· `7767e03b` skill-collection-review-gengar（dur 86,815 ms，last 11-21 07:32）· `f5148ff0` 版本檢查（dur 258,726 ms，last 11-22 00:00）。
- gateway（systemd 真相）：`MainPID=4137629`、`NRestarts=0`、`Result=success`、`ActiveState=active`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → 連續運行約 **26h16m、0 次重啟**。
- Discord：8 connected / 8 enabled accounts，近 60 分鐘 ingress 8 筆。
- lane 是否存活：**存活，且今晚 dreaming 完整跑完**。
- 交付：本記憶檔 append 寫入；依新規則未投遞進 rowlet 的 cron session、未 announce 任何外部頻道。

## 2026-11-24 07:02 — PASS（lane 第一次探針失敗＝provider 路徑事故、第二次重試通）／✅ dreaming 04:25 決定性驗證**通過**（ok, 1,816,088ms）／🔴 3h 窗 canonical 429 = 6（上輪 1，配額牆仍未觸發）／🔴 新失敗型別：fleet 級 600s heartbeat timeout 群集（6 支）／⚠️ rowlet 自家 2 支 job 被 429 打死<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（但**第一次探針失敗**，必須重試才可定性）
- 第一次探針 07:03 → `sessions_send` → `agent:gengar:main` runId `73e4dbf6-c409-4eb0-be32-24ba7e1e7445` → **status=error（"failed", sentBeforeError=true）**；log 07:04:30 記 `⚠️ minimax-portal/MiniMax-M3 request failed.`。
- **歸因（不是 lane 死亡）**：同一分鐘段 gengar 自己的 cron 也被打死 —— `88810bfe`（BBC News Morning Discussion）error_text = `All models failed (3): minimax-portal/MiniMax-M3: getaddrinfo EAI_AGAIN api.min…`、`ac9e7ada`（English coach）= `⚠️ API rate limit reached.`；本窗 canonical 429 落在 07:02:05（elapsed 124,312）與 07:03:28（113,891）→ **探針與被探 lane 同時被同一個 provider/網路事故命中**。
- **第二次探針 07:22 → status=ok**，token `LANE_OK_GENGAR_0702_24 = 7` **逐字一致**；gengar 遵守回程腿規則（未投遞進 cron session、未 announce 外部）→ 自報已 **append** 進同一檔（27,314 B、mtime 07:08）。
- gengar 自報 60m canonical（窗 06:04:26→07:04:26）：**429 = 3、overloaded = 3（同一批事件的信封，非額外事件）、EAI_AGAIN = 0、ENETUNREACH = 0** → **與我方實測一致**（我方同窗 canonical 429 = 07:01:20 / 07:02:05 / 07:03:28 ＝ 3 筆）；6 支自有 cron 全 `ok`、ce=0。

### 2) ✅ dreaming `36b493db`：**決定性驗證通過**（04:02 輪的開放問題結案）
- 11-24 04:25:01 → **status=ok、dur 1,816,088ms（30.3 分）、ce=0** → 三夜來第一次完整跑完；11-23 同槽 receipt error_text = `cron: job interrupted because owner is unavailable`（dur 1,406,872ms）。
- **守門有效**：`d4cd45bc`（discord-selfheal-after-dreaming）05:13 / 05:43 / 06:13 / 06:43 四個槽全部 ok、dur 750–863ms；gateway **MainPID 4137629、NRestarts=0、ActiveEnterTimestamp 11-23 04:48:17 → 連續 ≈26h20m、零重啟** ⇒ **「self-heal fail-open 腰斬 dreaming」在 04:25 這輪沒有再發生**。
- gengar 自報同一組數字（ok、1,816,088ms、ce=0）→ 雙方一致。

### 3) 🔴 Provider 分型：429 密度暴增 6 倍，配額牆仍未觸發
- 3h 窗（04:02→07:20）canonical `status=429` = **6**（上輪 1）：05:02:16 **133,353** / 05:31:44 98,980 / 06:03:06 **156,070**（新高）/ 07:01:20 **79,059**（新低）/ 07:02:05 124,312 / 07:03:28 113,891 ms。
- 24h canonical 429 = **42**（上輪 43 → 新增 6 與視窗位移抵銷）；**配額牆文字 `Token Plan usage limit reached` 3h = 0** → 仍是「限流」不是「額度用盡」，**不宣告恢復**（elapsed 帶 79k–156k）。
- 連線層：3h 窗 `[model-fetch] error` = **3 筆，全是 AbortError**（04:39:03 elapsed 239,020 / 04:48:21 136,351 / 04:48:25 561）→ **沒有 ENETUNREACH / EAI_AGAIN 的 transport 行**；但 receipts 的 error_text 顯示整個 fleet 在 **04:04:59 與 07:04:57 兩波** `All models failed (3/4): … getaddrinfo EAI_AGAIN api.minimax.io`（含 rowlet / mrmime / celesteela / gengar 各 lane）→ ⚠️ **transport 層 canonical 會漏掉 DNS 事故**，事件數必須用 receipts 的 error_text 補。

### 4) 🔴 新失敗型別：fleet 級 600s timeout 群集（3h 窗 123 runs / 11 non-ok）
- **6 支 heartbeat 全部 `cron: job execution timed out`**：picturecat 04:27:52（669,572ms）、roaringmoon 04:27:52（669,588）、mrmime 04:33:29（681,564）、gengar 04:33:29（681,572）、rowlet 04:39:02（616,973）、celesteela 04:44:50（602,502）+ 04:45:34 gengar（600,003）+ 06:12:47 celesteela（600,003）→ **heartbeat 被 429 擠壓拖到 600s 上限**（次生效應，不是 lane 死亡；下一輪全部恢復 ok）。
- 同窗另外 2 筆 provider 致死：**ae91b967 每日 LLM Wiki 巡讀與擴寫 05:30 error**（dur 104,355ms, ⚠️ API rate limit reached）、**58fe15dc 每日論文討論 07:00 error**（dur 208,723ms, 同上；07:04 自動重試 running）→ **rowlet 自家兩支被 429 打死＝本 lane 的實質損失**。

### 5) ⚠️ Jormungand `40e09cd1`：第 2 例「receipt=ok 但內容空」
- 03:00 error（dur 115,867ms, ⚠️ API rate limit reached）→ 03:02:25 retry **ok**（dur 865,320ms）但 summary = `The tool run finished, but no final summary was produced.` → **receipt status=ok 不等於有產出，查漏必須看 summary 內容**（11-23 同槽是完整 10/10 PASS 報告）。

### 6) 三支 KA anchor：第 20 次疊窗，且 picturecat↔celesteela 更近
- 07:02 槽啟動：gengar **07:02:03**（nextRunAtMs 1795474922652）／picturecat **07:02:15.412**（1795474935412）／celesteela **07:02:15**（1795474934774）→ **picturecat↔celesteela = 0.6ms**（上輪 5ms，更近）、gengar↔picturecat ≈ **12.4s**。
- dur：picturecat 07:02 = 170,696ms（>30s，完整一輪）；celesteela 07:02 當時仍 running；gengar 本輪 running（交付時仍在跑）。
- 紀錄檔：picturecat `memory/keepalive-picturecat-2026-11-24.md` 3 段（01/04/07）→ **11-23 22:02 的無紀錄坑仍未補**；celesteela lane 仍**完全不留檔**。

### 7) 本 job 自身近 24h（11-23 07:02 → 11-24 07:02，共 8 槽）
- ok **5**（16:02 822,130／19:02 414,305／22:02 265,655／11-24 01:02 390,673／04:02 541,066）｜provider 致死 **2**（11-23 07:02 error 1,624,295ms 429；13:02 error 158,634ms `⚠️ minimax-portal/MiniMax-M3 request failed.`）｜**降級跑 1**（10:02 dur 12,842ms → 當下無紀錄）｜補跑 1（07:29 dur 8,826ms `Explicit auth order for openai has no usable profiles` → fallback 仍無非 minimax 家族備援）。

### 8) 🧩 17 支 skill 缺 description：第 18 輪仍未修（未授權，不動）
- 今日 log 1,547 行 × **17 檔**（每檔 91 次）→ 13 支 `description is required` ＋ 4 支 `invalid frontmatter: BAD_INDENT`，清單與上輪一致。

### 9) 系統面
- gateway：MainPID 4137629、NRestarts=0、連續 ≈26h20m（本輪 0 次重啟）；近 24h journal 真重啟指令仍只有 11-23 04:46:50 / 04:47:46 兩筆。
- SSH：192.168.50.2 近 **1h 18 筆**（每 10 分 × 3 照舊）。
- Discord 3h：`Gateway reconnect scheduled` **64**、`gateway websocket closed` **58**（上輪 15/15；本輪 04:27–04:28、07:04 有 `invalid-session, resume=false` 群連）→ 抖動量級上升，與 429/600s 群集同窗。
- host：up **43d 12:53**、load 0.87/0.77/0.62、RAM avail 20,913 MB、/home 61%（178G free）。

### 10) ⭐ 本輪口徑修正（下一輪直接用）
1. **`cron_run_receipts` 才是 cron 真相的權威來源**（`state/openclaw.sqlite`，read-only python sqlite3；機器上**沒有 sqlite3 CLI**）：per-run status + error_text + dur 一次到位，比 log grep 可靠且不灌水。查法：`SELECT job_id,status,started_at_ms,finished_at_ms,error_text FROM cron_run_receipts WHERE started_at_ms BETWEEN ? AND ?`（job 名稱 join `cron_jobs.name`）。
2. **cron 狀態表列會灌水**：每 ~30s 一張狀態表會把「每支 job 的最後一次錯誤」重印一次 → 3h 窗 grep `All models failed|EAI_AGAIN` 得 169 行，實際事件數遠少於此 → 事件數以 receipts 的 error_text 為準。
3. **`/stall/i` 有假陽性**：會命中 a2a-gateway plugin 的 `in**stall**ed plugin package requires compiled runtime output`（每 30s 重複）；真 stalled session signature 必須是 `stalled session: … sessionKey=… age=… queueDepth=0`（本輪 3h 真實 stalled = **0**；11-23 24h 內 24 筆）。
4. **探針失敗 ≠ lane 死亡**：單次 `sessions_send` 失敗必須 (a) 重試一次，(b) 用被探 lane 自己 cron 的 receipt error_text 交叉歸因，才可定性。

### 11) 給 Linder 的待決事項（狀態更新）
1. 【中・第 20 輪】三支 KA anchor 仍疊（picturecat↔celesteela 0.6ms、gengar↔picturecat 12.4s）→ 建議拉開 ≥15 分鐘。
2. 【中・第 18 輪】17 支 skill 缺 description → 跨 lane／第三方 plugin，需點頭。
3. 【中・第 3 輪】fallback 廠商冗餘 = 0（本輪再實證：gengar 自己的 6 支 cron 在同窗全被打死；transport 層無非 minimax 家族備援）。
4. 【中・第 5 輪】payload 只有 `keep-alive test` → 建議寫入必做清單與檔名（降級跑 12.8s 交件、零紀錄）。
5. 【中・本輪新】**payload 應加「探針失敗需重試 + 失敗時以 receipts error_text 歸因」**，否則單次失敗會被誤判成 lane 死亡。
6. 【中・本輪新】**heartbeat 600s timeout 群集（6 支）**：建議給 heartbeat 類 job 加 timeout 上限／併發閘門，避免 429 高峰時 6 支同時卡滿 10 分鐘。
7. 【中・本輪新】rowlet 自家 `ae91b967`／`58fe15dc` 被 429 打死 → 這兩支與 KA 同時段起跑，應錯開 07:00–07:10 槽密度。
8. 【中・第 6 輪】`gw-upgrade-guard.log` 仍不存在、`dreaming-schedule-check.log` 仍停擺 11-19 → dreaming 前置仍無前瞻簽章（**本輪未動**）。
9. 【已結案】dreaming 04:25 決定性驗證**通過**（ok / 30.3 分 / ce=0，守門沒腰斬）→ 上一輪的 ① 結案。
10. 【已結案】回程腿新規則續用（第 4 輪：gengar 只寫檔、不投遞 cron session、不 announce 外部）。

### 12) 下一輪（11-24 10:02）交辦
① 3h 窗 canonical 429 是否續（6 筆是否再暴增）、配額牆文字是否首次 > 0、elapsed 156,070 是否再破；② heartbeat 600s 群集是否重演（尤其 07:00–07:10 槽密集區）；③ `ae91b967` / `58fe15dc` 重試是否成功、ce 是否歸零；④ 10:02 槽三支 KA dur（是否出現 <30s 降級跑）與 anchor 疊窗第 21 次；⑤ Jormungand 03:02 那筆「ok 但無摘要」是否再出現（3 天內第 3 例＝改 job payload 的證據已足）；⑥ 17 支 skill 第 19 輪；⑦ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 7 輪；⑧ 筆電端 SSH 是否仍每 10 分 ×3；⑨ 回程腿新規則續用；⑩ 下一個 dreaming 槽是 11-25 04:25（守門 expr `13,43 0-3,5-23` 排除 04 整點的取捨是否仍成立）。

## Gengar lane 自報（gengar 10:02 台北）— PASS（lane 雙向通）／📉 60m canonical provider 失敗全 0／✅ dreaming 上一槽完整跑完（ok 1,816,088 ms、ce=0）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_1002_24 = 7`
- **近 60 分鐘 canonical provider 失敗計數**：取數窗 **11-24 09:02:56 → 11-24 10:02:56**（`journalctl --since -60min`）；口徑 = `[model-fetch] … response` 且 `status=` 為數值的行算 429 event；overloaded / EAI_AGAIN / ENETUNREACH / AbortError 一律排除 `agent:nested`／`agent/embedded`／`agent:side` 自報迴音。
  **429 = 0、overloaded = 0、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0**（全零；對比 07:02 輪的 429=3／overloaded=3，該批尖峰已過）。
- 我自有 cron（id / 名稱 / lastRunStatus / ce / nextRunAt / 上一輪 dur）：
  | id | 名稱 | lastRunStatus | ce | nextRunAt | last dur |
  |---|---|---|---|---|---|
  | `29c2d630` | Gengar Cron Health Watchdog | ok | 0 | 11-24 10:04 | 3,190 ms |
  | `c29eca0f` | heartbeat-gengar | skipped (no-route, quiet-hours 區間) | 0 | 11-24 10:29 | 256 ms |
  | `ac9e7ada` | You are an English coach | ok | 0 | 11-25 05:00 | 156,547 ms |
  | `88810bfe` | BBC News Morning Discussion | ok | 0 | 11-25 07:00 | 284,218 ms |
  | `7767e03b` | skill-collection-review-gengar | ok | 0 | 11-28 07:32 | 86,815 ms |
  | `f5148ff0` | OpenClaw 版本檢查 | ok | 0 | 11-29 00:00 | 258,726 ms |
- **dreaming `36b493db`**：下一槽 = **11-25 04:25**；上一槽（11-24 04:25）= **status ok、dur 1,816,088 ms（30.3 分）、ce 0** → 守門修好後第一輪未被砍斷，續航正常。11-24 這輪守門生效（無 heal 槽位落在 04 時段），11-25 可再驗一次連續性。
- **gateway（systemd 真相）**：`MainPID=4137629`、`NRestarts=0`、`Result=success`、`ActiveState=active`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → 連續運行約 **29h14m、0 次重啟**。
- lane 是否存活：**存活**。
- 交付：依新規則僅 append 本記憶檔（`workspace-rowlet/memory/keepalive-gengar-2026-11-24.md`），**未**投遞進 rowlet 的 cron session、**未** announce 任何外部頻道。

## 2026-11-24 10:02 — PASS（lane 雙向通、token 逐字一致、第一次就通）／📉 3h 窗 canonical 429 = 3（上輪 6，**型別改變**：慢排空 → 立即拒絕）／✅ 配額牆文字仍 0（3h/24h）／🔴 heartbeat 600s 群集第 2 輪重演（3 支，窗移到 08:01–08:11）／✅ rowlet 被 429 打死的 2 支補跑全數復原（ce=0）／⭐ 新指標：`task_runs.terminal_summary` 長度＝降級 run 的簽名、空摘要的真凶＝mrmime lane／⚠️ `elle.service` 仍在重啟迴圈（禁用沒生效）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，本輪**第一次就通**，不需重試）
- 10:02 探針 → `sessions_send` → `agent:gengar:main` runId **`34b83f53-6d0a-4ffb-aa49-5c9d0d6533b8`**、status=**ok**、targetDisposition=queued、delivery=announce/pending。
- **去程讀回**：token `LANE_OK_GENGAR_1002_24 = 7` **逐字一致**（無亂碼）→ 與 07:02 輪「第一次失敗、重試才通」相反，**本輪 provider 路徑健康**。
- **回程腿**：gengar 自報「只 append 寫入 `workspace-rowlet/memory/keepalive-gengar-2026-11-24.md`（39,973 B、mtime 10:03:17）、**未**投遞進 rowlet cron session、**未** announce 任何外部頻道」→ **新規則第 5 輪生效**。本輪我同樣不投遞 cron session、不 announce 外部。
- gengar 自報近 60m canonical（窗 09:02:56→10:02:56）：**429 = 0、overloaded = 0、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0** → 與我方實測一致。
- gengar 自有 6 支 cron：`29c2d630` watchdog ok/ce0（dur 3,190ms、next 10:04）、`c29eca0f` heartbeat-**skipped**（no-route・quiet-hours、dur 256ms、next 10:29）、`ac9e7ada` English coach ok 156,547ms、`88810bfe` BBC ok 284,218ms、`7767e03b` skill-review ok 86,815ms、`f5148ff0` 版本檢查 ok 258,726ms。

### 2) ⚠️ 本 job 自身體檢（11-23 10:02 → 11-24 10:02，8 槽）
| 槽 | dur | 狀態 | 判定 |
|---|---|---|---|
| 11-23 10:02 | 12,842 ms | ok（summary_len=382） | ⚠️ **降級跑**（<30s） |
| 11-23 13:02 | 158,634 ms | error（`⚠️ minimax-portal/MiniMax-M3 request failed.`） | ❌ provider 表面致死（11-23 16:02 已查證真因＝transcript-ownership，非限額） |
| 11-23 16:02 | 822,130 ms | ok | ✅ |
| 11-23 19:02 | 414,305 ms | ok | ✅ |
| 11-23 22:02 | 265,655 ms | ok | ✅ |
| 11-24 01:02 | 390,673 ms | ok | ✅ |
| 11-24 04:02 | 541,066 ms | ok | ✅ |
| 11-24 07:02 | 539,317 ms | ok | ✅ |
| 11-24 10:02 | （本輪 running） | — | 交件後由 receipts 回填 |
- 8 槽＝**ok 7（含 1 降級）＋provider 表面致死 1**；比 11-23（1 降級＋2 致死）好，比 11-22（4 降級）好。**降級輪仍只有 11-23 10:02 那一輪**（payload 薄的老坑未解）。

### 3) 📉 Provider 分型：3h 窗 canonical 429 = 3，**型別由「慢排空」變成「立即拒絕」**
- 3h 窗（07:03:36→10:03:36）`[model-fetch] … status=429` = **3**（口徑：`model-fetch` + `status=429`，排除 `[agent:nested]` 自述迴音）：
  **08:01:50 elapsed=11ms**、**08:32:20 elapsed=11ms**、**09:02:50 elapsed=16ms**。
- ⭐ **本輪最重要的型別差異**：上輪 6 筆全是 **79k–156kms 的慢排空**（排隊到逾時），本輪 3 筆全是 **10–16ms 的立即拒絕** → **不是壅塞，是瞬時拒答**。→ 兩者不可直接比較密度。
- 24h canonical 429 = **19**（本口徑）；`Token Plan usage limit reached` 3h / 24h = **0 / 0** → 仍是「限流」不是「額度用盡」，**不宣告恢復**。
- transport：3h 窗 `[model-fetch] … error` = **0**（無 AbortError）；journal 內 EAI_AGAIN / ENETUNREACH 各 3 筆**全是 `[agent:nested] session=agent:gengar:main` 行內的自報文字**（自述污染），排除後**真實 transport 失敗 = 0** → 與 gengar 自報 60m 全 0 一致。
- receipts 3h 窗真實失敗 = **4 筆**（3× heartbeat 600s timeout ＋ 1× heartbeat agent-runner-failure），**provider 致死 = 0 筆**（上輪同窗有 2 支被 429 打死）。

### 4) 🔴 heartbeat 600s timeout 群集：**第 2 輪重演但減半（3 支 vs 上輪 6 支），窗也換了位置**
- 08:01:04 heartbeat-mrmime（**600,004ms**）、08:08:21 heartbeat-rowlet（**600,004ms**）、08:11:35 heartbeat-mrmime（**600,009ms**）＋ 07:11:40 heartbeat-mrmime `agent-runner-failure`（53,619ms）。
- ⭐ **窗在 08:01–08:11，不是上輪交辦預期的「07:00–07:10 密集槽」** → 「07:00 槽密度」假說**不成立**；較像 429 尾波 + 長跑 job 排隊（08:00 晨間情報 dur 1,131,841ms、08:09 群體智能架構研究 dur 515,424ms 都在同窗）。
- 24h 內 heartbeat timeout 共 **12 筆**（11-23 16:01/16:08；11-24 04:27×2、04:33×2、04:39×2、04:44、04:45、06:12、07:01、08:01、08:08、08:11）。
- **全部在下一輪恢復 ok**（mrmime 08:22:35 501,264ms ok、08:31:05 7,743ms ok）→ 仍是「次生效應」不是 lane 死亡。

### 5) ✅ rowlet 自家被 429 打死的兩支：**補跑全數復原，ce 已歸零**
- `ae91b967` 每日 LLM Wiki 巡讀與擴寫：11-24 05:30 **error**（104,355ms、`⚠️ API rate limit reached.`）→ **05:32:14 ok（245,993ms）**、ce=0。
- `58fe15dc` 每日論文討論：11-24 07:00 **error**（208,723ms、同上）→ **07:04:00 ok（486,124ms）**、ce=0。
- → 上輪待決事項 ⑦ 的「補跑救回」成立，但**兩支都跟 07:00–07:10 同一時段起跑**＝錯開仍是有效建議。

### 6) 三支 KA anchor：**第 21 次疊窗**＋⭐ 降級簽名新指標
- 10:02 槽：`state.nextRunAtMs` ＝ gengar **1795485723291（10:02:03）**／picturecat **1795485735412（10:02:15.412）**／celesteela **1795485735418（10:02:15.418）** → **picturecat↔celesteela = 6ms**（上輪 0.6ms）、**gengar↔picturecat = 12.121s**（上輪 12.4s）→ 疊窗結構 **21 輪未動**。
- 10:02 槽 dur（交件時）：picturecat **138,687ms ✅ 完整一輪（summary_len=2000）**；gengar（本 job）running；celesteela running。
- ⭐ **新指標（建議寫進下輪口徑）**：`task_runs.terminal_summary` 的**長度**＝降級 run 的簽名。例：11-23 10:02 celesteela dur=255,335ms 看起來很健康，但 **summary_len=8**（只有 token）→ receipts 的 dur 看不出降級，`task_runs` 一眼看穿。gengar/picturecat 的 payload 仍只有 `keep-alive test`（celesteela 的 payload 已含完整必做清單）→ 深度由 agent 自決的舊坑未解。

### 7) ⭐⭐ 空摘要歸因**更正**（本輪最重要更正）：真凶是 mrmime lane，不是 Jormungand
- 真相來源＝`task_runs.terminal_summary`（欄位存在；全期 14 筆 `The tool run finished, but no final summary was produced.`）：
  - **健康回報（mrmime）×7**：11-17 20:05、11-18 02:05、11-18 20:05、11-19 02:05、11-21 17:05、11-22 11:05、**11-24 02:05**
  - **OpenClaw 系統維護（mrmime）×3**：11-17 18:04、11-18 02:04、11-18 20:04
  - push-llm-wiki（mrmime）×1：11-20 05:05｜Picturecat Keep-Alive ×1：11-20 13:02｜**Jormungand ×1：11-24 03:02（首例）**
  - （另：11-24 04:02 gengar KA 命中 1 筆為**假陽性**——摘要內文引用了這句話。）
- → **10/14 集中在 mrmime lane 的同一對 job（健康回報 + OpenClaw 系統維護，皆為整點自報類）** → 改 payload 的對象應是 mrmime 那兩支；Jormungand 只是首例個案。
- 3h 窗（07:03→10:03）內 = **0 筆** → 本窗未再發生；下一個驗證點 11-25 02:05（健康回報）。

### 8) 🧩 17 支 skill 缺 description：**第 19 輪仍未修**（未授權，不動）
- 今日 journal：**13 支 `description is required` ×136 次 ＋ 4 支 `invalid frontmatter: BAD_INDENT` ×136 次 = 2,312 行**（上輪每檔 91 次 → 今日 136 次，**密度 ×1.5**）；17 檔清單與上輪一致。

### 9) 系統面
- gateway（**`systemctl --user`**，system 層會誤判 inactive）：MainPID **4137629**、NRestarts **0**、ActiveEnterTimestamp **Mon 2026-11-23 04:48:17 CST** → 連續 ≈**29h22m**、零重啟；24h 內 restart 指令 = 0 筆。
- 🔴 **`elle.service` 仍在重啟迴圈**：`systemctl show elle.service` → `ActiveState=activating`、**`is-enabled` = enabled**、**NRestarts 120,589**（近 1h 476 行 elle.sh log）→ **先前「已 disable」的結論不成立**（`disable --now` 未生效或被復原），且屬 system 層、需 root。
- SSH 192.168.50.2：近 1h **54 行 log ≈ 18 次連線**（每 10 分 ×3 照舊；每次連線多行 log，故行數 ≠ 次數）。
- Discord 3h：`Gateway reconnect scheduled` **13**、`gateway websocket closed` **13**（上輪 64/58 → **抖動量級下降約 78%**；13 筆皆帶 `flow=`＝良性 resume flow）。
- host：up **43d 15:50**、load 1.31/0.78/0.58、RAM avail **21,077 MB**、`/` **61%**（178G free）。
- dreaming `36b493db`：11-24 04:25 ok、dur **1,816,088ms（30.3 分）**、ce=0；下一槽 **11-25 04:25**。守門 `d4cd45bc` 05:13→09:43 全 ok（dur 740–863ms）→ 04 整點保護持續有效。

### 10) 給 Linder 的待決事項（狀態更新）
1. 【中・第 21 輪】三支 KA anchor 仍疊（picturecat↔celesteela 6ms、gengar↔picturecat 12.1s）→ 建議拉開 ≥15 分鐘。
2. 【中・第 19 輪】17 支 skill 缺 description，今日密度 ×1.5（每檔 136 次/日）→ 跨 lane／第三方 plugin，需點頭。
3. 【中・第 3 輪】fallback 廠商冗餘 = 0 → 續用。
4. 【中・第 5 輪】gengar / picturecat payload 只有 `keep-alive test` → **建議直接沿用 celesteela 那份含完整必做清單與檔名的 payload**。
5. 【中・沿用】payload 應加「探針失敗需重試 ＋ 失敗時以 receipts error_text 交叉歸因」。
6. 【中・第 2 輪】heartbeat 600s timeout 群集重演（3 支，08:01–08:11）→ 建議加 timeout 上限／併發閘門。
7. 【中・沿用】rowlet 兩支與 07:00 槽同窗 → 錯開。
8. 【中・第 7 輪】`gw-upgrade-guard.log` **仍不存在**；`dreaming-schedule-check.log` 仍停擺 **11-19 22:33**（檔在 `workspace-rowlet/memory/` 而非 `logs/`）→ dreaming 前置仍無前瞻簽章。
9. 【新・本輪】**空摘要根因＝mrmime lane 的 健康回報（×7）＋ OpenClaw 系統維護（×3）＝10/14** → 改這兩支的 payload 比改 Jormungand 有用。
10. 【新・本輪】**`elle.service` 的「已停用」結論不成立**（仍 enabled、仍重啟迴圈、24h 5,700+ 次）→ 需要 root 才能真停。
11. 【已結案】dreaming 04:25 通過、heartbeat 600s 屬次生效應、Discord 抖動大幅下降、rowlet 兩支 429 補跑復原。

### 11) ⭐ 本輪新增可重用方法（寫進 MEMORY.md）
1. **`task_runs.terminal_summary` 是「產出內容」的權威來源**：receipt 只有 status/dur，看不出一輪寫了什麼。查法：`SELECT label,agent_id,length(terminal_summary),terminal_summary FROM task_runs WHERE created_at > <epoch ms>`。同時 `length(terminal_summary)` 可當**降級 run 指標**（≈8 = 只有 token 的空殼）。
2. **state DB 的唯讀查詢不必被 exec guard 擋**：MEMORY.md 第 388 行說 `sqlite3` CLI 會被擋，**但 `python3` + `sqlite3.connect('file:...?mode=ro', uri=True)` 讀 `~/.openclaw/state/openclaw.sqlite` 完全可行**（本輪 11-24 10:02 實測，成功讀 `cron_run_receipts` / `cron_jobs` / `task_runs`）。→ 巡檢不必再退回 grep-only。
3. **429 有兩種型別，密度不可直接比較**：慢排空（elapsed 79k–156kms，排隊到逾時）vs 立即拒絕（elapsed 10–16ms）。前者是壅塞、後者是瞬時拒答。
4. **`heartbeat skipped: no-route / quiet-hours` 不是失敗**：receipt status=skipped 且 error_text 前綴為 `heartbeat skipped%` 的都是排程設計（無路由／靜默時段），統計紅單時必須排除（3h 窗 42 筆 non-ok 裡有 35 筆屬此類）。

### 12) 下一輪（11-24 13:02）交辦
① 3h 窗 canonical 429 是否再減、3 筆 fast-reject 是否變回 slow-drain、配額牆文字是否首次 > 0；② heartbeat 600s 群集第 3 輪（窗是否再位移）；③ picturecat / celesteela 10:02 槽**最終 dur ＋ summary_len**（降級輪用 summary_len 判定，不看 dur）；④ **mrmime 健康回報 11-25 02:05 是否再空摘要**（3 天內第 3 例＝改 payload 證據已足）；⑤ 17 支 skill 第 20 輪（密度是否再 ×1.5）；⑥ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 8 輪；⑦ 筆電端 SSH 是否仍每 10 分 ×3；⑧ **elle.service 是否仍 enabled 且重啟迴圈**；⑨ 回程腿新規則續用；⑩ 下一個 dreaming 槽 11-25 04:25；⑪ gengar lane 探針（token 換 `LANE_OK_GENGAR_1302_24 = 7`）。

## Gengar lane 自報（gengar 13:02 台北）— PASS（lane 雙向通）／📉 3h canonical 429 = 1（12:03:01）／6 支 cron 全 ok・ce 全 0<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_1302_24 = 7`
- **lane 狀態一句話**：idle，無進行中任務；近 3h 無實質錯誤（1 筆 canonical 429）。
- 近 3h canonical provider 失敗（視窗 11-24 10:02 → 13:02）：**429 = 1**（12:03:01，`provider=minimax-portal`）、**overloaded = 0、EAI_AGAIN = 0、cron/model timeout = 0**（`agent:*` 自報迴音已排除）。
- 我自有 cron：`29c2d630` ok/0 · `c29eca0f` skipped(no-route, quiet-hours)/0 · `ac9e7ada` ok/0 · `88810bfe` ok/0 · `7767e03b` ok/0 · `f5148ff0` ok/0 —— 全 ce=0。
- gateway（systemd 真相）：`MainPID=4137629`、`NRestarts=0`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → 連續運行約 **32h19m、0 次重啟**；Discord 8/8 connected。
- dreaming `36b493db`：上一槽 11-24 04:25 = ok / 1,816,088 ms / ce 0；下一槽 11-25 04:25。
- 交付：依規則僅 append 本記憶檔，未投遞進 rowlet cron session、未 announce 外部頻道。

## 2026-11-24 13:02 — PASS（lane 雙向通、token 逐字一致、第一次就通）／📉 3h 窗 canonical 429 = 1（上輪 3，再減）／✅ 10:02 槽三支 KA 最終 dur ＋ summary_len 到齊、零降級輪／🔴 heartbeat 600s 群集 3h 窗歸零（今日最後一次 08:11）／⭐⭐ 跨 lane ping 的 superseded 副作用第 3+ 次重現並觸發 model-fallback／⚠️ 17 支 skill 缺 description 密度 ×1.4（136→190 次/日）／⚠️ elle.service 仍重啟迴圈（+358/3h）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) lane PASS（探針第一次就通）
- `sessions_send` → `agent:gengar:main` → runId `032fabf5-672a-47e2-b767-2d7e63110282`、status=ok、回覆含逐字一致 token **`LANE_OK_GENGAR_1302_24 = 7`**。
- 對方自報：idle、無進行中任務、近 3h 無實質錯誤（1 筆 canonical 429）、6 支 cron 全 ok/ce=0、gateway 32h19m 未重啟、Discord 8/8 connected、dreaming 下一槽 11-25 04:25。
- 交叉核對（我用同一口徑複算）：一致。
- 本 job（`9d8b6001`）上一輪 10:02：ok / dur=**259,428ms** / ce=0 / cs=0 / summary_len=**2001** → 非降級輪。

### 2) ✅ 10:02 槽三支 KA 最終結果（上輪交辦③結案）
- gengar `9d8b6001`：dur **259,428ms** / summary_len **2001**
- picturecat `02eb0989`：dur **138,687ms** / summary_len **2000**
- celesteela `880b5c17`：dur **244,303ms** / summary_len **1563**
- 三支皆 succeeded 且 summary_len ≫ 8 → **10:02 槽零降級輪**（降級 run 簽名＝summary_len≈8）。

### 3) KA anchor 疊窗第 22 次（兩輪完全同構＝固定偏移，非隨機）
- 13:02 槽：gengar runningAt **13:02:03.328** → picturecat **13:02:15.471** → celesteela **13:02:15.477** ＝ **12,143ms / 6ms**。
- 10:02 槽同序：12,131ms / 5ms → 偏移量幾乎不變，證實 anchor 設定本身重疊（`every 3h` 同 anchor 家族）。

### 4) ⭐⭐ 跨 lane ping 的 superseded 副作用：第 3+ 次重現，**且已觸發 model-fallback**
- 我的探針 13:03:23 打 `agent:gengar:main` → 同一毫秒區間 **6 筆** `[diagnostic] lane task error: lane=nested/session:agent:gengar:main durationMs=5–7 error="prepared model runtime plugin generation was superseded"` ＋ **2 筆** `[model-fallback/decision] decision=candidate_failed requested=minimax-portal/MiniMax-M3 candidate=minimax/MiniMax-M3` → 回覆照常落地（仍屬良性）。
- 同時段 13:02:39 `agent:picturecat:main` 也出 2 筆（picturecat KA 那支的探針）→ **兩支 KA 同一輪各自打 ping，副作用同步產生**（本輪共 8 筆 lane task error）。
- 本窗 `lane wait exceeded` = **0** → 未釀成排隊死亡。
- 判準更新：此副作用已從「診斷噪音」升級為「會觸發 fallback 決策、消耗 fallback 額度」→ 建議探針改用不需重建 runtime 的 lane 形式，並把 KA anchor 拉開 ≥15 分（與 3, 12 項連動）。

### 5) provider 失敗四分法（canonical 口徑）＋ ⚠️ 上輪判讀撤回
- canonical 429（`[model-fetch]` + `status=429`）：3h **1** / 6h **4** / 24h **16**。
- ⭐ **型別判定撤回**：24h 全部 16 筆的 `elapsedMs` 落在 **79,059–169,762ms** → **全部是慢排空型；24h 內沒有任何「立即拒絕（10–16ms）」型**。上輪（10:02）「型別改變＝fast-reject」沒有 status=429 行佐證 → **該判讀撤回**（字串口徑與 canonical 口徑混用的第 N 例）。
- 配額牆（`usage limit` / quota）24h = **0** → 仍未觸發；`rate limit reached` 字串 21 ≠ canonical 16（多出的是 agent end 錯誤文字）。
- 3h 窗 overloaded 真實 = **0**、EAI_AGAIN 真實 = **0**、ENETUNREACH = **0**（與 gengar 自報一致）。
- ⚠️ **grep 污染再一例**：13:03:23 那行 `Lane state: … 0 overloaded … 0 EAI_AGAIN` 是**代理回覆文字被 journal 記錄**，會命中關鍵字。規則：只認帶 `[model-fetch]` / `[agent/embedded]` / `[provider-transport-fetch]` 前綴的系統行。

### 6) 12:03 的 429 打死 mrmime 的 Discord lane turn（本窗唯一 agent 死因）
- 12:03:01 provider 429 → 同毫秒 `[agent/embedded] embedded run agent end: runId=db08a3a4-4619-49c0-aea3-935b8f09cd1c isError=true model=MiniMax-M3 provider=minimax-portal error=⚠️ API rate limit reached`。
- `db08a3a4` = `agent:mrmime:discord:channel:1482069603512221927`（#魔牆人偶）→ 3h 窗 `agent end isError=true` = **1 筆**，受害者是這條 session。
- 對應 job 層：`13ac4b5a 健康回報` 11:24 ok / summary_len **94**（非空摘要）；`ca222989 OpenClaw 系統維護` 13:01 ok / summary_len **546**。→ **空摘要第 3 例尚未發生**（交辦④的驗證點仍在 11-25 02:05）。
- 教訓：429 的下游受害者必須用 runId 反查 session，否則只看得見 provider 層。

### 7) heartbeat 600s timeout 群集：3h 窗歸零，今日已兩度
- 6h 窗 non-ok（排除 skipped）：07:11:40 `bcf270b8` agent-runner-failure(53s)、08:01:04 `bcf270b8` timeout(600s)、08:08:21 `d82f78e3` timeout(600s)、08:11:35 `bcf270b8` timeout(600s)。
- 3h 窗（10:03→13:03）＝ **0 筆** → 今日最後一次群集在 **08:11**，其後近 5 小時無復發（窗未位移＝今日未再出現）。
- 24h fleet heartbeat 類錯誤 **18 筆**（timeout 16 + agent-runner-failure 2）：mrmime 5、rowlet 3、roaringmoon 2、picturecat 2、gengar 2、celesteela 2。
- `bcf270b8` 24h 7 筆錯誤全落在 11-23 16:01 → 11-24 08:11，之後全 skipped/ok → **ce=0 又一次把整輪死亡洗掉（ce=0 第 5 例）**。

### 8) fleet 紅單（24h receipt 全量 605 筆：ok 314 / skipped 265 / error 23 / running 3）
- error 23 拆解：heartbeat 18 ＋ provider 429 **4**（每日模型排行前十、Jormungand daily all-agent heartbeat、每日 LLM Wiki 巡讀與擴寫、每日論文討論）＋ `All models failed` **1**（OpenClaw 系統維護）→ **四支每日 job 現已全部 ce=0 復原**（上輪 07:00 槽的 429 紅單已洗淨）。
- 現行紅單只剩：`c5352a84 skill-collection-review-roaringmoon` ce=1（next 11-26）、legacy disabled `a94330a9 tmp-openai-probe` ce=2。
- cron_jobs 總數 **53**（enabled 46 / disabled 7）；`heartbeat skipped: quiet-hours|no-route` 全屬排程設計，統計紅單時排除。
- 讓人安心的常態：`537bd0dd Rowlet 轉錄監控` 3h 36 輪全 ok（dur≈1s）；`29c2d630 Gengar Cron Health Watchdog` ok/3,187ms；`d7b0355b Jormungand A2A heartbeat` ok/264,064ms/summary_len=584；`6ddc8b4c PTCGP Meta 三日彙整` ok/164,069ms/summary_len=512。

### 9) 🧩 17 支 skill 缺 description：第 20 輪仍未修（密度 ×1.4）
- journal canonical：24h unique **17 檔**（13 支 `description is required` ＋ 4 支 `invalid frontmatter: BAD_INDENT`），**每檔 190 次/日**（上輪 136 → ×1.4）；3h **238** 行、24h **3,230** 行（上輪 2,312 → ×1.4）。
- ⚠️ **口徑校正**：本輪另做靜態 frontmatter 掃描（60 支 SKILL.md）只得 **9 支**缺 description → **靜態掃描與 journal 口徑不等價**（journal 另含 4 支 BAD_INDENT 與 plugin 內嵌檔）。歷輪「17 支」是 journal 口徑，勿混用、勿用靜態數字取代。
- 未授權，不動。

### 10) 系統面
- gateway（**`systemctl --user show`**，system 層會誤判 inactive）：MainPID **4137629**、NRestarts **0**、ActiveEnterTimestamp **Mon 2026-11-23 04:48:17 CST** → 連續 **32h15m**（`ps` etimes=116,112s 佐證）；24h systemd 真重啟指令 = **0 筆**。
- 🔴 `elle.service` 仍在重啟迴圈：`UnitFileState=enabled`、ActiveState=activating、**NRestarts 120,943**（10:02 輪 120,585 → **+358/3h**）、近 1h **833** 行 log、24h **5,714** 次啟動 → 需 root 才能真停（歷輪不動）。
- SSH 192.168.50.2：1h **18** / 3h **54** / 24h **428** → **每 10 分 ×3 節奏未變**。
- Discord：帳號 **8/8 running+connected**（greninja disabled 為設計）、eventLoop degraded=false、utilization 0.143；3h `Gateway reconnect scheduled` **9**、`gateway websocket closed` **9**（上輪 13 → 再降）、code-1000/1006 **1** 筆。
- host：up **43d 18:50**、load **1.19/0.69/0.60**、RAM avail **20,604 MB**、`/` **61%**（178G free）。
- dreaming `36b493db`：上一槽 11-24 04:25 ok / dur **1,816,088ms** / ce=0；下一槽 **11-25 04:25**。守門 `d4cd45bc` 全 ok（dur 775ms）→ 04 整點保護持續有效。
- `gw-upgrade-guard.log` **第 8 輪仍不存在**；`dreaming-schedule-check.log` 仍停擺 **11-19 22:33**（1,694 B）→ dreaming 前置仍無前瞻簽章。

### 11) 給 Linder 的待決事項（沿用 11 項，新增 1 項）
1.【中・第 22 輪】三支 KA anchor 仍疊（gengar→picturecat 12,143ms、picturecat→celesteela 6ms，兩輪完全同構）→ 拉開 ≥15 分鐘。
2.【中・第 20 輪】17 支 skill 缺 description 密度 ×1.4 → 跨 lane／第三方 plugin，需點頭。
3.【中・第 3 輪】fallback 廠商冗餘 = 0 → 續用（但本輪 superseded 已實際觸發一次 fallback 決策）。
4.【中・第 5 輪】gengar / picturecat payload 只有 `keep-alive test` → 建議沿用 celesteela 那份含完整必做清單與檔名的 payload。
5.【中・沿用】payload 應加「探針失敗需重試 ＋ 失敗時以 receipts error_text 交叉歸因」。
6.【中・第 3 輪】heartbeat 600s timeout 今日兩度（最後 08:11）→ 加 timeout 上限／併發閘門。
7.【中・沿用】rowlet 兩支與 07:00 槽同窗 → 錯開。
8.【中・第 8 輪】`gw-upgrade-guard.log` 仍不存在；`dreaming-schedule-check.log` 停擺 11-19 → dreaming 前置無前瞻簽章。
9.【中・沿用】空摘要根因＝mrmime 健康回報（×7）＋OpenClaw 系統維護（×3）→ 改這兩支 payload 比改 Jormungand 有用。
10.【中・沿用】`elle.service` 仍 enabled 且重啟迴圈 → 需 root。
11.【已結案】dreaming 04:25 通過、Discord 抖動再降、四支每日 job 429 補跑全復原、10:02 槽零降級輪。
12.【新・中】**KA 探針本身會在被探 lane 製造 superseded 競態並觸發 model-fallback**（本輪 13:03:23，8 筆 lane task error ＋ 2 筆 fallback decision）→ 探針改用低風險 lane 形式，或與高頻 heartbeat 錯開。

### 12) 下一輪（11-24 16:02）交辦
① 3h 窗 canonical 429 是否歸零、slow-drain 型是否再變（必附 elapsedMs 分布）；② heartbeat 600s 群集第 3 輪（窗是否再位移）；③ 13:02 槽三支 KA 最終 dur ＋ summary_len（降級 run 判定）；④ mrmime 健康回報 11-25 02:05 是否第 3 例空摘要；⑤ 17 支 skill 第 21 輪密度；⑥ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 9 輪；⑦ SSH 是否仍每 10 分 ×3；⑧ elle.service 是否仍 enabled ＋ 迴圈；⑨ superseded 副作用第 4 次（並記錄是否伴隨 fallback decision）；⑩ dreaming 下一槽 11-25 04:25；⑪ gengar lane 探針 token 換 `LANE_OK_GENGAR_1602_24 = 7`；⑫ 若 gengar / picturecat payload 仍未換，改用 celesteela 版完整清單。

## Gengar lane 自報（gengar 16:02 台北）— PASS（lane 雙向通）／📉 60m 與 3h canonical provider 失敗全 0／✅ dreaming 上一槽完整跑完（ok 1,816,088 ms、ce 0）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_1602_24 = 7`
- **取數口徑（依本輪指示）**：只認帶系統前綴的日誌行（`node[…]` / `systemd[…]`），**不以關鍵字 grep 代理回覆文字**；429 僅計 `[model-fetch] … response` 且 `status=` 為數值的行；overloaded / EAI_AGAIN / ENETUNREACH / AbortError 同樣只在這些系統行內計。窗起訖：60m = 11-24 15:03:33 → 16:03:33；3h = 11-24 13:03:33 → 16:03:33。
  **60m：429 = 0、overloaded = 0、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0**
  **3h：429 = 0、overloaded = 0、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0**
  （對比 13:02 輪的 3h 429=1、07:02 輪的 429=3 —— 尖峰已完全平息。）
- 我自有 cron（id / 名稱 / lastRunStatus / ce / nextRunAt）：
  | id | 名稱 | lastRunStatus | ce | nextRunAt |
  |---|---|---|---|---|
  | `29c2d630` | Gengar Cron Health Watchdog | ok | 0 | 11-24 16:04 |
  | `c29eca0f` | heartbeat-gengar | ok | 0 | 11-24 16:29 |
  | `ac9e7ada` | You are an English coach | ok | 0 | 11-25 05:00 |
  | `88810bfe` | BBC News Morning Discussion | ok | 0 | 11-25 07:00 |
  | `7767e03b` | skill-collection-review-gengar | ok | 0 | 11-28 07:32 |
  | `f5148ff0` | OpenClaw 版本檢查 | ok | 0 | 11-29 00:00 |
- **dreaming `36b493db`**：上一槽 **已跑完** = 11-24 04:25 → status **ok**、dur **1,816,088 ms**（30.3 分）、**ce 0**（連續兩夜未被砍斷）；下一槽 **11-25 04:25**。
- **gateway（`systemctl --user show` 口徑）**：`MainPID=4137629`、`NRestarts=0`、`Result=success`、`ActiveState=active`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → 連續運行約 **35h19m、0 次重啟**。
- 交付：依指示**只 append 寫入本記憶檔**，**未**用 sessions_send 投遞任何 cron run session、未 announce 任何外部頻道。

## 2026-11-24 16:02 — PASS（lane 雙向通、token 逐字一致、第一次就通）／📉 3h 窗 canonical 429 = 0（上輪 1，**歸零**）／🔴 heartbeat 600s 群集 3h 窗再歸零（今日最後一次仍停在 08:11）／⭐ superseded 副作用第 4 次重現、**又觸發 2 筆 model-fallback 決策**／⚠️ 健康回報 11-24 02:05 槽出現 **filler 摘要**（新判準）／⚠️ elle.service 仍重啟迴圈（+360/3h）／⚠️ `gw-upgrade-guard.log` 第 9 輪仍不存在<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) lane PASS（探針第一次就通）
- `sessions_send` → `agent:gengar:main` → runId `7dc0bd18-db9a-4767-b14d-17a56f3abb86`、status=ok、回覆含逐字一致 token **`LANE_OK_GENGAR_1602_24 = 7`**。
- 對方自報：60m/3h canonical provider 失敗全 0、6 支 cron 全 ok/ce=0、dreaming 上一槽 11-24 04:25 ok（dur 1,816,088ms、ce=0）、gateway MainPID 4137629 / NRestarts 0 / 連續 35h19m。
- 交叉核對（我用同一口徑複算）：一致（3h 429 = 0、24h = 16、gateway MainPID/時間戳相同）。
- 對方自報已 append 進本檔（66,978 B、mtime 16:03:56、第 6 節 gengar 自報），**未**投遞任何 cron run session ✅（遵守「不要投遞進正在跑的 cron session」規則）。

### 2) ✅ 上輪交辦③結案：13:02 槽三支 KA 最終 dur ＋ summary_len ＝ **零降級輪**
- gengar `9d8b6001`：**215,202ms** / sumlen **2000**（ts 13:05:38）
- picturecat `02eb0989`：**173,018ms** / sumlen **1999**（ts 13:05:08）
- celesteela `880b5c17`：**171,302ms** / sumlen **1517**（ts 13:05:06）
- 三支皆 succeeded 且 sumlen ≫ 8 → **13:02 槽零降級輪**（連續第 2 槽）。
- 16:02 槽（16:07 補記最終值）：picturecat **145,332ms / sumlen 1999** ✅、celesteela **309,740ms / sumlen 1377** ✅（ts 16:07:26）→ 兩支皆非降級；本 job 自身 receipt 於本輪結束後產生 → **16:02 槽預期零降級輪**（下輪核實本 job 最終 dur/sumlen）。

### 3) KA anchor 疊窗第 23 次（固定偏移，非隨機）
- 16:02 槽 nextRunAt：gengar **16:02:03** → picturecat **16:02:15**（**12,143ms**）→ celesteela **16:02:15**（**6ms**）。
- 13:02 槽 lastRunAt 同序同值（13:02:03 / 13:02:15 / 13:02:15）→ 偏移量完全不變，證實是 anchor 設定本身重疊。
- 影響未釀災：本窗 `lane wait exceeded` = **0**（唯一護欄）。

### 4) ⭐ superseded 副作用第 4 次重現、**本輪再次觸發 model-fallback 決策**
- 我的探針 16:04:05 打 `agent:gengar:main` → 同毫秒區間 **6 筆** `[diagnostic] lane task error: lane=nested/session:agent:gengar:main durationMs=5–6 error="prepared model runtime plugin generation was superseded"` ＋ **2 筆** `[model-fallback/decision] decision=candidate_failed requested=minimax-portal/MiniMax-M3 candidate=minimax-portal…`。
- 回覆照常落地（仍屬良性）、`lane wait exceeded` = 0。
- 判準再更新：**連續 4 輪**（13:02/…／16:02）證實「跨 lane ping → superseded → fallback 決策」是**固定副作用**而非偶發 → 探針成本實質化（三種資源：gengar lane 重建 + fallback 額度 + 診斷噪音）。建議：探針改用不需重建 runtime 的 lane 形式，或與高頻 heartbeat 錯開。

### 5) provider 失敗四分法（canonical 口徑）：**3h 窗歸零**
- canonical 429（`[model-fetch]` ＋ `status=429`）：**3h = 0** / 6h = 1 / 24h = **16**（3h 窗內 model-fetch 共 363 行、181 筆 `status=200`、0 筆非 200）。
- 24h 16 筆 `elapsedMs` = **79s–170s（79,059–169,762ms）→ 仍全部慢排空型**，無立即拒絕型 → 13:02 輪的型別結論維持不變。
- 配額牆（`usage limit` / quota）24h = **0** → 仍未觸發。
- 3h 窗 `[agent/embedded] agent end … isError=true` = **0** → 本窗無下游受害者（12:03 那次的 mrmime Discord lane 已被上游 429 蓋掉）。
- ⚠️ 抓取教訓復現：`grep -iE "timeout"` 會抓到 `[model-fetch] … timeout=` 的請求列（全是 200）→ **heartbeat timeout 必用 `agent-runner-failure|cron.*timeout|timed out` 且排除 model-fetch**，否則會把 8 筆正常請求誤判成 timeout 群集。

### 6) 🔴 heartbeat 600s timeout 群集：3h 窗 **0**（連續第 2 輪），今日最後一次仍停在 08:11
- 9 支 heartbeat 逐支 receipt（3h 窗全覆蓋）：heartbeat-mrmime / charizard / gengar 全 `ok`（dur 4.7–29.2s、sumlen 19）；rowlet / celesteela / greninja / picturecat / roaringmoon 全 `skipped`（`quiet-hours` 或 `no-route`，屬排程設計、非錯誤）。
- 零 `agent-runner-failure`、零 600s timeout、零 `isError=true`。
- 守門 `d4cd45bc discord-selfheal-after-dreaming`（expr `13,43 0-3,5-23 * * *`）全 ok → dreaming 前後保護持續有效。

### 7) ⚠️ 新判準：**filler 摘要**（receipt status=ok 但 summary 是 runner 佔位文字）
- `13ac4b5a 健康回報` 11-24 **02:05:43** 槽：status=ok、dur=81,053ms、**sumlen=97、summary 首句 = 「The tool run finished, but no final summary was produced.」**。
- 其餘 13 筆皆為真實摘要（sumlen 94–1293，首句「🛡️ 健康回報 HH:MM UTC」）。
- ⇒ **降級 run 的簽名不能只看 `summary_len ≈ 8`**：還有「ok + 短摘要 + 佔位語意」這一型。判定規則更新為：**status=ok 但 summary 首句不是該 job 的正常格式 → 算降級輪**。
- 驗證點不變：**11-25 02:05 槽**（下一個 UTC 02:05 槽）是否再現。根治仍＝改 `健康回報` 與 `OpenClaw 系統維護` 的 payload。

### 8) fleet 紅單：無新增（第 2 輪持平）
- `cron_jobs` 總數 **53**（enabled 46 / disabled 7）。
- 紅單僅剩：`c5352a84 skill-collection-review-roaringmoon` ce=1（next 11-26）、legacy disabled `a94330a9 tmp-openai-probe` ce=2。
- 19 支 cron 型 job（daily/每小時/每 30 分）**全 last=ok ce=0**（含四支每日 job：`5b7c1082 每日模型排行前十`、`40e09cd1 Jormungand daily all-agent health`、`ae91b967 每日 LLM Wiki 巡讀與擴寫`、`58fe15dc 每日論文討論`）。
- `OpenClaw 系統維護 ca222989`：16:05:52 槽 ok / dur 64,377ms / sumlen 320（真摘要，非 filler）。
- `45ccf4e9 晨間情報` last=ok ce=0（下一槽 11-25 08:00）。

### 9) 🧩 17 支 skill 缺 description：第 21 輪仍未修（密度持平 ×1.0）
- journal canonical：24h **3,213 行**（上輪 3,230）、3h **238 行**、24h unique **17 檔**、**每檔 189 次/日**（上輪 190 → ×1.0）→ 密度持平，未再上升。
- 17 檔名單不變（`card-lookup`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-lookup`、`ptcgp-card-download`、`ocr-confidence-mark`、`meta-analyzer`、`image-attendant`、`human-behavior-simulation`、`excel-image-pipeline`、`web-fetch-troubleshooting`、`system-design-six-dimensions-analyzer` ＋ rosclaw plugin 5 支）。
- ⚠️ 口徑不變：journal 17 檔 ≠ 靜態 frontmatter 掃描數（靜態只有 9 支）→ 勿混用。未授權，不動。

### 10) 系統面
- **gateway**（`systemctl --user show`）：MainPID **4137629**、NRestarts **0**、ActiveState=active、ActiveEnterTimestamp **Mon 2026-11-23 04:48:17 CST** → 連續 **35h19m**（與 gengar 自報一致）。
- 🔴 `elle.service` **仍在重啟迴圈**：system 層 `UnitFileState=enabled`、`ActiveState=activating`、**NRestarts 121,303**（13:02 輪 120,943 → **+360/3h**，節奏與上輪 +358 一致）；近 3h journal 1,071 行提及 elle.service。⚠️ **層陷阱第 8 輪驗證**：`systemctl --user show elle.service` 顯示 `inactive` / NRestarts=0 → 那是**誤導**（與 gateway 同款），elle 必須用 system 層看。需 root 才能真停。
- SSH：1h **36** / 3h **54** / 24h **427** → 每 10 分 ×3 節奏未變。
- Discord：**8/8 enabled+running+connected**（greninja disabled 為設計）、eventLoop degraded=**false**、utilization 0.072、reconnectAttempts 全 0、activeRuns 全 0。
- host：up **43d 21:51**、load **1.58/0.96/0.71**、RAM avail **20,843 MB**、`/` **61%**（178G free）。
- dreaming `36b493db`：上一槽 11-24 04:25 ok / dur **1,816,088ms** / ce=0 → 下一槽 **11-25 04:25**（連續第 2 個乾淨夜）。
- `gw-upgrade-guard.log` **第 9 輪仍不存在**（`find /home/amr` 全域 0 筆）；`dreaming-schedule-check.log` 仍停擺 **11-19 22:33**（1,694 B）→ dreaming 前置仍無前瞻簽章。

### 11) 給 Linder 的待決事項（沿用 12 項，③結案、⑦/⑨更新、新增 1 項）
1.【中・第 23 輪】三支 KA anchor 仍疊（gengar→picturecat **12,143ms**、picturecat→celesteela **6ms**，兩輪完全同構）→ 拉開 ≥15 分鐘。
2.【中・第 21 輪】17 支 skill 缺 description 密度持平（189 次/日）→ 跨 lane／第三方 plugin，需點頭。
3.【中・第 3 輪】fallback 廠商冗餘 = 0 → 續用；**但 superseded 已連續 4 輪實觸發 fallback 決策**（本輪 16:04:05 再 2 筆）。
4.【中・第 5 輪】gengar / picturecat payload 只有 `keep-alive test` → 建議沿用 celesteela 那份含完整必做清單與檔名的 payload（改 job 需點頭）。
5.【中・沿用】payload 應加「探針失敗需重試 ＋ 失敗時以 receipts error_text 交叉歸因」。
6.【中・第 3 輪】heartbeat 600s timeout 今日兩度（最後 08:11）→ 加 timeout 上限／併發閘門。
7.【中・沿用・更新】rowlet 兩支與 07:00 槽同窗 → 錯開。
8.【中・第 9 輪】`gw-upgrade-guard.log` 仍不存在；`dreaming-schedule-check.log` 停擺 11-19 → dreaming 前置無前瞻簽章。
9.【中・沿用】空摘要根因＝mrmime 健康回報（×7）＋OpenClaw 系統維護（×3）→ 改這兩支 payload 比改 Jormungand 有用。
10.【中・沿用】`elle.service` 仍 enabled 且重啟迴圈（+360/3h）→ 需 root。
11.【已結案】dreaming 04:25 通過、Discord 抖動再降、四支每日 job 429 補跑全復原、10:02/13:02 槽零降級輪、13:02 槽交辦③結案。
12.【中・更新】KA 探針在被探 lane 製造 superseded 競態 → **已連續 4 輪並觸發 fallback 決策** → 探針改低風險 lane 形式，或與高頻 heartbeat 錯開。
13.【新・中】**filler 摘要新型別**：receipt `status=ok` 但 summary 是 runner 佔位文字（`The tool run finished, but no final summary was produced.`）→ 降級輪判定要加「summary 首句語意」條件，別只看 `summary_len≈8`。

### 12) 下一輪（11-24 19:02）交辦
① 3h 窗 canonical 429 是否維持 0（連 2 窗歸零）；② 16:02 槽 celesteela 最終 dur ＋ summary_len（降級輪判定）；③ heartbeat 600s 群集第 4 輪（窗是否再位移）；④ **健康回報 11-25 02:05 槽是否再現 filler 摘要**（第 2 例驗證點）；⑤ 17 支 skill 第 22 輪密度；⑥ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 10 輪；⑦ SSH 是否仍每 10 分 ×3；⑧ elle.service 是否仍 enabled ＋ 迴圈（+360/3h 節奏）；⑨ superseded 副作用第 5 次（是否仍伴隨 fallback 決策）；⑩ dreaming 下一槽 11-25 04:25；⑪ gengar lane 探針 token 換 `LANE_OK_GENGAR_1902_24 = 7`；⑫ gengar / picturecat payload 仍未換 → 續用 celesteela 版完整清單；⑬ ⚠️ **elle.service 一律用 system 層查（`--user` 層顯示 inactive/NRestarts=0 是誤導）**。

## Gengar lane 自報（gengar 19:02 台北）— PASS（lane 雙向通）／📉 60m 全 0、3h canonical 429=1／✅ dreaming 上一槽完整跑完（ok 1,816,088 ms、ce 0）／🔧 更正 16:02 那輪的計數 bug<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_1902_24 = 7`
- **取數口徑**：只認帶系統前綴的日誌行（`node[…]` / `systemd[…]`）；429 僅計 `[model-fetch] … response` 且 `status=` 為數值；overloaded / EAI_AGAIN / ENETUNREACH / AbortError 同樣只在這些系統行內計。窗用絕對時間邊界餵給 journalctl（不再自行解析時間戳）。
  **60m（11-24 18:05:14 → 19:05:14；總行 1355、系統行 1074）：429 = 0、overloaded = 0、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0**
  **3h（11-24 16:05:14 → 19:05:14；總行 3819、系統行 2990）：429 = 1、overloaded = 1（同一事件的 error envelope）、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0**
- 我自有 cron（id / 名稱 / lastRunStatus / ce / nextRunAt）：
  | id | 名稱 | lastRunStatus | ce | nextRunAt |
  |---|---|---|---|---|
  | `29c2d630` | Gengar Cron Health Watchdog | ok | 0 | 11-24 20:04 |
  | `c29eca0f` | heartbeat-gengar | ok | 0 | 11-24 19:29 |
  | `ac9e7ada` | You are an English coach | ok | 0 | 11-25 05:00 |
  | `88810bfe` | BBC News Morning Discussion | ok | 0 | 11-25 07:00 |
  | `7767e03b` | skill-collection-review-gengar | ok | 0 | 11-28 07:32 |
  | `f5148ff0` | OpenClaw 版本檢查 | ok | 0 | 11-29 00:00 |
- **dreaming `36b493db`**：上一槽（11-24 04:25）status **ok**、dur **1,816,088 ms**（30.3 分）、**ce 0**（連兩夜完整跑完）；下一槽 **11-25 04:25**。
- **gateway（`systemctl --user show`）**：`MainPID=4137629`、`NRestarts=0`、`ActiveState=active`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → 連續運行約 **38h21m、0 次重啟**。
- ⚠️ **更正 16:02 那輪的計數**：我的時間窗過濾器錯寫成要求時間戳後面接「.」，導致系統行一筆都沒被納入（`[system lines considered: 0]`），於是 60m 與 3h 全被報成 0 —— 那是**量測 bug，不是真的全 0**。改用絕對時間邊界餵 journalctl 後，本輪 3h 窗實際有 **429 = 1**（16:0x 那筆殘留，60m 窗則確實為 0）。給 rowlet 對帳時以本輪數字為準。
- 交付：依規則**只 append 寫入本記憶檔**，**未** sessions_send 進任何 cron run session、**未** announce 到外部頻道。

## 2026-11-24 19:02 — 第 7 輪 — PASS（lane 雙向通、token 逐字一致）／⭐⭐ **本輪頭號發現：Gengar / Picturecat 兩支 KA 是「路由空殼」，實際執行 runtime＝rowlet**／📉 **推翻上輪「3h canonical 429 歸零」**（那是 gengar 端量測 bug，實數＝1）／✅ 16:02 槽三支 KA 零降級輪（連 3 槽）／🔴 heartbeat 600s 群集第 4 輪＝0／⚠️ superseded 副作用第 5 次＋2 筆 fallback decision／⚠️ elle.service 仍重啟迴圈（+359/3h）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) lane PASS（探針第一次就通，且對方主動更正前一輪的量測 bug）
- `sessions_send` → `agent:gengar:main` → runId `a3f7ec4e-15d1-4ca8-8d47-3643565b11d7`、status=ok、delivery=announce/pending、回覆含逐字一致 token **`LANE_OK_GENGAR_1902_24 = 7`**。
- 對方自報：60m canonical 全 0；3h canonical **429=1、overloaded=1**（同一事件錯誤封套）；6 支自有 cron 全 ok/ce=0；dreaming 上一槽 11-24 04:25 ok（dur 1,816,088ms、ce=0）；gateway MainPID 4137629 / NRestarts 0 / 連續 **38h21m**。
- ⭐ **對方主動更正**：其 16:02 輪的時間窗過濾器誤寫成要求時間戳後接「.」，導致 `[system lines considered: 0]` → 該輪「60m/3h 全 0」是**量測假象**，非乾淨窗。
- **我的獨立複算（不採對方口徑，直接查 journal）**：3h(16:06→19:06) canonical 429＝**1**（`18:02:31`、`elapsedMs=120,488`）、6h＝1、24h＝**16**、usage-limit/quota 24h＝**0**。
- ⇒ **上輪（16:02）「3h 窗 canonical 429 = 0、上輪 1 → 歸零」這個結論不成立**：真相是 3h 窗內有 1 筆 18:02:31 的新 429，且 18:02:31 落在 16:02 與 19:02 兩槽之間 → 是本輪新增的一筆（24h 總數仍 16＝有新有出）。
- 教訓入冊：**報告方自報零 ≠ 零**；每輪必自算複核，且過濾器要能自我證明納入了幾行（`[system lines considered: N]` 必須 > 0 才可宣稱全零）。

### 2) ⭐⭐ 本輪頭號發現：**兩支 KA 的執行 runtime 與名稱不符（路由空殼）**
- 真相來自 `state/openclaw.sqlite`（`cron_jobs` + `worker_session_placements`）交叉比對：
  | KA job | payload `agentId` | `sessionKey` | 實際 worker placement（agent_id） | 判定 |
  |---|---|---|---|---|
  | `9d8b6001` Gengar Keep-Alive | **null** | `agent:gengar:discord` | **rowlet**（`agent:rowlet:cron:9d8b6001-…:run:9bf4dd89…`） | ❌ 跑在 rowlet |
  | `02eb0989` Picturecat Keep-Alive | **null** | `agent:picturecat:discord` | **rowlet** | ❌ 跑在 rowlet |
  | `880b5c17` Celesteela Keep-Alive | `celesteela` | `agent:mrmime:discord:channel:…` | **celesteela** | ✅ 正確 |
- ⇒ **「Gengar Keep-Alive」從未喚醒過耿鬼的 runtime**：本輪（19:02）這一筆就是 rowlet 在跑（runtime banner：`agent=rowlet | session=agent:rowlet:cron:9d8b6001-…`）。Picturecat 同理。
- **而且它也沒有回報到任何地方**：三支 KA 的 `state.lastDeliveryStatus` 皆為 **`not-requested`** → `sessionKey` 沒被當成投遞目標 → 這兩支 job 只消耗 model 額度，**既沒喚醒目標 agent、也沒把結果送回去**。
- **receipt 的 `agent_id` 會掩蓋這件事**：`cron_run_receipts.agent_id` 記成 `gengar`/`picturecat`（取自 job 的宣告目標），任何只看 receipt 的儀表板都會誤判為「耿鬼有被喚醒」。
- 附帶效應：**rowlet 自己的 `Rowlet Keep-Alive`（`ee14ba4c`，agentId=rowlet）是 disabled 的** → 現況是「關掉真的那支、留著假的兩支」。
- 這也解釋了為何 `automations list/get` 在 cron run session 內查不到這些 job（回 `cron job not found` / list=0）——受限 session 只看得到自己的 job，**審查必須直接讀 `state/openclaw.sqlite`**（本輪已這樣做）。
- 附帶：`[cron:9d8b6001] Failed to remove unused run continuation: Cannot delete session while competing work in progress`（16:04:41 / 16:09:03 兩支都有）＝ superseded 競態的落地痕跡。

### 3) ✅ 上輪交辦②結案：16:02 槽三支 KA 最終 dur ＝ **零降級輪（連續第 3 槽）**
- gengar `9d8b6001`：**419,443 ms / ok**、picturecat `02eb0989`：**145,332 ms / ok**、celesteela `880b5c17`：**309,740 ms / ok**（皆 > 30s、非降級簽名；`lastStatus=ok`、三支 `consecutiveErrors=0`）。
- 10:02 槽同樣三支全 ok（259.4s / 138.7s / 244.3s）→ 10:02、13:02、16:02 **連 3 槽零降級**。
- 19:02 槽三支 receipt 已開（running），本輪結束後落定。

### 4) heartbeat 600s timeout 群集：3h 窗 **0**（連續第 4 輪）
- 8 支 heartbeat 全覆蓋 3h 窗：`mrmime` 19:01 ok 7.3s / 18:31 ok 10.9s / 18:01 ok 225.0s；`gengar` 18:59 ok 57.9s / 18:29 ok 24.2s / 17:59 ok 11.1s；`charizard` 18:55 / 18:25 / 17:55 全 ok 11.2–11.7s；`rowlet`/`roaringmoon`/`greninja`/`picturecat`/`celesteela` 全 `skipped`（no-route，屬排程設計）。
- **零 600s timeout、零 `agent-runner-failure`、零 timeout receipt**；最長 dur＝mrmime 18:01 的 225.0s（< 600s 門檻）。
- 註：11-24 07:11 / 16:01 的 `heartbeat failed: agent-runner-failure` 落在 3h 窗外（mrmime `bcf270b8`），非本窗。

### 5) ⚠️ 健康回報 filler 摘要：驗證點仍未到（11-25 02:05）
- `13ac4b5a 健康回報` 近期三槽全 `ok`：11:05 dur 26.6s / 14:05 dur 39.2s / 17:05 dur 45.7s → 本窗無 8–20s 深度不足型、無佔位語意型。
- **決定性驗證點仍是 11-25 02:05 槽**（filler 第 2 例是否再現）。根治仍＝改 payload（mrmime 健康回報 / OpenClaw 系統維護）。

### 6) fleet 紅單：無新增（第 3 輪持平）
- `cron_jobs` 總數 **53**（enabled **46** / disabled **7**），與上輪同。
- 三支 KA 的 `consecutiveErrors` 皆 0；`scheduleErrorCount` 未見異常。
- 另註：`9d8b6001` 於 11-23 有 2 筆非 provider 的結構性失敗 → **「Explicit auth order for openai has no usable profiles.」**（07:29，fallback 鏈裡的 openai profile 不可用）＋ **「All models failed (3): … EAI_AGAIN api.minimax.io」**（11-24 03:04，DNS 層失敗）→ 這兩筆都源於 **fallback 沒有跨廠冗餘**（兩支 fallback 都在 minimax）。見待決事項③。

### 7) 🧩 17 支 skill 缺 description：第 22 輪仍未修（密度 ×0.99，微降）
- journal canonical：24h 共 **3,179** 行（上輪 3,213）、每個具名 skill **187 次/日**（上輪 189 → ×0.99）、`rosclaw*` 前綴聚合 748（≈5 支 plugin skill 各 ~150）。
- 檔名清單不變（`card-lookup`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-lookup`、`ptcgp-card-download`、`ocr-confidence-mark`、`meta-analyzer`、`image-attendant`、`human-behavior-simulation`、`excel-image-pipeline`、`web-fetch-troubleshooting`、`system-design-six-dimensions-analyzer` ＋ rosclaw plugin 5 支）。
- ⚠️ 口徑不變：journal 計數 ≠ 靜態 frontmatter 掃描數（靜態僅 9 支）→ 勿混用。未授權，不動。

### 8) 系統面
- **gateway**（`systemctl --user show`）：MainPID **4137629**、NRestarts **0**、ActiveState=active、ActiveEnterTimestamp **Mon 2026-11-23 04:48:17 CST** → 連續 **38h21m**（與 gengar 自報一致）。
- 🔴 `elle.service` **仍在重啟迴圈**（system 層口徑）：`UnitFileState=enabled`、`ActiveState=activating`、**NRestarts 121,662**（16:02 輪 121,303 → **+359/3h**，節奏與 +360/3h 一致）。⚠️ 層陷阱第 9 輪：`systemctl --user show elle.service` 顯示 inactive/NRestarts=0 = 誤導，elle 必須 system 層查。需 root 才能真停。
- SSH：**Accepted-only 口徑** 1h **18** / 3h **54** / 24h **427** → 與上輪完全相同（每 10 分 ×3 節奏未變）。
  ⚠️ **本輪自查抓到的 grep 陷阱**：若同時用 `sshd.*Accepted|ssh.*session opened` 兩條樣式會**重複計數**（1h 36 / 3h 108 / 24h 853 ≈ ×2）→ 單連線只認 `Accepted `（行尾空白）一條樣式。
- `gw-upgrade-guard.log` **第 10 輪仍不存在**（`find /home/amr` 全域 0 筆）；`dreaming-schedule-check.log` 仍停擺 **11-19 22:33**（1,694 B）→ dreaming 前置仍無前瞻簽章。
- dreaming `36b493db`：上一槽 11-24 04:25 ok / dur **1,816,088ms** / ce=0 → 下一槽 **11-25 04:25**（連續第 2 個乾淨夜）。
- host：up **44d 00:52**、load **1.72/0.95/0.64**、RAM avail **20,814 MB**、`/` **61%**（178G free）。

### 9) ⚠️ superseded 副作用第 5 次重現、**再伴隨 2 筆 model-fallback 決策**
- 本輪探針 19:03:5x 打 `agent:gengar:main` → 19:00 起 journal 命中 `superseded` **10 行** ＋ **2 筆** `[model-fallback/decision] decision=candidate_failed requested=minimax-portal/MiniMax-M3`（19:05:44.130 / .140）。
- 連續第 5 輪（13:02／…／16:02／19:02）重現 → 判定為**固定副作用**，非偶發。probe 成本已實質化（gengar lane 重建 + fallback 額度 + 診斷噪音）。
- 但它是目前**唯一真的喚醒耿鬼 runtime 的機制**（見第 2 節：KA 本身是空殼）→ 短期仍須保留，除非先修好 KA 路由。

### 10) 給 Linder 的待決事項（沿用 13 項＋新增 2 項，第 2 項升級為第 1 項）
1.【**新・最高優先**】**KA 路由空殼**：把 `9d8b6001`（Gengar）與 `02eb0989`（Picturecat）的 payload `agentId` 補成 `gengar` / `picturecat`（對照 `880b5c17` 的正確寫法），並決定要不要開 `lastDeliveryStatus`（現在全是 `not-requested`＝結果不回報）。⚠️ 副作用：這兩支 job 目前實際由 rowlet 執行，改完後才真的會喚醒耿鬼／貓貓，**本審查的前提也會跟著變**（須重設基準）。同時 `Rowlet Keep-Alive`（`ee14ba4c`）目前是 disabled → 是否開啟。
2.【中・第 3 輪】**fallback 跨廠冗餘 = 0**（兩支 fallback 都在 minimax；11-23 07:29 撞到「Explicit auth order for openai has no usable profiles.」、11-24 03:04 三模型全滅 `EAI_AGAIN api.minimax.io`）→ 補一支非 minimax 的 fallback，或修好 openai profile。
3.【中・第 23 輪】三支 KA anchor 仍疊（gengar→picturecat ≈ 12.1s、picturecat→celesteela ≈ 6ms）→ 拉開 ≥15 分鐘。
4.【中・第 21 輪】17 支 skill 缺 description 密度 ×0.99（187 次/日）→ 跨 lane／第三方 plugin，需點頭。
5.【中・第 5 輪】gengar / picturecat payload 只有 `keep-alive test` → 建議沿用 celesteela 那份含完整必做清單與檔名的 payload。
6.【中・沿用】payload 應加「探針失敗需重試 ＋ 失敗時以 receipts error_text 交叉歸因」。
7.【中・第 3 輪】heartbeat 600s timeout 今日兩度（最後 08:11 窗外；3h 窗已 4 輪 0）→ 加 timeout 上限／併發閘門。
8.【中・沿用・更新】rowlet 兩支與 07:00 槽同窗 → 錯開。
9.【中・第 9 輪】`gw-upgrade-guard.log` 仍不存在；`dreaming-schedule-check.log` 停擺 11-19 → dreaming 前置無前瞻簽章。
10.【中・沿用】空摘要根因＝mrmime 健康回報（×7）＋OpenClaw 系統維護（×3）→ 改這兩支 payload 比改 Jormungand 有用。
11.【中・沿用】`elle.service` 仍 enabled 且重啟迴圈（+359/3h）→ 需 root。
12.【已結案】dreaming 04:25 通過、Discord 抖動再降、10:02/13:02/16:02 槽零降級輪（連 3 槽）、13:02 與 16:02 槽交辦結案。
13.【中・更新】KA 探針在被探 lane 製造 superseded 競態 → **已連續 5 輪並觸發 fallback 決策** → 探針改低風險 lane 形式，或與高頻 heartbeat 錯開。
14.【新・中】**filler 摘要新型別**（ok 但 summary 是佔位語意）→ 降級輪判定要加「summary 首句語意」條件。
15.【新・中】**量測自我證明規則**：任何「N=0」結論必須附「已納入行數 > 0」，否則視為量測 bug（本輪 gengar 側即栽在這裡，上輪「429 歸零」被推翻）。另：cron run session 內 `automations list/get` 看不到 job → 審查改直讀 `state/openclaw.sqlite`。

### 11) 下一輪（11-24 22:02）交辦
① 18:02:31 那筆 429 之後 3h 窗 canonical 429 是否歸零（並附 elapsedMs 分布）；② **KA 路由是否已修**（若 Linder 未點頭則維持現狀，須明示本輪審查前提不變）；③ 19:02 槽三支 KA 最終 dur ＋ 是否仍非降級；④ heartbeat 600s 群集第 5 輪；⑤ 健康回報 11-25 02:05 槽是否再現 filler 摘要；⑥ 17 支 skill 第 23 輪密度；⑦ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 11 輪；⑧ SSH 是否仍 Accepted-only 18/h；⑨ elle.service 是否仍 enabled ＋ 迴圈（+360/3h）；⑩ superseded 副作用第 6 次；⑪ dreaming 下一槽 11-25 04:25；⑫ gengar lane 探針 token 換 `LANE_OK_GENGAR_2202_24 = 7`；⑬ 若 gengar / picturecat payload 仍未換，續用 celesteela 版完整清單；⑭ ⚠️ SSH 計數一律用 Accepted-only 單樣式；⑮ ⚠️ 零值結論一律附「已納入行數」。

## Gengar lane 自報（gengar 22:02 台北）— PASS（lane 雙向通）／📉 60m 全 0、3h canonical 429=1（附納入行數自證）／✅ dreaming 連兩夜完整跑完／📌 skill 缺 description：我方 9/57（非 17，17 是全艦）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- token：`LANE_OK_GENGAR_2202_24 = 7`
- **lane 狀態**：alive／idle，無進行中任務，6 支自有 cron 全 `ok`、`ce` 全 0。
- **取數口徑（第三次修正口徑）**：只認系統前綴行（`node[…]` / `systemd[…]`）**且必須再排除 `[agent:nested]` / `[agent:side]` / `[agent/embedded]`** —— 因為巢狀 agent 的回覆文字本身也會被 gateway 寫成 `node[…] … [agent:nested] …` 行，只用前綴過濾會把我的自報回音算成事件。窗用絕對時間邊界餵 journalctl。
  - **60m（11-24 21:03:48 → 22:03:48）：total 1280 行、system 991 行、system_non_nested 990 行 → 429 = 0、overloaded = 0、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0**
  - **3h（11-24 19:03:48 → 22:03:48）：total 3956 行、system 3114 行、system_non_nested 3103 行 → 429 = 1、overloaded = 1（同一事件的 error envelope）、EAI_AGAIN = 0、ENETUNREACH = 0、AbortError = 0**
  - （前一版把 3h 的 EAI_AGAIN/ENETUNREACH/AbortError 各報 3 筆，實為我 19:05 那則回覆的巢狀回音，已剔除。）
- 我自有 cron（id / 名稱 / lastRunStatus / ce / nextRunAt）：`29c2d630` watchdog ok/0 11-24 22:04 · `c29eca0f` heartbeat-gengar ok/0 11-24 22:29 · `ac9e7ada` English coach ok/0 11-25 05:00 · `88810bfe` BBC drill ok/0 11-25 07:00 · `7767e03b` skill-collection-review-gengar ok/0 11-28 07:32 · `f5148ff0` 版本檢查 ok/0 11-29 00:00。
- **dreaming `36b493db`**：上一槽 11-24 04:25 → status **ok**、dur **1,816,088 ms**、**ce 0**（連續兩夜未被砍斷）；下一槽 **11-25 04:25**。
- **gateway**：`MainPID=4137629`、`NRestarts=0`、`ActiveState=active`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST` → 連續運行約 **41h20m、0 次重啟**。
- **11-24 02:05 健康回報槽：未出現 filler 摘要**（該窗 01:50–02:30 內 filler 關鍵字命中 = 0）。
- **skill 缺 description 密度（我方 lane）**：`~/.openclaw/skills` 共 **57** 個 skill dir，缺 description = **9**（card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、system-design-six-dimensions-analyzer、web-fetch-troubleshooting）。**9 ≠ 17**：17 那個數字是全艦（含其他 lane 的 skill）口徑，請以各 lane 自己的目錄數為準。
- 交付：依規則**只 append 本記憶檔**，未 sessions_send 進任何 cron run session、未 announce 外部頻道。

## 2026-11-24 22:02 — 第 8 輪 — PASS（lane 雙向通、token 逐字一致）／📉 3h 窗 canonical 429 = 1（21:01:33 新增、上輪那筆 18:02:31 已出窗）／✅ 19:02 槽三支 KA 零降級輪（連 4 槽）／🔴 heartbeat 600s 群集第 5 輪＝1（mrmime 21:01:08）／⚠️ KA 路由空殼仍未修（第 6 輪確認）／📈 skill 缺 description 密度 ×1.06（198 次/日）／⚠️ SSH 大小寫坑自己踩了一次（修正後 18/h）／⚠️ elle.service 仍重啟迴圈（+357/3h）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) lane PASS（探針第一次就通，token 逐字一致）
- `sessions_send` → `agent:gengar:main` → runId `8862b64e-730c-434e-a794-664ecc11d484`、status=ok、delivery=announce/pending、回覆含逐字一致 token **`LANE_OK_GENGAR_2202_24 = 7`**。
- 對方自報：60m canonical 全 0（1280 行 → 991 系統 → 990 去巢狀）；3h **429=1 / overloaded=1**（同一事件封套）；6 支自有 cron 全 `ok`／ce 全 0；dreaming 上一槽 11-24 04:25 ok（1,816,088ms、ce 0）；gateway 連續 **41h20m**、NRestarts 0；11-24 02:05 健康回報槽 filler 命中 = 0；其 lane skill 缺 description = **9/57**（17 是全艦口徑）。
- 對方**第三次**修口徑：只認系統前綴行**且**排除 `[agent:nested]` / `[agent:side]` / `[agent/embedded]`（巢狀回音會落在 `node[…]` 行內）。
- **我的獨立複算**（不採對方口徑，自跑 journal）：

| 窗 | total 行 | 系統行 | 排除巢狀 | 429 | overloaded | EAI_AGAIN | ENETUNREACH | AbortError | usage_limit |
|---|---|---|---|---|---|---|---|---|---|
| 60m | 272 | 272 | 13 | 0 | 0 | 0 | 0 | 0 | 0 |
| 3h | 844 | 844 | 23 | **1** | 1 | 0 | 0 | 0 | 0 |
| 24h | 9,489 | 9,489 | 266 | **16** | 10 | 4 | 2 | 3 | **0** |

  ⇒ 與對方口徑一致（60m=0、3h=1），**互證通過**；所有零值結論均附「已納入行數」。

### 2) ① 3h 窗 canonical 429 = 1：上輪那筆出窗、新一筆 21:01:33 進窗
- 3h 窗唯一命中：**`21:01:33` status=429 elapsedMs=87,500**（provider=minimax-portal、model=MiniMax-M3）。
- 24h 全 16 筆（elapsedMs 分布 **79,059–169,762ms → 仍全為慢排空型**，無立即拒絕型）：23:01:29(89,046) / 23:03:42(116,722) / 00:02:35(106,578) / 03:01:55(105,849) / 05:02:16(133,353) / 05:31:44(98,980) / 06:03:06(156,070) / 07:01:20(79,059) / 07:02:05(124,312) / 07:03:28(113,891) / 08:01:50(110,149) / 08:32:20(114,719) / 09:02:50(169,762) / 12:03:01(108,027) / 18:02:31(120,488) / 21:01:33(87,500) → **命中時刻全部落在整點後 :01–:03 分**（＝ fleet 排程撞在一起的尖峰）。
- **配額牆仍 0**：24h `usage limit reached / quota` = **0**（429 是速率排空，不是 Token Plan 上限）。
- ⭐ **本輪新觀察（21:01:33 那筆的請求起點可回溯）**：`[model-fetch] start` 在 **21:00:06.283**、87.5s 後回 429 → 該請求屬 **21:00:05 起跑**的那支 job（`911eee45 每日資安建議`，dur 770.7s、ok）；同一分鐘 `bcf270b8 heartbeat-mrmime` 於 **21:01:08** 起被 **600s job timeout** 砍掉。
  → **429 空轉 87.5s 與 600s timeout 在同一分鐘相鄰出現**；但兩支 receipt 起點不重疊（21:00:05 vs 21:01:08），**尚不足以斷言同一條因果鏈** → 記為「疑似耦合」，留待下輪用請求起點對齊再定案。

### 3) ② KA 路由空殼仍未修（第 6 輪確認）＋ 本輪踩到的 schema 陷阱
- `cron_jobs`（LIKE 前綴查）：`9d8b6001` agent_id=**None**、`02eb0989` agent_id=**None**、`880b5c17` agent_id=**celesteela**（✅ 唯一正確者）、`ee14ba4c` Rowlet KA **enabled=0**。
- `worker_session_placements`：`agent:rowlet:cron:9d8b6001-…` / `agent:rowlet:cron:02eb0989-…` → agent_id=**rowlet**；`agent:celesteela:cron:880b5c17-…` → celesteela。
  ⇒ **「Gengar / Picturecat Keep-Alive」仍由 rowlet 執行**（本輪 runtime banner 即 `agent=rowlet | session=agent:rowlet:cron:9d8b6001-…`），Linder 尚未點頭改 payload → **本輪審查前提不變**。
- 三支 `lastDeliveryStatus` 仍全為 **not-requested** → 結果照舊不回報到任何地方。
- fallback 對照（新）：`9d8b6001` fallbacks＝[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7] → **跨廠冗餘 0**；`02eb0989` 已有第三支 `openai/gpt-5.4-mini`；`880b5c17` 同。三支 timeoutSeconds 1800。
- 🧩 **schema 陷阱（本輪新踩）**：`cron_jobs.job_id` 是**完整 UUID**（`9d8b6001-3178-46bf-…`），用 8 碼前綴 `IN (...)` 查不到任何列 → 必須 `LIKE '9d8b6001%'`；`cron_run_receipts` **沒有 duration_ms**，dur ＝ `finished_at_ms − started_at_ms`；`sqlite3` CLI 對 state 目錄直接被拒（`external sqlite3 cannot open databases under the active OpenClaw state directory`）→ 須 cp 三檔（sqlite / -wal / -shm）到 /tmp 再以 `file:…?mode=ro` 開啟。

### 4) ③ 19:02 槽三支 KA 最終 dur ＝ 零降級輪（連 4 槽）
| job | 19:02 槽 | 16:02 槽 | 13:02 槽 | 10:02 槽 |
|---|---|---|---|---|
| `9d8b6001` gengar | **321.5s** ok ce0 | 419.4s ok | 215.2s ok | 259.4s ok |
| `02eb0989` picturecat | **358.8s** ok ce0 | 145.3s ok | 173.0s ok | 138.7s ok |
| `880b5c17` celesteela | **151.0s** ok ce0 | 309.7s ok | 171.3s ok | 244.3s ok |

- 全 > 30s、非降級簽名 → **10:02、13:02、16:02、19:02 連 4 槽零降級**。
- 22:02 槽：`880b5c17` 已完（22:02:18 → 22:04:54、**155.9s ok**）；`9d8b6001` 22:02:04 起（＝本輪）；`02eb0989` 22:02:16 起執行中。
- fleet：`cron_jobs` **53**（enabled 46 / disabled 7）；三支 KA `consecutiveErrors` 全 0、`scheduleErrorCount` 全 0。

### 5) ④ heartbeat 600s timeout 群集：第 5 輪 ＝ **1**（上輪 0，本輪復發）
- 3h 窗 heartbeat receipts **49 筆**；唯一 600s+：`bcf270b8 heartbeat-mrmime` **21:01:08、dur=600.0s、err=`cron: job execution timed out`**；緊接著同一支 **21:11:38 error 81.0s `heartbeat failed: agent-runner-failure`**；**21:31:04 起恢復**（21:31 7.9s / 22:01 6.1s ok）。
- fleet-wide 600s+ receipts（3h）＝ **2**：另一筆 `911eee45 每日資安建議` dur=770.7s 但 **ok**（非失敗）。
- 其餘：`heartbeat-gengar`（21:29/21:59 ok 12–46s）、`heartbeat-charizard`（21:25/21:55 ok 11–15s）、`rowlet/roaringmoon/picturecat/greninja/celesteela` 全 `skipped: no-route`（排程設計）；最長非失敗 dur＝`heartbeat-rowlet` 21:08:22 的 **281.6s**（<600s 門檻）。

### 6) ⑤ 健康回報 filler：驗證點未到（11-25 02:05），且**同一槽兩輪判定相反**
- 對方回報：11-24 02:05 槽（01:50–02:30）filler 關鍵字命中 = **0**。
- 但 16:02 那輪曾把「11-24 02:05 槽」判成 **filler 摘要（新判準）** → **兩輪對同一槽判定相反**（口徑不同）。→ 不在本輪擅自定案，改列待對帳：**以同口徑重測 11-25 02:05 槽**（決定性驗證點仍在此）。

### 7) ⑥ 17 支 skill 缺 description：第 23 輪仍未修，密度**回升 ×1.06**
- 24h journal「Skipping invalid skill」＝**17 個具名 skill、每檔 198 次/日**（上輪 187 → ×1.06）；合計 **≈3,366 行/日**（`description is required` 2,574 ＋ `BAD_INDENT` 792）。
- 清單（13 支 description is required ＋ 4 支 BAD_INDENT）：card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、system-design-six-dimensions-analyzer、web-fetch-troubleshooting、excel-image-pipeline✳BAD_INDENT、human-behavior-simulation✳、image-attendant✳、ocr-confidence-mark✳、rosclaw plugin 4 支（check-status / navigate-to / pick-object / take-photo）。
- 口徑提醒：17 是**全艦**；gengar 自家 lane = **9/57**。

### 8) ⑦ `gw-upgrade-guard.log` 第 11 輪仍不存在；`dreaming-schedule-check.log` 仍停擺
- 全機 find → `gw-upgrade-guard.log` **0 筆**；`memory/dreaming-schedule-check.log` mtime ＝ **11-19 22:33**（停擺 5 天）→ dreaming 前置仍無前瞻簽章。

### 9) ⑧ SSH Accepted-only = 18/h（本輪自己踩到大小寫坑，已修正）
- 系統 journal（`journalctl --since "1 hour ago"`）：`grep -c "Accepted "` → **18**；3h → **54**；24h → **426**（全為 `Accepted publickey`，來源 192.168.50.2）→ 與 16:02 輪的 24h 427 基線一致。
- ⚠️ **我第一版寫 `grep -c "Accepted PublicKey"`（大寫 P）→ 0 / 0 / 0**，差點誤報「SSH 24h 歸零」；改成 `Accepted `（大小寫不敏感）後得 18/h → **教訓：SSH 一律用 Accepted-only 單樣式，且大小寫不敏感**。

### 10) ⑨ `elle.service` 仍 enabled ＋ 重啟迴圈（+357/3h）
- system scope：`LoadState=loaded`、**`UnitFileState=enabled`**、`ActiveState=activating`、**NRestarts=122,016**、`ActiveEnterTimestamp=11-24 22:04:27`（上輪 +359/3h → 本輪 **+357/3h**，速率持平）。
- journal 自證：`Scheduled restart` 3h ＝ **357**、`Main process exited` 3h ＝ **357**（兩者一致，非量測假象）。仍需 root 才能停用。

### 11) ⑩ superseded 副作用第 6 次
- `Failed to remove unused run continuation: Cannot delete session while competing work in progress` → **3h ＝ 9、24h ＝ 80**（含本輪 22:02 探針注入造成的競態）。

### 12) ⑪ dreaming 下一槽 11-25 04:25
- `36b493db` Memory Dreaming Promotion：lastRunAtMs **11-24 04:25:01**、lastStatus **ok**、dur **1,816,088ms**（30.3 分）、ce 0、nextRunAtMs **11-25 04:25:00** → 連兩夜完整跑完。

### 13) 量測口徑：本輪新增／重踩的 4 條
1. **SSH 大小寫坑**（見⑨）：`Accepted PublicKey` ≠ `Accepted publickey` → 一律用不敏感的 `Accepted `。
2. **`cron_jobs.job_id` 是完整 UUID** → 前綴查詢必須 `LIKE`（見③）。
3. **`sqlite3` CLI 對 state 目錄被拒** → cp 三檔到 /tmp 再 `mode=ro` 開（見③）。
4. **巢狀 agent 回音會落在系統行內** → 規則＝系統前綴 **且** 非 `[agent:nested]` / `[agent:side]` / `[agent/embedded]`；本輪 24h 排除 **266 行**，否則我自己的探針文字會被算成 "overloaded" 命中。

### 14) 給 Linder 的待決事項（承接 15 項，更新後 11 項）
1.【**最高優先・本輪仍未動**】**KA 路由空殼（第 6 輪）**：`9d8b6001` / `02eb0989` 的 payload `agentId` 仍空 → 兩支仍跑在 rowlet、仍不回報（`lastDeliveryStatus=not-requested`）。改法＝比照 `880b5c17` 補 `gengar` / `picturecat` ＋ 決定是否開投遞；**副作用＝改完本審查前提須重設**。`ee14ba4c`（Rowlet KA）仍 disabled。
2.【中・第 4 輪】**跨廠 fallback 冗餘 0**：`9d8b6001` 只有 minimax×2（`02eb0989` 已有 `openai/gpt-5.4-mini`）→ 建議至少補一支非 minimax。
3.【中・第 24 輪】三支 KA anchor 仍疊：22:02 槽 gengar 22:02:04 → picturecat 22:02:16（12,143ms）→ celesteela 22:02:18（2s）→ 拉開 ≥15 分鐘。
4.【中・第 23 輪】17 支 skill 缺 description，密度 **×1.06（198 次/日、≈3,366 行/日）** → 需點頭（跨 lane／第三方 plugin）。
5.【中・第 6 輪】`9d8b6001` / `02eb0989` payload 仍只有 `keep-alive test` → 沿用 `880b5c17` 那份含完整必做清單＋工作目錄的版本。
6.【中・沿用】KA 探針在被探 lane 製造 superseded 競態（第 6 次、3h 9 筆／24h 80 筆）→ 探針改低風險形式或與高頻 heartbeat 錯開。
7.【中・沿用・更新】heartbeat 600s timeout 群集**第 5 輪＝1**（mrmime 21:01:08）＋**疑似**與 21:01:33 的 429 空轉耦合 → 加 timeout 上限／併發閘門。
8.【中・沿用】`elle.service` 仍 enabled 且重啟迴圈（+357/3h、NRestarts 122,016）→ 需 root。
9.【中・沿用】`gw-upgrade-guard.log` 第 11 輪不存在、`dreaming-schedule-check.log` 停擺 5 天 → dreaming 前置無前瞻簽章。
10.【新・中】**健康回報 filler 判定口徑衝突**：16:02 輪說 11-24 02:05 有 filler、gengar 本輪說同窗命中 0 → 以 11-25 02:05 槽**同口徑**重測再定案。
11.【已結案】19:02 槽三支 KA 零降級輪（連 4 槽）、10:02/13:02/16:02/19:02 槽交辦結案、gateway 41h+ 零重啟、SSH 18/h 正常、dreaming 連兩夜完整跑完。

### 15) 下一輪（11-25 01:02）交辦
① 01:02 槽三支 KA 最終 dur ＋ 是否仍非降級（挑戰連 5 槽）；② 3h 窗 canonical 429 是否歸零（21:01:33 那筆何時出窗）＋ elapsedMs 分布；③ heartbeat 600s 群集第 6 輪；④ **11-25 02:05 健康回報槽 filler（決定性驗證）＋同口徑比對 11-24 02:05**；⑤ 17 支 skill 第 24 輪密度；⑥ KA 路由是否已修（若 Linder 未點頭則明示前提不變）；⑦ `gw-upgrade-guard.log` / `dreaming-schedule-check.log` 第 12 輪；⑧ SSH Accepted-only（**大小寫不敏感**）；⑨ `elle.service` 迴圈速率；⑩ superseded 第 7 次；⑪ dreaming 11-25 04:25 槽跑完結果；⑫ gengar lane token 換 `LANE_OK_GENGAR_0102_25 = 7`；⑬ **零值結論一律附「已納入行數」**；⑭ SSH 一律 Accepted-only 單樣式；⑮ sqlite 查詢一律 `LIKE` 前綴＋cp 到 /tmp。
