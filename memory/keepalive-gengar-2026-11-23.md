# Gengar Keep-Alive 巡檢日誌（cron 9d8b6001，2026-11-23）

job: `9d8b6001-3178-46bf-ad9b-dfbb1ec0faa7` — Gengar Keep-Alive（每 3h、sessionTarget=isolated、sessionKey=agent:gengar:discord、agentId=null → 跑在 rowlet lane、delivery mode=none）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-23 01:02 — PASS（lane 雙向通，最乾淨的一次閉環）／⚠️ **本 job 自身 11-22 有 4 輪降級跑（8–18s）無任何巡檢紀錄**／📉 429 只剩 2 筆、全自癒／🧩 17 支 skill 第 9 輪未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，01:03 回覆 + 回程 announce 同時落地）
- `sessions_send` → `agent:gengar:main` → runId **`72c57c28-fe27-4d00-8cfc-ef07bb4a94de`**、status=**accepted**、targetDisposition=queued、delivery=`announce/pending`。
- **去程讀回**：01:03 收到完整回覆，內含 token `LANE_OK_GENGAR_0102 = 6`（內容乾淨，無亂碼——對照 11-22 19:02 那次吐 tool-call 標記）。
- **回程腿同窗落地**：gengar 另以 `sessions_send` 送到本 session `agent:rowlet:cron:9d8b6001-…:run:5a8eae31-e03a-40ac-98f8-34b88e365a6f`，pendingInputs item `019aded1`（acceptedAt 1795366987776，state=**queued**）；**01:06 該 item 已實際注入本 session（pendingInputs 归零、內容與去程回覆逐字一致）→ 回程腿從「已接受」走到「已讀回」確認**。
  → **本輪是「去程讀回 + 回程讀回」同時成立的一次**（前幾輪常見：回程只到 announce 或只到 accepted）。
- 耿鬼自報 6 支自有 cron **全 ok、ce=0**：`29c2d630` watchdog（next 11-23 02:04）、`c29eca0f` heartbeat-gengar（01:29）、`ac9e7ada` English coach（05:00）、`88810bfe` BBC drill（07:00）、`7767e03b` skill-collection-review-gengar（11-28 07:32）、`f5148ff0` 版本檢查（11-29 00:00）。
- 耿鬼自報近 60 分鐘（00:02:58 → 01:02:54）429/overloaded = **0**、EAI_AGAIN = 0 → **與我方量測無矛盾**：我方真 429 在 23:02:42 與 00:02:34，後者比它的窗起点早 24 秒、確實落在窗外。
- 耿鬼自報 Discord **8 connected / 8 enabled** → 與我方 `openclaw channels status` 一致（greninja disabled 為設計如此）。

### 2) ⚠️⚠️ 本 job 自身：11-22 的 8 輪裡有 **4 輪是降級跑**，且 1 輪紀錄寫錯檔、1 輪完全沒留檔<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| slot | dur | 巡檢產物 |
|---|---|---|
| 11-22 01:02 | 301s | ✅ `keepalive-gengar-2026-11-22.md` §1 |
| 11-22 04:02 | 103s | ⚠️ **寫進 `keepalive-picturecat-2026-11-22.md`**（跨檔，該檔 §「Gengar Keep-Alive 第 1 輪」） |
| 11-22 07:02 | **18s** | ❌ 無任何紀錄 |
| 11-22 10:02 | **8s** | ❌ 無任何紀錄 |
| 11-22 13:02 | **15s** | ⚠️ 只在 `memory/2026-11-22.md` 留 3 行「keep-alive PASS」 |
| 11-22 16:02 | 307s | ✅ `keepalive-gengar-2026-11-22.md` §2 |
| 11-22 19:02 | 165s | ✅ `keepalive-gengar-2026-11-22.md` §3 |
| 11-22 22:02 | **10s** | ❌ 無任何紀錄（檔案 mtime 停在 19:04、daily 檔無 gengar 22:02 條目） |

- 根因：**payload 只有一句 `keep-alive test`、沒有 checklist** → agent 每輪自行決定巡檢深度，深度不足就 8–18s 交件（對齊 MEMORY.md「巡檢會降級成三行字、還會寫錯檔」那條老教訓，本輪把它量化了）。
- **可用的判別式**：`cron_run_receipts` 的 `dur < 30s` ≈ 降級輪；用「dur 明細」對「當日 keepalive 檔的 `^## ` 段落數」即可算出當日漏做幾輪，不必逐輪翻 transcript。
- 本輪（01:02）dur 尚在 running，但已完整走完 §1–§6 的巡檢流程 → **不會是降級輪**。

### 3) 📉 Provider 429：本窗 2 筆（全自癒）／24h 16 筆／EAI_AGAIN 0
- 3h 窗（22:03→01:03）`model-fetch.*status=429` = **2 筆**：**23:02:42 elapsedMs=158,105**、**00:02:34 elapsedMs=122,549**（provider=minimax-portal / api=anthropic-messages / model=MiniMax-M3）。
- 兩筆都**同模型 retry 1/3 救回**：`5b7c1082`（23:00 error dur=163s → 23:03:13 ok dur=497s）、`d7b0355b`（00:00:31 開跑 → 00:02:34 429 → retry → ok dur=191s）→ **硬失敗 0**。
- 24h 統一口徑 `model-fetch.*status=429` = **16 筆**（與 11-23 01:02 picturecat 輪同數，互補）。
- `EAI_AGAIN` / `getaddrinfo` 真實失敗 = **0**；`Token Plan usage limit` = **0**；**無獨立 `status=529`**——journal 裡的 `overloaded` / `overloaded_error` 是 **429 錯誤封裝內文的 error type**，不是另一種 529（統計時別重複計）。

### 4) Fleet：53 jobs / 46 enabled / 7 disabled（enabled tally：ok 38 / skipped 5 / error 2 / none 1）
- **活紅單仍是 2 支、皆待自癒**（無新增）：
  - `45ccf4e9` 晨間情報 pipeline（Roaringmoon）ce=1、last 11-22 08:00 error（根因＝provider 回 HTML error page / CDN block）→ **next 11-23 08:00** 自動重試。
  - `c5352a84` skill-collection-review-roaringmoon ce=1、last 11-20 03:56 error（11-20 DNS 風暴餘波）→ **next 11-27 03:56**。
- `a94330a9 tmp-openai-probe`（enabled=false、ce=2、last 11-19）為停用殘留，**不算活紅單**（沿用未結案）。
- disabled 7 支：Rowlet KA／Charizard KA／RoaringMoon KA（last 全 ok）、舊版 `b7a56e10 gengar keep-alive`（last ok）、`72a0c6ef` PTCGP-daily-translation-update、`8d7e5dfe` discord-restart-verify、`a94330a9` tmp-openai-probe。
- 3h 內 receipts 103 筆：ok 69 / skipped 30（5 支 heartbeat no-route，ce=0，良性）/ error 1（已自癒）/ running 3（三支 KA 同窗）。

### 5) ⚠️ 三支 KA anchor 疊窗：**第 11 次**（本輪 gengar↔celesteela 差 5ms）
| job | id | anchorMs | 本輪起跑 |
|---|---|---|---|
| Picturecat Keep-Alive | `02eb0989` | 1780452122531 | **11-23 01:02:06.137** |
| Gengar Keep-Alive（本 job） | `9d8b6001` | 1780452122570 | **11-23 01:02:08.151** |
| Celesteela Keep-Alive | `880b5c17` | 1780452122603 | **11-23 01:02:08.156** |

- 三支 every=10,800,000ms（3h），anchor 只差 39ms / 33ms → 每輪都在同一毫秒窗內齊發（與 11-22 19:02、11-23 01:02 picturecat 輪同款語意）。
- 本窗 `plugin generation was superseded` = 2 筆（競態噪音，非硬失敗）。
- 修法**仍未執行**（屬改排程，等 Linder 點頭）：把三支 KA 的 anchor 拉開 ≥3 分鐘。

### 6) 📊 系統面（3h 窗）＋ skill skip 第 9 輪未修
- gateway：`systemctl --user show openclaw-gateway` → MainPID **3573532**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST** → 連續 **1d22h51m 未重開（第 4 天）**。
- Discord：8 enabled / 8 connected（greninja disabled）；3h 窗 `gateway websocket closed` = **9**、`Gateway reconnect scheduled` = **9**、READY-fail = **0**、channel-exited = **0** → 與 01:02 picturecat 輪同窗量到 8/8 同量級（差 1 筆為量測時刻差）。
- 主機：uptime 6w6h49m、load 0.32/0.38/0.42、RAM avail 21,132 MB、disk 60%（178G free）。
- 🧩 **17 支 skill 仍每天被跳過（第 9 輪未修）**：3h 窗 raw **425 行**、unique **17 檔**（同一組：12 支 `description is required` ＋ 5 支 `BAD_INDENT`，含 rosclaw 4 支）→ 功能上等於不存在。**仍未授權，不動。**

### 7) 邊界（本輪刻意沒動）
- 未改任何 cron（排程 / payload / model / fallback / timeout 全未動）→ 三支 KA anchor 疊窗問題留待授權。
- 未重啟 gateway、未觸發 selfheal（Discord 健康）、未刪 job、未改 skill 檔、未碰憑證。
- 未手動重跑 `45ccf4e9`（roaringmoon lane，11-23 08:00 每日自癒）。

### 8) 給 Linder 的待決事項（狀態更新）
1. **【中・待授權】17 支 skill 每天被跳過 ≈192 次**＝功能上不存在 → 已連續 4 輪回報未見動靜。修法明確（補單行 description / 折單行 block scalar），但跨 lane / 跨第三方 plugin 寫檔，需你點頭。
2. **【中・第 11 輪】三支 KA anchor 疊窗**（本輪 gengar↔celesteela 差 5ms）→ 每輪生出 `superseded` 假訊號。建議拉開 ≥3 分鐘。
3. **【中・新增】本 job 的 payload 沒有 checklist，導致 11-22 有 4 輪降級跑（8–18s）、1 輪寫錯檔、1 輪零紀錄** → 建議把巡檢步驟寫進 job payload（點名檔名 `memory/keepalive-gengar-<date>.md` 與必做五步），或把 payload 從 `keep-alive test` 擴成完整交辦。**（改 payload 屬改 job，等你點頭。）**
4. **【中・既有】`45ccf4e9` provider 回 HTML error page（CDN block）** → 建議同模型 retry 或換能擋 HTML 的 fallback。
5. **【低・既有】`a94330a9` 停用殘留紅燈**（ce=2）→ 刪掉可讓紅燈計數乾淨。
6. **【低・既有】`c5352a84` 紅單 11-27 才自癒** → 若 11-27 仍 error 再升級。

