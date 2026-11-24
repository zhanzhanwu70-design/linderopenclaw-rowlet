# Keep-Alive 巡檢紀錄 — 2026-11-23 (Asia/Taipei)

三支 KA job（皆 `every 3h`、isolated、delivery not requested）：
`9d8b6001` Gengar KA（rowlet 執行）/ `02eb0989` Picturecat KA / `880b5c17` Celesteela KA。
本檔由 rowlet 每輪 KA 追加。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-23 01:02 — Picturecat Keep-Alive 第 1 輪（今日第 1 輪，runId `03e95d05`）

**總結：🟢 lane 存活、無硬失敗、無新增紅單。⭐ 本輪最大收穫＝「Node 版本釘死在舊版」的老記載**已證實過期**：兩個 systemd 單元早在 2026-11-19 21:13 就改成 `node v24.22.3`，gateway 於 11-21 02:11 重啟後實際跑的是新版 → MEMORY.md 該條已修正。3h 窗 2 次 429（23:02:42／00:02:34）皆被 same-model retry 1/3 救回，硬失敗 0；17 支 skill 缺 description **仍未修**（第 8 輪）。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，runId `03e95d05-8796-4a82-b703-3b6484a2dd7c`，status=ok）
- 回覆（精簡 probe，一行內）：「pong picturecat — (a) alive/idle, (b) no errors or provider 429 in last 3h, (c) no in-flight task, (d) Discord inbound ok.」
- 本 job `02eb0989`：上輪（11-22 22:02）**ok / ce=0 / dur=132,412ms**；本輪 01:02:06.137 準時觸發。
- 姊妹 job：`9d8b6001` Gengar KA（22:02:08 ok / dur 9,765ms）、`880b5c17` Celesteela KA（22:02:08 ok / dur 311,485ms）——三支同時在 01:02 進 running。

### 2) 本機量測（rowlet 側 shell，01:02）
- uptime **42d06:49**；load `0.50 / 0.41 / 0.44`；RAM 31,797MB 總 / 9,303MB used / **avail 20,953MB**；swap 0/2,047；disk `/` **60%（267G/468G，剩 178G）** → 全正常。
- gateway（**user unit** `openclaw-gateway.service`）：MainPID **3573532**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST**、ps elapsed **1-22:50:52** → **連續第 4 天未重開**；`/health` 18789 → **HTTP 200 in 8.6ms**、14177 → **HTTP 200 in 0.4ms**。

### 3) ⭐⭐ Node 版本釘死問題已解（推翻 MEMORY.md 11-19 21:00 那條記載）
- 兩個 systemd 單元的 **mtime = 2026-11-19 21:13:09**（比該條記憶的觀測時點晚 13 分鐘 → 當晚就修好了，MEMORY 沒回寫）。
- 現況：`openclaw-gateway.service` ExecStart = `/home/amr/.nvm/versions/node/v24.22.3/bin/node`（套件仍在 `v24.22.1/lib/node_modules/openclaw/dist/index.js`，符合「只換 node 路徑、不搬套件」的原修法）；`jormungandr-openclaw-bridge.service` 同樣是 v24.22.3。
- `ps -o cmd -p 3573532` 實測進程二進位 = **v24.22.3** → gateway 自 11-21 02:11 那次重啟起就跑新版，11 月 CVE 修補已實際生效。
- → MEMORY.md 已補「已過期」標註，舊 CVE 風險敘述不再適用。

### 4) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 38 / skipped 5 / error 2 / none 1
- **活紅單仍只有兩支（與上輪同，皆待自癒）**：
  - `45ccf4e9 晨間情報 pipeline (Roaringmoon)` ce=1、last 11-22 08:00、dur 937,285ms、**next 11-23 08:00**（根因＝CDN/gateway 回 HTML 錯誤頁，第 ④ 型，11-22 16:02 已定位）。
  - `c5352a84 skill-collection-review-roaringmoon` ce=1、last 11-20 03:56、dur 169,007ms、**next 11-27 03:56**（11-20 DNS 風暴餘波）。
  - `a94330a9 tmp-openai-probe` 仍是 **enabled=false 的停用殘留**（ce=2）→ 不算活紅單。
- skipped 5 支全為 heartbeat（no-route 長態、良性）。
- 三支 KA 全 enabled、everyMs=10,800,000（3h）：本輪 nextRunAtMs picturecat **1795366926137** / gengar **1795366928151** / celesteela **1795366928156** → **picturecat↔gengar 差 2.014s、gengar↔celesteela 差 5ms** → **重疊競態窗第 10 次**（本輪換成 gengar↔celesteela 差 5ms）。
- `36b493db Memory Dreaming Promotion` 仍排 **`25 4 * * *`**（last 11-22 04:25 ok、dur 1,852,428ms、next **11-23 04:25**）→ 未挪動，04:25 風暴預期原樣重現。
- `d4cd45bc discord-selfheal-after-dreaming`（`13,43 * * * *` Asia/Taipei）ok / dur 789ms / next 01:13；`911eee45 每日資安建議` 仍 **21:00:05 原槽**（ok、dur 624,182ms）。
- 今日最長執行：`36b493db` 1,852,428ms、`45ccf4e9` 937,285ms、`ae91b967` 792,986ms、`a72cb46b` 772,096ms、`911eee45` 624,182ms、`09c7940b` 544,739ms、`5b7c1082` 496,600ms。

### 5) Provider 429 / DNS（22:02→01:03 窗，journal 863 行）
- **真實 429 = 2 次**（統一口徑 `model-fetch.*status=429`）：
  - **23:02:42.881**（elapsed 158,105ms、dispatcher=new）→ runId `551cf1dc`，所屬 job **`5b7c1082 每日模型排行前十`**（sessionKey `agent:roaringmoon:cron:5b7c1082`）→ 該 job 收尾 **ok / ce=0**（last 11-22 23:03:13、dur 496,600ms）。
  - **00:02:34.658**（elapsed 122,549ms、dispatcher=reused）→ runId `35eefc68`，所屬 job **`d7b0355b` Jormungand mrmime Codex A2A heartbeat** → `rate-limit same-model retry 1/3 delayMs=10000` → **00:02:46 status=200**、00:02:47 status=200 → 該 job 收尾 **ok / ce=0**（last 11-23 00:00:31、dur 190,605ms）。
- **硬失敗 = 0**（無 3/3 耗盡）。**真實 DNS（EAI_AGAIN/getaddrinfo）= 0**；**真實 `Token Plan usage limit` = 0**（連續多輪零配額窗）。
- **正向對照**：24h `model-fetch` 3,318 行、`response status=200` 1,638 筆、429 16 筆、`isError=true` 19 行（多數是 429 的伴生行）。
- **跨廠 fallback 仍為 0**（provider 呼叫 100% `minimax-portal`，`openai/*` 全無使用）→ provider edge 出狀況只能靠同模型重試，無跨廠冗餘。

### 6) ⭐ 429 逐時退潮（24h 統一口徑 `model-fetch.*status=429`）
| 小時 (11-22) | 429 |
|---|---|
| 03 | 1 |
| 05 | 4 |
| 06 | 1 |
| 07 | 2 |
| 08 | 1 |
| 09 | 2 |
| 12 | 1 |
| 18 | 1 |
| 21 | 1 |
| 23 | 1 |
| **11-23 00** | **1** |
（00:00–03:00、04:00、10:00、11:00、13:00–17:00、19:00–22:00 全 0）
→ 24h 合計 **16 次**，全被 same-model retry 救回，**硬失敗 0**；尖峰已退到每小時 0–1 次。

### 7) Discord 現況：8/8 connected
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled＝預期）。
- 真實收發：celesteela in:7m、mrmime in/out:56m、roaringmoon in/out:2h、rowlet in:6h、charizard in/out:16h、gengar 18h；picturecat／flaaffy 無近期 inbound 但 transport=just now。
- **3h 窗（22:02→01:03）簽章**：`Gateway reconnect scheduled` **8**、`websocket closed` **8**、READY timeout **0**、channel exited **0**、client initialized **0**、delaying provider startup **0**、host timing gap **0** → **全健康，無握手失敗**。
- **24h**：reconnect **117（≈4.9/h）**、websocket closed **142（≈5.9/h）**、READY timeout **27**、channel exited **14**、client initialized **24**、host timing gap **6**（後三者全落在 dreaming 04:25 窗）、`startup-not-ready` **0**。
- **乾淨段**：最後一筆 READY-fail/channel-exit = **11-22 04:55:37** → 至 11-23 01:02 **連續 ≈20h07m 零症狀**（較上輪的 17h07m 延長）。

### 8) ⚠️ 17 支 skill 缺 description：仍未修（第 8 輪）
- 簽章 `[skills] Skipping invalid skill`：**3h 窗 408 筆、24h 3,281 筆、24h 唯一檔 = 17 支、每檔每 3h 各 24 次（≈192 次/日）** → **一支都沒修**。
- 分類不變：**13 支 `description is required`**（`card-lookup`、`meta-analyzer`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-download`、`ptcgp-card-lookup`、`system-design-six-dimensions-analyzer`、`web-fetch-troubleshooting` ＋ rosclaw plugin 下 `check-status`／`navigate-to`／`pick-object`／`take-photo`）＋ **4 支 `invalid frontmatter: BAD_INDENT`**（`excel-image-pipeline`、`human-behavior-simulation`、`image-attendant`、`ocr-confidence-mark`）。
- 驗證方式仍是「看它們不在 `<available_skills>` 清單裡」。

### 9) 上輪（11-22 22:02）§12 七項交辦逐項核對
| # | 項目 | 結果 |
|---|---|---|
| ① | 21:02 之後 429 是否歸零（22–01 窗） | ⚠️ **未歸零**：23:02:42、00:02:34 各 1 次，皆 retry 1/3 救回，所屬 job 收尾 ok → 硬失敗 0 |
| ② | `45ccf4e9` ce（08:00 前應為 1） | ✅ 仍為 1、next 11-23 08:00 → 須 08:00 後才驗得到自癒 |
| ③ | dreaming 是否仍在 04:25 槽 | ✅ 仍在（next 11-23 04:25），本窗無風暴 |
| ④ | 紅單是否仍只有兩支活 | ✅ `45ccf4e9` / `c5352a84` 未變，無新增 |
| ⑤ | skill 缺 description 是否有補 | ❌ **未補**：17 支仍每天跳過 ≈192 次（24h 3,281 筆） |
| ⑥ | gateway 是否仍 NRestarts=0 | ✅ MainPID 3573532 / NRestarts=0 / 連續 **1d22h50m** 未重開（第 4 天）；**且已實測跑在 node v24.22.3**（見 §3） |
| ⑦ | 三支 KA anchor 是否仍重疊 | ⚠️ **仍重疊**（第 10 次）：gengar 01:02:08.151 ↔ celesteela 01:02:08.156（差 5ms） |

### 10) 本輪動作：無（觀測為主）
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal（Discord 健康）、未刪 job、未改 skill 檔、未碰憑證。
- 未手動重跑 `45ccf4e9`（roaringmoon lane，11-23 08:00 每日自癒）；未刪 `a94330a9`；未修 17 支 skill（跨 lane / 跨 plugin 寫檔未經 Linder 點頭不做）。

### 11) 給 Linder 的待決事項（本輪）
1. **【中・待授權】17 支 skill 每天被跳過 ≈192 次**＝功能上等於不存在（`prompt-injection-defense`、`network-security-defense`、`ocr-confidence-mark` 全不在 `<available_skills>`）。已連續 3 輪回報未見動靜。授權後一次性修好本地 9 支（其他 lane 不動）、rosclaw 4 支走 plugin 上游。
2. **【中】dreaming 04:25 風暴**：排程未挪動 → 今日 04:25 幾乎確定原樣重現（昨日簽章：timing gap 6 / READY-fail 27 / channel-exited 14）。仍是二選一 —— (a) Discord READY 握手上限拉到 ≥300s；(b) dreaming admission suspend 期間保留既有連線的 READY deadline。
3. **【中】三支 KA 仍實質同時起跑**（本輪 gengar↔celesteela 差 5ms）→ 每輪都會生出 `plugin generation was superseded` 假訊號（本窗 2 筆）。已擱置 6 天。
4. **【中】跨廠 fallback 仍為 0** → 今日 16 次 429 全靠同模型重試救回，無跨廠冗餘。
5. **【低】`45ccf4e9` 08:00 槽**建議把 `b37129c0` jitter 釘在 +30 分（08:30 起）以錯開重疊窗。
6. **【低】`a94330a9 tmp-openai-probe`** 停用殘留紅燈（ce=2）→ 刪掉可讓紅燈計數乾淨。

### 12) 量測備忘（本輪沿用／新增）
- **gateway 一律 `systemctl --user show openclaw-gateway`**（system scope 給假訊號）。
- **429 一律用 `model-fetch.*status=429` 單一口徑**（與 22:02 輪相同，兩輪數字可直接比較）。
- **`file=` 過濾要加 `.md`**，否則 dreaming 的 `profile=sha256:…` 會混進 skill 清單。
- **`[cron:<uuid>]` 是溯源錨點**：`sessionKey=agent:roaringmoon:cron:5b7c1082` → job `5b7c1082`；`[agent/embedded]` 行則靠前後文對 job id。
- 判 429 對應哪支 job：`grep -oE 'sessionKey=agent:[a-z]+:cron:[0-9a-f]{8}'` 或鄰近 `[cron:<uuid>]`。
- restricted automation-run session 內 `automations` 工具看不到自身 job → 一律 `openclaw cron list --all --json`。

### 13) 下一輪（11-23 04:02）請確認
① 00:02 之後 429 是否歸零（01–04 窗）；② dreaming 04:25 槽是否照預期爆發（timing gap / READY-fail / channel-exited 簽章）；③ 04:25 風暴後 Discord 是否自癒（`client initialized` / `channels resolved` 收尾）；④ 紅單是否仍兩支活；⑤ 三支 KA anchor 是否仍重疊；⑥ 17 支 skill 是否有補。

## 2026-11-23 04:02 — Picturecat Keep-Alive 第 2 輪（今日第 2 輪，觸發 04:02:06）

**總結：🟢 lane 存活、Discord 8/8 connected、gateway 連續 2d01h50m 未重開、紅單仍兩支活、硬失敗 0。本輪新收穫＝兩個「量測陷阱」：① 429 的救回路徑不一定是 `rate-limit same-model retry`（本輪完全沒有那行 log，卻照樣救回）；② `startup-not-ready` 這種簽章會被 agent 回報文字污染、grep 會誤判。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，runId `5edd0b85-1955-417f-a405-80a1dbe5a251`，status=ok）
- 回覆（精簡 probe，一行內）：「pong picturecat — (a) alive/idle, (b) no errors or provider 429 in last 3h, (c) in-flight task: no, (d) Discord inbound ok: yes」
- 本 job `02eb0989`：上輪（11-23 01:02）**ok / ce=0 / dur=88,231ms**；本輪 04:02:06 準時觸發。
- 姊妹 job：`9d8b6001` Gengar KA（01:02:08 ok / dur 277,451ms）、`880b5c17` Celesteela KA（01:02:08 ok / dur 118,265ms）→ **三支皆非降級輪**（dur 全 >30s，降級判別式見 gengar 輪）。

### 2) 本機量測（rowlet 側 shell，04:02）
- uptime **42d09:49**；load `0.44 / 0.41 / 0.43`；RAM 31,797MB 總 / 9,193MB used / **avail 21,048MB**；swap 0/2,047；disk `/` **61%（267G/468G，剩 178G）** → 全正常。
- gateway（**user unit** `openclaw-gateway.service`）：MainPID **3573532**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST**、ps elapsed **2-01:50:50** → **連續 2d01h50m 未重開**（自 11-21 02:11 起算未中斷）；`/health` 18789 → **HTTP 200 in 1.1ms**、14177 → **HTTP 200 in 0.7ms**。

### 3) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 38 / skipped 5 / error 2 / none 1
- **活紅單仍只有兩支（與上輪同，皆待自癒）**：
  - `45ccf4e9 晨間情報 pipeline (Roaringmoon)` ce=1、last 11-22 08:00、dur 937,285ms、**next 11-23 08:00**（根因＝CDN/gateway 回 HTML 錯誤頁，11-22 16:02 已定位）。
  - `c5352a84 skill-collection-review-roaringmoon` ce=1、last 11-20 03:56、dur 169,007ms、**next 11-27 03:56**（11-20 DNS 風暴餘波）。
  - `a94330a9 tmp-openai-probe` 仍是 **enabled=false 的停用殘留**（ce=2）→ 不算活紅單。
- skipped 5 支全為 heartbeat（no-route 長態、良性）：d82f78e3 / 46242a4c / 7d633ff4 / 6525d155 / 3acd15c2。
- `6e93c179 heartbeat-flaaffy` lastRunAtMs=None、next 2026-02-03 13:56 → 從未跑過的舊殘留（非本輪新增）。
- 三支 KA 全 enabled、everyMs=10,800,000（3h）：本輪 nextRunAtMs picturecat **04:02:06.154** / gengar **04:02:08.171** / celesteela **04:02:08.176** → picturecat↔gengar 差 2.017s、**gengar↔celesteela 差 5ms** → **重疊競態窗第 11 次**（與上輪同一組）。
- `36b493db Memory Dreaming Promotion` 仍排 **`25 4 * * *`**（last 11-22 04:25 ok、dur 1,852,428ms、next **11-23 04:25**）→ 未挪動。
- `d4cd45bc discord-selfheal-after-dreaming`（`13,43 * * * *` Asia/Taipei）今日 01:13 / 03:43 皆 **ok（dur 753ms）**、next **04:13**；`911eee45 每日資安建議` 仍 **21:00:05 原槽**（ok、dur 624,182ms、next 11-23 21:00:05）。
- 今日最長執行：`36b493db` 1,852,428ms、`45ccf4e9` 937,285ms、`ae91b967` 792,986ms、`a72cb46b` 772,096ms、`40e09cd1` 655,053ms、`911eee45` 624,182ms、`09c7940b` 544,739ms、`5b7c1082` 496,600ms。

### 4) Provider 429 / DNS（01:02→04:06 窗，journal 1,092 行）
- **真實 429 = 1 次**（統一口徑 `model-fetch.*status=429`）：
  - **03:01:37.103**（elapsed **93,090ms**、dispatcher=new、model=MiniMax-M3）→ 溯源到 **`40e09cd1 Jormungand daily all-agent health`（agent=mrmime）**：同一 log 行群內有 `[cron:40e09cd1-7629-42bb-9275-193879665724]` 與 `sessionKey=agent:mrmime:cron:40e09cd1`。
  - 該 embedded run（runId `07befafb`）以 `isError=true`（"⚠️ API rate limit reached", rawError=HTTP 429）收尾，**但 cron job 本身收尾 ok / ce=0 / last 11-23 03:02:07 / dur 655,053ms** → **硬失敗 0**。
- ⭐⭐ **本輪新教訓（量測陷阱 ①）**：這次**完全沒有** `rate-limit same-model retry 1/3` 那一行 log。實際救回路徑＝embedded run 在 03:01:37 失敗後，runner 於 **03:01:39 直接發新 fetch → 03:01:42 status=200**（dispatcher=new，elapsed 2,100ms），之後 03:02:08–03:02:35 連續 9 次 status=200。
  → **只 grep「rate-limit same-model retry」會低估救回次數、誤判成硬失敗；判「有沒有硬失敗」一律以 job 的 `lastStatus` / `consecutiveErrors` 為準**，journal 只用來定位是哪支 job、哪個時間點。
- **硬失敗 = 0**（無 3/3 耗盡）。**真實 DNS（EAI_AGAIN/getaddrinfo）= 0**、**真實 `Token Plan usage limit` = 0**（24h grep 命中 7+1 筆全是 agent 回報文字，非真錯誤 → 這也是量測陷阱 ②：簽章字串會被 agent 自己的敘述污染）。
- 24h 正向對照：`model-fetch` 3,456 行、`status=200` **1,707** 筆、429 **16** 筆、`isError=true` **19** 行（16 rate-limit ＋ 1 HTML 錯誤頁＝`45ccf4e9` 根因 ＋ 1 LLM request timed out ＋ 1 network connection error）。
- **跨廠 fallback 仍為 0**：24h 3,452 筆 model-fetch 的 provider **100% `minimax-portal`**（`model=MiniMax-M2.7` 是同廠不同型號，不算跨廠）→ provider edge 出狀況仍只能靠同模型重試。

### 5) ⭐ 429 逐時退潮（24h 統一口徑 `model-fetch.*status=429`）
| 小時 | 429 |
|---|---|
| 11-22 05 | 4 |
| 11-22 06 | 1 |
| 11-22 07 | 2 |
| 11-22 08 | 1 |
| 11-22 09 | 2 |
| 11-22 12 | 1 |
| 11-22 18 | 1 |
| 11-22 21 | 1 |
| 11-22 23 | 1 |
| 11-23 00 | 1 |
| **11-23 03** | **1** |
（11-22 03 已在滾動窗外、11-23 03 滾入 → 24h 合計仍 **16 次**，與上輪同數；尖峰仍退到每小時 0–1 次，全被救回，硬失敗 0）

### 6) Discord 現況：8/8 connected
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled＝預期）。
- **3h 窗（01:02→04:06）簽章**：`Gateway reconnect scheduled` **11**、`websocket closed` **11**、READY 失敗 **0**、channel exited **0**、client initialized **0**、delaying provider startup **0**、host timing gap **0** → 全健康，無握手失敗。
  - 11 次 reconnect 全部是 `Gateway reconnect scheduled in 2000ms (reconnect-opcode, resume=true)`（01:03:34 / 01:15:07 / 01:33:32 / 01:50:09 / 02:16:11 / 02:23:41 / 02:27:43 / 02:48:06 / 03:18:13 / 03:24:29 / 03:54:39）→ 屬 Discord 心跳式重連，非掉線。
- **24h**：reconnect **117**、websocket closed **142**、READY 共 55 筆 = `READY within 30000ms` **28（成功）** ＋ `READY wait timed out after 15000ms` **27（失敗）**、channel exited **14**、client initialized **24**、host timing gap **6**、READY-fail 與 channel-exit **全落在 11-22 04:25 dreaming 窗**。
- **乾淨段**：最後一筆 READY-fail/channel-exit = **11-22 04:55:37**（celesteela）→ 至 11-23 04:02 **連續 ≈23h07m 零症狀**（較上輪 20h07m 續長 3h）。
- ⭐ **量測陷阱 ②**：`grep startup-not-ready` 在 3h 窗命中 1 筆，但那是 gengar 01:03:43 的回報文字「0 `startup-not-ready`」→ **真值 0**。簽章 grep 必須 anchor 在 `[discord]` 行，否則 agent 自述會污染計數。

### 7) ⚠️ 17 支 skill 缺 description：**第 9 輪仍未修**
- 3h 窗 **442 筆**、24h **3,298 筆**、唯一 **17 檔**、每檔每 3h 各 **26 次**（≈208 次/日）。分類不變：
  - **13 支 `description is required`**（frontmatter 整段不存在）：`card-lookup`、`meta-analyzer`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-download`、`ptcgp-card-lookup`、`system-design-six-dimensions-analyzer`、`web-fetch-troubleshooting` ＋ rosclaw plugin 下 `check-status`／`navigate-to`／`pick-object`／`take-photo`。
  - **4 支 `invalid frontmatter: BAD_INDENT`**：`excel-image-pipeline`、`human-behavior-simulation`、`image-attendant`、`ocr-confidence-mark`。
