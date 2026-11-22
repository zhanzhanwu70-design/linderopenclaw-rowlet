# Gengar Keep-Alive 巡檢日誌（cron 9d8b6001，2026-11-22）

## 2026-11-22 01:02 — PASS（lane 雙向通）／⚠️ **三支 KA anchor 疊成 2ms（比上輪 14ms 更糟）**／📉 **真 429 要 ~143–174s 才回來（新量測）**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，01:05 回覆）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main` → runId **`a9c09e1c-ca6d-41c6-b158-aad0dcdc5484`**、status=**ok**、delivery=`announce/pending` → 01:05 收到完整回覆；**隨後 announce 訊息也實際落地**（由 `agent:gengar:main` 以 inter-session 形式送達本 session，內容與上述回覆一致）→ **keep-alive 雙向閉環確認完成**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報 6 支自有 cron **全 ok、ce=0**：watchdog（11-22 00:04 ok / next 02:04）、heartbeat-gengar（00:59 ok / next 01:29）、English coach（11-21 05:05 ok / next 05:00）、BBC drill（07:00 ok / next 07:00）、skill-collection-review（07:32 ok / next 11-28 07:32）、版本檢查（00:00 ok / next 11-29 00:00）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報近 60 分鐘（**00:04:51 → 01:04:51**）429/overloaded = **0**、EAI_AGAIN = 0、clock-change flush = 0 → **本輪與我方量測無矛盾**（我方真 429 在 23:02:58 / 00:02:23 / 00:02:54，全落在它的 60 分鐘窗外）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報 Discord **8 connected / 8 enabled**、0 startup-not-ready → 與我方 `openclaw channels status` **一致**（greninja disabled 設計如此）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 對端自報數字仍需以 journal 為準（本輪只是「剛好一致」，非結構性修正）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⚠️⚠️ 三支 KA anchor 疊成 **2ms**（上輪 14ms → 本輪更糟）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | anchorMs（原始） | 本輪 nextRunAt | receipt |
|---|---|---|---|---|
| Picturecat Keep-Alive | 02eb0989 | 06-03 10:02:02**.53** | **11-22 01:02:04** | ok / 16s |
| Gengar Keep-Alive（本 job） | 9d8b6001 | 06-03 10:02:02**.57** | **11-22 01:02:04** | running |
| Celesteela Keep-Alive | 880b5c17 | 06-03 10:02:02**.60** | **11-22 01:02:06** | running |