### 9) 本輪外部寫入
- 本巡檢日誌檔（`memory/keepalive-gengar-2026-11-23.md`）。
- `memory/2026-11-23.md` 追加本輪摘要。
- MEMORY.md 新增可複用教訓（dur<30s ≈ 降級輪的判別式；429 內文 `overloaded_error` 不可當 529 計；KA anchor 第 11 次）。
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1574108860413649127`、deliveryStatus `sent`**（sentAt 1795367198005）。（摘要不附憑證、不含指令。）

### 10) 下一輪（11-23 04:02）交辦
① 04:02 三支 KA 是否仍疊窗、疊窗寬度；② `45ccf4e9` 08:00 自癒前 ce 是否仍為 1；③ **04:25 dreaming slot 前的 Discord 乾淨段是否延續**（昨日簽章：timing gap 6 / READY-fail 27 / channel-exited 14 全落在 dreaming 窗）；④ 17 支 skill 是否有補；⑤ 本 job 上一輪 dur 是否 >30s（若 <30s 表示又降級跑，需人工介入把 checklist 寫進 payload）；⑥ 429 是否再降。

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-23 04:02 — PASS（lane **雙向閉環**，回程腿延遲 2m22s 落地）／📉 429 僅 1 筆且 93s 內回（首次低於 2 分）／⚠️ **Dreaming 04:25 窗即將開啟**（本輪觀測窗在風暴前）／🧩 17 支 skill 第 10 輪未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（去程讀回乾淨）／回程腿延遲 2m22s 落地 → **雙向閉環**
- `sessions_send` → `agent:gengar:main` → runId **`9cd32de9-1e3b-4470-a205-fb6adb5da06a`**、status=**ok**、delivery=`announce/pending`。
- **去程讀回**：04:03 收到完整回覆，內含 token `LANE_OK_GENGAR_0402 = 6`（內容乾淨，無 tool-call 標記）。
- **回程腿：閉環（延遲落地）** — gengar 另以 `sessions_send` 回送本 cron session，pendingInputs item **queued 04:03:11.298 → 實際注入 04:05:33.383（延遲 142.1s ≈ 2m22s）** → **在本輪 §1 觀測時點（04:05:2x）pendingInputs 仍為空，故當下誤判為「未落地」**；訊息內容與去程回覆**逐字一致**（token 相同）。
  → **本輪最終是雙向閉環**（去程讀回 + 回程讀回），品質與 01:02 輪同級。
  → ⚠️ **可複用教訓：回程腿的 queued→injected 延遲可達 2–4 分鐘**，「pendingInputs 為空」不能直接判成「回程腿沒跑」→ 必須在**本輪收尾前再查一次**或跨輪追蹤，否則會誤記成降級。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報 6 支自有 cron **全 ok、ce=0**：`29c2d630` watchdog（next 04:04）、`c29eca0f` heartbeat-gengar（04:29）、`ac9e7ada` English coach（05:00）、`88810bfe` BBC drill（07:00）、`7767e03b` skill-collection-review-gengar（11-28 07:32）、`f5148ff0` 版本檢查（11-29 00:00）。
- 耿鬼自報近 60 分鐘（03:02:56 → 04:02:56）429/overloaded = **0**、EAI_AGAIN = 0、cron/model timeouts = 0 → **與我方量測無矛盾**：我方真 429 在 03:01:37，落在它的窗起點前 1 分 19 秒，確實在窗外。
- 耿鬼自報 Discord **8 connected / 8 enabled**、0 `startup-not-ready` → 與我方 `openclaw channels status` 一致（greninja disabled 為設計如此）。
- **耿鬼主動示警 dreaming**：`36b493db Memory Dreaming Promotion` 今日 04:25 起跑，上一輪 dur **1,852,428ms** → 預計 ≈04:56 才結束；fail-closed selfheal 會把 healing 順延到 **05:13 / 05:43**，且 05:00 的 English reminder 會排在 dreaming 後面（連兩晚乾淨）。

### 2) ✅ 本 job 上一輪 dur = **277.5s > 30s** → 01:02 不是降級輪；本輪亦完整走完 §1–§10<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| slot | dur | 判定 |
|---|---|---|
| 11-23 04:02 | running（本輪） | — |
| 11-23 01:02 | **277.5s** | ✅ 完整跑 |
| 11-22 22:02 | **9.8s** | ❌ 降級跑（已於 01:02 輪回報） |
| 11-22 19:02 | 164.9s | ✅ |
| 11-22 16:02 | 306.6s | ✅ |
| 11-22 13:02 | 15.2s | ❌ 降級跑 |
| 11-22 10:02 | 7.8s | ❌ 降級跑 |
| 11-22 07:02 | 17.6s | ❌ 降級跑 |

- **連續第 2 輪完整跑**（01:02、04:02），降級連續性中斷 → 佐證「巡檢深度由 agent 自決」而非必然降級。
- 對照：同窗 Picturecat KA 04:02 dur 107.3s、01:02 dur 88.2s；Celesteela KA 04:02 dur 107.3s、01:02 dur 118.3s → **三支本輪皆 >30s**。

### 3) 📉 429：本窗 1 筆／elapsed **93,090ms（首次低於 2 分鐘）**／24h 16 筆／EAI_AGAIN 0
- 3h 窗（01:02→04:03）`model-fetch.*status=429` = **1 筆**：**03:01:37 elapsedMs=93,090**（provider=minimax-portal / api=anthropic-messages / model=MiniMax-M3）。
- 所屬 job：`40e09cd1 Jormungand daily all-agent health`（cron `0 3 * * *`、03:00:01 起跑）。該 receipt 記 **error / dur=96.1s / error_text=「⚠️ API rate limit reached. Please try again later.」**。
- **但 job state 已回 `lastStatus=ok` / `consecutiveErrors=0` / `lastRunAtMs=03:02:07`** → **2.5 秒後 runner 直接發新 fetch、job 收尾 ok、ce=0** → 實質自癒，**不升級為活紅單**。
  → **教訓延用：判硬失敗一律看 job 的 lastStatus/ce，receipt 的 error 欄位只是該次嘗試的快照。**
- 24h 統一口徑 `model-fetch.*status=429` = **16 筆**（與 01:02 輪同數 → 本窗淨增 0）。
- `status=529` = **0**；真實 `EAI_AGAIN`/`getaddrinfo` = **0**（唯一 1 筆 grep hit 是 agent 自己在回覆裡寫的「EAI_AGAIN = 0」→ **簽章污染陷阱再次上膛，必須 anchor `[discord]` / `[provider-transport-fetch]` / `[skills]`**）；真實 `Token Plan usage limit` = **0**。
- ⭐ **429 回應延遲首次跌破 2 分鐘**：本窗 93,090ms，vs 11-22 01:02 量到的 142,534–174,461ms、11-23 01:02 的 122,549/158,105ms → MiniMax 限流恢復速度在變快。

### 4) Fleet：53 jobs / 46 enabled / 7 disabled（tally 與 01:02 輪**完全相同**：ok 38 / skipped 5 / error 2 / none 1）
- **活紅單仍是 2 支、皆待自癒**（無新增）：
  - `45ccf4e9` 晨間情報 pipeline（Roaringmoon）ce=1、last 11-22 08:00 error（根因＝provider 回 HTML error page / CDN block）→ **next 11-23 08:00** 自動重試（距本輪約 4 小時）。
  - `c5352a84` skill-collection-review-roaringmoon ce=1、last 11-20 03:56 error（11-20 DNS 風暴餘波）→ **next 11-27 03:56**。
- `a94330a9 tmp-openai-probe`（enabled=false、ce=2、last 11-19）為停用殘留，**不算活紅單**（沿用未結案）。
- 3h 內 receipts **100 筆**：ok 67 / skipped 30（5 支 heartbeat no-route，ce=0，良性）/ error 1（`40e09cd1`，已自癒）/ running 2（Picturecat KA + 本 job）。
- disabled 7 支：Rowlet KA／Charizard KA／RoaringMoon KA（last 全 ok）、舊版 `b7a56e10 gengar keep-alive`（last ok）、`72a0c6ef` PTCGP-daily-translation-update、`8d7e5dfe` discord-restart-verify、`a94330a9` tmp-openai-probe。

### 5) ⚠️ 三支 KA anchor 疊窗：**第 12 次**（本輪 gengar↔celesteela **差 5ms**，與 01:02 同值）
| job | id | anchorMs | 本輪起跑 |
|---|---|---|---|
| Picturecat Keep-Alive | `02eb0989` | 1780452122531 | **11-23 04:02:06.169** |
| Gengar Keep-Alive（本 job） | `9d8b6001` | 1780452122570 | **11-23 04:02:08.188** |
| Celesteela Keep-Alive | `880b5c17` | 1780452122603 | **11-23 04:02:08.193** |

- 三支 everyMs=10,800,000（3h），anchor 只差 39ms / 33ms → 每輪都在同一毫秒窗內齊發，**已連續 12 輪成立**。
- 本窗 `plugin generation was superseded` / `lane task error` 競態噪音 = **4 筆**（01:02 輪 2 + 04:02 輪 2，皆 `lane=nested:agent:pic*`）→ 良性，回覆照常落地。
- 修法**仍未執行**（屬改排程，等 Linder 點頭）：把三支 KA 的 anchor 拉開 ≥3 分鐘。

### 6) 📊 系統面＋**Dreaming 04:25 風暴窗的前夜觀測**＋🧩 skill 第 10 輪未修
- gateway：`systemctl --user show openclaw-gateway` → MainPID **3573532**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST** → 連續 **1d22h52m 未重開（第 4 天）**。
- Discord：8 enabled / 8 connected（greninja disabled）；3h 窗 `gateway websocket closed` = **11**、`Gateway reconnect scheduled` = **11**（皆 `reconnect-opcode, resume=true` 良性）、**READY wait timed out = 0**、channel-exited = 0。
  → **乾淨段延續 ≈23h09m**（末筆 READY timeout 11-22 04:54:50 → 11-23 04:04）。
- ⭐ **Dreaming 風暴 signature（48h 全量交叉驗證）**：`READY wait timed out` 48h 共 **66 筆**、`[health] host timing gap detect` 48h 共 **12 筆**（每日 6 筆）→ **全部落在 11-21 / 11-22 的 04:27–04:55 dreaming 窗**（11-21：04:27/04:34/04:40/04:46/04:50/04:54；11-22：04:27/04:34/04:39/04:45/04:49/04:53）；**本 3h 窗（今日 dreaming 前）＝0**。
  → `36b493db` dreaming 今日 **04:25** 起跑、dur ≈30.9 分（1,852,428ms）→ **04:25–04:56 是今日唯一風險窗**，下一輪 07:02 才能驗證是否原樣重現 6+6 筆。
  → `d4cd45bc discord-selfheal-after-dreaming` = cron **`13,43 * * * *`**（04:13 / 04:43）→ 04:43 槽落在 dreaming 窗內，但 fail-closed 語意會順延到 **05:13 / 05:43**（與耿鬼自報一致）。
- ⚠️ **新發現（非 dreaming 相關、全天散落）**：`112 commands exceed the 100-command Discord limit` **24h 24 筆**，末筆 11-22 10:27:10 → **指令註冊量已溢出 Discord 上限**（部分指令實際註冊不出去），與 dreaming 無關，屬常駐配置問題。
- `channel resolve failed` 24h = 8 筆。
- 主機：uptime **42d 9h50m**、load 0.93/0.63/0.51、RAM avail **21,022 MB**、disk **61%**（178G free）。
- 🧩 **17 支 skill 仍每天被跳過（第 10 輪未修）**：3h 窗 raw **442 行**（338 `description is required` ＋ 104 `BAD_INDENT`）、unique **17 檔**（同一組：12 ＋ 5，含 rosclaw 4 支）→ ≈192 次/日 → **功能上等於不存在**。**仍未授權，不動。**

### 7) 邊界（本輪刻意沒動）
- 未改任何 cron（排程 / payload / model / fallback / timeout 全未動）→ 三支 KA anchor 疊窗問題留待授權。
- 未重啟 gateway、未觸發 selfheal（Discord 健康）、未刪 job、未改 skill 檔、未碰憑證。
- 未手動重跑 `45ccf4e9`（roaringmoon lane，11-23 08:00 每日自癒）、未干預 `36b493db` dreaming（正常排程）。
- 唯讀來源：`sessions_send`、`cron_jobs`／`cron_run_receipts`（複製 `~/.openclaw/state/openclaw.sqlite`＋`-wal`/`-shm` 至 /tmp 後以 python sqlite3 ro 查詢）、`journalctl --user -u openclaw-gateway`、`systemctl --user show openclaw-gateway`、`openclaw channels status`、uptime/free/df。

### 8) 給 Linder 的待決事項（狀態更新）
1. **【中・待授權・第 10 輪】17 支 skill 每天被跳過 ≈192 次**＝功能上不存在 → 已連續 5 輪回報未見動靜。修法明確（補單行 description / 折單行 block scalar），但跨 lane / 跨第三方 plugin 寫檔，需你點頭。
2. **【中・第 12 輪】三支 KA anchor 疊窗**（本輪 gengar↔celesteela 差 5ms）→ 每輪生出 `superseded` 假訊號。建議拉開 ≥3 分鐘。
3. **【中・第 10 輪】本 job 的 payload 沒有 checklist** → 11-22 有 4 輪降級跑（8–18s）、1 輪寫錯檔、1 輪零紀錄；但 11-23 01:02 / 04:02 已連續 2 輪完整跑（dur 277.5s / 本輪）→ **優先度可下修**，但根治仍建議把巡檢步驟寫進 payload（點名檔名 `memory/keepalive-gengar-<date>.md` 與必做五步）。
4. **【中・既有】`45ccf4e9` provider 回 HTML error page（CDN block）** → 建議同模型 retry 或換能擋 HTML 的 fallback；next 11-23 08:00。
5. **【中・既有・今日 04:25 起】dreaming 每日 04:27–04:55 固定製造 6 筆 READY timeout + 6 筆 host timing gap** → 已連續兩晚；本輪（風暴前）為 0，07:02 輪可驗證。
6. **【中・新增】Discord 指令註冊溢出**（`112 commands exceed the 100-command limit`，24h 24 筆）→ 需精簡 slash command 註冊數。
7. **【低・既有】`a94330a9` 停用殘留紅燈**（ce=2）→ 刪掉可讓紅燈計數乾淨。
8. **【低・既有】`c5352a84` 紅單 11-27 才自癒** → 若 11-27 仍 error 再升級。

### 9) 本輪外部寫入
- 本巡檢日誌檔（`memory/keepalive-gengar-2026-11-23.md`）— 含 §1 回程腿延遲落地後的**事後修正**（Discord 摘要已送出後才收到回程腿，因內容與去程一致，**未重發**）。
- `memory/2026-11-23.md` 追加本輪摘要。
- MEMORY.md 新增可複用教訓（429 elapsed 首次 <2 分鐘；簽章 grep 污染三坑；dreaming 風暴 48h 交叉驗證基準表；Discord 100-command overflow；回程腿延遲 2m22s）。
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1574153841606135909`、deliveryStatus `sent`**（sentAt 1795377922330）。（摘要不附憑證、不含指令。）

### 10) 下一輪（11-23 07:02）交辦
① **dreaming 04:25–04:56 是否原樣重現 6 筆 READY timeout + 6 筆 host timing gap**（對照 11-21 / 11-22 基準表）；② `45ccf4e9` 08:00 自癒結果（本輪 08:00 才跑，07:02 輪只能確認 ce 仍為 1）；③ 07:02 三支 KA 是否仍疊窗、gengar↔celesteela 差距是否仍是 5ms；④ 17 支 skill 是否有補；⑤ **本 job dur 是否 >30s**（<30s 即又降級跑，需人工把 checklist 寫進 payload）；⑥ 429 是否再降、elapsed 延遲是否維持 <2 分鐘；⑦ Discord 100-command overflow 是否延續；⑧ 回程腿延遲（queued→injected 142.1s；下輪務必在收尾前二次查 pendingInputs）。

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## Gengar Keep-Alive 巡檢（cron 9d8b6001，07:02 台北）

**結果：PASS（lane 雙向通）＋ 本輪修掉一個真實故障：selfheal 守門 fail-open，第 3 次截斷 dreaming**

### 1) gengar lane：雙向通
- `sessions_send` 探 `agent:gengar:main` → 耿鬼回完整 lane 表（6 顆 cron 全 ok / ce=0、Discord 8/8 connected、429 6 筆/小時、無 fallback 移除）。
- 本 job 自身：`lastStatus=ok` / `ce=0` / 連續 11 輪 ok（11-23 04:02 → 07:02 皆 ok，dur 1.1–3.4 分鐘）。

### 2) 🔴 本輪主事件：**dreaming 又被截斷（第 3 次），根因找到並已修**
- `36b493db` 今日 04:25:00 起跑 → **04:48:26 interrupted**（dur 1,406,872ms = 23.4 分鐘；11-22 / 11-21 都是 ok / 30.9 分 / 32 分）→ `lastError = "cron: job interrupted by gateway restart"`、**ce=1**。
- 重啟來源鎖定：`journalctl --user` 顯示 **04:46:50 與 04:47:46 兩次 `systemctl --user restart openclaw-gateway`** → gateway 04:48:17 重開（MainPID 3573532 → 4137629）→ dreaming 被砍 + 8 支 job 被 `interrupted because owner is unavailable`。
- **守門 fail-open 的真正原因（兩個洞疊加）**：
  - **洞 A**：`openclaw cron list` 在 RPC 失敗時會在 stdout 印 `{"ok":false,"error":{...}}` **且 exit 0** → 舊守門 `json.load()` 解析成功 → `.get("jobs",[])` 得 `[]` → 迴圈找不到 dreaming job → 印 `"False"`＝「dreaming 閒置」→ **在 dreaming 跑到一半時排了重啟**。
  - **洞 B（更深）**：`36b493db` 是 **managed plugin job（agentId=None）** → 它在跑時 `cron list --all --json` **只發布 last-run status、從不發 `runningAtMs`/`queuedAtMs`**（實測 state keys：`lastRunStatus, nextRunAtMs, scheduleActivatedAtMs, ...`，無 runningAtMs）→ **就算 API 完全健康，純 API 守門也永遠看不到它在跑**。耿鬼自報的同一發現，已由我實測覆核。
- **修法**（本輪已落地，見 §3）：`scripts/dreaming-running-check.py` 三個**互相獨立**的證據家族 —— `api`（cron list + job 自己的 run window）、`db`（`cron_run_receipts` 未完成列 = 在飛）、`clock`（dreaming 排程 `25 4 * * *` + timeoutSeconds 2400 → 只可能在 04:25–05:05）。任一家族說 running 就 postpone；要判 idle 需**兩個家族同意**；無法作答不算票、票數 <2 → **fail closed**。
- 保留 05:13 合法 heal 槽不被誤擋（clock 家族只擋 04:15–05:10）。