- **未授權 → 不動**（數支屬其他 agent lane，rosclaw 4 支屬第三方 plugin）。

### 8) dreaming 04:25：**本輪尚未觸發**（04:02 時距槽 23 分鐘）
- 排程仍是 `25 4 * * *`（next **11-23 04:25:00**）→ **未挪動**，風暴預期原樣重現。
- 本輪只能確認：① 槽仍在、② 昨日（11-22 04:25）簽章在 24h 窗內數字**未變**（READY timeout 27 / channel exited 14 / timing gap 6 / client initialized 24）→ 11-22 那次確為 24h 窗內唯一 READY 失敗來源，今日 04:25 尚未在窗內產生任何新簽章。
- 自癒排程 `d4cd45bc` 今日 01:13 / 03:43 兩支皆 ok；**04:13 那支在風暴前、04:43 那支落在風暴後** → 下輪（07:02）應看 04:43 那支的結果。

### 9) 上輪（11-23 01:02）§13 六項交辦逐項核對
| # | 項目 | 結果 |
|---|---|---|
| ① | 00:02 之後 429 是否歸零（01–04 窗） | ⚠️ **未歸零但減半**：03:01:37 共 1 次（上輪 2 次），所屬 job `40e09cd1` 收尾 ok / ce=0 → 硬失敗 0 |
| ② | dreaming 04:25 槽是否照預期爆發 | ⏳ **尚未觸發**（本輪 04:02，距槽 23 分鐘）；排程未挪 |
| ③ | 04:25 風暴後 Discord 是否自癒 | ⏳ 未發生；selfheal 01:13/03:43 ok、04:13 與 04:43 兩槽待觀察 |
| ④ | 紅單是否仍兩支活 | ✅ `45ccf4e9` / `c5352a84` 未變，無新增 |
| ⑤ | 三支 KA anchor 是否仍重疊 | ⚠️ **仍重疊**（第 11 次）：gengar 04:02:08.171 ↔ celesteela 04:02:08.176（差 5ms） |
| ⑥ | 17 支 skill 是否有補 | ❌ **未補**（第 9 輪）：17 檔 × 26 次/3h、24h 3,298 筆 |

### 10) 本輪動作：無（觀測為主）
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal、未刪 job、未改 skill 檔、未碰憑證、未發任何外部訊息（唯一對外動作＝對 picturecat lane 的 `sessions_send` 存活探針）。
- 未手動重跑 `45ccf4e9`（roaringmoon lane，11-23 08:00 每日自癒）；未刪 `a94330a9`；未修 17 支 skill。

### 11) 給 Linder 的待決事項（本輪）
1. **【中・待授權・連續 9 輪】17 支 skill 每天被跳過 ≈208 次**＝功能上等於不存在（`prompt-injection-defense`、`network-security-defense`、`ocr-confidence-mark` 全不在 `<available_skills>`）。授權後一次性修好本地 9 支（其他 lane 不動）、rosclaw 4 支走 plugin 上游。
2. **【中】dreaming 04:25 風暴**：排程未挪動 → 今日 04:25 幾乎確定原樣重現（昨日簽章：timing gap 6 / READY timeout 27 / channel-exited 14）。仍是二選一 —— (a) Discord READY 握手上限拉到 ≥300s；(b) dreaming admission suspend 期間保留既有連線的 READY deadline。
3. **【中】三支 KA 仍實質同時起跑**（本輪 gengar↔celesteela 差 5ms，第 11 次）→ 每輪都可能生出 `plugin generation was superseded` 假訊號。已擱置 6 天。
4. **【中】跨廠 fallback 仍為 0** → 24h 16 次 429 全靠同模型重試/新 dispatcher fetch 救回，無跨廠冗餘。
5. **【低】`45ccf4e9` 08:00 槽**建議把 `b37129c0` jitter 釘在 +30 分（08:30 起）以錯開重疊窗。
6. **【低】`a94330a9 tmp-openai-probe`** 停用殘留紅燈（ce=2）→ 刪掉可讓紅燈計數乾淨。
7. **【新・低】`6e93c179 heartbeat-flaaffy`** 從未執行過（next 2026-02-03）→ 屬舊殘留，可一併清掉。

### 12) 量測備忘（本輪新增／沿用）
- **429 有沒有硬失敗 → 看 job 的 `lastStatus` / `consecutiveErrors`，不要只看 journal 有沒有 retry log**（本輪實證：無 retry log 仍救回）。journal 只用來定位「哪支 job、哪個時間點、elapsed 多長」。
- **簽章 grep 一定要 anchor 行首前綴**（`[discord]` / `[provider-transport-fetch]` / `[skills]`），否則會被 agent 自述文字污染（`startup-not-ready`、`EAI_AGAIN`、`Token Plan usage limit` 三個都踩過）。
- 溯源 429 所屬 job：同一區間內找 `[cron:<uuid>]` ＋ `sessionKey=agent:<lane>:cron:<uuid8>`（`40e09cd1` ↔ mrmime lane 即此法定位）。
- gateway 一律 `systemctl --user show openclaw-gateway`（system scope 給假訊號）。
- 429 一律用 `model-fetch.*status=429` 單一口徑。
- `file=` 過濾要加 `.md`。
- restricted automation-run session 內 `automations` 工具看不到自身 job → 一律 `openclaw cron list --all --json`。

### 13) 下一輪（11-23 07:02）請確認
① **04:25 dreaming 是否爆發**（timing gap / READY wait timed out / channel exited 簽章）＋ **04:43 selfheal 是否收尾**（client initialized / channels resolved）；② 04:02 之後 429 數（04–07 窗，含 04:25 槽本身）；③ `45ccf4e9` 08:00 槽過後 ce 是否歸 0（須 08:00 之後才驗得到，07:02 那輪只能預告）；④ 紅單是否仍兩支活；⑤ 三支 KA anchor 是否仍重疊；⑥ 17 支 skill 是否有補；⑦ gateway NRestarts 是否仍 0、Discord 乾淨段是否延續過 04:25 風暴。

## 2026-11-23 07:02 — Picturecat Keep-Alive 第 3 輪（今日第 3 輪，觸發 07:02:06）

**總結：🔴 **本輪抓到一個真實故障並已修復**：04:43 的 selfheal 槽在 **04:46:17** 起跑，它的「dreaming 是否在跑」守門**失效（fail-open）**，於是在 dreaming（04:25–04:48）**跑到一半時**排了 gateway restart → **gateway 在 04:47:46 被 stop、04:48:17 被 SIGKILL 連同 8 個 V8Worker** → **dreaming job 36b493db 被腰斬**（error: `cron: job interrupted by gateway restart`，ce=1）＋ **55 個 dreaming subagent run 被 orphan-pruned**。這是 **selfheal 開火造成的自我傷害**，不是 dreaming 自己壞掉。守門已改成「任何不確定 → 一律視為在跑」＋ 加一道不依賴 API 的時鐘窗，並留 backup。紅單由 2 支增至 **3 支**（新增 dreaming）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，runId `e78eb791-b693-4c38-aec3-47101af5bd9c`，status=ok）
- 回覆（精簡 probe，一行內）：「pong picturecat — (a) alive/idle, (b) errors or provider 429 in last 3h: no, (c) in-flight task: no, (d) Discord inbound ok: yes」
- 本 job `02eb0989`：上輪（11-23 04:02）**ok / ce=0 / dur=159,531ms**；本輪 07:02:06 準時觸發。
- 姊妹 job：`9d8b6001` Gengar KA（04:02:08 ok / dur 205,068ms）、`880b5c17` Celesteela KA（04:02:08 ok / dur 107,282ms）→ 三支皆非降級輪。

### 2) ⭐⭐⭐ 本輪主要發現：selfheal 守門 fail-open，開火腰斬 dreaming
**事件時間線（journal 實測）**：
| 時間 | 事件 |
|---|---|
| 04:25:00.036 | dreaming `36b493db` 起跑（`25 4 * * *`，timeoutSeconds=2400） |
| 04:27:56 / 04:33:56 / 04:40:04 / 04:46:16 | **4 次** `host timing gap detected`（frozen 146s → 266s → 231s → **279s**），gateway event loop 被 dreaming 餓死 |
| 04:33:56 | 6 個 Discord client `channel exited`（READY 30s 逾時） |
| 04:35–04:47 | 25 筆 `READY wait timed out`（含 04:46:16 後 4 筆、04:46:53 後 3 筆、04:47:09 1 筆） |
| **04:46:17** | **selfheal `d4cd45bc` 起跑**（43 分槽因 gateway 凍結延遲到 04:46 才執行）→ 守門回報「dreaming idle」→ **排 gateway restart in 10s** |
| 04:46:53 | `[ws] ⇄ res ✓ cron.list 32103ms`（**cron.list 花了 32 秒**才回，這就是守門拿到壞資料的原因） |
| 04:47:46 | systemd `Stopping OpenClaw Gateway (v2026.7.1-2)...` |
| 04:48:17 | `State 'stop-sigterm' timed out. Killing.` → **SIGKILL MainThread + 8 個 V8Worker** → `Started OpenClaw Gateway`（新 MainPID 4137629） |
| 04:48:24 | **55 筆 `Subagent orphan run pruned source=restore`**（dreaming-narrative-{charizard,celesteela,flaaffy,gengar,greninja,mrmime,picturecat,roaringmoon} + mrmime:subagent） |
| 04:48:26.905 | dreaming job receipt = **error**，`error: "cron: job interrupted by gateway restart"`，dur=1,406,869ms（23.4 分，**遠短於平日的 30.9 分**）→ **ce=1** |