- 三支 every=10800000ms（3h）支 KA 的 anchor 只差 30–70ms → **每輪都在同一毫秒窗內齊發**（本輪三支集中在 01:02:04–01:02:06，寬度 **2ms**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 直接後果：22:08:45 那筆真 429（elapsedMs=174461）就落在上輪同樣的疊窗時段 → **「三支同刻起跑 → provider 吃滿 → 429」的路徑再次被觀察到**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 修法（**仍未執行**，屬改排程，等 Linder 點頭）：把三支 KA 的 anchor 拉開 ≥3 分鐘（例：Picturecat 保持 :04、Gengar 移到 :07、Celesteela 移到 :10）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 📉 真 429 的**回應延遲量測**（新）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 3h 內真 provider 429 共 **4 筆**（`status=429`，provider=minimax-portal / api=anthropic-messages / model=MiniMax-M3）：**22:08:45 / 23:02:58 / 00:02:23 / 00:02:54**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **elapsedMs = 174461 / 142534 / 143243** → MiniMax 的限流回應要 **~143–174 秒（2.4–2.9 分）才回** → 每次真 429 都會**白燒近 3 分鐘的 job wall-clock**，且 fallback 鏈在這段時間裡完全不能推進。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對應的 job 紀錄：`5b7c1082`「每日模型排行前十」23:00:00 **error**（dur 178s，err=「⚠️ API rate limit reached. Please try again later.」）→ **23:03:28 自動重跑 ok（dur 375s）** → 屬「紅一輪、自癒」不是死帳。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Token Plan usage limit` = **0 筆**（3h 內）；`EAI_AGAIN` = **0 真實**（唯一命中是 22:04:12 耿鬼自報文字回音）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 📉 heartbeat skip 耗時大幅回落（505s/240s → 138s/120s）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 內 skipped 30 筆：p50 = **0s**、max = **138s**（`d82f78e3` heartbeat-rowlet 22:08:22 = 120s、23:08:23 = 138s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對比上輪（505s / 240s）→ **ws 重連拖慢 route 解析的症狀明顯緩解**，§6 的 ws churn 同期也下降（13 → 11）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skip 本身仍屬「無來源可達」的正常跳過（ce=0），不需處理。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Fleet：53 jobs / 46 enabled / 7 disabled<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單（enabled + ce>0）**只有 1 張**：`c5352a84` skill-collection-review-roaringmoon ce=1（lastErr DNS lookup）→ **11-27 03:56** 才自動重試（沿用未結案）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- heartbeat no-route skipped（cs 累計，全為綠燈閒置）：greninja cs=49／picturecat cs=41／roaringmoon cs=33／celesteela cs=28／rowlet cs=7。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled 7 支：Rowlet KA／Charizard KA／RoaringMoon KA（last ok）／`gengar keep-alive`（舊 5 分鐘版，last ok）／PTCGP-daily-translation-update／discord-restart-verify／**`tmp-openai-probe` ce=2 last=error**（殘留探針，未刪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`9d8b6001`）狀態：**ce=0 / cs=0 / lastRunStatus=ok / lastDurationMs=331,109（5.5 分）** → 已連續 2 輪綠（11-21 22:02 起）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `6e93c179 heartbeat-flaaffy` st=None → 排程形同停擺（良性長態，沿用未結案）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 📉 websocket churn：3h 內 **11 次** code=1005（上輪 13，再上輪 9）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 時間點 22:12／22:37／22:38／23:11／23:13／23:31／23:40／00:23／00:42／00:47／01:00，全部 `code=1005 reasonBytes=0`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 每次都接回：`openclaw channels status` → **8 個 enabled 帳號全 running+connected**（greninja disabled），無連線卡死。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 🧩 17 個 skill 被持續跳過（**同一組 17 檔，第 5 輪未修**）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 缺 `description`（12）：card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、rosclaw/extensions/openclaw-plugin/skills/{check-status,navigate-to,pick-object,take-photo}、system-design-six-dimensions-analyzer、web-fetch-troubleshooting。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- frontmatter `BAD_INDENT`（5）：excel-image-pipeline、human-behavior-simulation、image-attendant、ocr-confidence-mark、＋（同批命中）→ 每檔 **25 次/3h**，合計 **425 行/3h**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **計數口徑差異**：上輪記 221 筆/3h、本輪 425 筆/3h，但**同一組 17 檔、每檔 25 次** → 差異來自統計口徑（是否含重複行），**不是新增缺陷**；請勿誤判為惡化。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 修法明確（各 SKILL.md frontmatter 補 `description:` / 修 BAD_INDENT 縮排）但屬跨專案檔案 → **仍等 Linder 點頭才動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 📊 系統面（3h）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：`active`、NRestarts=**0**、ActiveEnterTimestamp = **11-21 02:11:49** → 已連續在線 **~22h50m**；config `openclaw.json` mtime = **11-21 01:56:03**（與上輪一致，未被動過）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 資源：load 0.37／mem used 9,051MB（available 21,213MB）／swap 0／disk / 60%（179G free）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ingress 3h = **197 筆**（22:00 48、23:00 111、00:00 38），status 全部 `completed`；帳號分布 celesteela 182／roaringmoon 8／mrmime 6／rowlet 1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `delivery_queue_entries` 3h = 5 筆全 `completed`／retry=0 → 出站無積壓。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming `36b493db` last 11-21 04:25 **ok dur=1,918,841ms（32 分）** → next **11-22 04:25**（本輪尚未到，是下一個可驗窗口）；`d4cd45bc` self-heal 00:43 ok / 803ms（discord healthy, no action）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 其他綠燈：`40e09cd1` Jormungand daily（11-21 03:06 ok / 586s）、`d7b0355b` mrmime Codex A2A（11-22 00:00 ok / 282s）、`29c2d630` Gengar watchdog（00:04 ok / 3s）、`e2b00e12` Codex health（11-21 18:05 ok / 2.9s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改任何 cron 排程 / anchor / payload / fallback / timeout / delivery / model；未刪 job；未重啟 gateway；未改 provider / channel / auth；未改任何 skill 檔。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯讀來源：`sessions_send`、`openclaw automations list --all --json`、`cron_jobs` / `cron_run_receipts` / `channel_ingress_events` / `delivery_queue_entries`（複製 DB+WAL/SHM 至 /tmp 後以 python sqlite3 ro 查詢）、`journalctl --user -u openclaw-gateway`、`systemctl --user show openclaw-gateway`、`openclaw channels status`、uptime/free/df。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 寫入：本記憶檔、MEMORY.md、一則 Discord 摘要。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 給 Linder 的待決事項（狀態更新）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【高・連六輪】KA 三姊妹 anchor 疊窗**：本輪疊到 **2ms**（Picturecat 01:02:04／Gengar 01:02:04／Celesteela 01:02:06），且 **22:08:45 又吃一筆真 429**（耗 174s）→ 建議把三支 KA 的 anchor 拉開 ≥3 分鐘。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【中】真 429 的延遲成本**：MiniMax 限流回應要 **143–174s** 才回 → 一律用 `timeoutSeconds` 留 ≥3 分裕度、並把重試排在下一槽而不是同一槽。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】17 個 skill 被跳過**（同一組 17 檔，第 5 輪未修；425 行/3h）→ 修法明確但屬跨專案檔案，等你點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【已結案・觀察】heartbeat skip 耗時**：上輪 505s/240s → 本輪 **138s/120s**，ws churn 同期 13 → 11 → **症狀緩解，可降為觀察**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】殘留**：`c5352a84` 紅單（11-27 才重試）、`a94330a9` disabled 探針、`6e93c179 heartbeat-flaaffy` st=None → 皆未刪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**11-22 04:02**（本 job，3h 一次；同一槽 dreaming 04:25 也要跑 → 注意疊窗）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 本輪外部寫入<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1573746542786117805`、deliveryStatus `sent`**（sentAt 1795280814797）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- MEMORY.md 新增 2 條可複用教訓：真 429 的回應延遲成本（143–174s）／KA 三姊妹 anchor 疊窗要用 `state.nextRunAtMs` 驗證寬度。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