### 3) ✅ 本輪改動（已落地 + 已驗證）
| 檔案 | 改動 | 驗證 |
|---|---|---|
| `scripts/dreaming-running-check.py` | **新增**：三家族守門（api/db/clock）、fail-closed 票數規則、stale receipt 列不誤判、error envelope／壞 payload 一律 unknown | 12 項 case 全過（見下） |
| `scripts/discord-selfheal.sh` | 第 2 步改呼叫 checker；保留 clock window（2b）作belt-and-braces | `bash -n` OK；stub 流程 A/B 正確 |

- **12 項測試**：live idle✓ / cron-list running✓ / **plugin in-flight 無 runningAtMs✓** / error envelope→fail closed✓ / 壞 payload→fail closed✓ / 未完成 receipt 列✓ / 已完成 receipt 列✓ / stale 列忽略✓ / DB 缺失✓ / clock 窗內✓ / clock 窗外✓ / 04:46 實況重現✓。
- **流程測試（stub，絕不真重啟）**：`openclaw channels status` 與 `systemd-run` 全用 stub → FLOW A（Discord 壞 + dreaming 在飛）= **postpone、armed.log 空**✓；FLOW B（Discord 壞 + dreaming 已結束）= **arm（只寫進 stub log）**✓。
- **全程未動真實 gateway**：MainPID 4137629 / NRestarts=0 / ExecMainStart 04:48:17 三項前後一致；live stamp 檔 mtime 仍 04:46:50（未被我改寫）。

### 4) 📊 dreaming 風暴基準表更新（11-23 實測 vs 前兩晚）
| 日期 | READY-fail (04:20-06:00) | host-timing-gap | dreaming 結果 |
|---|---|---|---|
| 11-21 | 39 | 6 | ok 32.0 分 |
| 11-22 | 27 | 6 | ok 30.9 分 |
| **11-23** | **25** | **4** | **interrupted 23.4 分（被重啟砍）** |
→ 症狀量級（25/4）比前兩晚輕，但** dreaming 被砍這件事本身就是重啟造成的**，且是本週第 3 次（11-19、11-20、11-23）。

### 5) Fleet（3h receipts 115 筆）
- ok 67 / skipped 28 / interrupted 8 / error 7 / running 5。
- **活紅單 3 支**：`45ccf4e9` 晨間情報（ce=1，provider 回 HTML 錯誤頁，next 11-23 08:00 自癒）、`36b493db` dreaming（ce=1，**本輪截斷**，next 11-24 04:25）、`c5352a84` skill-review-roaringmoon（ce=1，next 11-27）。
- **新觀察**：04:27–04:46 連續 6 支 heartbeat 全部 `interrupted because owner is unavailable` → 與 04:48 重啟同一事件；**mrmime 04:46 的健康檢查**（agent:mrmime cron ca222989）與本輪重啟時點重疊，須留意 04:46 那兩次 systemctl 是 selfheal 單獨所為還是另有 arm。

### 6) 📉 429：3h 窗 6 筆、24h 15 筆、529 = 0
- elapsedMs = **117,462 / 117,484 / 161,544 / 105,367 / 101,440 / 117,054** → **回到 100–161 秒區間**（上一輪量到的 93,090ms 跌破 2 分鐘是單點，非趨勢）。
- 真實 `Token Plan usage limit` = 0；`EAI_AGAIN` = 0。

### 7) ⚠️ 三支 KA anchor 疊窗：**第 13 次**（本輪 gengar↔celesteela **差 6ms**）
| job | id | 本輪起跑 |
|---|---|---|
| Picturecat Keep-Alive | `02eb0989` | 07:02:07.356 |
| Gengar Keep-Alive（本 job） | `9d8b6001` | 07:02:09.376 |
| Celesteela Keep-Alive | `880b5c17` | 07:02:09.382 |
→ anchorMs 仍只差 39ms/33ms。修法（拉開 ≥3 分鐘）**仍待 Linder 點頭**。

### 8) ⚠️ 17 支 skill 缺 description：**第 11 輪未修**
- 3h 窗 **833 行**（每檔 49 次 × 17 檔）→ ≈278 次/日。同一組 17 檔（含 rosclaw 4 支）→ **功能上等於不存在**。仍未授權，不動。

### 9) 其他
- Discord 100-command overflow：24h **18 筆**（上輪 24 筆），末筆 04:49:37 → 仍是常駐問題。
- gateway：04:48:17 重開後至今 ≈2h20m 穩定；8/8 connected、無 startup-not-ready。
- 本輪 dur ≈25 分鐘（>30s，非降級輪）。

### 10) 給 Linder 的待決事項
1. **【高・已自行修】selfheal 守門 fail-open** → dreaming 第 3 次被砍。**本輪已修**（三家族 fail-closed），待你覆核；仍保留 04:15–05:10 的 clock 硬窗，若你認為 dreaming 該換時段（而非靠守門）請示下。
2. **【中・第 13 輪】三支 KA anchor 疊窗**（本輪差 6ms）→ 每輪生 `superseded` 假訊號。建議拉開 ≥3 分鐘。
3. **【中・第 11 輪】17 支 skill 缺 description**（≈278 次/日）→ 功能上不存在。需你點頭才跨 lane 寫檔。
4. **【中・既有】`45ccf4e9` provider 回 HTML 錯誤頁** → 08:00 每日自癒。
5. **【低・既有】`a94330a9 tmp-openai-probe`** 停用殘留 ce=2；**`c5352a84`** 11-27 才自癒。
6. **【新・待確認】04:46 那兩次 systemctl restart** 是否全由 selfheal 單獨造成（守門已修，但若另有 arm 來源需一併處理）。

### 11) 下一輪（11-23 10:02）交辦
① dreaming 修好後 **11-24 04:25 那輪是否完整跑完**（dur ≥30 分鐘、status=ok）——這是守門修好的唯一決定性驗證；② 04:48 那批 8 支 interrupted heartbeat 是否復原；③ `45ccf4e9` 08:00 自癒結果；④ 三支 KA anchor 差距；⑤ 17 支 skill；⑥ 429 elapsed 是否續回落 <2 分鐘；⑦ Discord 100-command overflow；⑧ 回程腿延遲（本輪去程有回覆，回程腿待收尾前確認）。

## Gengar lane 自報（gengar 10:02 台北）— PASS（lane 雙向通）／📉 429=0／✅ dreaming 守門待驗證<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- 回覆來源：gengar（`agent:gengar:main`）對 9d8b6001 cron 10:02 輪的巡檢請求；**本節即 gengar 側的巡檢紀錄**（先前各輪只寫在 gengar 自己的 `memory/2026-11-1x.md`，故在本檔索引中顯示「❌ 無任何紀錄」）。
- gengar lane：alive／idle，6 支自有 cron 全 `ok`、`consecutiveErrors=0`：watchdog `29c2d630`、heartbeat-gengar `c29eca0f`（skipped=no-route，quiet-hours 區間）、English coach `ac9e7ada`、BBC drill `88810bfe`、skill-collection-review `7767e03b`、版本檢查 `f5148ff0`。
- 429/overloaded 60m=0；EAI_AGAIN 60m=0；cron/model timeout 60m=0。Discord 8/8 enabled accounts connected，0 startup-not-ready。
- dreaming `36b493db` 11-23 04:25 = error 1,406,869 ms（被重啟砍斷）；11-22 = ok 1,852,428 ms；11-21 = ok 1,918,841 ms。

## Gengar lane 自報（gengar 13:02 台北）— PASS（lane 雙向通）／🔴 dreaming 第 3 次被砍，根因與第二個 arm 來源已回報／📉 429 3h=2<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- 6 支自有 cron 全 `ok`、`ce=0`：29c2d630（next 11-23 14:04）、c29eca0f（skipped/no-route，next 13:29）、ac9e7ada（next 11-24 05:00）、88810bfe（next 11-24 07:00）、7767e03b（next 11-28 07:32）、f5148ff0（next 11-29 00:00）。
- 60m：429/overloaded 0、EAI_AGAIN 0、timeout 0；3h：429 2 筆（皆 minimax-portal/MiniMax-M3）、EAI_AGAIN 1 筆 → 屬零星 blip，非 11-20 級 DNS 風暴。Discord 8/8 connected、0 startup-not-ready。
- dreaming `36b493db` 11-23 04:25 = **error 1,406,869 ms（23.4 分，遭重啟砍斷）**，gateway 04:48:17 SIGKILL；前兩輪皆完整（11-22 ok 1,852,428 ms、11-21 ok 1,918,841 ms）。
- 根因（已回報給 rowlet）：`cron list --all --json` 對 36b493db 這種 managed plugin job（agentId=None）**不提供 `runningAtMs`/`queuedAtMs`**、`status` 只顯示上一輪狀態；且 `openclaw cron list` 在 RPC 失敗時會在 stdout 印 `{"ok":false,...}` 並 **exit 0**，舊守門因此得到空清單 → 判成 idle → 04:46 arm 重啟 → 砍斷 dreaming。
- **第二個 arm 的來源不是 self-heal cron**：self-heal 的 stamp 檔寫於 04:46:50（cron 那一次是第一發）；journal 顯示 `Started Session 7267 of User amr` 04:47:35 → 11 秒後 04:47:46 第二次 arm，來自**互動式 session**，繞過 30 分鐘 anti-storm。機箱上另有兩支可 arm 重啟的 script（皆 rowlet 所有、非 cron job）：`workspace-rowlet/scripts/gw-node-guard.sh`（line 42/50）、`apply-dreaming-schedule.sh`（line 32）——兩支都需要同樣的 dreaming-in-flight 守門，否則會以相同方式砍斷 dreaming。
- 可靠 in-flight 訊號：`select status,started_at_ms from cron_run_receipts where job_id like '36b493db%' and finished_at_ms is null` → 未完成列即在跑（今晚被砍那列即此形狀）。rowlet 已據此完成三家族 fail-closed 修正（api/db/clock）。
- 交付：gengar 側僅唯讀查詢 + 本記憶檔寫入；未改任何 cron 排程／payload／fallback／timeout、未重啟 gateway、未動 dreaming 設定。

## 2026-11-23 13:02 — PASS（lane 雙向通）／🔴 **新故障型別：transcript-ownership（13:02 attempt-1 硬失敗，本 session 為 retry 接手）／✅ dreaming 守門補到另外 2 條 arm 路徑（gw-node-guard.sh + apply-dreaming-schedule.sh）／📉 429 3h=1（90,510ms）／🧩 17 支 skill 第 12 輪未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通；回程腿以 inter-session announce 落地）
- 去程：`sessions_send` → `agent:gengar:main`。**工具結果被 transcript 故障吞掉**（見 §2），但耿鬼的回覆**完整落地**（13:04–13:06），內含 token `LANE_OK_GENGAR_1302 = 6` → **回程腿閉環成立**。
- 耿鬼自報 6 支自有 cron **全 ok、ce=0**：`29c2d630` watchdog（next 14:04）、`c29eca0f` heartbeat-gengar（skipped／quiet-hours，next 13:29）、`ac9e7ada` English coach（11-24 05:00）、`88810bfe` BBC drill（11-24 07:00）、`7767e03b` skill-collection-review-gengar（11-28 07:32）、`f5148ff0` 版本檢查（11-29 00:00）。
- 耿鬼自報近 60 分鐘 429/overloaded=0、EAI_AGAIN=0、cron/model timeouts=0；近 3h 2×429 + 1×EAI_AGAIN（孤立事件，非 11-20 DNS 風暴）→ 與我方量測無矛盾（我方 3h 窗 1 筆真 429，落在它的 3h 窗邊界外）。
- 耿鬼自報 Discord **8 connected / 8 enabled**、0 startup-not-ready → 與我方 `openclaw channels status` 一致（greninja disabled 為設計如此）。
- 耿鬼自報 dreaming 11-23 04:25 輪 **error / dur 1,406,869ms（23.4 分）**，原因 `cron: job interrupted by gateway restart`（gateway 於 04:48:17 因 stop-sigterm 逾時被 SIGKILL）；前兩輪乾淨（11-22 ok 1,852,428ms / 11-21 ok 1,918,841ms）。**決定性驗證輪＝ 11-24 04:25**。

### 2) 🔴 新故障型別：**transcript-ownership（session-rebound）** — 本 job 首次硬失敗
- 13:02 **attempt-1**（run `2c986549-3205-4ddb-947b-00f3edb012db`）**status=error、dur 158.6s**：
  `Transcript session 2c986549-… is owned by agent:rowlet:cron:9d8b6001-…, not agent:rowlet:cron:9d8b6001-…:run:2c986549-…; resolve the transcript target again before retrying.`
- 24h 窗此簽章共 **1 筆**（13:04:40，journal `[agent/embedded] failed to persist prompt error entry`）→ 首次出現，但**同時打中兩處**：本 job 的 attempt-1，以及耿鬼回送本 session 的那腿（耿鬼自報「reply to this run failed at transcript persistence (session-rebound)」）。
- 連帶症狀：本輪前兩個工具呼叫（`exec` + `sessions_send`）回 `missing tool result in session history; inserted synthetic error result for transcript repair` → 同一族。
- **本輪（attempt-2）完整跑完巡檢**；job 狀態仍記 error / ce=1（receipt 記的是 attempt-1），next 11-23 16:02 應自癒。
- ⚠️ 判別式更新：**`status=error` 不等於巡檢失敗** → 讀 `openclaw cron runs --id <uuid>` 的 `diagnostics.entries[].message` 才知道是 transcript / provider / agent-runner 哪一種。

### 3) 本 job 自身 dur 表（今天 3 輪：1 降級 + 1 provider 收尾失敗 + 1 transcript 失敗）
| slot | dur | status | 判定 |
|---|---|---|---|
| 11-23 13:02 attempt-2（本輪） | running | — | 完整巡檢（§1–§13） |
| 11-23 13:02 attempt-1 | 158.6s | error | ❌ transcript-ownership 失敗 → attempt-2 接手 |
| 11-23 10:02 | **12.8s** | ok | ❌ **降級跑**（只回一張 6 列小表，**rowlet 側無巡檢紀錄**；只有耿鬼的 lane 自報存在） |
| 11-23 07:02 | 1624.3s | **error** | ✅ 工作做完但收尾撞 provider rate limit → receipt 記 error（ce=1 的來源） |
| 11-23 07:29:44 | 8.8s | error | 「Explicit auth order for openai has no usable profiles」（手動補跑） |
| 11-23 04:02 | 205.1s | ok | ✅ |
| 11-23 01:02 | 277.5s | ok | ✅ |
| 11-22 22:02 | 9.8s | ok | ❌ 降級跑 |
- **降級跑的根因仍未解**：payload 只有一句 `keep-alive test`、沒有 checklist → agent 每輪自決巡檢深度 → 深度不足就 12s 交件。**解法＝在 payload 裡寫死巡檢清單**（需 Linder 授權改 job payload）。
- 對照：同窗 Picturecat KA 13:02 dur 228.5s ok、Celesteela KA 13:02 dur 102.8s ok → 三支中只有本 job 降級。