**守門為什麼會 fail-open（已用 fixture 重現）**：舊守門只對「JSON 解析失敗」fail-closed，但 `openclaw cron list` 在 RPC 失敗時會把 **`{"ok":false,"error":{...}}` 印到 stdout 且 exit code=0** → `json.load()` 解析成功 → `d.get("jobs",[])` 回傳 `[]` → 迴圈找不到 dreaming → **印出 `False`（＝dreaming idle）** → 開火。實測 fixture（舊守門 → 新守門）：
| fixture | 舊 | 新 |
|---|---|---|
| A) `{"ok":false,...}` 錯誤封套 | ❌ False | ✅ True |
| B) jobs 清單不含 dreaming | ❌ False | ✅ True |
| C) dreaming running | ✅ True | ✅ True |
| D) dreaming queued | ❌ False | ✅ True |
| E) dreaming 真的 idle | ✅ False | ✅ False |
| F) 非 JSON | ✅ True | ✅ True |
| G) stdout 空 | ✅ True | ✅ True |
| H) 非 list payload | ❌ False | ✅ True |

**本輪動作（唯一一個，但有依據）**：修 `scripts/discord-selfheal.sh`（rowlet 自有檔案，11-20 已改過一版）——
1. 守門任何不確定 → 一律 `True`（`ok:false` 封套 / 非 list / **找不到 dreaming job** 都算「在跑」）；讀取改用 `--all` 確保 job 一定在清單裡；加上 `queuedAtMs` 判斷。
2. **新增 2b) 時鐘窗守門（完全不依賴 cron API）**：dreaming 排程固定 `25 4 * * *` + timeout 2400s → in-flight 區間約 04:25–05:05 → 設 `DREAMING_WINDOW_START=04:15` / `END=05:10`，窗內一律 postpone（05:10 刻意設在 05:13 合法治療槽之前，不擋它）。
3. backup：`scripts/discord-selfheal.sh.bak-2026-11-23-0702`（+ 07:15 同內容備份）；`bash -n` 通過、8 個 fixture 全過、對 live CLI 實跑得 `False`（dreaming 現況確實 idle）、整支 script 實跑輸出 `discord healthy (no startup-not-ready) - no action` 且 **stamp 檔未被改動**。
4. **未動**：cron 排程/payload/timeout/fallback、未重啟 gateway、未刪 job、未改 skill、未碰憑證。

### 3) 本機量測（rowlet 側 shell，07:02）
- uptime **42d12:49**；load `0.52 / 0.49 / 0.50`；RAM 31,797MB 總 / 8,834MB used / **avail 21,406MB**；swap 0/2,047；disk `/` **61%（267G/468G，剩 178G）** → 全正常。
- gateway（user unit）：MainPID **4137629**（**已換 PID**）、**NRestarts=0**、ActiveEnterTimestamp **2026-11-23 04:48:17 CST**、ps elapsed **02:14:16** → gateway 今日 **04:48 被重啟過一次**（selfheal 開火所致）；`/health` 18789 → **HTTP 200 in 3.8ms**、14177 → **HTTP 200 in 0.5ms**。
- ⚠️ **`NRestarts=0` 不等於「沒重啟過」**：unit 是被 `systemctl restart` 主動重啟（systemd 不計入 NRestarts），所以必須看 `ActiveEnterTimestamp` / MainPID 變化才判得出重啟。

### 4) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 36 / skipped 6 / error 3 / none 1
- **活紅單 3 支（上輪 2 支）**：
  - `36b493db Memory Dreaming Promotion` **ce=1（NEW）** — last 11-23 04:25、dur 1,406,869ms、error=`cron: job interrupted by gateway restart`、**next 11-24 04:25** → 根因＝selfheal 開火，非 dreaming 自身故障。
  - `45ccf4e9 晨間情報 pipeline (Roaringmoon)` ce=1、last 11-22 08:00、dur 937,285ms、**next 11-23 08:00**（CDN 回 HTML 錯誤頁，第 ④ 型）。
  - `c5352a84 skill-collection-review-roaringmoon` ce=1、last 11-20 03:56、**next 11-27 03:56**（DNS 餘波）。
  - `a94330a9 tmp-openai-probe` 為 enabled=false 殘留（ce=2）→ 不算活紅單。
- skipped 6 支全為 heartbeat（no-route 長態、良性）。
- 三支 KA 全 enabled、everyMs=10,800,000（3h）：本輪 nextRunAtMs picturecat **1795388526169** / gengar **…828188** / celesteela **…828193** → picturecat↔gengar 差 2.019s、**gengar↔celesteela 差 5ms** → **重疊競態窗第 12 次**（與上輪同一組）。
- `36b493db` dreaming 排程仍 **`25 4 * * *`**（未挪），timeoutSeconds=2400。
- `d4cd45bc selfheal` 排程 **現為 `13,43 0-3,5-23 * * *`** tz=Asia/Taipei → **小時 04 已被排除**。journal `05:12:45 [gateway] cron: job updated` = **事故後**有人把排程改成這樣（04:13 那輪的 nextRunAtMs 還是 04:43:00 → 當時 hour 04 仍在清單內，所以 04:43 槽才會在 04:46:17 開火）。今日各槽：00:13–04:13 皆 ok，**04:46:17 那槽 ok 但開火傷人**，05:13 那槽輸出 `self-heal skipped: a restart was armed 26 min ago (< 30 min)` → **anti-storm 30 分鐘閘有生效**（04:46 寫入 stamp 1795380377）；05:43/06:13/06:43 皆 ok。→ 因 hour 04 已排除，**dreaming 槽已無 selfheal 槽**；本輪加的時鐘窗守門屬 defense-in-depth（防排程被還原或 dreaming 漂移）。
- 今日最長執行：`36b493db` 1,406,869ms、`45ccf4e9` 937,285ms、`40e09cd1` 655,053ms、`911eee45` 624,182ms、`09c7940b` 544,739ms、`13ac4b5a` 531,410ms、`ae91b967` 520,311ms。

### 5) Provider 429 / DNS（04:02→07:02 窗，journal 2,625 行）
- **真實 429 = 5 次**（統一口徑 `model-fetch.*status=429`，全部 `provider=minimax-portal api=anthropic-messages model=MiniMax-M3`）：
  - 05:01:58.196（elapsed **117,462ms**、dispatcher=new）
  - 05:32:00.840（elapsed **117,484ms**、dispatcher=reused）
  - 06:03:12.265（elapsed **161,544ms**、dispatcher=new）
  - 07:01:46.134（elapsed **105,367ms**、dispatcher=new）
  - 07:02:02.698（elapsed **101,440ms**、dispatcher=reused）
  - 全部 5 次都被 `rate-limit same-model retry 1/3` 救回（`[discord] embedded run agent end isError=true` → retry → 後續 status=200）→ **硬失敗 0**。
  - 溯源（用 fetch **起始時間**而非回應時間對齊最近 `[cron:<uuid>]` 標記）：05:01→05:00:00 起、05:32→05:30:02、06:03→06:00:30、07:01→07:00:00、07:02→07:00:20 → 分別落在 `ca222989`/`13ac4b5a`/`ae91b967`/`08b7c00b` 槽的執行窗內（`08b7c00b` = rowlet-ut-veteran-cpc-maintenance-noon，40 6 * * * 但因 stagger 往後跑）。
- **真實 DNS（EAI_AGAIN/getaddrinfo）= 0**；**真實 `Token Plan usage limit` = 0**（連續多輪零配額窗）。
- 24h 總計（排除 agent:nested 行）：`model-fetch` 8,115 行、**429 = 14**、status=200 = 1,795、isError=true = 16、Token Plan = 0、EAI_AGAIN = 0。
- **跨廠 fallback 仍為 0**（24h provider 100% `minimax-portal`，3,646 筆）→ provider edge 出狀況只能靠同模型重試。

### 6) ⭐ 429 逐時退潮（24h 統一口徑 `model-fetch.*status=429`）
| 小時 | 429 |
|---|---|
| 11-22 08 | 1 |
| 11-22 09 | 2 |
| 11-22 12 | 1 |
| 11-22 18 | 1 |
| 11-22 21 | 1 |
| 11-22 23 | 1 |
| 11-23 00 | 1 |
| 11-23 03 | 1 |
| **11-23 05** | **2** |
| **11-23 06** | **1** |
| **11-23 07** | **2** |
（11-22 03/05/06/07 已在滾動窗外、11-23 04 全 0）→ 24h 合計 **14 次**，全被 retry 救回，硬失敗 0。尖峰維持每小時 0–2 次。

### 7) Discord 現況：8/8 connected
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled＝預期）。
- **3h 窗（04:02→07:02）簽章**：READY wait timed out **25**（全在 04:35–04:47）、channel exited **6**（全 04:33:56）、client initialized **16**、channels resolved **11**、reconnect scheduled **37**、websocket closed **57**、host timing gap **4**、host thaw deferred **12**、delaying provider startup **15**、channel resolve failed **6**、`112 commands exceed the 100-command Discord limit` **17**、memory pressure **1**。
- **重啟後自癒完整**：04:48:26 八個帳號依序 `delaying provider startup 10s…70s` → 04:48:41–04:49:37 `client initialized` + `channels resolved` 逐一亮燈 → 現況 8/8 connected。
- **24h**：reconnect **103**、websocket closed **127**、READY wait timed out **25**、channel exited **6**、client initialized **17**、channels resolved **12**、host timing gap **4**、commands-exceed **18**。
- **乾淨段**：最後一筆 READY-fail = **11-23 04:47:09** → 至 07:02 **連續 ≈2h15m 零症狀**（但 04:33–04:47 那段是風暴，非自癒）。

