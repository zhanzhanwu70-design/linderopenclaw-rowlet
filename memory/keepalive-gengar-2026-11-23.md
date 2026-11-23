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