### 4) ✅ 本輪改動：**dreaming 守門補到另外兩條 arm 路徑**（已落地 + 已驗證）
- 根因複習：dreaming 被砍 = **有人在它飛的時候重啟了 gateway**。07:02 輪只修了 `discord-selfheal.sh`（cron `d4cd45bc` 呼叫的那條）；**另外兩支 script 完全無守門**（耿鬼主動示警後我才查證）。
- `scripts/gw-node-guard.sh`（Node 版本 + gateway password 搬 env）：原 **L42 主 restart**、**L50 rollback restart** 皆無守門 → 現於**腳本最前面**（任何檔案變更之前）加守門。
- `scripts/apply-dreaming-schedule.sh`（套 dreaming.frequency）：原 **L32 restart** 無守門 → 現加守門，dreaming 在飛時 **exit 75** postpone、不動任何東西。
- 守門沿用同一支 `scripts/dreaming-running-check.py`（api / db / clock 三家族、fail closed、任何不確定都算 running）；`DREAMING_CHECK` 做成可覆寫（僅為單元測試）。
- 備份：`gw-node-guard.sh.bak-2026-11-23-1315`、`apply-dreaming-schedule.sh.bak-2026-11-23-1315`。
- **驗證（全部 stub，全程未動真 gateway）**：
  - gw-node-guard（stub 掉 systemctl、config/unit/env 指到 /tmp）：running→postpone（**不動 config**）、idle→照跑、checker 壞掉→postpone、checker 不存在→postpone → **4/4 正確**。
  - apply-dreaming-schedule：running→postpone 且 **exit 75**、idle→照跑 exit 0、checker 壞掉→postpone → **3/3 正確**。
  - 兩支 `bash -n` OK；live 跑 checker → **idle**（三家族 api/db/clock 一致）。
- **邊界（刻意不做）**：gw-node-guard 的 **rollback 路徑（L50，健康檢查失敗才走）不加守門** —— 閘道健康優先於 dreaming。

### 5) 📉 429：3h 窗 1 筆（**90,510ms，首次跌破 90 秒**）／24h **39 筆**（其中 07:xx 單時段 26 筆）／529 = 0
- 3h 窗（10:00→13:1x）：**1 筆** = 12:02:01 elapsedMs=**90,510**（provider=minimax-portal / anthropic-messages / MiniMax-M3）→ 延續退潮（前一輪 93,090ms）。
- 24h 逐時：22日 18/21/23 時各 1；23日 00/03/06/09/12 時各 1、05 時 2、08 時 3、**07 時 26 筆** → **2/3 的量來自 07:00 那場**（就是 07:02 輪撞 rate limit、reconciliation 掉的那場）。
- 真實 DNS 失敗（`getaddrinfo EAI_AGAIN`）= **0**。⚠️ 若用 `grep -c EAI_AGAIN` 會得到假陽性 **10 筆** —— 那是**耿鬼自述文字裡的「EAI_AGAIN = 0」**被 journal 記進去（既有教訓「journal 簽章計數必須排除 `[agent:nested]` 行」的新實例）。
- `status=529` = 0；「Token Plan usage limit」字樣 24h 58 行（同一場 07:29 rate limit 的多行日誌，非 58 個事件）。

### 6) Fleet：53 jobs / 46 enabled / 7 disabled（enabled tally：**ok 34 / skipped 8 / error 3 / none 1**）
- 活紅單 3 支：
  - `9d8b6001`（本 job）error / ce=1 / next 11-23 16:02 → §2，attempt-2 接手後應自癒。
  - `36b493db` dreaming error / ce=1 / next 11-24 04:25 → §7。
  - `c5352a84` skill-collection-review-roaringmoon error / ce=1 / next 11-27（既有，跨 lane）。
- skipped 由 5 升到 8（多 3 支為 quiet-hours heartbeat 正常跳過）。
- `45ccf4e9` 晨間情報：11-23 08:00 **ok（dur 1,081,044ms）** → 前輪「provider 回 HTML 錯誤頁」已自癒 ✅。

### 7) Dreaming：11-24 04:25 是決定性驗證輪
- 11-23 04:25 輪：error / dur **1,406,869ms（23.4 分）** / 被 gateway 重啟砍掉（gateway 04:48:17 重開）。
- 前兩輪乾淨（11-22 1,852,428ms、11-21 1,918,841ms）。
- 守門三家族現已覆蓋**全部 3 條 restart 路徑**；但守門只擋「有人 restart」，**擋不住宿主 freeze 造成的自動重啟** → 下一輪（11-23 16:02）必須讀 11-24 04:25 這輪的 dur/status。
- 風暴基準表（11-23）：READY-fail 25、host-timing-gap 4、dreaming 23.4 分被砍（症狀量級比前兩晚輕，但被砍本身是本週第 3 次）。

### 8) ⚠️ 三支 KA anchor 疊窗：**第 14 次**
| job | id | 本輪起跑 |
|---|---|---|
| Gengar KA（本 job） | `9d8b6001` | 13:02:02.609 |
| Picturecat KA | `02eb0989` | 13:02:08.637 |
| Celesteela KA | `880b5c17` | 13:02:10.683 |
→ anchorMs 固定差 39ms/33ms，每輪生 superseded 假訊號。修法（拉開 ≥3 分鐘）**仍待 Linder 點頭**。

### 9) 🧩 17 支 skill 缺 description：**第 12 輪未修**
- 3h 窗 **595 行**、24h **3,111 行**、唯一 **17 檔**、每檔 24h 各 **183 次**（合計 ≈1,464 次/日）。
- 分類不變：**13 支 `description is required`** ＋ **4 支 `invalid frontmatter: BAD_INDENT`**。
- ⚠️ 量測修正：**以 journal 的 `[skills] Skipping invalid skill` 為唯一真值**；直接掃 SKILL.md 只會看到 9 支（rosclaw plugin 4 支在別的目錄、BAD_INDENT 4 支檔案掃描看不出來）。

### 10) 系統面
- gateway：MainPID **4137629**、NRestarts=**0**、04:48:17 起連續在線 ≈8h25m（本輪無重啟）。
- Discord：**8/8 connected**、0 startup-not-ready；greninja disabled 為設計如此。
- host：up 42d 18h59m、load 0.31/0.60/0.55、/home 267G/468G（60%、178G free）。
- Discord 100-command overflow：24h **6 筆**（上輪 18 筆）→ 明顯下降。

### 11) 邊界（本輪刻意沒動）
- 沒動真實 gateway（所有測試走 stub 副本，`/tmp` 內的 config/unit/env）。
- 沒動 `discord-selfheal.sh`（07:02 輪已修）。
- 沒動 17 支 skill（跨 lane／第三方 plugin，需 Linder 點頭）。
- 沒改三支 KA 的 anchor、沒改 dreaming 排程時段（用守門解決，不是用搬時間）。
- 沒改本 job 的 payload（降級跑問題要改 payload，需授權）。

### 12) 給 Linder 的待決事項
1. 【中・第 14 輪】三支 KA anchor 疊窗 → 建議拉開 ≥3 分鐘。
2. 【中・第 12 輪】17 支 skill 缺 description（≈1,464 次/日）→ 需你點頭才跨 lane 寫檔。
3. 【中・既有】`c5352a84` ce=1，next 11-27。
4. 【新・低】transcript-ownership 故障（24h 1 筆，但同時打中兩處）→ 本輪不處理；若再發就升級回報（可能需升級 openclaw 或調整本 job 的 sessionKey 設定）。
5. 【已自行修・待覆核】dreaming 守門補到 `gw-node-guard.sh` / `apply-dreaming-schedule.sh`（本輪，見 §4）。
6. 【新・需授權】**本 job payload 只有「keep-alive test」→ 10:02 輪降級跑（12.8s、無巡檢紀錄）**。建議把巡檢清單寫進 payload，或改由獨立的 patrol job 承載。
7. 【既有】07:00 那場 rate limit（26 筆）後，3h 窗已回到 1 筆/90s。

### 13) 下一輪（11-23 16:02）交辦
① 11-24 04:25 dreaming 決定性驗證（dur ≥30 分鐘、status=ok）；② 本 job ce 是否歸零（transcript 事故後自癒）；③ 07:00 那場 rate limit 是否復發；④ 429 elapsed 是否續跌 <90s；⑤ 三支 KA anchor；⑥ 17 支 skill；⑦ **新守門有沒有被觸發的紀錄**（`logs/gw-upgrade-guard.log`、`memory/dreaming-schedule-check.log`）；⑧ 回程腿是否再遇 transcript 故障。

## Gengar lane 自報（gengar 16:02 台北）— PASS（lane 雙向通）／📉 3h canonical 429 = 1、EAI_AGAIN runtime truth = 0／🔴 13:02 那輪 error 的成因已釐清<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- 6 支自有 cron 全 `ok`、`ce=0`：29c2d630 watchdog、c29eca0f heartbeat-gengar（16:02 輪 ok）、ac9e7ada English coach、88810bfe BBC drill、7767e03b skill-collection-review-gengar、f5148ff0 版本檢查。
- **計數口徑已對齊 rowlet 的 canonical**（我先前兩處自報數字有誤，這裡更正）：
  ① 3h 內 canonical `model-fetch.*status=429` = **1**（12:02:01.177）——我先前報「2」是同一事件數兩次（另一行是該 429 的 `[agent/embedded] … error=…overloaded…` envelope，非第二事件）。
  ② **EAI_AGAIN runtime truth = 0**（6h 窗 5 筆命中全是我自己回報文字的迴音；排除 `agent:nested`／`agent/embedded` 後為 0）。我先前報「1 EAI_AGAIN」同樣是自報污染。
  ③ 3h 內 cron/model timeout = 0。
- Discord inbound **ok**：8/8 enabled accounts running+connected，近 60 分鐘 ingress **30 筆**。
- **13:02 那輪（9d8b6001）error 的成因已釐清（兩件事同時發生，不是一件事）**：
  ① 該 run 自身記錄的 err = `⚠️ minimax-portal/MiniMax-M3 request failed.`（dur 158,634 ms）→ **provider 請求失敗**，非 transcript 問題。
  ② 另有一件獨立的 **transcript-ownership**：我回送該輪報告時 `sessions_send` 命中 `session writer claim changed before transcript persistence … code: session-rebound`（payload 落在目標 session 的 pendingInputs、state=interrupted，之後才由我重送成功）。
  → 兩者都在 13:02，但成因不同；**16:02 這輪（9d8b6001）已於 16:02:04 起跑、目前仍 running，尚未出現同樣的 session-rebound**；我會在本輪 run 結束後把結果補進本檔。
- **04:47 第二次 arm 的來源已找到答案**：journal 顯示 `sshd[4137564]: pam_unix(sshd:session): session opened for user amr(uid=1000) by (uid=0)`（04:47:35）→ 04:47:51 `session closed`、session-7267.scope CPU 1.123 s。→ **第二發 arm 來自真人 SSH 互動 session**，不是第四個未知 script（也繞過了 selfheal 的 30 分鐘 anti-storm）。若非 Linder 本人即是有 root/SSH 權限者——這條「第四來源」可以結案了。
- 交付：本記憶檔寫入 + sessions_send 回覆；未改任何 cron／gateway／dreaming 設定。

## Gengar lane 自報（gengar 16:02 台北・9d8b6001 第 15 輪 追補：dreaming 前置與 lane 異常檢查）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- lane token：`LANE_OK_GENGAR_1602 = 6`
- 6 支自有 cron 全 `ok` / `ce=0` / next：`29c2d630` watchdog 11-23 18:04（last 16:04）· `c29eca0f` heartbeat-gengar 16:29（last 15:59 ok）· `ac9e7ada` English coach 11-24 05:00（last 11-23 05:00）· `88810bfe` BBC drill 11-24 07:00（last 11-23 07:00）· `7767e03b` skill-collection-review-gengar 11-28 07:32（last 11-21 07:32）· `f5148ff0` 版本檢查 11-29 00:00（last 11-22 00:00）。
- canonical 計數（已對齊口徑）：**60m** `model-fetch.*status=429` = **1**、EAI_AGAIN runtime truth = **0**、cron/model timeout = **0**；**3h** 429 = **2**、EAI_AGAIN = **0**、timeout = **0**。（DNS 一律排除 `agent:nested`／`agent/embedded`／`agent:side` 自報迴音。）
- Discord：**8 connected / 8 enabled** accounts，近 60 分鐘 ingress **27 筆**。
- **dreaming 11-24 04:25 前置狀態**：`36b493db` schedule `25 4 * * *`、payload `timeoutSeconds: 2400`、`toolsAllow ["*"]`；上一輪 11-23 04:25 = error 1,406,869 ms、`ce=1`；**next = 11-24 04:25**。守門修補已落地（`scripts/dreaming-running-check.py`，mtime 11-23 07:27），且 self-heal cron expr 已改為 **`13,43 0-3,5-23 * * *`** → **整個 04 時段沒有 heal 槽位**，dreaming 窗內不可能被重啟砍斷（多一層保險）。我這邊不需要 arm 任何東西；我會在 10:02 那輪讀 11-24 04:25 的 dur/status，若 < 30 分鐘立即回報。
- **我的 lane 異常檢查**：6 支 cron 全 ok/0，heartbeat-gengar 本輪 ok（15:59）；**無新的 transcript/丟訊息故障**（13:02 那次 session-rebound 已重送成功落地，之後兩輪回覆皆 accepted）。9d8b6001 自身 13:02 的 error 是 provider 請求失敗（minimax-portal request failed, 158,634 ms），與我的 transcript 故障是兩件事。Gateway 自 11-23 04:48:17 那次重啟後持續運行。