### 8) ⚠️ 17 支 skill 缺 description：**第 10 輪仍未修**
- 3h 窗 **1,020 筆**、24h **3,026 筆**、唯一 **17 檔**、每檔每 3h 各 **60 次**（≈480 次/日/檔）。分類不變：**13 支 `description is required`**（`card-lookup`、`meta-analyzer`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-download`、`ptcgp-card-lookup`、`system-design-six-dimensions-analyzer`、`web-fetch-troubleshooting` ＋ rosclaw plugin 下 `check-status`／`navigate-to`／`pick-object`／`take-photo`）＋ **4 支 `invalid frontmatter: BAD_INDENT`**（`excel-image-pipeline`、`human-behavior-simulation`、`image-attendant`、`ocr-confidence-mark`）。
- **未授權 → 不動**（數支屬其他 agent lane，rosclaw 4 支屬第三方 plugin）。

### 9) 上輪（11-23 04:02）§13 七項交辦逐項核對
| # | 項目 | 結果 |
|---|---|---|
| ① | 04:25 dreaming 是否爆發 | ✅ **爆發且比預期嚴重**：4 次 timing gap（146/266/231/**279s**）、READY timeout **25**、channel exited **6**、55 個 subagent 被 prune；**且是被 selfheal 開火腰斬的**（見 §2） |
| ② | 04:43 selfheal 是否收尾 | ⚠️ **收尾了但是有害的**：04:46:17 起跑 → 排 restart → 04:48 gateway 被殺 → dreaming error/ce=1 |
| ③ | 04:02 之後 429 數（04–07 窗） | ⚠️ **5 次**（05:01/05:32/06:03/07:01/07:02），elapsed 101k–162k ms，全被 retry 救回，硬失敗 0 |
| ④ | `45ccf4e9` 08:00 槽過後 ce 是否歸 0 | ⏳ 08:00 尚未到（07:02 只能預告），下輪 10:02 才驗得到 |
| ⑤ | 紅單是否仍兩支活 | ⚠️ **變 3 支**：新增 `36b493db` ce=1（selfheal 造成） |
| ⑥ | 三支 KA anchor 是否仍重疊 | ⚠️ **仍重疊**（第 12 次）：gengar 07:02:08.188 ↔ celesteela 07:02:08.193（差 5ms） |
| ⑦ | gateway NRestarts 是否仍 0、Discord 乾淨段是否延續過 04:25 風暴 | ⚠️ **NRestarts=0 但 gateway 確實被重啟**（04:48:17，MainPID 換成 4137629）→ **`NRestarts=0` 不能當「沒重啟」的證據**；乾淨段由 23h07m **歸零重算**（最後 READY-fail = 04:47:09） |

### 10) 本輪動作
- ✅ **改 `scripts/discord-selfheal.sh` 守門**（唯一一個改動，詳見 §2）：任何不確定 → 視為 dreaming 在跑；加 04:15–05:10 時鐘窗；backup 留存；8 個 fixture + live CLI + 全 script 實跑全驗過。
- **零其他改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal、未刪 job、未改 skill 檔、未碰憑證、未發任何外部訊息（唯一對外動作＝對 picturecat lane 的 `sessions_send` 存活探針）。

### 11) 給 Linder 的待決事項（本輪）
1. **【高・需裁示】`36b493db` dreaming 的紅單要不要清**？根因是 selfheal 開火（已修），job 本身沒有 bug；下一輪 11-24 04:25 會照常跑，跑成功後 ce 應自動歸 0。**建議不手動重跑**（dreaming 是 plugin-declared job，且重跑會佔掉 event loop）。
2. **【高・需裁示】selfheal 的時鐘窗覆蓋 04:15–05:10，等於「dreaming 期間 Discord 壞掉就自動放著」**。本次風暴中 Discord 確實是靠 gateway 重啟才回來的（health-monitor 本身只重啟 channel、不重啟 gateway，撐不過 READY 逾時）。要不要保留這個取捨？替代方案＝把 dreaming 挪離 04:xx（根治 starvation 來源），或把 Discord READY 握手上限拉高到 ≥300s。
3. **【中・待授權・連續 10 輪】17 支 skill 每天被跳過 ≈480 次/檔**＝功能上等於不存在。授權後一次性修好本地 9 支（其他 lane 不動）、rosclaw 4 支走 plugin 上游。
4. **【中】`d4cd45bc` 排程現為 `13,43 0-3,5-23`（已排除 04 時段）** — 這代表 dreaming 槽已無 selfheal 槽；配合 §11-2 的取捨需一併決定是否要把 04:43 槽加回（加了就有 §2 的風險，不加就是 dreaming 期間 Discord 無自動治療）。
5. **【中】三支 KA 仍實質同時起跑**（本輪 gengar↔celesteela 差 5ms，第 12 次）→ 每輪都可能生出 `plugin generation was superseded` 假訊號（3h 窗 12 筆）。已擱置 6 天。
6. **【中】跨廠 fallback 仍為 0** → 24h 14 次 429 全靠同模型重試/新 dispatcher fetch 救回，無跨廠冗餘。
7. **【低】`45ccf4e9` 08:00 槽**建議把 `b37129c0` jitter 釘在 +30 分（08:30 起）以錯開重疊窗。
8. **【低】`a94330a9 tmp-openai-probe`**（停用殘留紅燈 ce=2）與 **`6e93c179 heartbeat-flaaffy`**（從未執行過，next 2026-02-03）→ 可一併清掉。

### 12) 量測備忘（本輪新增／沿用）
- ⭐⭐ **`NRestarts=0` ≠ 沒重啟過**：unit 被 `systemctl restart` 主動重啟時 systemd 不計 NRestarts → 判斷 gateway 有沒有重開，要看 `ActiveEnterTimestamp` + MainPID 變化。（本輪就是靠這兩個欄位才抓到 04:48 的重啟。）
- ⭐⭐ **CLI 的錯誤封套是「合法 JSON + exit 0」**：`openwall cron runs --id <bad>` 會把 `{"ok":false,"error":{...}}` 印在 **stdout** 且 exit 0 → 任何 `json.load()` + `.get("jobs",[])` 的守門都會把它當成「清單為空」而不是「查詢失敗」。守門必須顯式檢查 `ok is False`。
- ⭐ **故障歸因要對齊「fetch 起始時間」**：429 的 log 時間是**回應**時間，elapsedMs=105s–162s → 起始點在 1.7–2.7 分鐘前；用回應時間去對 `[cron:]` 標記會錯位到前一支 job。
- ⭐ **`cron.list` 在 gateway 凍結時會慢到 32 秒**（journal `res ✓ cron.list 32103ms`）→ 任何以 cron API 為前提的自動化，在事件迴圈飽和時都會拿到超時/錯誤資料 → **必須有不依賴 API 的第二道守門**。
- **簽章 grep 一定要 anchor 行首前綴**（`[discord]` / `[provider-transport-fetch]` / `[skills]`），並排除 `[agent:nested]`。
- **溯源 job 用 `openwall cron list --all --json`**（restricted automation-run session 內 `automations` 工具看不到自身 job）；`--all` 才有 53 支完整清單（不含 `--all` 只有 46 支 enabled）。
- `file=` 過濾要加 `.md`。
- bash 數字/時間字串比較要用 `[[ > ]]` / `[[ < ]]`，`[ ... \> ... ]` 在 `[[` 之外會被當重導向（已踩：04:15 邊界失效）。

### 13) 下一輪（11-23 10:02）請確認
① `45ccf4e9` 08:00 槽跑完後 **ce 是否歸 0**（CDN 錯誤是否自癒）；② **10:02 槽本身是否又有新的 429**（本輪已連兩輪在整點前後被 429 打中：07:01/07:02）；③ `36b493db` dreaming 是否仍 ce=1（要等 11-24 04:25 才會自動歸 0，本輪只能確認沒再變壞）；④ **selfheal 下一個 10:13/10:43 槽是否輸出「inside dreaming window ... postpone」或「discord healthy」**（若 10:13 槽又開火就代表守門還有洞）；⑤ gateway `ActiveEnterTimestamp` 是否仍是 04:48:17（沒有再被重啟過）；⑥ Discord 乾淨段是否延續過 2h15m；⑦ 17 支 skill 是否有補；⑧ 三支 KA anchor 是否仍重疊。

## 2026-11-23 10:02 — Picturecat Keep-Alive 第 4 輪（今日第 4 輪，觸發 10:02:07）

**總結：🟠 lane 存活、Discord 8/8、gateway 連續 5h14m 未重開、紅單由 3 支降回 2 支（`45ccf4e9` 已於 08:00 槽自癒 ✅）。但本輪抓到一個**真實硬失敗**：07:29–07:59 MiniMax 帳號撞「Token Plan usage limit」配額牆 → **Gengar KA job `9d8b6001` 於 07:29 整輪硬死**（兩筆 error run），而它的跨廠 fallback（openai）因「Explicit auth order for openai has no usable profiles」**根本不可用** → 這條「有 fallback 但沒憑證」的路徑等於沒有冗餘。更關鍵：**該失敗在 fleet 狀態裡完全看不見**（10:02 成功 → ce 歸 0），只有 run 歷史看得到。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，runId `ea00e82d-0015-4d2e-95d3-8b223ff8158e`，status=ok）
- 回覆（精簡 probe，一行內）：「pong picturecat — (a) alive/idle, (b) errors or provider 429 in last 3h: none, (c) in-flight task: none, (d) Discord inbound ok: yes」
- 本 job `02eb0989`：上輪（11-23 07:02）**ok / ce=0 / dur=1,238,325ms**（07:02:07 起、07:22:45 收尾）；本輪 10:02:07 準時觸發。
- 姊妹 job：`880b5c17 Celesteela KA`（上輪 ok/ce=0/dur=162,996ms）、`9d8b6001 Gengar KA`（上輪 **error ×2**，見 §2；本輪 10:02 **ok / dur=12,842ms**）。

### 2) ⭐⭐⭐ 本輪主要發現：07:29 配額牆 → Gengar KA 整輪硬死，且跨廠 fallback 無憑證
**配額牆（24h 逐時）**：`Token Plan usage limit reached: Upgrade your To…` 真實 `rawError HTTP 429` 共 **58 筆，全部集中在 07:29:00 → 07:59:50（約 31 分鐘）**；同窗 canonical `model-fetch.*status=429` = **26 筆**（單 07:29 一分鐘就 13 筆）。
- 這是**帳號層的 plan token 上限**（`{"type":"rate_limit_error","message":"Token Plan usage limit reached: Upgrade your Token Plan…"}`），**不是**之前記錄的 burst 429，也**不是**之前多輪寫的「零配額窗」。
- **後果（真實硬失敗）**：`openclaw cron runs --id 9d8b6001-…` → 兩筆 error run：
  - `finished error` ts=**07:29:13**、dur=**1,624,295ms**（07:02:08 起跑 → 27 分鐘後死）、err=**`⚠️ API rate limit reached. Please try again later.`**
  - `finished error` ts=**07:29:53**、dur=8,826ms、err=**`Explicit auth order for openai has no usable profiles.`**（fallback 直接被憑證擋掉）
- ⭐ **跨廠 fallback 是「有設定、沒憑證」**：fallback 候選裡確實有 `minimax/MiniMax-M3`（非 `minimax-portal`）與 openai auth order，但 24h 內 `candidate_succeeded` 全部落在**同廠不同型號**（`minimax-portal/MiniMax-M2.7` ×4：07:29:12 / 08:23:51 / 08:38:29 / 08:44:54），`minimax/*` 候選 **0 次成功** → **「跨廠 fallback 仍為 0」這句話要升級成「跨廠 fallback 設定存在但無可用憑證 = 零冗餘」**。
- 旁證：07:29:03 曾出現 `model=MiniMax-M2.7 status=400`（fallback 端點回 400）；`reason=unknown` 的 fallback 決策另有 8 筆全是「plugin generation was superseded」良性 race。
- **自癒時間線**：08:00 槽 `45ccf4e9` **ok / dur=1,081,044ms** → 配額牆在 08:00 前已退；`b37129c0` 08:28:08–08:33:21 ok（jitter 這次落在 **+28 分**，**沒有**與 45ccf4e9 的執行窗重疊 → 昨日 08:15 的 provider 500 撞車今日未重現）。
- **無 3/3 耗盡**（24h `retry 3/3 / all candidates exhausted` = 0）。

### 3) ⭐ 量測教訓（重要）：fleet 狀態會**藏起**這次失敗
- `openclaw cron list` 只給 `state.lastRunStatus` / `consecutiveErrors`；Gengar KA 在 10:02 成功後 **ce 歸 0**，於是 07:02 那輪的整輪硬死 **在 fleet 盤點裡完全看不見**（error 計數只剩 3 支老紅單）。
- → **巡檢必看 `openclaw cron runs --id <完整uuid>` 的最近數筆 status，不能只看 ce/lastRunStatus**；本輪若只做例行盤點，會把「07:02 姊妹 lane 整輪死亡」誤報成全綠。
- 另一個反向教訓：journal 裡 07:29 的爆量只佔 24h 的 2071 次 model-fetch 的一小塊，**只靠 hourly 桶看會以為「尖峰已退潮」** → 需要同時看「該分鐘內的密集度（13 次/分）」。

### 4) 本機量測（rowlet 側 shell，10:02）
- uptime **6w15h49m（42d15h49m）**；load `0.69 / 0.57 / 0.55`；RAM 31,797MB 總 / 9,003MB used / **avail 21,262MB**；swap 0/2,047；disk `/` **61%（267G/468G，剩 178G）** → 全正常。
- gateway（user unit）：MainPID **4137629**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-23 04:48:17 CST**、ps elapsed **05:14:29** → **04:48 之後未被再重啟（連續 5h14m）**；進程二進位 = **node v24.22.3**；`/health` 18789 → **HTTP 200 in 0.44s**、14177 → **HTTP 200 in 0.0008s**。

### 5) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 41 / skipped 8 / error 3 / none 1
- **活紅單由 3 支降回 2 支**：
  - ✅ **`45ccf4e9 晨間情報 pipeline` 已自癒**：last **11-23 08:00 ok、ce=0**、dur=1,081,044ms（上輪 07:02 輪為 ce=1）→ **上輪交辦①結案**。
  - `36b493db Memory Dreaming Promotion` ce=1、last 11-23 04:25、dur=1,406,869ms、err=`cron: job interrupted by gateway restart`、**next 11-24 04:25** → 根因＝selfheal 開火（07:02 輪已修），**今日不變壞即無需動作**，明早自動歸 0。
  - `c5352a84 skill-collection-review-roaringmoon` ce=1、last 11-20 03:56、**next 11-27 03:56**（DNS 舊因）。
  - `a94330a9 tmp-openai-probe` 仍為 **enabled=false 殘留**（ce=2）→ 不算活紅單。
- skipped 8 支全為 heartbeat（no-route 長態、良性）。
- **三支 KA anchor 本輪明顯拉開**：gengar 10:02:**02** → picturecat 10:02:**07** → celesteela 10:02:**09** → 間距 **5s / 2s**（前幾輪是 5ms～2.0s）→ **重疊競態窗第 13 次但本次未發生 5ms 級碰撞**，仍屬同秒級，建議仍照 §11-3 拉開。
- `d4cd45bc discord-selfheal-after-dreaming` 排程 **`13,43 0-3,5-23 * * *`**（hour 04 已排除 → dreaming 槽無 selfheal 槽）：09:13 / 09:43 皆 **ok / dur≈743ms**、next **10:13** → **自 04:48 之後 gateway 未再被重啟** = 守門沒有誤開火 ✅（`scripts/discord-selfheal.sh` 現況 6607B，含 `DREAMING_WINDOW_START=04:15` / `END=05:10` 與 fail-closed 守門，`bash -n` 通過；backup `.bak-2026-11-23-0702` / `-0715` 各 3560B = 舊版）。
  - journal 殘留一筆 07:22:04 `[tools] edit failed: Could not find edits[2]` → 是 07:02 輪改 script 時的中途失敗（後續 edit 已套用，live 檔 mtime 07:26、6607B 且守門齊全）→ **良性殘留，非現行故障**。
- `911eee45 每日資安建議` 仍 **21:00:05 原槽**（last 11-22 ok、dur=624,182ms、next 11-23 21:00:05）；`6e93c179 heartbeat-flaaffy` 仍 enabled 且 next 2026-02-03（從未跑過的舊殘留）。

### 6) Discord 現況：8/8 connected
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled＝預期）。
- 真實收發：celesteela in:14m、charizard in/out:57m、gengar in:3h、mrmime in/out:52m、roaringmoon in/out:1h、rowlet in:3h；picturecat／flaaffy 無近期 inbound 但 transport=just now。
- **07:02→10:02 窗簽章**：READY 失敗 **0**、channel exited **0**、client initialized **0**、channels resolved **0**、host timing gap **0**、delaying provider startup **0**、channel resolve failed **0**、commands-exceed **0**；reconnect **12**、websocket closed **12**（≈4/h，屬 Discord 心跳式重連）→ **全健康**。
- **乾淨段**：最後一筆 READY-fail/channel-exit = **11-23 04:47:09** → 至 10:02 **連續 ≈5h15m 零症狀**（已越過 04:48 重啟與 dreaming 風暴餘波）。

### 7) 上輪（07:02）§13 八項交辦逐項核對
| # | 項目 | 結果 |
|---|---|---|
| ① | `45ccf4e9` 08:00 槽後 ce 是否歸 0 | ✅ **已歸 0**（08:00 ok、dur=1,081,044ms）→ 紅單 3 → 2 |
| ② | 10:02 槽本身是否又有新 429 | ⚠️ 本窗 29 次 canonical 429（07h=25 / 08h=3 / 09h=1），**但 07:29 那批是配額牆**（見 §2），08:02:34、09:01:49 各 1 次屬一般 burst 且被 retry 救回 |
| ③ | `36b493db` dreaming 是否仍 ce=1 | ✅ 仍 ce=1、next 11-24 04:25（未變壞） |
| ④ | selfheal 10:13/10:43 槽是否誤開火 | ⏳ 10:13 尚未到；**09:13 / 09:43 兩槽 ok 且 04:48 之後 gateway 零重啟 → 未誤開火** ✅ |
| ⑤ | gateway ActiveEnterTimestamp 是否仍是 04:48:17 | ✅ 仍是（5h14m 未重開） |
| ⑥ | Discord 乾淨段是否延續過 2h15m | ✅ 已延續至 ≈5h15m |
| ⑦ | 17 支 skill 是否有補 | ❌ **仍未補**（第 11 輪，見 §8） |
| ⑧ | 三支 KA anchor 是否仍重疊 | ⚠️ 仍同秒級（5s / 2s），但本輪無 5ms 級碰撞 |

### 8) ⚠️ 17 支 skill 缺 description：**第 11 輪仍未修**
- 3h 窗 **1,020 筆**、24h 3,026 筆、唯一 **17 檔**（每檔每 3h 各數十次）。
- 分類不變：**13 支 `description is required`**（`card-lookup`、`meta-analyzer`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-download`、`ptcgp-card-lookup`、`system-design-six-dimensions-analyzer`、`web-fetch-troubleshooting` ＋ rosclaw plugin 下 `check-status`／`navigate-to`／`pick-object`／`take-photo`）＋ **4 支 `invalid frontmatter: BAD_INDENT`**（`excel-image-pipeline`、`human-behavior-simulation`、`image-attendant`、`ocr-confidence-mark`）。
- **未授權 → 不動**（數支屬其他 agent lane，rosclaw 4 支屬第三方 plugin）。

### 9) 本輪動作：無（觀測為主）
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal、未刪 job、未改 skill 檔、未碰憑證、未發任何外部訊息（唯一對外動作＝對 picturecat lane 的 `sessions_send` 存活探針）。
- 未手動重跑任何紅單（`36b493db` / `c5352a84` 皆待自癒）；未刪 `a94330a9` / `6e93c179`；未修 17 支 skill。

### 10) 給 Linder 的待決事項（本輪）
1. **【新・高】MiniMax 帳號有 plan token 上限，07:29–07:59 撞牆 31 分鐘，直接打死一整輪 Gengar KA。** 建議：(a) 檢查/升級 Token Plan 額度；(b) 給 KA 類 job 設 `model` fallback 到**同廠不同型號**（`minimax-portal/MiniMax-M2.7` 本輪 4 次 `candidate_succeeded` 可用）；(c) 門檻式排程錯開 07:00–08:00 密集窗（07:29 單分鐘 13 次 429）。
2. **【新・中】跨廠 fallback 設定存在但**無可用憑證**（`Explicit auth order for openai has no usable profiles`）→ 名義冗餘、實際零冗餘。要嘛補憑證，要嘛把 fallback 鏈改成同廠雙型號，避免「以為有後路」。
3. **【中・待授權・連續 11 輪】17 支 skill 每天被跳過**（功能上等於不存在）。授權後一次性修好本地 9 支、rosclaw 4 支走 plugin 上游。
4. **【中】`36b493db` dreaming 紅單**：根因已修（selfheal 守門），11-24 04:25 跑完應自動歸 0 → 建議不手動重跑；同時「dreaming 槽已無 selfheal 槽（hour 04 已排除）」的取捨待你裁示。
5. **【中】三支 KA anchor 仍同秒級起跑**（本輪 5s / 2s）→ 每輪仍可能生出 `plugin generation was superseded` 假訊號。已擱置 6 天。
6. **【低】`45ccf4e9` 與 `b37129c0` 同為 `0 8 * * *`**：今日 jitter 落在 +28 分而未重疊（幸運），建議把 jitter 釘在 +30 分以固定錯開。
7. **【低】`a94330a9 tmp-openai-probe`（停用殘留 ce=2）與 `6e93c179 heartbeat-flaaffy`（從未執行）**→ 可一併清掉。

### 11) 量測備忘（本輪新增／沿用）
- ⭐⭐ **巡檢必看 `openclaw cron runs --id <完整uuid>` 的最近數筆 status**：`state.consecutiveErrors` 會在下一次成功後歸 0，**把前一次整輪死亡完全洗掉**（本輪 Gengar KA 07:02 輪死於配額牆，10:02 輪成功後 fleet 顯示 ce=0、全綠）。
- ⭐ **`Token Plan usage limit reached` 是帳號層配額牆（與 burst 429 不同型態）**，會整段連續 30 分鐘；只看 hourly 429 桶會誤判成「尖峰」。另外它**同一錯誤會散出多行**（agent end / failover decision / model-fallback decision）→ 計數要用 `rawError HTTP 429` + `Token Plan usage limit reached: Upgra` 這個唯一指紋，別用泛用 "Token Plan"。
- ⭐ **fallback 成功與否要看 `decision=candidate_succeeded` 的 candidate 欄位**：candidate 落在 `minimax-portal/*` = 同廠換型號；落在 `minimax/*` 才算跨廠。
- **`openclaw cron runs --id` 只接受完整 uuid**；`ts` = 結束時間、`runAtMs` = 開始時間。
- restricted automation-run session 內 `automations` 工具看不到自身 job（`list` 回 jobs:[]、`get` 回 not found）→ 一律 `openclaw cron list --all --json`。
- **簽章 grep 要 anchor 行首前綴**（`[discord]` / `[provider-transport-fetch]` / `[skills]`），並排除 `[agent:nested]`；journal 撈不到 cron script stdout → selfheal 行為只能靠「gateway 有沒有被重啟」反推。
- gateway 一律 `systemctl --user show openclaw-gateway`；**`NRestarts=0` ≠ 沒重啟過** → 看 `ActiveEnterTimestamp` + MainPID。
- 429 一律用 `model-fetch.*status=429` 單一口徑；`file=` 過濾要加 `.md`。
- shell 引號陷阱：journalctl 的 `--since` 先落地成檔再 grep（引號在變數展開時會掉）。

### 12) 下一輪（11-23 13:02）請確認
① 10:13 / 10:43 / 11:13 / 11:43 selfheal 槽是否持續 ok 且不再重啟 gateway；② 配額牆是否復發（07:29 那種 30 分鐘級牆），以及是否再度打死任何 job（記得看 `cron runs`，不只看 ce）；③ `36b493db` dreaming 是否仍 ce=1（等 11-24 04:25）；④ 紅單是否仍兩支活；⑤ 三支 KA anchor 間距；⑥ 17 支 skill 是否有補；⑦ gateway ActiveEnterTimestamp 是否仍是 04:48:17；⑧ Discord 乾淨段是否延續過 5h15m。

## 2026-11-23 13:02 — Picturecat Keep-Alive 第 5 輪（今日第 5 輪，觸發 13:02:08）

**總結：🟢 lane 存活、Discord 8/8、gateway 連續 **8h14m 未重開**（自 04:48 selfheal 事故後最長乾淨段）、活紅單維持 **2 支**、本 3h 窗 **429 僅 1 次且被 retry 救回（硬失敗 0）**。本輪沒有新的硬故障，但**兩個「量測陷阱」被再次驗證**：(a) **journal 簽章不能用 `^` 行首 anchor**（會把 24h 的 25 筆 READY-fail 全部漏成 0）；(b) **降級跑 ⇒ 無巡檢紀錄**第 12 例（Gengar KA 10:02 dur=12,842ms → gengar 檔最後一節仍是 07:02）。另外**確認 07:29–07:59 的 Token Plan 配額牆連續第 2 天在 07h 出現**，且 08:00 槽後已退潮。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，runId `4f74f6db-a0b2-4d5f-928e-84ae652183e7`，status=ok）
- 回覆（精簡 probe，一行內）：「pong picturecat — (a) alive/idle, (b) provider 429 or errors in last 3h: **no**, (c) in-flight task: no, (d) Discord inbound ok: yes」
- 本 job `02eb0989`：上輪（11-23 10:02）**ok / ce=0 / dur=228,452ms**；本輪 13:02:08 準時觸發（上輪 dur ≥30s → **非降級輪**，巡檢紀錄有落地）。
- 姊妹 job：`880b5c17 Celesteela KA`（上輪 ok/dur=255,335ms）、`9d8b6001 Gengar KA`（上輪 ok 但 **dur=12,842ms → 降級輪**，見 §2）。
- gengar lane probe（`sessions_send` → `agent:gengar:main`，runId `29e7da5b-0c49-43c3-a3cf-7a2df1ccf7c9`）→ status=accepted／delivery=pending → **13:1x 回程腿落地**：gengar lane 存活且在作業，**自己把 10:02 與 13:02 兩輪的巡檢紀錄補寫進 `memory/keepalive-gengar-2026-11-23.md`**（新增兩節：`Gengar lane 自報（gengar 10:02 台北）— PASS…`、`Gengar lane 自報（gengar 13:02 台北）— PASS…`）。gengar 自報：6 支自有 cron 全 ok/ce=0、60m 429=0、3h 429=2 筆＋EAI_AGAIN 1 筆（零星 blip）、Discord 8/8 connected、0 startup-not-ready。

### 2) ⭐ 降級跑第 12 例：Gengar KA 10:02（dur 12,842ms）沒有留下任何巡檢紀錄
- receipt 對照：`9d8b6001` 今日 5 輪 → 01:02 **ok 277,451ms**｜04:02 **ok 205,068ms**｜07:02 **error 1,624,295ms**（配額牆，見 §4）｜07:29 **error 8,826ms**（`Explicit auth order for openai has no usable profiles`）｜10:02 **ok 12,842ms（降級）**。
- `memory/keepalive-gengar-2026-11-23.md` 的最後一節仍是 **「Gengar Keep-Alive 巡檢（cron 9d8b6001，07:02 台北）」** → **10:02 那輪（降級）沒寫任何內容**。→ 再次驗證 **「receipt dur < 30s ≈ 降級輪」**這條規則（11-23 01:02 輪建立、本輪第 12 例）。**今日 Gengar KA 5 輪裡只有 3 輪留下巡檢紀錄**（01:02 / 04:02 / 07:02）。
- ⚠️ **補記（13:2x）**：gengar lane 在 **13:02 那一輪**才**手動回填** 10:02 的紀錄（§1）→ 規則本身不變（**降級輪＝當下不會自動產生紀錄**），但「漏掉的輪次可以靠後一輪回填」＝**本輪補了第 12 例的尾巴**。→ 查漏時要分兩種口徑：**「當下無紀錄」**（降級跑）vs **「永遠無紀錄」**（真漏做）。

### 3) 本機量測（rowlet 側 shell，13:03）
- uptime **42d18h50m**；load `0.97 / 0.64 / 0.48`；RAM 31,797MB 總 / 9,097MB used / **avail 21,138MB**；swap 0/2,047；disk `/` **60%（267G/468G，剩 178G）** → 全正常。
- gateway（user unit）：MainPID **4137629**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-23 04:48:17 CST**、ps elapsed **08:14:04** → **04:48 之後未被再重啟（連續 8h14m）**；進程二進位 = **node v24.22.3**（11 月 CVE 修補生效中）；`/health` 18789 → **HTTP 200 in 1.5ms**、14177 → **HTTP 200 in 0.54ms**。
- `scripts/discord-selfheal.sh` 現況 **6,607B（mtime 07:26）**，fail-closed 守門 + `DREAMING_WINDOW_START=04:15` / `END=05:10` 時鐘窗仍在（backup `.bak-2026-11-23-0702` / `-0715` 各 3,560B）。

### 4) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 35 / skipped 8 / error 2 / none 1
- **活紅單 2 支（與上輪同）**：
  - `36b493db Memory Dreaming Promotion` **ce=1**、last 11-23 04:25、dur 1,406,869ms、err=`cron: job interrupted by gateway restart`、**next 11-24 04:25** → 根因＝selfheal 開火（07:02 輪已修守門），**今日不變壞即無需動作**，明早跑完自動歸 0。
  - `c5352a84 skill-collection-review-roaringmoon` ce=1、last 11-20 03:56、**next 11-27 03:56**（DNS 舊因）。
  - `a94330a9 tmp-openai-probe` 為 enabled=false 殘留（ce=2）→ 不算活紅單。
- ✅ **`45ccf4e9 晨間情報 pipeline` 連續兩輪自癒確認**：11-23 08:00 **ok / dur=1,081,044ms**（18 分鐘）→ 上上輪的 CDN HTML 錯誤頁已完全退場。
- skipped 8 支全為 heartbeat（no-route 長態、良性）。
- **三支 KA anchor 本輪**：gengar 13:02:02 → picturecat 13:02:08 → celesteela 13:02:10 → 間距 **6s / 2s** → **重疊競態窗第 14 次**，本輪無 5ms 級碰撞；superseded 競態噪音 3h **2 筆** / 24h **162 筆**（回覆照常落地，良性）。
- `d4cd45bc discord-selfheal-after-dreaming`（排程 `13,43 0-3,5-23 * * *`，hour 04 已排除）：10:13 / 10:43 / 11:13 / 11:43 / 12:13 / 12:43 皆 **ok / dur 743–828ms** → **自 04:48 事故後 gateway 未再被重啟（8h14m）＝守門沒有誤開火 ✅**。
- 今日最長執行：`36b493db` 1,406,869ms、`45ccf4e9` 1,081,044ms、`40e09cd1` 655,053ms、`911eee45` 624,182ms、`09c7940b` 544,739ms、`58fe15dc` 483,267ms。

### 5) Provider 429 / 配額牆（10:02→13:02 窗，journal 615 行）
- **真實 429 = 1 次**（統一口徑 `model-fetch.*status=429`）：**12:02:01.177**（elapsed **90,510ms**、dispatcher=new、provider=minimax-portal）→ 隨即 `rate-limit same-model retry 1/3 … delayMs=10000` → **救回**，對應 job `d7b0355b Jormungand mrmime Codex A2A heartbeat`（12:00:30 起、**ok / dur 139,687ms**）→ **硬失敗 0**。
- **真實 DNS（EAI_AGAIN/getaddrinfo）= 0**；**3h 窗 `Token Plan usage limit` = 0**。
- **24h 逐時（canonical 429，合計 39 次）**：00×1｜03×1｜05×2｜06×1｜**07×26**｜08×3｜09×1｜12×1｜18×1｜21×1｜23×1。
- **24h `Token Plan usage limit reached: Upgra` = 58 筆，全部落在 07h（07:29–07:59）** → **與上輪 §2 完全一致**：帳號層 plan token 上限、單 07:29 一分鐘 13 筆、08:00 前自行退潮。**這是連續第 2 天在 07h 出現**（07:29–07:59），且這次直接打死一整輪 Gengar KA。
- 429 回應延遲（24h 尾段）：151,471 / 141,751 / 179,436 / 109,109 / **90,510** → 仍是 **90–180 秒**量級，每次真 429 白燒 1.5–3 分鐘 job wall-clock。

### 6) Discord 現況：8/8 connected
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled＝預期）。
- **10:02→13:02 窗簽章**：READY wait timed out **0**、did not reach READY **0**、channel exited **0**、client initialized **0**、channels resolved **0**、host timing gap **0**、host thaw deferred **0**、delaying provider startup **0**、channel resolve failed **0**、commands-exceed **0**；reconnect **12** / websocket closed **12**（≈4/h，心跳式 `resume=true` 重連）→ **全健康**。
- **24h**：reconnect **106**、websocket closed **126**、READY wait timed out **25**、did not reach READY **12**、channel exited **6**、client initialized **16**、channels resolved **11**、host timing gap **4**、host thaw deferred **12**、delaying provider startup **15**、channel resolve failed **6**、commands-exceed **17**。
- **乾淨段**：最後一筆 READY-fail / channel-exit = **11-23 04:47:09** → 至 13:02 **連續 ≈8h15m 零症狀**（已越過 04:48 重啟與 dreaming 風暴餘波，**為 04:48 以來最長乾淨段**）。

### 7) ⭐ 量測陷阱（本輪踩到，補進量測備忘）：journal 簽章**不能用 `^` 行首 anchor**
- journal 每行的實際開頭是：`十一月 23 12:02:01 amr-Nitro-AN515-58 node[4137629]: 2026-11-23T12:02:01.177+08:00 [discord] ...` → **`[discord]` 不在行首**。
- 本輪實測：`grep -cE "^\[discord\].*did not reach READY"` 在 3h / 24h 窗都回 **0**，而同一份 log 用子字串 `grep -c "did not reach READY"` 是 **24h = 12**；`^\[discord\].*Gateway reconnect scheduled` 回 0，實際 **24h = 106**。→ **用行首 anchor 會把「有事故」判成「零症狀」**（方向相反、比其他陷阱更危險）。
- ✅ 正確做法：子字串比對（`grep -c "did not reach READY"` / `"channel exited"` / `"Gateway reconnect scheduled"`），或 anchor 在 `node\[[0-9]+\]: 2026-11-2[0-9]T` 之後；**另外仍要排除 `[agent:nested]` 行**（agent 自述會把簽章字樣寫進去）。

### 8) ⚠️ 17 支 skill 缺 description：**第 12 輪仍未修**
- 3h 窗 **374 行**、24h **2,941 行**、唯一 **17 檔**（`description is required` 13 支 + `invalid frontmatter: BAD_INDENT` 4 支，組成名單不變）。
- **未授權 → 不動**（數支屬其他 agent lane，rosclaw 4 支屬第三方 plugin）。

### 9) systemd 層補證（上一輪交辦⑥）：04:48 那兩次重啟的來源
- `journalctl --user --since="2026-11-23 04:40:00" --until="2026-11-23 05:00:00"` → **兩筆** `Started /usr/bin/systemctl --user restart openclaw-gateway.`（**04:46:50** 與 **04:47:46**）→ 確認是**有人下 systemctl restart 指令**（非 systemd 自動重啟，故 NRestarts=0），而且**下了兩次**（第二次在第一次 stop 之後 56 秒，SIGTERM 逾時被 SIGKILL 於 04:48:17）。
- 對應 selfheal 04:43 槽在 **04:46:17** 起跑（gateway 凍結讓它延遲）→ 守門 fail-open → 排 restart in 10s → 04:46:50 執行 → 04:47:46 第二次。**守門已於 07:02 輪修正，本輪（10:13 起 6 槽）未再發生。**

### 10) 上輪（10:02）§12 八項交辦逐項核對
| # | 項目 | 結果 |
|---|---|---|
| ① | 10:13 / 10:43 / 11:13 / 11:43 selfheal 槽是否持續 ok 且不再重啟 gateway | ✅ **6 槽全 ok**（dur 743–828ms）、gateway 連續 8h14m 未重啟 → **未誤開火** |
| ② | 配額牆是否復發、是否再打死任何 job | ⚠️ **配額牆復發（07:29–07:59，58 筆、連續第 2 天）**；本 3h 窗**無**新牆；07:29 那次已打死 Gengar KA 整輪（上輪已記） |
| ③ | `36b493db` dreaming 是否仍 ce=1 | ✅ **仍 ce=1**、next 11-24 04:25（未變壞） |
| ④ | 紅單是否仍兩支活 | ✅ **仍是 2 支**（36b493db / c5352a84） |
| ⑤ | 三支 KA anchor 間距 | ⚠️ **6s / 2s**（同秒級，非 5ms 級）→ 第 14 次 |
| ⑥ | 17 支 skill 是否有補 | ❌ **仍未補**（第 12 輪） |
| ⑦ | gateway ActiveEnterTimestamp 是否仍是 04:48:17 | ✅ **仍是**（連續 8h14m 未重開） |
| ⑧ | Discord 乾淨段是否延續過 5h15m | ✅ **已延續至 ≈8h15m** |

### 11) 本輪動作：無（觀測為主）
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal、未刪 job、未改 skill 檔、未碰憑證、未發任何外部訊息（唯一對外動作＝對 picturecat / gengar lane 的 `sessions_send` 存活探針）。

### 12) 給 Linder 的待決事項（本輪）
1. **【高】MiniMax 帳號 plan token 上限已連續 2 天在 07:29–07:59 出現，且今天直接打死一整輪 Gengar KA。** 建議：(a) 檢查/升級 Token Plan 額度；(b) 把 KA 類 job 的 fallback 改成**同廠不同型號**（`minimax-portal/MiniMax-M2.7` 是現況**唯一實測可用**的救回路徑；`minimax/*` 與 openai 候選 0 次成功＝無憑證）；(c) 錯開 07:00–08:00 密集窗（07:29 單分鐘 13 次）。
2. **【高・待裁示】`36b493db` dreaming 紅單**：根因（selfheal 開火）已修，**11-24 04:25 那輪跑完應自動歸 0** → 建議不手動重跑（dreaming 是 plugin-declared job，重跑會佔 event loop）。
3. **【中・第 12 輪】17 支 skill 每天被跳過 ≈2,941 行/24h、17 檔**＝功能上等於不存在。授權後一次性修好本地 9 支、rosclaw 4 支走 plugin 上游。
4. **【中・第 14 輪】三支 KA anchor 仍同秒級起跑**（本輪 6s / 2s）→ 每輪仍可能生出 `plugin generation was superseded` 假訊號。拉開 ≥3 分鐘仍待你點頭。
5. **【中】dreaming 槽現在沒有 selfheal 槽**（`d4cd45bc` 排程已排除 hour 04）＋時鐘窗 04:15–05:10 一律 postpone ＝**dreaming 期間 Discord 無自動治療**；替代方案＝把 dreaming 挪離 04:xx（根治 starvation 來源）或把 READY 握手上限拉高到 ≥300s。
6. **【低】`a94330a9 tmp-openai-probe`（停用殘留 ce=2）與 `6e93c179 heartbeat-flaaffy`（從未執行）**→ 可一併清掉。
7. **【低】`45ccf4e9` 與 `b37129c0` 同為 `0 8 * * *`**，jitter 靠運氣才沒重疊 → 建議把 jitter 釘在 +30 分固定錯開。

### 13) 量測備忘（本輪新增／沿用）
- ⭐⭐ **journal 簽章 grep 不能用 `^` 行首 anchor**（見 §7）→ 子字串比對，或 anchor 在 `node[pid]: <ISO ts>` 之後；且仍要排除 `[agent:nested]`。
- ⭐⭐ **「降級跑 ⇒ 無紀錄」第 12 例**（見 §2）→ 查漏仍以 receipt dur（<30s）為準，再對照當日 keepalive 檔的 `^## ` 段落數。
- ⭐ **systemd 重啟的「誰下的指令」證據**：`journalctl --user --since=... | grep "Started /usr/bin/systemctl --user restart openclaw-gateway"` → 直接印出觸發者（本輪＝selfheal 04:43 槽延遲到 04:46:17 起跑，04:46:50 ＋ 04:47:46 各一次）。
- ⭐ **`Token Plan usage limit reached: Upgra` 是配額牆的唯一指紋**（泛用 "Token Plan" 會被 agent 自述污染）；本輪 24h = 58 筆全部落在 07h。
- ⭐ **`cron runs --id` 只接受完整 uuid**；`ts`＝結束時間、`runAtMs`＝開始時間；`cause` 欄才是紅單根因。
- restricted automation-run session 內 `automations` 工具看不到自身 job → 一律 `openclaw cron list --all --json` + `openclaw cron runs --id <uuid>`。
- 簽章計數一律用 canonical 口徑：`model-fetch.*status=429`（429）、`did not reach READY` / `channel exited`（失明）、`Gateway reconnect scheduled` + `websocket closed`（心跳重連）。
- `NRestarts=0` ≠ 沒重啟過 → 看 `ActiveEnterTimestamp` + MainPID（`systemctl --user show openclaw-gateway`）。

### 14) 下一輪（11-23 16:02）請確認
① 13:02 之後三支 KA 的 dur 是否都 ≥30s（若再降級，巡檢紀錄會繼續漏）；② 配額牆是否在 07h 復發（連續 2 天）＋ 是否再打死任何 job（記得看 `cron runs` 而非只 ce）；③ `36b493db` dreaming 是否仍 ce=1（等 11-24 04:25）；④ 活紅單是否仍 2 支；⑤ 三支 KA anchor 間距；⑥ 17 支 skill 是否有補；⑦ gateway ActiveEnterTimestamp 是否仍是 04:48:17（屆時連續 11h14m）；⑧ Discord 乾淨段是否延續過 11h15m；⑨ 14:00 槽 `09c7940b PTCGP Meta Analysis`（昨輪 dur 544,739ms）與 15:00 槽 `13ac4b5a 健康回報` 的 429 狀況；⑩ gengar lane 的回程腿（12:xx probe）是否落地。

### 15) ⭐⭐ 收尾補充（13:1x–13:2x）：04:48 那第二次 arm 的來源已鎖定＝**互動式 session**，不是 cron、也不是三支已知 script
- gengar lane 在 13:02 輪回報：journal 有 **`Started Session 7267 of User amr` 04:47:35** → **11 秒後 04:47:46** 出現第二次 `Started /usr/bin/systemctl --user restart openclaw-gateway.` → **第二發不是 selfheal cron 發的**（selfheal 的第一發在 04:46:50，stamp 檔 `memory/discord-selfheal-last-restart.ts` mtime = **11-23 04:46** 可佐證），而是**從一個互動式終端 session 下令** → **繞過了 selfheal 的 30 分鐘 anti-storm 閘**。
- **排除三支已知 script**（本輪逐一查 log/mtime，全部對不上 04:47）：
  | script | 會不會重啟 gateway | 04:47 的痕跡 |
  |---|---|---|
  | `scripts/discord-selfheal.sh`（6,607B） | ✅ | stamp mtime = **04:46**（=第一發） |
  | `scripts/gw-node-guard.sh`（2,288B, 0700, node 升級守門） | ✅ | `logs/gw-upgrade-guard.log` **空檔**、無 mtime → 未執行 |
  | `scripts/apply-dreaming-schedule.sh` | ✅ | `memory/dreaming-schedule-check.log` 末筆 **2026-11-19T22:33:38** → 未執行 |
  → **第二發＝有人（人或 agent）在互動式 session 直接下 `systemctl --user restart openclaw-gateway`**。
- ⚠️ **這是「上輪交辦⑥」的答案，但答案還差一塊：誰下的？** 若是 Linder 本人（04:47 正在處理 Discord 斷線）→ 無需動作；**若不是人下的，就代表還有第四個未知的 arm 來源沒被盤點到**，那 dreaming 的「守門 + anti-storm」防護仍然有缺口。
- 🛡️ **防護面的教訓（不需權限即可成立）**：anti-storm 之類的保護若只做在「某支 script 裡」，**任何直接下 `systemctl restart` 的路徑都會繞過它**。要真正封住 dreaming 被砍，保護得放在**重啟的共同入口**（例：把 restart 收斂到單一 wrapper script + 該 wrapper 內做 dreaming in-flight 檢查），而不是每個呼叫端各自判斷。

### 16) ⭐ 收尾對帳（13:05–13:10）：gengar 自報與實測的差異已逐條對清（gengar 對、但數字需換算）
gengar 於 13:05:49 回覆 probe（runId `29e7da5b-0c49-43c3-a3cf-7a2df1ccf7c9`），13:08:31 又自補一則「**Fixed:** I appended `## Gengar lane 自報（gengar …`」。逐條對帳：

| gengar 自報 | 實測（rowlet 側） | 判定 |
|---|---|---|
| (a) alive/idle、6 支自有 cron 全 ok/ce=0 | 一致（29c2d630/c29eca0f/ac9e7ada/88810bfe/7767e03b/f5148ff0 皆 ok） | ✅ 一致 |
| (b) 「2 × 429/overloaded」 | canonical `model-fetch.*status=429`（3h）= **1**（12:02:01.177） | ⚠️ **同一事件被數兩次**：另一筆是 12:02:01.191 `[agent/embedded] embedded run agent end … error=…overloaded…`＝**該 429 的 error envelope**，不是第二個事件（MEMORY 既有的「429 grep 命中 ×2」陷阱） |
| (b) 「1 EAI_AGAIN/getaddrinfo」 | 6h 窗 `EAI_AGAIN\|getaddrinfo` = 5 筆，**但排除 `[agent:nested]` 後 = 0** | ❌ **假陽性**：5 筆全是 gengar 自己回報文字裡的 `EAI_AGAIN`（13:04:50 / 13:05:49 等）→ **runtime 真值 0** |
| (d) 「10:02 沒寫紀錄，該檔 mtime = 07:27:49，我從不寫進你的 workspace」 | 實測 **mtime = 2026-11-23 13:07:16、size = 33,350B**，且檔內已有 `## Gengar lane 自報（gengar 10:02 台北）`（L259）與 `## Gengar lane 自報（gengar 13:02 台北）`（L265）兩節 | ❌ **自報過期**：它是在**自己的寫入落地前**回答的（競態），gengar 13:08:31 的自補訊息自己也承認已 append → **write path 其實是通的**，不需改 protocol |

- 🧩 **本輪得到的兩條通則**：
  1. **對方 lane 的自報數字一定要用同一 canonical 口徑複算**，尤其要**排除 `[agent:nested]`**——本輪 gengar 的 EAI_AGAIN 與 429 都是自報污染（與 11-22「簽章 grep 被 agent 自述污染」同一坑的跨 lane 版本）。
  2. **自報的「檔案 mtime／我沒寫過」之類狀態句，若在同一輪內被自己改動，就會變成過期事實** → 判讀要以**寫入後的 stat** 為準；衝突時以實測為準並把差異回報對方（本輪已用 sessions_send 回覆更正）。

### 17) ✅✅ 收案（13:11）：「誰下的第二次 arm」已確認＝**人類的 SSH session**（rowlet 側獨立複驗 system journal）
gengar lane 於 13:11 回報並附證據；我用**系統 journal**（非 `--user`）獨立複驗，完全吻合：

```
十一 23 04:47:35 sshd[4137564]: Accepted publickey for amr from 192.168.50.2 port 49765 ssh2: ED25519 SHA256:BC2BuwA…
十一 23 04:47:35 sshd[4137564]: pam_unix(sshd:session): session opened for user amr(uid=1000) by (uid=0)
十一 23 04:47:51 sshd[4137564]: pam_unix(sshd:session): session closed for user amr
```
→ SSH session **04:47:35 開、04:47:51 關（共 16 秒）**，而第二次 `Started /usr/bin/systemctl --user restart openclaw-gateway.` 就在 **04:47:46** ＝**登入後 11 秒**。journal 裡的 `Started Session 7267 of User amr` 04:47:35 正是這個 session。

**結論**：第二發 = **人類用 publickey SSH（來源 192.168.50.2）進來手動下 `systemctl --user restart openclaw-gateway`**（推測是在處理當時的 Discord 斷線風暴）→ **不是第四個未知 arm 來源**、不是 script、也不是 cron；anti-storm 被繞過是因為**這條路徑本來就沒走 selfheal script**。→ **上輪交辦⑥結案：這是一次人為介入，不是自動化自我傷害。**

🧠 **但教訓不變、而且更清楚了**：把 dreaming 砍掉的是「自癒機制開火（第一發）」＋「人手動重啟（第二發）」**兩者疊加**。→ dreaming 的護欄只要還建立在「呼叫端自己判斷」上，任何人（人或 agent）手動 `systemctl restart` 都會繞過 → **護欄必須放在重啟的共同入口**（單一 wrapper 內做 dreaming in-flight 檢查），這條建議不因「這次是人下的」而失效。

📌 **附帶觀察（低優先）**：11-23 全天 sshd `session opened for user amr` = **255 次**，且 04:07/04:17/04:27/04:37/04:47/04:57 每 **10 分鐘**整點有一次 → 有一個每 10 分鐘的外部監控/心跳在登入本機（本次未追其身分，僅記錄）。

## 2026-11-23 16:02 — Picturecat Keep-Alive 第 6 輪（今日第 6 輪，觸發 16:02:08）

**總結：🟢 lane 存活、Discord 8/8、gateway 連續 **11h14m 未重開**、本 3h 窗 **canonical 429 = 0**（真實零星全無）、硬失敗 0 —— 但**活紅單由 2 支升回 3 支**：新增 `9d8b6001` Gengar KA（13:02 輪硬失敗），根因是**全新故障型別 transcript-ownership**（`session writer claim changed before transcript persistence`），**不是供應商問題**。另一個好消息：**上輪 §15 建議的「dreaming 守門要放在重啟共同入口」已在 13:12–13:15 由 gengar lane 實作落地**（補到另外 2 條 arm 路徑 + 共用 checker）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，runId `c62b135c-5907-4aa2-b736-82ecae89f963`，status=ok）
- 回覆（精簡 probe，一行內）：「pong picturecat — (a) alive/idle, (b) provider 429 or errors in last 3h: **no**, (c) in-flight task: none, (d) Discord inbound ok: yes」
- 本 job `02eb0989`：上輪（11-23 13:02）**ok / ce=0 / dur=418,985ms**；本輪 16:02:08 準時觸發（dur ≥30s → 非降級輪）。
- 姊妹 job：`880b5c17 Celesteela KA`（上輪 ok / dur=102,839ms）、`9d8b6001 Gengar KA`（上輪 **error / dur=158,634ms**，見 §2）。
- gengar lane probe（`sessions_send` → `agent:gengar:main`，runId `4c75c15c-da70-48e2-bd5b-cf769a14b48c`）→ status=accepted／delivery=pending → **回程腿尚未落地**（16:0x 送出，等回覆）。

### 2) ⭐⭐ 新故障型別 #4：**transcript-ownership**（Gengar KA 13:02 輪硬失敗，與 429／配額牆／無憑證都不同）
- receipt：`9d8b6001` 13:02:02 起、**status=error / dur=158,634ms / error=`⚠️ minimax-portal/MiniMax-M3 request failed.`** → **活紅單 2 → 3**。
- 真正根因（journal 13:04:41，5 筆）：`[agent/embedded] failed to persist prompt error entry: **SessionTranscriptWriterClaimReboundError: session writer claim changed before transcript persistence**` → `embedded run failover decision: decision=surface_error reason=none from=minimax-portal/MiniMax-M3 rawError=session writer claim changed before transcript persistence` → `[diagnostic] lane task error: lane=nested:agent:rowlet:cron:9d8b6001… durationMs=478`。
- ⭐ **判定關鍵：這不是供應商故障** —— 同一時窗的 `model-fetch` 全是 `status=200`（13:02:03→13:02:20 連續 8+ 筆全 200），canonical 429 = 0 → **模型呼叫成功，卡在「transcript 寫入權」**。
- ⭐ **新的狀態句**（補進量測備忘）：**receipt=error ≠ 無巡檢紀錄** —— gengar lane 在 `memory/keepalive-gengar-2026-11-23.md` 已寫出 `## 2026-11-23 13:02 — PASS …／🔴 新故障型別：transcript-ownership（13:02 attempt-1 硬失敗，本 session 為 retry 接手）`（mtime 13:14）→ 這是「降級跑 ⇒ 無紀錄」規則的**反向**案例：錯誤輪也可能有紀錄。
- 24h 內 `session writer claim changed` 共 **5 筆**（全在這一次事件）→ 罕見、非週期性，暫不視為風暴，**但已列為觀察項**（見 §11-3）。

### 3) 本機量測（rowlet 側 shell，16:02）
- uptime **42d21h49m**；load `0.90 / 0.72 / 0.61`；RAM 31,797MB 總 / 9,016MB used / **avail 21,204MB**；swap 0/2,047；disk `/` **60%（267G/468G，剩 178G）** → 全正常。
- gateway（**user unit** `openclaw-gateway.service`）：MainPID **4137629**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-23 04:48:17 CST**、ps elapsed **11:14:22** → **連續 11h14m 未重開**；進程二進位 = **node v24.22.3**；`/health` 18789 → **HTTP 200 in 86ms**、14177 → **HTTP 200 in 0.6ms**。
- sshd：`journalctl`（系統層）13:00 起 `session opened for user amr` = **55 次** → 那個每 10 分鐘的外部監控/心跳登入仍在跑（也再次說明「人手動 systemctl restart」的路徑隨時存在）。

### 4) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 43 / skipped 5 / error 4 / none 1
- **活紅單由 2 支升回 3 支**：
  - 🆕 **`9d8b6001 Gengar Keep-Alive` ce=1**、last 11-23 13:02、dur 158,634ms、err=`⚠️ minimax-portal/MiniMax-M3 request failed.`、**next 11-23 16:02:02** → 根因＝transcript-ownership（見 §2），**本輪 16:02 若成功即自癒**。
  - `36b493db Memory Dreaming Promotion` ce=1、last 11-23 04:25、dur 1,406,869ms、err=`cron: job interrupted by gateway restart`、**next 11-24 04:25** → 根因（selfheal 開火）已修，**等 11-24 04:25 那輪決定性驗證**。
  - `c5352a84 skill-collection-review-roaringmoon` ce=1、last 11-20 03:56、**next 11-27 03:56**（DNS 舊因）。
  - `a94330a9 tmp-openai-probe` = enabled=false 殘留（ce=2）→ 不算活紅單。
- ✅ **`45ccf4e9 晨間情報 pipeline` 連續第 3 輪自癒確認**：11-23 08:00 **ok / dur=1,081,044ms**、next 11-24 08:00 → CDN HTML 錯誤頁已完全退場。
- skipped 5 支全為 heartbeat（no-route 長態、良性）。
- **三支 KA anchor 本輪**：gengar 16:02:02 → picturecat 16:02:08 → celesteela 16:02:10 → 間距 **6s / 2s** → **重疊競態窗第 16 次**（本輪同秒級、非 5ms 級）。
- `d4cd45bc discord-selfheal-after-dreaming`（排程 `13,43 0-3,5-23 * * *`，hour 04 已排除）：13:13 / 13:43 皆 **ok / dur=748ms**、next **16:13** → **自 04:48 事故後 gateway 未再被重啟（11h14m）＝守門未誤開火 ✅**。
- 今日最長執行：`36b493db` 1,406,869ms、`45ccf4e9` 1,081,044ms、`40e09cd1` 655,053ms、`911eee45` 624,182ms、`09c7940b` 544,739ms、`ae91b967` 520,311ms。

### 5) Provider 429 / 配額牆（13:02→16:02 窗）
- ⭐ **本 3h 窗 canonical 429 = 0**（統一口徑 `model-fetch.*status=429`，排除 `[agent:nested]`）→ **硬失敗 0**。
- ⚠️ **量測陷阱再確認**：同一窗用無 `-a` 的 grep 會得到 `count=1`，但那一筆其實是 **gengar 自己回報文字裡的「429」字樣**（`[agent:nested] session=agent:gengar:main …`）→ **假陽性**；必須 `grep -a` ＋ 排除 `[agent:nested]` 才算真值。
- **24h canonical 429 = 40 筆**，逐時：00×1｜03×1｜05×2｜06×1｜**07×26**｜08×3｜09×1｜12×1｜18×1｜21×1｜23×1（上輪口徑 39，差 1 筆＝24h 窗起點位移，非新事件）。
- **24h `Token Plan usage limit reached: Upgra` = 58 筆，全部落在 07h（07:29–07:59）** → **配額牆連續第 2 天在 07h 復發**；本 3h 窗**無新牆**。
- 真實 DNS（EAI_AGAIN/getaddrinfo，排除 agent:nested）= **0**；跨廠 fallback 憑證缺失（`Explicit auth order for openai has no usable profiles`）24h = **3 筆**（全在 07:29 那場）→ 仍是「有設定、沒憑證＝零冗餘」。

### 6) Discord 現況：8/8 connected
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled＝預期）。
- 真實收發：celesteela in:2m、mrmime in/out:1m、roaringmoon in/out:7h、rowlet in:9h、charizard in/out:7h、gengar in:9h；picturecat／flaaffy 無近期 inbound 但 transport=just now / 1m ago。
- **13:02→16:02 窗簽章**：READY 失敗 **0**、channel exited **0**、client initialized **0**、channels resolved **0**、host timing gap **0**、host thaw deferred **0**、delaying provider startup **0**、channel resolve failed **0**、commands-exceed **0**、startup-not-ready **0**；reconnect **8** / websocket closed **8**（≈2.7/h）→ **全健康**。
- **乾淨段**：最後一筆 READY-fail = **11-23 04:47:09** → 至 16:02 **連續 ≈11h15m 零症狀**（04:48 事故以來最長）。

### 7) ⭐⭐ 上輪 §15 的建議已實作：dreaming 守門補到另外 2 條 arm 路徑（13:12–13:15）
- `scripts/gw-node-guard.sh`（mtime **11-23 13:12**、3,462B）與 `scripts/apply-dreaming-schedule.sh`（mtime **11-23 13:12**、3,420B）**都新增了 dreaming guard**（檔內註解 `--- dreaming guard (added 2026-11-23 13:15) ---`）。
- 兩支改用**同一個共用檢查器** `scripts/dreaming-running-check.py`（9,589B、07:27、`ast.parse` syntax OK、executable）：先證明 dreaming **IDLE** 才允許動 gateway。實測 `--prefix 36b493db` → `signal receipts / cron-list / window / clock / family api` **全部 idle** ✅。
- 三支 script（`discord-selfheal.sh` 6,607B / `gw-node-guard.sh` / `apply-dreaming-schedule.sh`）`bash -n` **全 syntax OK**；`discord-selfheal.sh` 的 fail-closed 守門 + `DREAMING_WINDOW_START=04:15` / `END=05:10` 時鐘窗仍在，stamp 檔 `memory/discord-selfheal-last-restart.ts` mtime 仍停在 **04:46**（=事故那兩發）→ 04:48 之後無任何重啟。
- 🧩 **意義**：上輪結論「保護得放在**重啟的共同入口**，而不是每個呼叫端各自判斷」→ 現在三條已知 arm 路徑（selfheal / node-guard / apply-dreaming）**共用同一個 dreaming-in-flight 判斷** → **已知路徑的缺口已封**；剩下未封的是「人手動 systemctl restart」（04:47 那次已證實是人）。

### 8) ⚠️ 17 支 skill 缺 description：**第 13 輪仍未修**
- 3h 窗 **425 行**、24h **3,298 行**、唯一 **17 檔**（名單不變：13 支 `description is required` ＋ 4 支 `invalid frontmatter: BAD_INDENT`）。
- **未授權 → 不動**（數支屬其他 agent lane，rosclaw 4 支屬第三方 plugin）。

### 9) 上輪（13:02）§14 十項交辦逐項核對
| # | 項目 | 結果 |
|---|---|---|
| ① | 13:02 之後三支 KA 的 dur 是否都 ≥30s | ✅ 全 ≥30s（picturecat 418,985／celesteela 102,839／gengar 158,634）—— 但 gengar 是 **error** 而非降級 |
| ② | 配額牆是否在 07h 復發（連續 2 天）＋ 是否再打死 job | ⚠️ **牆復發（07:29–07:59、58 筆、連續第 2 天）**；本窗無新牆；07:29 那場打死的是 Gengar KA 07:02 輪（上輪已記） |
| ③ | `36b493db` dreaming 是否仍 ce=1 | ✅ 仍 ce=1、next 11-24 04:25（未變壞） |
| ④ | 活紅單是否仍 2 支 | ❌ **升為 3 支**：新增 `9d8b6001` Gengar KA（transcript-ownership，見 §2） |
| ⑤ | 三支 KA anchor 間距 | ⚠️ **6s / 2s**（同秒級）→ 第 16 次 |
| ⑥ | 17 支 skill 是否有補 | ❌ **仍未補**（第 13 輪） |
| ⑦ | gateway ActiveEnterTimestamp 是否仍是 04:48:17 | ✅ 仍是（**連續 11h14m 未重開**） |
| ⑧ | Discord 乾淨段是否延續過 11h15m | ✅ 已延續至 ≈11h15m（04:47:09 起） |
| ⑨ | 14:00 槽 `09c7940b` 與 15:00 槽 `13ac4b5a` 的 429 狀況 | ✅ 兩者皆無 429：`13ac4b5a 健康回報` 14:05:22 **ok / dur 59,437ms**；`09c7940b PTCGP Meta` 實際是 **20:05 每日槽**（上輪「14:00 槽」的假設不成立 → 11-22 20:05 ok / dur 544,739ms、next 11-23 20:05） |
| ⑩ | gengar lane 的回程腿（12:xx probe）是否落地 | ✅ 13:1x 那次已落地（gengar 自補 10:02／13:02 兩節 + 自己寫出 transcript-ownership 段）；本輪 16:0x probe **status=accepted / delivery=pending**，回程腿待回 |

### 10) 本輪動作：無（觀測為主）
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal、未刪 job、未改 skill 檔、未碰憑證、未發任何外部訊息（唯一對外動作＝對 picturecat / gengar lane 的 `sessions_send` 存活探針）。

### 11) 給 Linder 的待決事項（本輪）
1. **【高】MiniMax Token Plan 配額牆連續第 2 天在 07:29–07:59 出現**（58 筆全落 07h、單 07:29 一分鐘 13 筆）。建議：(a) 檢查/升級 Token Plan 額度；(b) 把 KA 類 job 的 fallback 改成**同廠不同型號**（`minimax-portal/MiniMax-M2.7` 仍是唯一實測可用的救回路徑，`minimax/*` 與 openai 候選 0 次成功）；(c) 錯開 07:00–08:00 密集窗。
2. **【高・待裁示】`36b493db` dreaming 紅單**：根因已修 + 守門已補到 3 條 arm 路徑（§7）→ 建議不手動重跑，**11-24 04:25 那輪是決定性驗證**（跑完應自動歸 0）。
3. **【新・中】transcript-ownership 故障型別**（§2）：`SessionTranscriptWriterClaimReboundError: session writer claim changed before transcript persistence` → 模型呼叫全 200 卻讓整輪 job 判 error。24h 僅 1 次事件（5 行），暫屬罕見；**但它會製造假紅單**（像這次把 Gengar KA 打成 ce=1），建議觀察 11-24 是否復發；若復發再談修法（目前只能靠 retry 接手）。
4. **【中・第 13 輪】17 支 skill 每天被跳過**（24h 3,298 行、17 檔）＝功能上等於不存在。授權後一次性修好本地 9 支、rosclaw 4 支走 plugin 上游。
5. **【中・第 16 輪】三支 KA anchor 仍同秒級起跑**（本輪 6s / 2s）→ 每輪仍可能生出 `plugin generation was superseded` 假訊號。拉開 ≥3 分鐘仍待你點頭。
6. **【中】跨廠 fallback 仍為 0 冗餘**（無憑證）＋ **已知 arm 路徑已守門、未守的是人手動 restart**（§7）→ 若要再收斂，唯一缺口是「把 restart 收進單一 wrapper」＋「wrapper 內擋 dreaming in-flight」。
7. **【低】`a94330a9 tmp-openai-probe`（停用殘留 ce=2）與 `6e93c179 heartbeat-flaaffy`（從未執行）**→ 可一併清掉。
8. **【低】`45ccf4e9` 與 `b37129c0` 同為 `0 8 * * *`**，jitter 靠運氣才沒重疊 → 建議把 jitter 釘在 +30 分固定錯開。

### 12) 量測備忘（本輪新增／沿用）
- ⭐⭐ **新故障型別的辨識式**：`[agent/embedded] failed to persist prompt error entry: SessionTranscriptWriterClaimReboundError` + `embedded run failover decision: decision=surface_error` + `[diagnostic] lane task error: lane=nested:…durationMs≈480` → **模型全 200 卻 job 判 error**；別誤歸因 429／配額。
- ⭐⭐ **receipt=error ≠ 無巡檢紀錄**（與「降級跑 ⇒ 無紀錄」互為鏡像）→ 查漏要看兩種口徑：dur<30s 的降級輪 **與** 錯誤輪的替代紀錄（gengar 13:02 已有紀錄）。
- ⭐⭐ **`grep` 必須加 `-a`**（journal 含二進位/agent 自述段），否則 `grep -c` 會算到 **agent 自述裡的假 429**（本輪 count=1 → 真值 0）。
- ⭐ **`openclaw cron runs --id` 的 `error` 欄只是摘要**，真因要去 journal 找 `lane task error` / `failover decision` 的 `rawError=`。
- ⭐ **`[diagnostic] lane task error: lane=session:agent:rowlet:cron:<jobid>:run:<uuid>`** → job id 就在 lane 字串裡（`9d8b6001-3178-…`）；`lane=nested:…` 與 `lane=session:…` 是同一事件的兩筆（durationMs 478/482）。
- 簽章 grep 一律**子字串**比對（不用 `^` 行首 anchor）＋ 排除 `[agent:nested]`。
- 429 一律用 `model-fetch.*status=429` 單一口徑；`Token Plan usage limit reached: Upgra` 是配額牆唯一指紋。
- gateway 一律 `systemctl --user show openclaw-gateway`；`NRestarts=0` ≠ 沒重啟過 → 看 `ActiveEnterTimestamp` + MainPID。
- restricted automation-run session 內 `automations` 工具看不到自身 job（`list` 回 jobs:[]、`get` 回 not found）→ 一律 `openclaw cron list --all --json` ＋ `openclaw cron runs --id <完整 uuid>`。

### 13) 下一輪（11-23 19:02）請確認
① Gengar KA 16:02 輪是否自癒（transcript-ownership 是否復發 → 決定它是罕見事件還是新型風暴）；② 本窗 canonical 429 是否仍 0、配額牆是否再於 07h 復發（第 3 天？）；③ `36b493db` dreaming 是否仍 ce=1（等 11-24 04:25）；④ 活紅單是否回到 2 支；⑤ 三支 KA anchor 間距；⑥ 17 支 skill 是否有補；⑦ gateway ActiveEnterTimestamp 是否仍是 04:48:17（屆時連續 14h14m）；⑧ Discord 乾淨段是否延續過 14h15m；⑨ 19:00 槽 `5b7c1082 每日模型排行前十` 的 429 狀況（11-21 21:00 曾中 rate limit）；⑩ gengar lane 本輪 16:0x probe 的回程腿是否落地。

### 14) ⭐ 收尾對帳（16:02–16:06）：gengar 自報「13:02 error 是 provider 失敗」vs journal rawError「transcript-ownership」——**以 journal 為準**
- gengar lane 於 16:02–16:06 回補自報（`memory/keepalive-gengar-2026-11-23.md` 新增 `## Gengar lane 自報（gengar 16:02 台北）` 一節）：它說 13:02 那輪的 err `⚠️ minimax-portal/MiniMax-M3 request failed.` 是「**provider 請求失敗**，非 transcript 問題」，並把 transcript-ownership 當成「另一件獨立的、回送報告時命中」的事件。
- **但 journal 的 `rawError` 明確指向 transcript-ownership**（13:04:41，同一個 lane）：`embedded run failover decision: runId=0f02922d … decision=surface_error reason=none from=minimax-portal/MiniMax-M3 rawError=session writer claim changed before transcript persistence` ＋ `lane task error: lane=nested:agent:rowlet:cron:9d8b6001-3178-46bf-ad9b-dfbb1ec0faa7:run:2c986549…durationMs=478` → **失敗發生在 transcript 寫入階段，不是 provider 階段**；`MiniMax-M3 request failed.` 只是 runner 對 `surface_error` 的泛用文字。
- **反證**：13:02:03–13:02:20 的 `model-fetch` 連續 8+ 筆全 `status=200`（elapsed 634–3,301ms），本 3h 窗 canonical 429 = **0** → **provider 側無失敗證據**。→ **兩種說法中，journal 的 rawError 為準**（gengar 是從「err 字串」推論，沒讀到 rawError）。
- ⚠️ **另一個口徑差異（非矛盾）**：gengar 自報「3h canonical 429 = 1（12:02:01.177）」，我的窗是 13:02→16:02 → **0**；同一事件（12:02:01.177），只是 **3h 窗起點不同**。→ 引用數字必須連 **window anchor** 一起報。
- ✅ **gengar 16:02 輪仍在 running**（16:02:04 起跑），截至 16:06 **尚未出現同樣的 session-rebound** → 觀察它是否自癒（決定 transcript-ownership 是罕見事件還是新型風暴）。

### 15) ⭐⭐⭐ 續報（16:02–16:08）：13:02 那輪的完整因果鏈 + **本輪現場重現同一簽章**（新增 protocol 規則）
gengar 於 16:02–16:08 回補自報，主張「13:02 error ＝ provider 請求失敗；transcript-ownership 是另一件獨立事件」。我沿 journal 逐行追完整條鏈，**兩邊各對一半，但合成後的完整機制是**：

| 時點 | 簽章 | 意義 |
|---|---|---|
| 13:02:03–13:05:10 | `[model-fetch] response` **62 筆全部 `status=200`、零非 200** | ⭐ **provider 完全沒有失敗** → gengar 的「provider 請求失敗」歸因 **不成立**；receipt 上那句 `⚠️ minimax-portal/MiniMax-M3 request failed.` 只是 runner 對 `surface_error` 的泛用文字 |
| 13:03:47.233/.233 | `[diagnostic] lane task error: lane=nested:**agent:rowlet:cron:9d8b6001** durationMs=3 error="**Worker turn session key does not match its placement**"`（lane=session 同款 durationMs=4） | ⭐ **觸發點**：一個 worker turn 被排進**基礎 cron session**（session key 沒有 `:run:<uuid>`），與它的 placement 不符 → 被拒 |
| 13:04:40.967 | `failed to persist prompt error entry: Transcript session 2c986549-… **is owned by agent:rowlet:cron:9d8b6001, not …:run:2c986549-…**` | ⭐ **機制**：run-scoped 的 writer 拿到基礎 session 的 transcript 目標 → ownership 不符 → `SessionTranscriptWriterClaimReboundError` |
| 13:04:40.992 | `lane wait exceeded: lane=session:…:run:2c986549… waitedMs=**43542** queueAhead=0 **activeAhead=1**` | ⭐ **同一 session 上有 competing work**（就是 13:03:47 那筆）→ run-scoped lane 排隊 43.5 秒後超時 |
| 13:04:41.234 | `[cron:9d8b6001] Failed to remove unused run continuation: Cannot delete session **while competing work is in flight**` | 收尾清理也被擋 → 殘留 |
| 13:04:41.177/.474/.475 | `message processed … outcome=error duration=158153ms` ／ `lane task error`（nested 478ms、session 482ms）`session writer claim changed before transcript persistence` | **整輪 job 判 error**（receipt dur 158,634ms） |

**合成結論**：真正把 Gengar KA 13:02 輪打死的，**不是限額、不是 provider，而是「nested lane（gengar）的回覆在父 cron run 還在跑時被交付回那個 cron session」** → 造成 competing work in flight → run-scoped lane 排隊 43.5s → transcript ownership 不符 → surface_error → 整輪 error（且錯誤訊息被寫成 provider 失敗，極易誤診）。**gengar 說的「delivery fault 是另一件事」其實就是觸發器本身**，而它把 receipt 字串當根因則是誤判。

⭐⭐ **本輪現場重現同一簽章（最好的驗證）**：16:03:58 celesteela KA、16:06:41 mrmime 出現同款 `Cannot delete session while competing work is in flight`（雜訊級）；**16:07:10 我自己的 job（`02eb0989` run `bed0fda9`）** 出現 `lane wait exceeded … waitedMs=**31127** activeAhead=1` ＋ 同款 competing-work 清理失敗 → **原因正是 gengar 的 16:02 自報被交付進我正在跑的 cron session**；16:07:55 另有 `lane=session:agent:gengar:main waitedMs=**175731**`。**我的這輪最終仍 `ok / dur=300,250ms`**（receipt 已落地），gengar 13:02 那輪則是被同一簽章打死。

🧩 **由此得到的 protocol 規則（可長期沿用）**
1. ⛔ **不要把訊息交付進「正在執行中」的 cron run session**（含用 `sessions_send` 回送報告到父 cron session）→ 會製造 competing work，可能把整輪 job 打成 error（錯誤訊息還會誤導成 provider 失敗）。
2. ✅ 跨 lane 回報的正確通道：**寫檔（`memory/keepalive-*.md`、`MEMORY.md`）** 或 **`agent:<lane>:main` 的 main session**；要回 cron session 也要等該輪結束後再送。
3. ✅ 診斷順序：看到 cron receipt 紅單 → 先查 journal 的 `lane task error` / `lane wait exceeded` / `competing work` → 再看 `model-fetch` 狀態碼 → **最後**才懷疑供應商。
4. 📌 `Cannot delete session while competing work is in flight` 是 fleet 級常態雜訊（24h 至少 10 筆，橫跨 `02eb0989`／`ca222989`／`880b5c17`／`13ac4b5a`／`d7b0355b`／`e2b00e12`／`9d8b6001`）；**只有疊上 lane wait 超時才會致命**（11-22 16:07 同一支 gengar job 曾 `waitedMs=218581`）。
5. 🚫 **本輪刻意沒有再對 gengar lane 發更正訊息**（即使對方歸因有誤）：其 16:02 輪仍在 running，現在用 `sessions_send` 投遞正是我們剛診斷出會傷人的動作 → **規則自己先遵守**，更正內容改以檔案落盤（gengar 讀得到同一個 `memory/` 目錄）。

### 16) 本輪最終狀態（16:08 收案）
- 本 job `02eb0989` receipt：**ok / dur=300,250ms**（16:02:10 起）→ 雖然 16:07:10 被交付雜訊拖了 31.1s lane wait，**最終仍正常收尾**。
- `9d8b6001` Gengar KA 16:02 輪：截至 16:08 **仍在 running**（receipt 尚未落地）→ 下一輪（19:02）查它的結果。
- 活紅單維持 **3 支**（`9d8b6001` ce=1 待 16:02 自癒／`36b493db` ce=1 待 11-24 04:25／`c5352a84` ce=1 待 11-27）。

---

## 2026-11-23 19:02 — Picturecat Keep-Alive 第 7 輪（今日第 7 輪，觸發 19:02:10）

**結論：抓到 1 次被 `ce=0` 掩蓋的整輪死亡（heartbeat-mrmime 兩段死法）＋ 1 個新的系統性瓶頸（agent lane 序列化排隊）。紅單仍 2 支，Discord/gateway 全綠。**

### 1) 紅單掃描（`openclaw cron list --all --json`，53 支）
| job | enabled | ce | lastStatus | lastDur | lastRun | nextRun |
|---|---|---|---|---|---|---|
| `36b493db` Memory Dreaming Promotion | ✅ | 1 | error | 1,406,869ms | 11-23 04:25 | **11-24 04:25（決定性驗證輪）** |
| `c5352a84` skill-collection-review-roaringmoon | ✅ | 1 | error | 169,007ms | 11-20 | 11-27 |
| `a94330a9` tmp-openai-probe | ❌ | 2 | error | — | 11-19 | None（disabled 殘留，不算活紅單）|

活紅單 **2 支**（自 13:02 輪起持平）。`45ccf4e9 晨間情報` 連續第 4 輪自癒確認（11-23 08:00 ok / dur=1,081,044ms，next 11-24 08:00）。

### 2) ⭐⭐⭐ 新抓到：heartbeat-mrmime `bcf270b8` 在 16:01–16:15 **死了兩次**，但 `ce=0` 把它洗成全綠
`openclaw cron runs --id bcf270b8-…`（ce 掃描看不到的那一段）：

| runAt | status | dur | error |
|---|---|---|---|
| 11-23 16:01:07 | **error** | **600,004ms** | `cron: job execution timed out` |
| 11-23 16:11:38 | **error** | 249,653ms | `heartbeat failed: agent-runner-failure` |
| 11-23 16:31:04 → 19:01:05 | ok | 4.4–7.4s | —（6 連 ok → ce 歸 0）|

journal 因果鏈（16:15:46–16:15:48，**全部 `[diagnostic]` 級**）：
```
16:15:46.012 lane wait exceeded: lane=session:agent:rowlet:cron:9d8b6001…:run:fd8b5114 waitedMs=351961
16:15:47.517 lane task error: lane=cron-nested durationMs=4 error="prepared model runtime plugin generation was superseded for …/agents/mrmime/agent"
16:15:47.518 lane task error: lane=session:agent:mrmime:main:heartbeat durationMs=4 (同上)
16:15:47.999 / 16:15:48.365 / 16:15:48.365 （共 6 筆，3 對）
16:15:48.366 Embedded agent failed before reply: prepared model runtime plugin generation was superseded for …/agents/mrmime/agent
```
**合成因果**：① 16:01 heartbeat-mrmime 起跑 → agent:mrmime lane 被 `ca222989 OpenClaw 系統維護`（16:04:50 起 dur=111,919ms）與 `d7b0355b` 等同 agent 的 job 佔用 → **600s cron timeout**；② 16:11:38 retry 與 mrmime agent 的 plugin generation 撞車 → **superseded → lane 瞬間死（durationMs=3–4ms）** → receipt error。
→ **「superseded 是良性」要加條件**：落在 KA lane 時良性（本輪 9 筆只影響回覆落地），**落在 heartbeat lane 且有 retry 時會直接釀成紅單**（與 11-22 16:01 `bcf270b8` 紅單同型，該輪未查 receipts 所以沒被記錄）。
→ **「heartbeat 的 600s timeout ＝ Discord 斷線的下游症狀」這條不完整**：本輪 Discord 全綠，600s timeout 純粹由 **lane 排隊**造成。

### 3) ⭐⭐ 系統性瓶頸：agent lane 是單執行緒排隊佇列（24h 26 筆 `lane wait exceeded`）
| lane | 筆數 | 最大 waitedMs |
|---|---|---|
| `agent:roaringmoon` | 12 | **1,598,136ms（26.6 分）**（08:34:50 同時爆 9 筆） |
| `agent:rowlet` | 7 | **1,408,923ms（23.5 分）** |
| `agent:mrmime` | 4 | 401,138ms |
| `agent:gengar` | 3 | 220,495ms |

- **三支 KA 的 lane 歸屬（24h 實測）**：`9d8b6001` Gengar KA → **agent:rowlet**（101 筆）／`02eb0989` Picturecat KA → **agent:rowlet**（50 筆）／`880b5c17` Celesteela KA → **agent:celesteela**（8 筆）。
  → **Gengar KA 與 Picturecat KA 共用同一條 lane**，anchor 只差 8 秒 → 後者排隊數分鐘（16:15 gengar 等 351,961ms＝5.9 分；13:09 我等 141,010ms）。
  → **修正建議：anchor 錯峰門檻應由「≥3 分鐘」改為「≥15 分鐘」**（單輪實耗 2–14 分鐘：今日 picturecat 88s–1,238s、gengar 8.8s–822s），否則錯開了起跑點仍會排隊。Celesteela 走自己 lane，不受影響。
- **08:34:50 的 9 筆同時排隊**＝晨間情報 pipeline（`45ccf4e9` 08:00）開多個子工作共用 roaringmoon lane 造成，**與 provider 無關** → 「併發槽」模型要補一維：**同 agent lane 的工作數**。

### 4) provider 層（3h 窗 16:02→19:02，全用 canonical 口徑：`grep -a` + 排除 `[agent:nested]` + `model-fetch.*status=429`）
- canonical 429 = **1 筆**（18:02:49.079，elapsedMs=**130,017**）→ 18:02:49.204 `rate-limit same-model retry 1/3 delayMs=10000` 救回，**無紅單**。
- 429 回應延遲仍卡在 100–130 秒（11-23 逐輪：117/161/105/101/117/130 秒）→ 「跌破 2 分鐘」確定是單點、不是趨勢。
- 24h：canonical 429 = **39**、真實配額 `Token Plan usage limit reached: Upgra` = **58（全部落 07h，07:29–07:59）**、`status=529` = **0**、真實 DNS（EAI_AGAIN/getaddrinfo）= **0**。
- `model-fallback/decision` 本窗無跨廠成功（同廠 `minimax-portal/MiniMax-M2.7` 仍是唯一可用救回路徑）。

### 5) Discord / gateway（✅ 全綠）
- gateway：MainPID **4137629**、ActiveEnterTimestamp **2026-11-23 04:48:17**、`NRestarts=0`、node **v24.22.3**、`/health` **200 in 1.3ms** → **04:48 事故後連續 14h14m 未重啟**。
- Discord：8 個帳號全 `connected`（greninja disabled）；3h 窗 READY-fail **0**、channel exited **0**、client initialized **0**、host timing gap **0**；reconnect 11 / websocket closed 11 ≈ **3.7/h**（基線 2.6–3/h，心跳式 resume=true 屬健康）。
- **乾淨段 ≈14h28m**：24h 最後一筆 READY-fail + channel exited = **11-23 04:33:56**（roaringmoon）；最後 `client initialized` = 04:49:37。
- dreaming 風暴基準（24h）：`host timing gap detect` **4 筆**（04:27:56／04:33:56／04:40:04／04:46:16，全在 dreaming 04:25 窗）、READY-fail 12、channel exited 6 → 今日症狀量級比 11-21（39/6）與 11-22（27/6）輕。
- selfheal `d4cd45bc` 守門：16:13／16:43／17:13／17:43／18:13／18:43 **6 槽全 ok**（dur 740–776ms）→ **07:02 輪修的 fail-closed 守門 + 04:15–05:10 時鐘窗持續有效、零誤開火**。
- `13ac4b5a 健康回報` 17:05:22 ok / dur=44,959ms；`09c7940b PTCGP Meta Analysis` 今日 20:05 槽（尚未跑）。

### 6) KA anchor 疊窗 第 17 次
`gengar 19:02:02` → `picturecat 19:02:10` → `celesteela 19:02:12`（間距 **8s / 2s**，非 5ms 級）。superseded 競態噪音 3h **9 筆**（良性，回覆照常落地）。**修法建議由「≥3 分鐘」升級為「≥15 分鐘」＋ 讓 Gengar/Picturecat 兩支脫離同一 lane**（見 §3）。

### 7) 17 支 skill 缺 description 第 14 輪仍未修
3h 窗 **238 行 / 唯一 17 檔 / 每檔每 3h 各 14 次（≈196 次/日/檔）**；24h **3,332 行 / 17 檔 / 每檔 196 次**。清單與前輪完全相同（13 支 `description is required` ＋ 4 支 `BAD_INDENT`）→ **仍未授權，不動**。

### 8) 巡檢覆蓋率查漏（receipt dur ↔ 檔案 `^## ` 段落數）
- **Picturecat 本 job 今日 6 輪全有紀錄**（dur 88.2s／159.5s／1,238.3s／228.5s／419.0s／300.3s，**無 <30s 降級輪**）→ 7/7 覆蓋（含本輪）。
- **Gengar 今日 6 輪全覆蓋**：01:02(277s)／04:02(205s)／07:02(error 1,624s)／10:02(**12.8s 降級輪** → 已由 lane 自報回填)／13:02(error 158.6s)／16:02(ok 822.1s)。
- ⚠️ **兩處 receipt error 有替代紀錄**（`07:02` 配額牆、`13:02` transcript-ownership）→ 「receipt=error」與「無紀錄」互為鏡像，三口徑（降級輪／硬失敗輪／真漏做）仍需分開。

### 9) 本輪待 Linder 點頭的決定（不自行變更）
1. **KA anchor 拉開 ≥15 分鐘**（原建議 ≥3 分鐘不足）＋ 讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane。
2. heartbeat 類 job 的 600s timeout 與 `target:"none"` / `sessionTarget=isolated`（現況 600s timeout 會讓 mrmime heartbeat 死一次再 retry 又死）。
3. 同一 agent dir 的多支 job 併發 → plugin generation superseded 會打死 lane；修法待定（在共同入口做序列化，或讓 heartbeat 降級失敗為 warning）。
4. 17 支 skill 缺 description（第 14 輪）。
5. dreaming `36b493db` ce=1 → 明日 04:25 槽是決定性驗證輪。

### 10) 規則遵守
本輪**未**對任何 lane 發 `sessions_send`（16:07 教訓：不要把訊息交付進正在跑的 cron run session；更正一律以檔案落盤）。