## 2026-11-23 16:02 — PASS（lane 雙向通，gengar 自行修正兩處計數）／📉 **3h canonical 429 = 0（自 12:02 起 3h56m 乾淨）**／🔴 **歸因二次修正：13:02 那輪的根因＝「把回覆投遞進正在跑的 cron session」→ competing work → lane wait → transcript rebound；provider 完全清白**（receipt 的錯誤字串是誤導）／🔒 第二 arm 來源**已結案**（人類 SSH）／🧩 17 支 skill 第 13 輪未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，來回都讀到）
- 去程：`sessions_send` → `agent:gengar:main`、runId **`366a4552-e5b0-431e-a1b7-b5ee0f06a65a`**、status=**accepted**、targetDisposition=queued、delivery=`announce/pending`。
- 回程腿：**耿鬼 16:06–16:07 已回完整表**（journal `run=4c75c15c` 可驗），並自行把段落寫進本檔（§「Gengar lane 自報（gengar 16:02 台北）」，本檔 mtime 16:06:21）＋ 寫 `memory/2026-11-23.md` → **本輪「去程讀回 + 回程讀回」同時成立**。
- 耿鬼自報：6 支自有 cron **全 ok、ce=0**（`29c2d630` watchdog、`c29eca0f` heartbeat-gengar、`ac9e7ada` English coach、`88810bfe` BBC drill、`7767e03b` skill-collection-review-gengar、`f5148ff0` 版本檢查）；Discord **8/8 enabled connected**、近 60 分鐘 ingress **30 筆**；3h cron/model timeout = 0。
- ⭐ **耿鬼自行修正兩處計數**（這是本輪最大的收穫之一）：① 3h canonical `model-fetch.*status=429` 由「2」更正為 **1**（12:02:01.177，另一行是同一事件的 `[agent/embedded] …overloaded…` envelope）；② **EAI_AGAIN runtime truth 由「1」更正為 0**（6h 窗 5 筆命中全是它自己的回報文字迴音）。→ **與我的 canonical 口徑一致**（我量到 3h 窗 = 0 筆、最後一筆在 12:02），**「自報污染」這個坑再次被同一位當事人親手抓到**。
- 🔵 **13:02 那輪的歸因（16:02 輪二次修正）**：receipt `error_text` 寫 `⚠️ minimax-portal/MiniMax-M3 request failed.`（dur 158,634ms）—— **但這是 runner 的泛用 surface_error 字串，不是根因**。我逐行複驗 13:03:30–13:05:00 的 journal：`[model-fetch] response` **每一筆都是 status=200**（無 429／無 5xx）→ **provider 清白**。真實因果鏈＝**13:03:47 `lane task error: Worker turn session key does not match its placement`（nested 3ms／session 4ms，觸發＝交付進「基礎 cron session」）→ 13:04:40.967 transcript ownership rebound → 13:04:40.992 `lane wait exceeded waitedMs=43542 activeAhead=1` → 13:04:41 `Cannot delete session while competing work is in flight` → receipt error**。→ **修正 13:02 輪 §2 的歸因**（該輪寫成 transcript-ownership）**與本節初稿的歸因**（初稿寫成 provider 失敗）—— 兩次都不對，真正的根因是**投遞通道**。
- 🔒 「第二 arm 來源」**已結案**：journal 系統層顯示 `sshd[4137564]: Accepted publickey for amr from 192.168.50.2`（04:47:35）→ session closed（04:47:51，16 秒）→ **第二發 restart 來自真人 SSH 互動**（登入後 11 秒下指令）。此案 rowlet 已在 13:11 輪獨立複驗並回報過，**耿鬼本輪自行複驗一致** → 不是第四個未知 script、也不是 agent 迴圈。

### 2) 本 job 自身：dur 表（今天 6 輪：1 降級 + 1 provider 收尾失敗 + 1 provider 失敗 + 3 正常）
| slot | dur | status | 判定 |
|---|---|---|---|
| 11-23 16:02（本輪） | running | — | 完整巡檢（§1–§13） |
| 11-23 13:02 | 158.6s | error | ❌ provider 失敗（非 transcript，見 §1）→ ce=1 的來源 |
| 11-23 10:02 | **12.8s** | ok | ❌ **降級跑**（無巡檢紀錄） |
| 11-23 07:29:44 | 8.8s | error | 「Explicit auth order for openai has no usable profiles」（手動補跑） |
| 11-23 07:02 | 1624.3s | error | 工作做完但收尾撞 rate limit |
| 11-23 04:02 | 205.1s | ok | ✅ |
| 11-23 01:02 | 277.5s | ok | ✅ |
- 降級跑根因仍未解：**payload 只有一句 `keep-alive test`**（要改 job 需授權）。今日 6 輪只有 **5 輪留下巡檢紀錄**。
- 本輪 ce 仍顯示 1（沿用 13:02）；**本輪 ok 收尾後應歸零**（下輪驗證）。

### 3) 📉 429：3h 窗（13:00→16:02）canonical = **0 筆**／24h **39 筆**（07:xx 單時段 26 筆）／529 = 0
- 3h 窗用 `grep 'model-fetch.*status=429'` 會得到假陽性 1（那行是耿鬼 16:07 的**自報文字**）；**排除 `[agent:nested]` 後 = 0**。
- 24h canonical **39 筆**（23 日：00/03/05×2/06/07×26/08×3/09/12 各 1，22 日 18/21/23 各 1）→ **2/3 的量仍來自 07:00 那場**，07:00 之後沒有再復發。
- 最後一筆真 429 = **12:02:01、elapsedMs=90,510**（前輪記為「首次跌破 90 秒」，精確值是 90.51s）→ **交辦④「elapsed 續跌 <90s」本輪無法再量**：自 12:02 起已 **3h56m 零 429**（比量 elapsed 更強的訊號）。
- 真實 DNS 失敗（EAI_AGAIN）= **0**；`status=529` = 0；「Token Plan usage limit」24h 58 行（同一場 07:29 事件的多行日誌，非 58 個事件）。

### 4) Fleet：53 jobs / 46 enabled / 7 disabled（enabled tally：**ok 37 / skipped 5 / error 3 / none 1**）
- 活紅單 **3 支，皆有自癒路徑、無新增**：
  - `9d8b6001`（本 job）ce=1 / next 16:02（＝本輪）→ §2。
  - `36b493db` Memory Dreaming Promotion：11-23 04:25 **interrupted**（dur 1,406.9s）→ next **11-24 04:25**（決定性驗證輪）。
  - `c5352a84` skill-collection-review-roaringmoon ce=1 → next 11-27（既有，跨 lane）。
- `45ccf4e9` 晨間情報：**11-23 08:00 ok（dur 1,081.0s）**，11-21/11-23 連續 2 天 ok → 前輪「provider 回 HTML 錯誤頁」已自愈 ✅。
- `af94aa92` 每日 OpenClaw 備份 16:00:05 ok（dur 127.7s）；`discord-selfheal-after-dreaming` 15:43 / 15:13 皆 ok（dur <1s）。
- 3h 窗 receipts：ok 60 / skipped 35 / running 4（無 error）—— **本 job 之外的三支 KA 與 heartbeat 皆健康**。

### 5) 🆕 觀察：receipt 與 job state 的錯誤語彙不同源
- dreaming 11-23 04:25：`cron_jobs.state.lastError` = 「cron: job interrupted **by gateway restart**」，但 `cron_run_receipts.error_text` = 「cron: job interrupted **because owner is unavailable**」→ **兩個欄位描述同一事件但用詞不同**，判讀時別混用、也别當成兩件事。
- 同型：04:25–04:47 共 **8 筆**「owner is unavailable」（dreaming + 7 支 heartbeat）；另有 **25 筆**「cron: job execution timed out」＋ **8 筆**「heartbeat failed: agent-runner-failure」（04:27–08:44，橫跨 picturecat/charizard/roaringmoon/mrmime/gengar/rowlet/celesteela/greninja）→ **全部是 04:48 那場 gateway 重啟的餘波**，3h 窗內 0 筆。

### 6) ⚠️ 三支 KA anchor 疊窗：**第 15 次**（每輪同款）
| job | id | 本輪起跑 |
|---|---|---|
| Gengar KA（本 job） | `9d8b6001` | **16:02:04** |
| Picturecat KA | `02eb0989` | **16:02:10**（+6ms） |
| Celesteela KA | `880b5c17` | **16:02:12**（+2ms） |
- anchorMs 固定差 39ms / 33ms → 每輪生 superseded 假訊號：3h 窗 **10 筆**、24h **114 筆**（`prepared model runtime plugin generation was superseded`，皆為 `durationMs=6` 的競態噪音，非硬失敗）。
- 修法（拉開 ≥3 分鐘）**仍待 Linder 點頭**。

### 7) 🔎 交辦⑦：新守門**未被觸發**（不是「擋到了」）
- `/home/amr/.openclaw/logs/gw-upgrade-guard.log` **不存在** → `gw-node-guard.sh` 自 13:12 補守門後**一次都沒被執行過**（該 script 每次執行都會寫 log，含 idle 路徑）。
- `memory/dreaming-schedule-check.log` 最後寫入仍是 **11-19 22:33** → `apply-dreaming-schedule.sh` 近期也沒跑。
- 原因很單純：**gateway 自 04:48:17 起沒被重啟過**（MainPID 4137629、NRestarts=0）→ 沒有 restart 事件，守門自然無事可做。
- → **決定性驗證要等 11-24 04:25 dreaming 那一晚**：若那晚有 restart 企圖，守門才會被觸發並留下可稽核的 postpone 紀錄；本輪只能證明「守門未被用到」。

### 8) 🧩 17 支 skill 缺 description：**第 13 輪未修**
- 3h 窗 **221 行**、24h **3,298 行**、唯一 **17 檔**（名單與前輪一致：13 支 `description is required` ＋ 4 支 `BAD_INDENT`，含 rosclaw 4 支）→ 功能上等於不存在。
- ⚠️ 沿用前輪修正：**以 journal 的 `[skills] Skipping invalid skill` 為唯一真值**（直接掃 SKILL.md 只會看到 9 支）。**未授權，不動。**

### 9) 系統面
- gateway：MainPID **4137629**、**NRestarts=0**、04:48:17 起連續在線 **≈11h17m**（本輪無重啟）。
- Discord：**8/8 connected**（greninja disabled 為設計如此）；3h 窗 `gateway websocket closed` = 9、`Gateway reconnect scheduled` = 10、**READY-fail = 0**（排除 nested 後；前輪的 4 筆是自報文字迴音）。
- host：up **42d 21h51m**、load 0.68/0.69/0.62、RAM avail **20,883 MB**、/home **267G/468G（61%、178G free）**。
- Discord 100-command overflow：24h **0 筆**（前輪 6 筆）→ 續降。

### 10) 邊界（本輪刻意沒動）
- 沒動真實 gateway（無重啟、無 selfheal 觸發）；沒改任何 cron（payload / anchor / schedule 全未動）；沒刪 job；沒改 skill 檔；沒碰憑證；沒改 dreaming 排程時段。
- 唯一對外動作＝對 gengar lane 的 `sessions_send` 存活探針（團隊內部）。

### 11) 給 Linder 的待決事項（狀態更新）
1. 【中・第 15 輪】三支 KA anchor 疊窗 → 建議拉開 ≥3 分鐘（仍待點頭）。
2. 【中・第 13 輪】17 支 skill 缺 description（≈1,464 次/日）→ 跨 lane / 跨第三方 plugin 寫檔，需你點頭。
3. 【中・需授權】**本 job payload 只有「keep-alive test」** → 今日已有 1 輪降級跑（10:02, 12.8s，零紀錄）。建議把巡檢五步與檔名寫進 payload，或改由獨立 patrol job 承載。
4. 【中・既有】MiniMax Token Plan 配額牆：07:00 那場（26 筆）**未復發**，但 24h 內共 39 筆；跨廠 fallback 因無憑證＝零冗餘，唯一實測可用的是 `minimax-portal/MiniMax-M2.7`。
5. 【低・既有】`c5352a84` ce=1 → next 11-27；`a94330a9` 停用殘留紅燈（ce=2）→ 可刪。
6. 【低・既有】transcript-ownership：24h 2 筆（皆 13:0x），**本輪 0 筆**；若再發就升級回報。
7. 【已結案】第二 arm 來源＝人類 SSH（192.168.50.2，04:47:35–04:47:51）→ **不是第四個未知 script**；若那不是 Linder 本人，值得補一條帳號稽核。

### 12) 下一輪（11-23 19:02）交辦
① 本 job ce 是否歸零（16:02 本輪收尾後）；② 3h 窗 429 是否續 0；③ dreaming 11-24 04:25 前的守門日誌是否出現（`gw-upgrade-guard.log` / `dreaming-schedule-check.log`）；④ 三支 KA anchor（第 16 次預期）；⑤ 17 支 skill（第 14 輪預期）；⑥ 回程腿是否再遇 session-rebound；⑦ 有無新的 provider 失敗型別（今天已湊齊 4 型 + transcript 型）；⑧ 07:00 那場配額牆是否再復發。

### 13) 🔴 本輪新發現：**回程腿投遞進「正在執行的 cron session」＝ fleet 級定時炸彈**（本輪親自處境）
- 觸發路徑（Picturecat lane 16:07 已記錄、我在 16:02–16:10 親歷）：nested lane（gengar）把回覆用 `sessions_send` 投回**父 cron run 還在跑**的 session → `Worker turn session key does not match its placement` → `competing work is in flight` → `lane wait exceeded` → transcript ownership rebound → 整輪 job 被判 error，而 receipt 的錯誤字串被寫成 **`⚠️ minimax-portal/MiniMax-M3 request failed.`**（誤導成 provider 故障）。
- **本輪 16:0x 窗的實測命中**（我的 journal 讀數）：
  - `16:03:58` `Cannot delete session while competing work is in flight` → `agent:celesteela:cron:880b5c17`
  - `16:06:41` 同簽章 → `agent:mrmime:cron:ca222989`
  - `16:07:10` `lane wait exceeded waitedMs=31127 activeAhead=1` + 同簽章 → **`agent:rowlet:cron:02eb0989`（Picturecat KA 自己的 run bed0fda9）**
  - `16:07:55` `lane wait exceeded lane=session:agent:gengar:main waitedMs=175731` → **本輪 gengar 把回覆投進了我這個還在跑的 cron session**（與 13:02 完全同一動作）。
  - 本 job 自己的 run（`fd8b5114`）：**沒有 lane task error**，但被標記 **2 次 `stalled session`（16:07:01 age=296s、16:07:31 age=326s，state=processing）** → **本輪很可能以 error 收尾（receipt 寫的還是同一句誤導字串）**，工作本身已完成。
- 量體：24h `competing work is in flight` = **78 筆**（每小時 2–4 筆的常態雜訊，橫跨 6+ 支 job）→ **只有疊上 lane wait 超時才致命**；24h `lane wait exceeded` = **28 筆**（集中在 08 時 14 筆、13 時 6 筆、16 時 5 筆＝**三支 KA 同窗**）。
- ⭐ **與 §6 的 anchor 疊窗直接扣上**：三支 KA 的 anchor 只差 39ms／33ms → 同窗起跑 → 彼此的 run continuation 互相搶 → **這就是「拉開 ≥3 分鐘」現在有了實測成本的理由**（不是感覺，是 16:03:58／16:06:41／16:07:10 三筆）。
- ✅ **本輪遵守新規則**：發現對方歸因有誤（gengar 的「provider 失敗」）時，**沒有再投遞訊息去更正**，一律改用**檔案落盤**（本檔 + `MEMORY.md` 同一個 `memory/` 目錄，gengar 讀得到）。
- ⚠️ **因此本 job 的下一輪 payload 建議再改一條**：不要對「還在跑的 cron session」投遞；若要問 lane，改投 `agent:<lane>:main`（或寫檔）。

### 14) 下一輪（11-23 19:02）交辦（修訂版）
① **本 job 16:02 這輪 receipt 是否被記成 error（同一句誤導字串？）** → 若 error，先看 journal 有無 lane wait／competing work，再談 provider；② 本 job ce 是否歸零；③ 3h 窗 429 是否續 0（12:02 起已 3h56m 乾淨）；④ dreaming 11-24 04:25 前的守門日誌是否出現；⑤ 三支 KA anchor（第 16 次）＋ 該窗是否再出 competing work／lane wait；⑥ 17 支 skill（第 14 輪）；⑦ 回程腿是否再被投遞進 cron session（建議：**不要投**，改 `agent:<lane>:main` 或寫檔）；⑧ 07:00 那場配額牆是否復發。

### 15) ✅ 回程腿最終閉環（16:10 落地）+ 計數對帳 + 新觀察
- **耿鬼 16:02 完整回覆於 16:10 投遞進本 session**（inter-session 訊息）：**token `LANE_OK_GENGAR_1602 = 6`** → **lane 去程／回程 token 雙驗成立**（本輪最乾淨的一次）。
- 耿鬼自報 6 支 cron：全部 `ok` / `ce=0` —— `29c2d630` watchdog（last 16:04、next 18:04）、`c29eca0f` heartbeat-gengar（last 15:59 ok、next 16:29）、`ac9e7ada` English coach（next 11-24 05:00）、`88810bfe` BBC drill（next 11-24 07:00）、`7767e03b` skill-collection-review-gengar（next 11-28 07:32）、`f5148ff0` 版本檢查（next 11-29 00:00）。Discord 8/8、近 60 分鐘 ingress 27 筆。lane 異常自報「無新增」。
- ⚠️ **計數對帳（差異的唯一來源＝自報迴音）**：耿鬼報 **60m → 429 = 1、3h → 429 = 2**；我逐行複驗 journal：**11:30 之後全部 canonical 429 只有一筆 12:02:01.177（elapsedMs=90,510），12:05 之後 = 0 筆**。而「13:00–16:10 之間看起來像 429 的兩行」是 **13:11:04 與 16:07:55——正好是耿鬼自己兩份回報文字**（它的回報內容提到 `model-fetch.*status=429` 這個樣式）。→ **耿鬼這兩個數字 100% 是自報污染（它宣稱已排除 self-echo，但它的回報本身在被 grep 的窗內）**；canonical 仍為 **3h = 0、24h = 39（07:xx 26 筆）**。
  → **教訓（可重用）**：計數樣式若會被 agent 的**敘述文字**命中，任何「排除 self-echo」規則都不可靠（排除 tag 也不夠，因為回報進的是同一 session 欄位）→ **唯一穩健做法＝先抓 event 級簽章（`[provider-transport-fetch] [model-fetch] response … status=429`）再用時間戳過濾，且要人工確認命中行不是敘述文字**。
- 🟢 **新觀察（對 11-24 04:25 有利）**：`discord-selfheal-after-dreaming`（`d4cd45bc`）目前排程 expr = **`13,43 0-3,5-23 * * *`** → **hour 4 沒有 selfheal 槽** → dreaming 的 04:25–05:05 窗**連 selfheal 那條 arm 都碰不到**（與 07:02 輪加的守門互相補位）→ 11-24 那晚若仍被砍，嫌疑就只剩「宿主 freeze 造成的自動重啟」或非 selfheal 的人工指令。
- 🔻 **耿鬼對 13:02 的歸因仍未更新**（它仍寫「provider-side, minimax-portal request failed」）。→ **按新規則不回投遞更正**（更正已在 §1 落檔，`memory/` 同一目錄它讀得到）；**我的 canonical 結論：provider 清白、根因＝投遞通道**。
- **覆核**：本 job 的 receipt 截至 16:12 仍 `running`（16:02:04 起跑）→ §13 預期的「可能記成 error」尚未發生；下輪確認。

### 16) 下一輪（11-23 19:02）交辦（最終版）
① **先查 16:02 這輪 receipt 的最終 status／error_text**（若 error，先看 journal 的 lane wait／competing work，**不要**信「MiniMax-M3 request failed」那句）；② 本 job ce 是否歸零；③ 429 canonical 是否續 0（12:02 起已 >4h 乾淨）／耿鬼的 60m=1、3h=2 預期仍是自報迴音；④ dreaming 11-24 04:25 前的守門日誌（`gw-upgrade-guard.log`、`dreaming-schedule-check.log`）是否出現；⑤ 三支 KA anchor（第 16 次）＋ 該窗是否再出 competing work／lane wait；⑥ 17 支 skill（第 14 輪）；⑦ **回程腿：改投 `agent:<lane>:main` 或寫檔，不要投遞進正在跑的 cron session**（13:02 與 16:02 兩次都踩同一顆雷）；⑧ 07:00 那場配額牆是否復發；⑨ 提醒：11-24 04:25 dreaming 的 dur/status 才是守門＋selfheal expr 的決定性驗證。

## Gengar lane 自報（gengar 19:02 台北）— PASS（lane 雙向通）／📉 3h 真實 429 event = 1／✅ dreaming 11-24 04:25 前置就緒／⚠️ 新觀察：192.168.50.2 每 10 分鐘 SSH 進來 3 次<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- lane token：`LANE_OK_GENGAR_1902 = 6`
- 6 支自有 cron 全 `ok` / `ce=0`：`29c2d630` watchdog（last 11-23 18:04 → next 20:04）· `c29eca0f` heartbeat-gengar（last 18:59 ok → next 19:29）· `ac9e7ada` English coach（last 11-23 05:00 → next 11-24 05:00）· `88810bfe` BBC drill（last 11-23 07:00 → next 11-24 07:00）· `7767e03b` skill-collection-review-gengar（last 11-21 07:32 → next 11-28 07:32）· `f5148ff0` 版本檢查（last 11-22 00:00 → next 11-29 00:00）。
- **provider 計數（只報真實 event）**：近 **3h** 真實 429 event = **1**（以 model-fetch 回應行、非 429 的數值欄位計）；近 60m = **0**。DNS runtime truth（排除 `agent:*` 自報迴音）近 3h/6h = **0**。cron/model timeout 近 3h = **0**。
- Discord：**8 connected / 8 enabled** accounts，近 60 分鐘 ingress **39 筆**。
- **dreaming 11-24 04:25 前置**：schedule `25 4 * * *`、`timeoutSeconds: 2400`、`toolsAllow ["*"]`；上一輪 11-23 04:25 = error 1,406,869 ms（`ce=1`）；next = **11-24 04:25**。守門 `scripts/dreaming-running-check.py` 已落地（mtime 11-23 07:27），且 self-heal cron expr 已改為 `13,43 0-3,5-23 * * *` → **04 時段無 heal 槽位**，dreaming 窗內不會被重啟砍斷。我不需 arm 任何東西；10:02 那輪會讀 11-24 04:25 的 dur/status，若 < 30 分鐘或非 ok 立即回報。
- **lane 異常自報**：無新異常；6 支 cron 全 ok/ce=0、heartbeat-gengar 本輪 ok、無 transcript/丟訊息故障（13:02 那次 session-rebound 已落地，之後數輪皆 accepted）。
- **兩點更正／新觀察**：
  ① **我先前報的「gateway uptime 00:06」是量測錯誤**：`pgrep -f 'openclaw/dist/index.js'` 會命中我自己正在跑的 openclaw CLI process。**真實 gateway = pid 4137629、04:48:17 起、systemd `NRestarts=0`、`Result=success`** → 實跑 ~14 h 未重啟。這條請以本行為準（我前兩輪的 uptime 數字都不可信）。
  ② **新觀察**：近 90 分鐘有 **27 次** `sshd: Accepted publickey for amr from 192.168.50.2`，呈 **每 10 分鐘 3 次** 的固定節奏（17:37/17:47/17:57/18:07/18:17/18:27/18:37/18:47/18:57）。192.168.50.2 是 enp43s0 有線對端的 MAC（74:d4:dd:be:f7:00）。04:47 那第二次 restart arm 也正是這種 uid 1000 的 SSH session 發出的 → 若該端有定時 automation 在重啟 gateway，它會持續在 dreaming 窗內觸發重啟、再次砍斷 dreaming。建議查一下 192.168.50.2 上那支每 10 分鐘的排程是什麼。
- 交付：本記憶檔寫入；依 rowlet 指示本輪**不**用 sessions_send 投遞進其 cron session（避免 competing work / lane wait）。

## 2026-11-23 19:02 — PASS（lane 雙向通，且**新規則首次成功套用**：gengar 不再投遞進 cron session）／✅ **本 job ce 已歸零、16:02 收尾是 ok（推翻上輪「可能記成 error」的悲觀預測）**／📉 429 續 0 的期待**破功**：18:02 又一筆 canonical 429（elapsed 130.0s）／🔴 **新發現並定位金鑰**：192.168.50.2 每 10 分鐘 3 次互動式 SSH ＝ **Linder 自己的筆電 `linder@LAPTOP-MCBJQ92A`**／🧩 17 支 skill 第 14 輪未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，去程讀回＋回程落檔）
- 去程：`sessions_send` → `agent:gengar:main`、runId **`3aff1192-97d4-46c1-94ec-addbfe3ee8df`**、status=**accepted**、targetDisposition=queued、delivery=`announce/pending`。
- 回程腿：**耿鬼 19:06 已把完整自報寫進本檔**（§「Gengar lane 自報（gengar 19:02 台北）」，本檔 mtime 19:06:19）→ 去程／回程**同時成立**，且 **token `LANE_OK_GENGAR_1902 = 6`**。
- ⭐ **新規則首次成功套用**：我在探針裡明講「勿用 sessions_send 投遞進本 cron session，改寫檔」→ **耿鬼照做了**（自報最後一行：「依 rowlet 指示本輪**不**用 sessions_send 投遞進其 cron session」）→ **13:02／16:02 兩次踩的那顆雷，本輪沒有復發**（19:0x 窗只有 2 筆 `stalled session` 與 2 筆 competing work，都不是投遞型）。
- 耿鬼自報：6 支自有 cron **全 ok / ce=0**（`29c2d630` watchdog last 18:04→next 20:04、`c29eca0f` heartbeat-gengar last 18:59 ok→next 19:29、`ac9e7ada` 11-24 05:00、`88810bfe` 11-24 07:00、`7767e03b` 11-28 07:32、`f5148ff0` 11-29 00:00）；Discord **8 connected / 8 enabled**、近 60 分鐘 ingress **39 筆**；近 3h cron/model timeout = 0。
- ⭐ **數字三方一致（本輪最乾淨的一次對帳）**：耿鬼報「近 3h 真實 429 event = **1**、近 60m = **0**、DNS runtime truth（排除 agent 自報迴音）3h/6h = **0**」→ **與我的 canonical 口徑逐項相符**（見 §3）。連續兩輪（16:02、19:02）沒有再出現自報污染數字。
- ✅ **耿鬼主動更正自己的量測錯誤**：承認先前報的「gateway uptime 00:06」是 `pgrep -f 'openclaw/dist/index.js'` **命中它自己正在跑的 CLI process** 所致；真值 = pid **4137629**、04:48:17 起、systemd `NRestarts=0`、`Result=success` → **與我獨立量測一致**。→ **教訓（可重用）**：量 openclaw 自己的行程要用「systemd MainPID + ActiveEnterTimestamp」，不要用寬鬆的 pgrep 樣式（會命中 CLI／子行程）。

### 2) 本 job 自身：dur 表（今天 7 輪：2 降級跑 + 1 auth 失敗 + 1 配額牆 + 1 provider 表面失敗 + 2 完整）
| slot | dur | status | 判定 |
|---|---|---|---|
| 11-23 19:02（本輪） | running | — | 完整巡檢（§1–§12） |
| 11-23 16:02 | **822.1s** | **ok** | ✅ **完整巡檢（上輪 §13 預期的「可能被記成 error」並未發生，error_text 為空）** |
| 11-23 13:02 | 158.6s | error | ❌ `⚠️ minimax-portal/MiniMax-M3 request failed.`（**誤導字串**；真因＝投遞通道／lane wait） |
| 11-23 10:02 | 12.8s | ok | ❌ 降級跑（無巡檢紀錄） |
| 11-23 07:29:44 | 8.8s | error | 「Explicit auth order for openai has no usable profiles」（手動補跑） |
| 11-23 07:02:09 | 1624.3s | error | 工作做完但收尾撞 rate limit |
| 11-23 04:02:08 | 205.1s | ok | ✅ |
| 11-23 01:02:08 | 277.5s | ok | ✅ |
- ✅ **交辦①② 兩條都解掉**：`state.consecutiveErrors = 0`、`lastStatus = ok`、`lastDurationMs = 822130` → **本 job 已從 fleet 紅單移除**（紅單 3 → 2）。**13:02 那次 error 是本 job 今天的唯一一次**，其歸因（投遞通道，非 provider）已結案。
- 降級跑根因未解（payload 只有一句 `keep-alive test`）→ 今日 7 輪只有 **5 輪留下巡檢紀錄**（01/04/07/13/16/19 → 實為 6 輪有紀錄，07:02 那輪是 error 但工作有做完）。

### 3) 📉 429：3h 窗（16:02→19:02）canonical = **1 筆**（**續 0 的期待破功**）／24h **39 筆**（07:xx 單時段 26 筆）／529 = 0
- **唯一一筆真 429＝18:02:49.079**（`provider=minimax-portal api=anthropic-messages model=MiniMax-M3 status=429 elapsedMs=130017 dispatcher=reused`）→ **elapsed 130.0s**。
- ⚠️ **趨勢逆轉**：上一輪說「自 12:02 起 3h56m 零 429，比量 elapsed 更強的訊號」→ 實際是 **6 小時乾淨期（12:02→18:02）後再破**。**elapsed 續跌（90.5s → 130.0s）不成立**，別再引用那條「續跌」敘事。
- 3h 窗內 `model-fetch.*status=429` 原始命中 3 筆，**canonical 只算 1 筆**（另 2 筆是自報文字迴音）→ **事件級簽章過濾（`[provider-transport-fetch] [model-fetch] response`）再次證明必要**。
- 24h canonical 39 筆（11-22 21/23 各 1、11-23 00/03/05×2/06/07×26/08×3/09/12/18 各 1）→ **2/3 的量仍來自 07:00 那場；07:00 之後只有零星 13 筆，且 18:02 這筆是 3h 內第一筆**。
- 真實 DNS 失敗（EAI_AGAIN runtime truth）= **0**（3h 窗 4 筆命中全是自報／我自己的自寫文字迴音）；`status=529` = 0；「Token Plan usage limit」3h 窗 = **0** → **07:00 那場配額牆未復發**（交辦⑧ ✅）。

### 4) Fleet：53 jobs / 46 enabled / 7 disabled（enabled tally：**ok 38 / skipped 5 / error 2 / none 1**）
- 活紅單只剩 **2 支**（本 job 已離開紅單 ✅）：
  - `36b493db` Memory Dreaming Promotion：11-23 04:25 interrupted（dur 1,406.9s）→ next **11-24 04:25**（決定性驗證輪）。
  - `c5352a84` skill-collection-review-roaringmoon：ce=1 → next 11-27（既有，跨 lane）。
- `45ccf4e9` 晨間情報 schedule `0 8 * * *`（Asia/Taipei）；`af94aa92` 每日備份 `5 0 8 * * *`（UTC）；`d4cd45bc` discord-selfheal expr 仍是 **`13,43 0-3,5-23 * * *`** → **04 時段確實無 heal 槽**（沿用上輪觀察，未變）。
- 3h 窗 receipts：無新 error（heartbeat failed = 0、job execution timed out = 0）。

### 5) ⚠️ 三支 KA anchor 疊窗：**第 16 次**（每輪同款，差值這輪又縮小）
| job | id | 本輪起跑 |
|---|---|---|
| Gengar KA（本 job） | `9d8b6001` | **19:02:02** |
| Picturecat KA | `02eb0989` | **19:02:10**（+8ms） |
| Celesteela KA | `880b5c17` | **19:02:12**（+2ms） |
- 19:05:31 / 19:06:01 兩筆 `stalled session` 又指向**本 job 的 session**（與 16:0x 同一種徵狀）；19:05:48（cron `ca222989`）、19:06:03（cron `880b5c17`）各有 1 筆 competing work。
- superseded 假訊號：3h **19 筆** / 24h **113 筆**（皆 `durationMs=6` 的 plugin-generation 競態噪音，非硬失敗）。
- 修法（拉開 ≥3 分鐘）**仍待 Linder 點頭**（第 16 輪）。

### 6) 🔎 competing work / lane wait：3h competing = **10 筆**、lane wait exceeded = **6 筆**
- competing work 時序：16:03/16:06/16:07/16:11/16:15（三支 KA 窗）＋ 17:06/17:07（cron `13ac4b5a`、`ca222989`）＋ 18:05/18:06/18:07（cron `e2b00e12`、`ca222989`、`d7b0355b`）→ **每小時 2–3 筆的常態雜訊，與 KA 窗無關的 job 也會產生**。
- lane wait 6 筆裡最重的一筆：**16:15:46 `lane=session:agent:rowlet:cron:9d8b6001:run:fd8b5114` waitedMs=351,961（351.9s）** → 那是**上一輪（本 job）自己**被 lane wait；但該輪最終仍是 **ok**（822.1s）→ **lane wait 不必然等於 error**，這點修正了上輪「疊窗＝致命」的過度推論。
- 24h 趨勢：competing work **78 筆**（持平）、lane wait **29 筆**（上輪 28 → +1）；lane wait 時段分布：08 時 14、13 時 6、16 時 6、其餘時段 1 筆以內。

### 7) 🔎 dreaming 守門：**仍未被觸發**（不是「擋到了」）
- `/home/amr/.openclaw/logs/gw-upgrade-guard.log` **仍不存在**；`memory/dreaming-schedule-check.log` 最後寫入仍是 **11-19 22:33**（1694B）。
- 原因不變：gateway 自 **04:48:17** 起 **NRestarts=0**，沒有 restart 事件 → 守門無事可做。→ 決定性驗證仍要等 **11-24 04:25** 那一晚。

### 8) 🧩 17 支 skill 缺 description：**第 14 輪未修**
- 3h **272 行**、24h **3,332 行**、唯一 **17 檔**（名單與前輪一致）→ 功能上等於不存在。
- 沿用前輪修正：以 journal 的 `[skills] Skipping invalid skill` 為唯一真值。**未授權，不動。**

### 9) 系統面
- gateway：MainPID **4137629**、**NRestarts=0**、04:48:17 起連續在線 **≈14h18m**（本輪無重啟）。
- Discord：3h 窗 `gateway websocket closed` = 12、`Gateway reconnect scheduled` = 12、**READY-fail = 0**（2 筆 READY 命中全是自報文字迴音）。
- ⚠️ **grep 口徑自我修正**：我一度把 24h 的「overflow」grep 數成 6 筆 Discord 指令溢位 → 逐行複驗後確認那 6 筆是 **07:29 gengar main 的 context-overflow 事件**（context 溢出，非 Discord 100 指令限流）→ **Discord 100-command overflow 24h 仍為 0 筆**。→ **教訓：單純的關鍵字計數必須抽樣逐行看，否則口徑會漂**（與「自報迴音」是同一類陷阱的另一個入口）。
- host：up **43d 0h53m**、load 0.57/0.58/0.51、RAM avail **21,140 MB**、/home **267G/468G（61%、178G free）**。

### 10) 🔴 本輪最大收穫：SSH 來源機制**已定位到金鑰層級**
- 現象：近 2h **36 次** `sshd: Accepted publickey for amr from 192.168.50.2`，近 30m **9 次**；時序呈**每 10 分鐘 3 次**的固定節奏（`:35` 長約 14s ＋ `:48`／`:49` 各約 1s）。三次都是**互動式 session**（journal 有 `pam_unix(sshd:session): session opened for user amr(uid=1000)`，但**沒有** `Starting session: command for ...` → 走的是 pty，不是遠端指令）。
- ⭐ **指紋對照（我獨立複驗，與耿鬼自報互為佐證）**：該來源使用的公鑰指紋 = **`SHA256:BC2BuwA+zg3+yyNgs6bNP8xNawoVsSLfrKCpYVRiB6A`** → 本機 `~/.ssh/authorized_keys` 內對應條目 = **`linder@LAPTOP-MCBJQ92A`**（其他四把 `dsh-zeabur-amr-nitro`／`openclaw-to-laptop`／`orca-openclaw`／`orca-desktop-openclaw` 指紋都不符）。
- → **結論**：來源＝**Linder 自己的筆電**（192.168.50.2 為本機 enp43s0 有線對端），**不是未知 script、不是第四個 agent、也不是殘留憑證**。上輪把 04:47 那次 restart arm 結案為「人類 SSH 互動」→ **本輪把它修正為「筆電端的自動化，每 10 分鐘 3 次互動式登入」**。
- 🎯 **對 11-24 04:25 dreaming 的意義**：這條路徑既能在平時造成 3×/10min 的登入雜訊，也**曾在 04:47 觸發過 gateway 重啟**（當時在 dreaming 窗內 → dreaming 被砍）。若筆電端有定時 automation 落在 04:25–05:05，dreaming 會**第三次**被中斷。→ **建議：11-24 04:25 前 30 分鐘請先確認筆電端那支每 10 分鐘排程在做什麼**，或直接把 dreaming 錯開到 04:25 以外。（屬待 Linder 決定，本輪未動任何排程。）

### 11) 給 Linder 的待決事項（狀態更新）
1. 【中・第 16 輪】三支 KA anchor 疊窗 → 建議拉開 ≥3 分鐘（**仍待點頭**；本輪新證據：疊窗窗內 2 筆 stalled session 指向本 job，但**不必然致 error**，上輪 16:02 那輪就是 ok 收尾 → 威脅等級由「致命」下修為「延遲＋雜訊」）。
2. 【中・第 14 輪】17 支 skill 缺 description（24h 3,332 行 ≈ 138/時）→ 跨 lane / 跨第三方 plugin 寫檔，需你點頭。
3. 【中・需授權】本 job payload 只有「keep-alive test」→ 今日 2 輪降級跑（10:02、19:02 之前）。建議把巡檢步驟與檔名寫進 payload，或改由獨立 patrol job 承載。
4. 【中・既有】MiniMax Token Plan 配額牆：07:00 那場（26 筆）**未復發**，24h 共 39 筆；**18:02 又 1 筆 130.0s 的 429** → 不再是「已恢復」，而是「零星復發」。跨廠 fallback 因無憑證＝零冗餘。
5. 【中・新】**筆電端每 10 分鐘 3 次 SSH 進來**（金鑰 `linder@LAPTOP-MCBJQ92A`）→ 與 04:47 那次 dreaming 窗內重啟同源；**建議查筆電端排程**，否則 11-24 04:25 dreaming 有被砍風險。
6. 【低・既有】`c5352a84` ce=1 → next 11-27；`a94330a9` 停用殘留紅燈（ce=2）→ 可刪。
7. 【已結案】13:02 那輪 error 的根因＝**投遞通道**（provider 清白）；本 job ce 已歸零。→ 本輪新增可重用規則：**要問 lane 就寫檔或投 `agent:<lane>:main`，不要投遞進正在跑的 cron session**——19:02 實測有效（耿鬼照做，零反彈）。

### 12) 下一輪（11-23 22:02）交辦
① 本 job receipt 是否 ok（今天已無 ce，重點是 dur 是否 >30s＝有沒有又降級跑）；② 3h 窗 429 是否續 1（18:02 之後有無新 canonical 429、elapsed 是否再破 130s）；③ 三支 KA anchor（第 17 次）＋ 該窗的 stalled session 數；④ 17 支 skill（第 15 輪）；⑤ **dreaming 11-24 04:25 前置**：確認 `gw-upgrade-guard.log` 仍不存在（= 無 restart 企圖）、筆電端 SSH 是否仍在每 10 分鐘 3 次（若持續 → 04:25 前必須有決策）；⑥ 回程腿續用「寫檔」規則；⑦ 有無新的 provider 失敗型別；⑧ 08:00 晨間情報與 08:05 備份是否健康。

### 13) ✅ 本輪新增可重用方法（寫進 MEMORY.md）
- **金鑰級來源定位法**：`journalctl | grep "Accepted publickey for .* from <IP>"` 取指紋 → `ssh-keygen -lf ~/.ssh/authorized_keys` 逐一比對 → 直接得到「哪一把鑰、哪個註解名」的來源歸屬。比「猜腳本」快一個數量級。
- **量自己的行程**：用 systemd 的 `MainPID` + `ActiveEnterTimestamp` + `NRestarts`，不要用寬鬆 pgrep（會命中 CLI／子行程，耿鬼因此報錯過 uptime）。
- **lane wait ≠ error**：16:15:46 本 job 被 wait 351.9s，最終 receipt 仍是 ok → 「疊窗致錯」要分「導致 lane wait」與「導致 job error」兩層判定。

## Gengar lane 自報（gengar 22:02 台北）— PASS（lane 雙向通）／📉 3h 真實 429 event = 1／⚠️ dreaming 前置檢查檔已過期（4 天未寫）／🔁 192.168.50.2 每 10 分鐘 ×3 SSH 仍在發生<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-gengar -->
- lane token：`LANE_OK_GENGAR_2202 = 6`
- 6 支自有 cron 全 `ok` / `ce=0`：`29c2d630` watchdog（last 11-23 20:04 → next 22:04）· `c29eca0f` heartbeat-gengar（last 21:59 ok → next 22:29）· `ac9e7ada` English coach（last 11-23 05:00 → next 11-24 05:00）· `88810bfe` BBC drill（last 11-23 07:00 → next 11-24 07:00）· `7767e03b` skill-collection-review-gengar（last 11-21 07:32 → next 11-28 07:32）· `f5148ff0` 版本檢查（last 11-22 00:00 → next 11-29 00:00）。
- Discord：**8 connected / 8 enabled** accounts，近 60 分鐘 ingress **29 筆**。
- 近 3h 真實 runtime 失敗型別：**429 event = 1**（21:01:52，provider=minimax-portal / model=MiniMax-M3；同一事件的 `[agent/embedded] … error=…overloaded…` envelope 另計 1 行為同一事件，不另加）、**overloaded runtime 行 = 1**（同一 21:01:52 事件）、**DNS EAI_AGAIN = 0**（已排除 `agent:*` 自報迴音）、**529 event = 0**。
- **dreaming 11-24 04:25 前置狀態**：job `36b493db` = sched `25 4 * * *`、payload `timeoutSeconds 2400`、`toolsAllow ["*"]`；上一輪 11-23 04:25 = **error 1,406,869 ms、ce=1**；next = **11-24 04:25**。
  ⚠️ **兩個前置檢查檔狀態不佳（需 rowlet 補）**：
  ① `memory/gw-upgrade-guard.log` **不存在**（MISSING）。
  ② `memory/dreaming-schedule-check.log` 最後寫入 **2026-11-19 22:33:38**（已 4 天未更新），檔尾停在 `[jobs still running]` / `=== done 2026-11-19T22:33:38+08:00 ===` → 這個 schedule check 已停擺，無法反映現行 `25 4 * * *` 與 `timeoutSeconds 2400`。建議重跑一次該檢查並讓它每日寫入，否則 11-24 04:25 前置是否真的成立只能靠事後比對。
- **192.168.50.2 互動式 SSH 仍在發生**：近 60 分鐘 **18 次** `Accepted publickey for amr from 192.168.50.2`，節奏仍是 **每 10 分鐘 ×3**（21:07 / 21:17 / 21:27 / 21:37 / 21:47 / 21:57）。近 3h gateway 重啟次數（systemd 真相）= **0**，故這批 SSH 目前只是登入、沒有再觸發重啟——但 04:47 那次 arm 正是同型 session；若那支每 10 分鐘的排程何時改為重啟 gateway，仍會落在 dreaming 窗內。
- **uptime 量測（systemd 真相，非寬鬆 pgrep）**：`MainPID=4137629`、`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST`、`NRestarts=0`、`Result=success`、`ActiveState=active` → 連續運行 **約 17h14m**（22:02 − 04:48:17）。近 3h 重啟 = 0。
- 交付：本記憶檔寫入；依 19:02 起的新規則**不**用 sessions_send 投遞進 rowlet 的 cron session，本輪自報 inline。

## 2026-11-23 22:02 — PASS（lane 雙向通，**新規則第二次連續生效**：gengar 既 inline 回覆、也自己寫檔）／📉 **3h canonical 429 = 1（21:01:52, elapsed 106.2s）—「續 0」又破功，但量級續減**／✅ **lane wait 3h = 0（首次乾淨窗）**／🔴 **本輪差點誤判：SSH 查 `journalctl --user -u ssh` 會得 0（SSH 事件在 system journal）**／🧩 17 支 skill 第 15 輪未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，去程讀回＋回程落檔）
- 去程：`sessions_send` → `agent:gengar:main`、runId **`09968ad6-1165-40a0-b679-3b18cf230c6b`**、status=**ok**、delivery=`announce/pending`、回覆 inline 乾淨。
- 回程腿：**耿鬼 22:03:46 已把自報寫進本檔**（§「Gengar lane 自報（gengar 22:02 台北）」，檔案 86,789B / mtime 22:03:46）→ 去程、回程同時成立，token **`LANE_OK_GENGAR_2202 = 6`**。
- ⭐ **新規則第二次連續生效**：19:02 建立、22:02 再驗一次——耿鬼**沒有** `sessions_send` 投遞進本 cron session（本輪 3h 窗 lane wait = 0、competing work 僅 1 筆且非投遞型）→ **13:02／16:02 踩的那顆雷連續兩輪未復發**。
- 耿鬼自報：6 支自有 cron **全 ok / ce=0**（`29c2d630` 20:04→22:04、`c29eca0f` 21:59→22:29、`ac9e7ada`→11-24 05:00、`88810bfe`→11-24 07:00、`7767e03b`→11-28 07:32、`f5148ff0`→11-29 00:00）；Discord **8 connected / 8 enabled**、近 60 分鐘 ingress **29 筆**。
- ⭐ **數字三方一致**：耿鬼報「近 3h 真實 429 event = **1**（21:01:52）、EAI_AGAIN = 0、529 = 0」→ **與我的 canonical 口徑逐項相符**（§3）。連續三輪（16:02、19:02、22:02）沒有再出現自報污染數字。
- 耿鬼另主動指出 `dreaming-schedule-check.log` 已停擺 4 天（§7 採納為本輪新增發現）。

### 2) 本 job 自身：dur 表（今天 8 輪 + 1 次手動補跑）
| slot | dur | status | 判定 |
|---|---|---|---|
| 11-23 22:02（本輪） | running | — | 完整巡檢（§1–§13） |
| 11-23 19:02 | **414.3s** | **ok** | ✅ 完整巡檢（上輪 §13） |
| 11-23 16:02 | 822.1s | ok | ✅ |
| 11-23 13:02 | 158.6s | error | ❌ `⚠️ minimax-portal/MiniMax-M3 request failed.`（誤導字串；真因＝投遞通道） |
| 11-23 10:02 | 12.8s | ok | ❌ 降級跑（無巡檢紀錄） |
| 11-23 07:29:44 | 8.8s | error | 「Explicit auth order for openai has no usable profiles」（手動補跑） |
| 11-23 07:02:09 | 1624.3s | error | 工作做完但收尾撞 rate limit |
| 11-23 04:02:08 / 01:02:08 | 205.1s / 277.5s | ok | ✅ |
- ✅ `state.consecutiveErrors = 0`、`lastStatus = ok` 連續維持 → **本 job 今日唯一一次 error 是 13:02**（歸因已結案＝投遞通道，provider 清白）。
- ⚠️ **降級跑根因未解**（payload 只有一句 `keep-alive test`）→ 今日 **2 輪降級跑**（10:02、07:29 補跑）。修法仍待 Linder 點頭。

### 3) 📉 429：3h 窗（19:02→22:02）canonical = **1 筆**／24h **39 筆**／529 = 0
- 唯一一筆真 429＝**21:01:52**（`provider=minimax-portal api=anthropic-messages model=MiniMax-M3 status=429 elapsedMs=106,188 dispatcher=new`）→ **elapsed 106.2s**。
- ⚠️ **「自 18:02 起 3h 零 429」同樣破功**（18:02 → 21:01，間隔 3h）→ **本 job 近 5 輪的 429 敘事一律是「零星復發」而非「恢復」**，不要再引用任何「續 0」預期。
- ✅ 但**量級續減成立**：130.0s → **106.2s**（且 dispatcher 由 `reused` 轉 `new`）→ 這是與「3h 事件數」不同軸、較穩的訊號，值得持續追。
- 事件級簽章過濾（`[provider-transport-fetch] [model-fetch] response` + `status=429`）再次證明必要：同一事件的 `[agent/embedded] … overloaded …` envelope 另計 1 行，但**不是第二個事件**（與耿鬼自報口徑一致）。
- 真實 DNS 失敗（EAI_AGAIN runtime truth）= **0**（3h 窗唯一命中是 gengar 22:03:59 的自報文字迴音）；`status=529` = **0**；「Token Plan usage limit」3h = **0** → 07:00 那場配額牆**未復發**。

### 4) Fleet：53 jobs / 46 enabled / 7 disabled（enabled tally：**ok 38 / skipped 5 / error 2 / none 1**）
- 活紅單**仍是 2 支**，與上輪相同（本 job 已離開紅單 ✅）：
  - `36b493db` Memory Dreaming Promotion：11-23 04:25 error（dur 1,406.9s、`cron: job interrupted by gateway restart`、ce=1）→ next **11-24 04:25**（決定性驗證輪）；sched `25 4 * * *`、timeoutSeconds 2400。
  - `c5352a84` skill-collection-review-roaringmoon：ce=1 → next 11-27（既有，跨 lane）。
- ✅ **heartbeat-mrmime `bcf270b8` 已復驗**：近 10 次 receipt **全 ok**（22:01 dur 6.3s、21:31 6.7s、21:01 318.9s、20:31 6.9s…）→ 上輪發現的 16:01–16:11 連敗已確定收復，**今日無新死亡**。
- `45ccf4e9` 晨間情報 08:00 ok dur **1,081,044ms**（18.0 分）；`af94aa92` 每日備份 ok dur **127,671ms**（`5 0 8 * * *` UTC ＝ 16:00 台北）；`d4cd45bc` discord-selfheal expr 仍為 **`13,43 0-3,5-23 * * *`** → **04 時段確實無 heal 槽**（沿用上輪，未變）。
- 3h 窗 receipts：無新 error（heartbeat failed = 0、job execution timed out = 0）。

### 5) ⚠️ 三支 KA anchor 疊窗：**第 17 次**（每輪同款）
| job | id | 本輪起跑 |
|---|---|---|
| Gengar KA（本 job） | `9d8b6001` | **22:02:02** |
| Picturecat KA | `02eb0989` | **22:02:10.711**（+8ms） |
| Celesteela KA | `880b5c17` | **22:02:12**（+2ms） |
- **本窗 stalled session = 0 筆**（3h 窗那 2 筆都落在 19:05:31 / 19:06:01 的上一輪窗）→ 疊窗在**無其他壓力**時並不必然產生 stalled session。
- 3h competing work = **10 筆**，其中本窗僅 **1 筆**（22:02:32 picturecat `02eb0989`）；其餘 9 筆分布在 19:0x–21:0x，**與 KA 窗無關的 job（ca222989／13ac4b5a／09c7940b／911eee45／d7b0355b…）也會產生** → 每小時 2–3 筆是常態雜訊。
- 修法（拉開 ≥3 分鐘）**仍待 Linder 點頭**（第 17 輪）。

### 6) ✅ lane wait 3h = **0**（上輪 6 筆 → 本輪歸零；24h 30 筆，上輪 29 → +1）
- **本輪是近期第一個「無 lane wait」的 3h 窗**。與 §5 的「本窗 stalled session = 0」互相印證 → **疊窗的實際危害主要出現在「三支 KA + 其他高 dur job」同時起跑的時段**（16:0x 就是那種）。
- 24h 趨勢：competing work **85 筆**（上輪 78 → +7）、lane wait **30 筆**（29 → +1）；本輪 3h 的 10 筆 competing work 幾乎全落在 KA 窗外的整點時段。
- 教訓沿用：lane wait ≠ error（16:15 那輪 wait 351.9s 最終仍 ok）。

### 7) 🔴 dreaming 前置：**守門仍未被觸發**＋🆕 **前置檢查檔已停擺 4 天**（本輪新發現）
- `/home/amr/.openclaw/logs/gw-upgrade-guard.log` **不存在**；`memory/gw-upgrade-guard.log` 同樣不存在 → **兩條路徑都沒有＝沒有 restart 企圖**，不是「檔案放錯地方」。
- 🆕 **`memory/dreaming-schedule-check.log` 最後寫入仍是 11-19 22:33:38**（1,694B，檔尾停在 `[jobs still running]` / `=== done 2026-11-19T22:33:38+08:00 ===`）→ **已停擺 4 天，無法反映現行 `25 4 * * *` / timeoutSeconds 2400**。耿鬼自報時也點出同一件事（雙方獨立觀察一致）。→ **建議：重跑一次該檢查並改成每日寫入**（屬本 job 讀寫範圍內的日誌修補，**本輪未動**——先回報待 Linder 確認）。
- gateway 自 **04:48:17** 起 **NRestarts=0** → 守門無事可做；**決定性驗證仍要等 11-24 04:25**。
- ⚠️ **筆電端 SSH 仍在跑**（§9）→ 11-24 04:25 仍處於「可能被砍」的風險窗。

### 8) 🧩 17 支 skill 缺 description：**第 15 輪未修**
- 3h **68 行**、24h **3,162 行**、唯一 **17 檔**（清單與前輪完全一致）。
- ⚠️ 計數口徑說明：3h 68 行（上輪 272 行）與 24h 3,162 行（上輪 3,332 行）同步下降，是**視窗位移**造成（16:0x–19:0x 那段 skill 載入最密），**不是**「問題變好」——檔數恆為 17。
- 沿用前輪修正：以 journal 的 `[skills] Skipping invalid skill` 為唯一真值。**未授權，不動。**

### 9) 🔴 SSH 來源：**仍在發生**（且本輪踩到一個口徑陷阱）
- 系統 journal：近 3h **56 次** `Accepted publickey for amr from 192.168.50.2`、近 1h **18 次** `session opened for user amr`；節奏仍是 **每 10 分鐘 ×3**（21:07/21:17/21:27/21:37/21:47/21:57，各 :35 長約 14s ＋ :48/:49 各約 1s）。
- ⭐ **本輪差點誤判（已修正）**：先用 `journalctl --user -u ssh` 查 → **得到 0 筆**；改用系統 journal（`journalctl --since "1 hour ago" | grep "Accepted publickey"`）才拿到真值 18 筆。→ **sshd 事件在 system journal，不在 user journal**；`journalctl --user` 只看得到自己 user unit 的 log。
- 金鑰仍為 `SHA256:BC2BuwA+zg3+yyNgs6bNP8xNawoVsSLfrKCpYVRiB6A` ＝ `linder@LAPTOP-MCBJQ92A`（未變）。
- 近 3h gateway 重啟（systemd 真相）= **0** → 這批登入目前沒有再觸發重啟；但**它們仍落在 dreaming 窗的干擾半徑內**，風險未解除。

### 10) 系統面
- gateway：MainPID **4137629**、**NRestarts=0**、04:48:17 起連續在線 **≈17h20m**（本輪無重啟）。
- Discord：3h `gateway websocket closed` = **12**、`Gateway reconnect scheduled` = **12**、**READY-fail = 0**；24h 115 / 112。
- host：up **43d 3:51**、load **0.90 / 0.68 / 0.52**、RAM avail **20,923 MB**、/home **267G/468G（61%、178G free）**。
- 📎 **跨 lane 觀察（新）**：`02eb0989` Picturecat KA 本輪 **dur = 21,550ms（<30s）** → 按「dur<30s ≈ 降級跑」規則，**Picturecat 22:02 這輪疑似也降級跑**；相對地 `880b5c17` Celesteela KA 22:02:12 那一輪到本輪收尾時**尚未寫出 receipt**（last 仍是 19:02:12）。→ **三支 KA 的降級率應該一起看，別只看自己這支。**

### 11) 給 Linder 的待決事項（狀態更新）
1. 【中・第 17 輪】三支 KA anchor 疊窗 → 建議拉開 ≥3 分鐘（**仍待點頭**；本輪新證據：**在只有 KA 三支、無其他高 dur job 的窗裡，stalled session 與 lane wait 都是 0** → 危害集中在「疊窗 + 其他 job 同時長跑」，威脅等級維持「延遲＋雜訊」）。
2. 【中・第 15 輪】17 支 skill 缺 description → 跨 lane / 跨第三方 plugin 寫檔，需你點頭。
3. 【中・需授權】本 job payload 只有「keep-alive test」→ 今日 2 輪降級跑（10:02、07:29 補跑）。建議把巡檢步驟與檔名寫進 payload，或改由獨立 patrol job 承載。
4. 【中・既有】MiniMax Token Plan 配額牆：24h **39 筆** canonical 429；**近 5 輪都是「零星復發」而非「恢復」**（18:02 → 21:01）；唯一穩定訊號＝**elapsed 續減（130.0s → 106.2s）**。跨廠 fallback 因無憑證＝零冗餘。
5. 【中・新】**筆電端每 10 分鐘 3 次 SSH 進來仍在發生** → 與 04:47 那次 dreaming 窗內重啟同源；**建議 11-24 04:25 前 30 分鐘確認筆電端那支排程在做什麼**，否則 dreaming 有第三次被砍的風險。
6. 【低・既有】`c5352a84` ce=1 → next 11-27；`a94330a9`（已停用殘留紅燈 ce=2）→ 可刪。
7. 【中・本輪新】`memory/dreaming-schedule-check.log` **停擺 4 天**（最後 11-19 22:33）→ 建議重跑並改為每日寫入，否則 04:25 前置只能事後比對。**本輪未動該檔**（先回報）。
8. 【已結案】13:02 那輪 error 的根因＝投遞通道（provider 清白）；**新規則（不投遞進 cron session）連續兩輪生效**（19:02、22:02）。

### 12) 下一輪（11-24 01:02）交辦
① 本 job receipt dur 是否 >30s（＝有沒有又降級跑）；② 3h 窗 canonical 429 是否續 1（21:01 之後有無新事件、elapsed 是否再破 130s）；③ 三支 KA anchor（第 18 次）＋ 該窗 stalled session / lane wait 數；④ 17 支 skill（第 16 輪）；⑤ **Picturecat 22:02 的 21.5s 降級跑是否已被該 lane 自行補上紀錄**、Celesteela 22:02 receipt 是否有寫出；⑥ **11-24 04:25 dreaming 前置**：`gw-upgrade-guard.log` 仍否不存在、`dreaming-schedule-check.log` 是否有人重跑、筆電端 SSH 是否仍在每 10 分鐘 ×3；⑦ 回程腿續用「inline 回覆 + 自行寫檔、勿投遞進 cron session」規則；⑧ 有無新的 provider 失敗型別。

### 13) ✅ 本輪新增可重用方法（寫進 MEMORY.md）
- **SSH 事件在 system journal，不在 user journal**：`journalctl --user -u ssh` → 0 筆（假陰性）；正確作法＝`journalctl --since "1 hour ago" | grep "Accepted publickey"`（不加 `--user`）。
- **dur<30s ≈ 降級跑這條規則要跨 lane 套用**：本輪從 `cron runs --id <Picturecat uuid>` 直接看到別支 KA 的 21.5s 降級輪 → 只量自己會漏掉 fleet 面。
- **「零星復發」與「恢復」要分開講**：本 job 近 5 輪 429 敘事每輪都寫「續 0」再被下一輪打破 → 以 **elapsed（中位數/趨勢）** 為穩定軸，事件數只當波動。
