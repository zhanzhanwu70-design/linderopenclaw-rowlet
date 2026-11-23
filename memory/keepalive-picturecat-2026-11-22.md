# Keep-Alive 巡檢紀錄 — 2026-11-22 (Asia/Taipei)

三支 KA job（皆 `every 3h`、isolated、delivery not requested）：
`9d8b6001` Gengar KA（rowlet 執行）/ `02eb0989` Picturecat KA / `880b5c17` Celesteela KA。
本檔由 rowlet 每輪 KA 追加。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-22 04:02 — Gengar Keep-Alive 第 1 輪（今日 2 輪，runId `84f09e1b`）

**總結：🟢 全綠，唯一殘留是 11-20 DNS 風暴留下的舊 error（ce=1，已排定 11-27 自癒重試）。**

### 1) gengar lane 自報（`sessions_send` → `agent:gengar:main`，status=ok）
- 6 支 cron 全 enabled、全 `ok`、全 **ce=0**：
  - `29c2d630` Gengar Cron Health Watchdog — last 11-22 02:04 / next 04:04
  - `c29eca0f` heartbeat-gengar — last 11-22 03:59 / next 04:29
  - `ac9e7ada` You are an English coach — last 11-21 05:05 / next 11-22 05:00
  - `88810bfe` BBC News Morning Discussion — last 11-21 07:00 / next 11-22 07:00
  - `7767e03b` skill-collection-review-gengar — last 11-21 07:32 / next 11-28 07:32
  - `f5148ff0` OpenClaw 版本檢查 — last 11-22 00:00 / next 11-29 00:00
- 近 60 分鐘 provider 429/overloaded = **0**（量測窗 03:02:34 → 04:02:34）
- EAI_AGAIN/getaddrinfo = **0**；clock-change flush = 0；timeout = 0 → **11-20 DNS 風暴未復發**
- Discord **8 connected / 8 enabled**（greninja 停用不計），0 startup-not-ready

### 2) 本機（rowlet 側 shell 量測，04:03:24）
- load `0.46 / 0.54 / 0.50`；RAM 21,184 MB avail；disk 179G free（60% used）
- gateway pid 2808154 / 2808161 / 3225706 存活；workspace-rowlet 70 檔案可讀
- journalctl 自查 429/EAI_AGAIN 命中數 = 1/1，但 grep 命中的是**本輪 gengar 回覆文字本身**（關鍵字出現在它回報「= 0」的句子里），實際 provider 429 = 0、DNS = 0

### 3) 三支 KA job 本輪皆準時觸發
| job | 01:02 輪 | 本輪 (04:02) |
|---|---|---|
| `9d8b6001` Gengar KA | ok / ce=0 / dur=300,654ms | running（本輪） |
| `02eb0989` Picturecat KA | ok / ce=0 / dur=16,495ms | running（本輪） |
| `880b5c17` Celesteela KA | ok / ce=0 / dur=30,793ms | ok / dur=30,793ms |

### 4) rowlet lane 自有 cron（全 ok）
`537bd0dd` Rowlet 轉錄監控（每 5 分, ok suppressed）、`d82f78e3` heartbeat:rowlet（skipped）、`ae91b967` 每日 LLM Wiki 巡讀與擴寫、`a72cb46b` 每日 Agent × 軟體開發、`08b7c00b` ut-veteran-cpc、`58fe15dc` 每日論文討論、`a661258a` skill-collection-review-rowlet。

### 5) ⚠️ 唯一殘留 watch item
- `c5352a84` **skill-collection-review-roaringmoon**：`last=error`、**ce=1**、last run **11-20 03:56**、dur=169,007ms、
  error = `Skill collection review failed for /home/amr/.openclaw/workspace-roaringmoon: FailoverError: LLM request failed: DNS lo…`
  → 根因是 **11-20 DNS 風暴**，不是程式壞；job 仍 enabled，**next run 11-27 03:56** 會自癒重試。
  本輪未手動觸發（屬 roaringmoon lane，且非本 job 職責）；若 11-27 仍 error 再升級處理。

### 6) gengar 提示的排程鄰接風險
`36b493db` Memory Dreaming Promotion（cron `25 4 * * *`）**04:25 觸發**，而 gengar 的 `ac9e7ada` English reminder 在 **05:00**，
落在 dreaming 的硬結束 05:05 區間內 → 若 dreaming 今晚超時，05:00 的提醒會排在後面。屬可觀察項，不需動作。

### 4:03 收訖確認（inter-session 回送）
gengar 的自報以 inter-session 訊息形式再回送一次（內容與上表一致，runId `84f09e1b`），明言「Nothing needed from you」。
第 1 輪至此閉環：無需任何動作。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-22 04:02 — Picturecat Keep-Alive 第 1 輪（今日第 1 輪，runId `24136309`）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

**總結：🟢 lane 存活、無硬失敗。唯一值得記錄的是「深夜窗 429」的新觀察（原清單①的缺口本輪補上）。**

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，status=ok）
- runId `24136309-a14a-4d04-b8e5-45388df2a409`、delivery announce pending、回覆：
  「pong — 1) lane 存活 2) 近 3 小時無錯誤／429 3) 無進行中任務 4) Discord inbound 正常。」
- 佐證 lane 是活的而非只是被喚醒：`agent:picturecat:main` 於 **03:03:54** 自己也回過 `pong 🐱`（runId `ef7b0030`，status=done）→ 03:04 與 04:03 兩個時點都有回應。
- 本 job `02eb0989`：schedule `every 3h`、enabled=true、上輪（11-22 01:02）**ok / ce=0 / dur=16,495ms**；本輪準時 04:02 觸發。

### 2) 本機量測（rowlet 側 shell，04:03）
- uptime **41d09:50**；load `0.61 / 0.59 / 0.52`；disk `/` 60%（266G/468G，剩 179G）；RAM 8G/31G used、**avail 20G** → 全正常
- gateway：`MainPID 3573532`、`NRestarts=0`、`ActiveEnterTimestamp 2026-11-21 02:11:49 CST` → **今日未重開**（與 11-20 DNS 風暴當時的重開不同）
- cron fleet **53 支**；`enabled && consecutiveErrors>0` 只剩 **`c5352a84` skill-collection-review-roaringmoon（ce=1，11-20 03:56，next 11-27 03:56 自癒）** → 紅單仍為單一，未新增
- `d4cd45bc` discord-selfheal-after-dreaming（每 :13/:43）本輪 **ok / dur=734ms**；`13ac4b5a` 健康回報 02:05 ok；`40e09cd1` 全 agent 健康 03:00 ok（dur=299,318ms）；`911eee45` 每日資安建議仍在 21:00 原槽（dur=337,860ms，ok，**未挪點**）

### 3) 深夜窗（2026-11-21 22:00 → 11-22 04:02）429 觀察 — 補上上輪清單①的缺口<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **真實 provider 429 = 3 次，全部在 same-model retry 1/3 就恢復，硬失敗 0 次**：
  - 00:02:23 run `48a2a073`（gengar OpenClaw 版本檢查）
  - 00:02:54 run `e58c348f`（mrmime Codex A2A heartbeat 00:00 槽）
  - 03:01:52 run `8481e06c`（mrmime all-agent health 03:00 槽）
- **DNS（EAI_AGAIN/getaddrinfo）真實失敗 = 0**：grep 命中的 4 筆全是 nested 回覆文字裡的關鍵字（同 gengar 那輪的誤判陷阱，兩輪各自踩到同一個坑）
- 深夜窗 22:00–04:02 沒有任何「整點尖峰全滅」型潰散 → 與 11-20 的 755 筆/小時風暴不同型態

### 4) Discord 連線量測（6h / 24h）
- gateway reconnect：`6h 31 次`、`24h 156 次`（≈6.5 次/小時，約每 9 分鐘一次）→ 與 11-17 那天「3h 4,992 次」的高壓症狀不是同一量級，屬**慢性低頻**、非本日新增
- READY/identified 類 handshake 24h 內 211 行 → 連線在斷續重建、不是全瞎
- `d4cd45bc` selfheal 每 :13/:43 全 ok；picturecat 自報 Discord inbound 正常；近 12h journal 無 inbound 訊息（該頻道本就閒置，非故障）

### 5) 量測備忘（本輪新增／沿用）
- 受限 automation session 內 `automations list` 回 0 筆、`automations get/runs` 對本 job 回 "not found" → **別用 automations 工具查自身 job**；改用 `openclaw cron list --all --json` ＋ python 摘要（欄位用 `state.lastRunAtMs` / `lastRunStatus` / `consecutiveErrors` / `lastDurationMs`）
- **禁用 `automations runs`**：會回 50 筆完整 summary（約 64KB），本輪刻意迴避，維持 token 紀律
- `journalctl --user -u openclaw-gateway.service --since "…"` 的 429/DNS grep 會**命中 agent 回覆的內文**（含「429=0」「EAI_AGAIN」等字樣）→ 計數前先濾掉 `[agent:nested]` / `flow=` 行，並改用「rate-limit same-model retry」這類明確事件字串

### 6) 下一輪（07:02）請確認
① 04:00–07:00 是否再出現 same-model retry 429（本輪 3 次全在 00:02 與 03:01，皆非整點尖峰密集段）；② `c5352a84` 是否仍是唯一紅單（11-27 自癒前）；③ Discord reconnect 次數是否維持 ~6.5/h（若暴增到 11-17 量級要升級回報）；④ `911eee45` 是否仍 21:00 原槽未挪點；⑤ picturecat lane 是否持續有自發回覆（不只被 KA 喚醒才有回應）。

---

## 2026-11-22 07:02 — Picturecat Keep-Alive 第 2 輪（今日第 2 輪，runId `559a4d12`）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

**總結：🟢 lane 存活、無硬失敗、無手動動作。本輪釐清一個結構性根因：04:25 dreaming 槽的 admission suspend 會撞死 Discord 30s READY 握手 → 每天固定 ~23 分鐘的 8 帳號重連風暴（非 DNS、非主機 freeze）。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，status=ok）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- runId `559a4d12-bcc2-4c78-ac0f-a4d410496642`、delivery announce pending、回覆：「pong — 1) lane alive/idle 2) no errors or provider 429s in last 3h 3) no in-flight tasks 4) Discord inbound normal.」
- 本 job `02eb0989`：enabled、`every 3h`、上輪（04:02）**ok / ce=0 / dur=156,612ms**；本輪 07:02 準時觸發（runningAt=07:02）。
- 姊妹 job：`9d8b6001 Gengar KA`（上輪 ok/ce=0/dur=102,737ms）、`880b5c17 Celesteela KA`（上輪 ok/ce=0/dur=30,793ms）——三支同時在 07:02 進 running。

### 2) 本機量測（rowlet 側 shell，07:02）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- uptime **41d12:49**；load `0.40 / 0.38 / 0.45`；RAM 31,797MB 總 / 9,279MB used / **avail 20,966MB**；disk `/` 60%（266G/468G，剩 179G）→ 全正常
- gateway：MainPID **3573532**、NRestarts=**0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST**（連續第 2 天未重開）、`/health` **HTTP 200 in 1.6ms**

### 3) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 39 / skipped 5 / error 1 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **紅單仍只有一支**：`c5352a84 skill-collection-review-roaringmoon` ce=1、last=11-20 03:56、dur=169,007ms、**next 11-27 03:56 自癒** → 連續第 2 輪維持單一紅單，未新增。
- skipped 5 支全是 heartbeat（no-route 長態、良性）：`46242a4c` celesteela cs=40、`6525d155` picturecat cs=6、`3acd15c2` roaringmoon cs=6、`7d633ff4` greninja cs=5、`d82f78e3` rowlet cs=2。
- 今日最長：dreaming `36b493db` 1,852,428ms（30.9 分，ok）、`ae91b967` LLM Wiki 792,986ms、`a72cb46b` 792→772,096ms、`40e09cd1` all-agent health 299,318ms、`f5148ff0` 版本檢查 258,726ms。

### 4) Provider 429 / DNS（04:02→07:02 窗）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **真實 same-model retry = 5 次**（05h 4 次、06h 1 次），**硬失敗 0**（全部 ≤2/3 恢復、無 3/3）：
  - `056e797c` 05:01:36 retry 1/3 → 05:04:36 retry 2/3
  - `13a807bc` 05:31:04 retry 1/3 → 05:32:36 retry 2/3
  - `2206dfad` 06:02:23 retry 1/3
  - `9f81da0a`（僅 embedded run end isError=true，無 retry 記錄）
- **真實 DNS（EAI_AGAIN/getaddrinfo）失敗 = 0**：grep 命中 2 筆全是 agent 回覆內文的關鍵字（gengar 04:03 自報、rowlet 04:04 自報）——老陷阱第 3 次出現，已能用「先看原始行」分辨。
- 無 Token Plan 配額窗。

### 5) 🔍 本輪最大發現：dreaming admission suspend 撞死 Discord 30s READY 握手（每日結構性重現）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **先排除三個錯誤假設**：不是 DNS（真實失敗 0）、不是主機 freeze（無 systemd suspend/resume）、不是 laptop 睡眠（無 PM: suspend 記錄）。
- **真因**：OpenClaw 自己的 `[admission] closed: suspend phase`（dreaming 期間的 admission 暫停）→ watchdog 記成 `host timing gap detected: process was frozen ~131–280s`。
  - 6 次 timing gap：04:27:55(158s) / 04:34:11(280s) / 04:39:58(207s) / 04:45:59(265s) / 04:49:48(131s) / 04:53:57(150s)
  - 連帶效應：suspend 期間 Discord 握手超時 → `gateway opened but did not reach READY within 30000ms` → `channel exited` **14 筆** → auto-restart 1/10 → OpenClaw 主動 `delaying provider startup 10–70s` 避開 Discord startup rate limit（**21 筆**，04:34–04:57）→ **04:57 全數恢復**
  - **重現性**：近 7 天每天固定 6 次（11-15:7／11-16:6／11-17:6／11-18:6／11-19:6／11-20:2／11-21:6／11-22:6），全部落在 dreaming 04:25 槽 → **結構性、每日重現，非本輪偶發**。
- dreaming 本身最終仍成功：04:55:52 `dreaming promotion complete (workspaces=9, candidates=21, applied=1, failed=0)`，dur 1,852,428ms < timeoutSeconds 2400；期間有 `cleanup scrub failed for light phase: Cannot delete session while com[plete]` 與 light/rem 相 `detached dreaming narrative degraded`（degraded 但未失敗）。
- 附帶：`stuck session` `9379f82f`(agent:rowlet:cr…) 04:28:29 / 04:34:54 → 04:40:29 `stuck session recovery outcome: status=released action=release_lane` → 已自解。

### 6) Discord 現況：8/8 connected，checkpoint ③ 通過<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, running, connected**（greninja disabled=預期）。
- inbound 雙向有實流：rowlet **40m**、mrmime **57m**、gengar 2h、celesteela 2h、roaringmoon 8h；charizard 22h（該頻道本來就閒置）、picturecat/flaaffy 近期無 inbound 但 transport=just now。
- **reconnect 速率**：04h=76（dreaming 風暴集中在 04:34–04:57）、05h=2、06h=4 → **安靜時段 ≈3/h，低於上輪 6.5/h 基線**；暴增只在 dreaming 窗。checkpoint ③ ✅（不需升級回報）。

### 7) 上輪清單逐項核對<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| # | 項目 | 結果 |
|---|---|---|
| ① | 04:00–07:00 是否再出現 same-model retry 429 | ✅ 出現 5 次（05h 4／06h 1），全在 ≤2/3 恢復，硬失敗 0 |
| ② | `c5352a84` 是否仍唯一紅單 | ✅ 仍唯一（ce=1，11-27 03:56 自癒） |
| ③ | Discord reconnect 是否維持 ~6.5/h | ✅ 安靜時段 ≈3/h；暴增僅限 dreaming 窗 |
| ④ | `911eee45` 是否仍 21:00 原槽未挪點 | ✅ last 11-21 21:00 ok（dur=337,860ms）、next 11-22 21:00 |
| ⑤ | picturecat lane 是否持續自發回覆 | ⚠️ **沒有**：04:02–07:02 僅 2 筆 picturecat:main（04:03 上輪 KA、07:02 本輪 KA），上次自發回覆是 11-22 03:03:54 → lane 活著但近 4h 無自發活動 |

### 8) 本輪動作：無（觀測為主）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron、未重啟 gateway、未觸發 self-heal（Discord 已自癒、紅單會自癒，無「條件已滿足卻沒動作」的情境）。
- 唯一待 Linder 決策的升級建議（**不在 unattended 輪次自行變更**）：二選一 ——
  (a) 把 Discord READY 握手上限拉高到 > dreaming suspend 長度（≥300s），讓 suspend 期間的握手有容忍度；
  (b) 讓 dreaming 的 admission suspend 期間保留 Discord 連線（不中斷既有連線的 READY deadline）。

### 9) 量測備忘（本輪新增／沿用）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **受限 automation session 內 `automations get/list` 對自身 job 仍回 "not found"**（本輪 07:02 的呼叫本身還在 journal 留下一筆 `cron.get ... cron job not found: 02eb0989...`，會污染 07h 的 grep 桶）→ **別用 automations 工具查自身 job**，用 `openclaw cron list --all --json` + python 摘要。
- **禁用 `automations runs`**（會回 50 筆完整 summary）。
- `host timing gap detected` **不等於**主機 freeze：先看有沒有 `[admission] closed: suspend phase` 同時出現——有的話是 gateway 自己的 admission 暫停，不是 OS 層 suspend。
- 判讀「Discord 帳號重連」時用 `delaying provider startup`（OpenClaw 為避開 Discord startup rate limit 而錯開啟動）當指標，比直接數 reconnect 更有意義。

### 10) 下一輪（10:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① dreaming 是否仍在 04:25 槽（若有被挪動，§5 的每日風暴應同步消失，可反證因果）；② same-model retry 是否再增（若 07:00–10:00 又是 5+ 次，需升級為 provider 容量問題而非雜訊）；③ `c5352a84` 是否仍唯一紅單（11-27 自癒前）；④ Discord 安靜時段 reconnect 是否仍 ≤6/h；⑤ picturecat lane 是否恢復自發回覆（若 04:00 以後仍只有 KA 觸發，可視為該 lane 空轉）。

---

## 2026-11-22 10:02 — Picturecat Keep-Alive 第 3 輪（今日第 3 輪，runId `64dc5962`）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

**總結：🟡 lane 存活、Discord 健康、429 未升級；但**新增一支紅單** `45ccf4e9 晨間情報 pipeline`（08:00 槽 provider 回 HTTP 500 HTML 錯誤頁），且**第 2 輪的每日 dreaming 重連風暴今日原樣重現**（同型同量）。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `64dc5962-4768-4c1a-965f-bc1580ce82af`、status=ok、回覆：「pong — 1) lane 存活且空閒 2) 近 3 小時無錯誤或 provider 429 3) 無進行中任務 4) Discord inbound 正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job `02eb0989`：上輪（07:02）**ok / ce=0 / dur=101,763ms**；本輪 10:02 準時觸發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` 上輪 ok/ce=0/dur=83,925ms；`9d8b6001 Gengar KA` 上輪 10:02 ok/ce=0/dur=7,760ms → **三支 KA 全綠、ce=0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 本機量測（rowlet 側 shell，10:02）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- uptime **41d15:49**；load `0.53 / 0.45 / 0.40`；RAM 31,797MB 總 / 9,327MB used / **avail 20,941MB**；disk `/` 60%（266G/468G，剩 179G）→ 全正常。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：MainPID **3573532**、NRestarts=**0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST** → **連續第 3 天未重開**；`/health`（port 18789）**HTTP 200 in 1.5ms**；bridge 4188→401、14177→200（兩個 HTTP 服務都在聽）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 35 / skipped 8 / error 2 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **🔴 新增紅單 `45ccf4e9 晨間情報 pipeline (Roaringmoon)`**：last **11-22 08:00**、dur=**937,285ms**（15.6 分）、ce=1、next **11-23 08:00**（每日 → 會自癒重試）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 錯誤全文：`The provider returned an HTML error page instead of an API response. This usually means a CDN or gateway (e.g. Cloudflare) blocked the request.` + diag `HTTP 500: <HTML>...Internal Server Error - Read...`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - journal 簽章：08:15:37 `[model-fetch] response provider=minimax-portal status=500 elapsedMs=4114 contentType=text/html` → **provider 端點回 HTML 錯誤頁（provider/edge 層），非本機網路、非 429、非 DNS、非 timeout**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **同時刻關聯**：`b37129c0 群體智能架構研究`（同 `0 8 * * *`、staggerMs=900000＝15 分）恰在 **08:15 啟動**，與 provider 500 同一秒 → 與既往「429 尖峰跟著整點槽走」同一型態（併發壓力撞 provider edge）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 該 job 近 3 次：11-20 error(timeout / network connection error) → 11-21 **ok**(dur=261,186ms) → 11-22 error(**provider 500 HTML**) → **同一槽、不同根因、連續兩天不穩**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `c5352a84 skill-collection-review-roaringmoon` ce=1、11-20 03:56（DNS 舊因）、**next 11-27 03:56 自癒** → 維持不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skipped 8 支全是 heartbeat（no-route 長態、良性）。綠燈重點：`d4cd45bc` selfheal 09:43 ok（dur=754ms）、`36b493db` dreaming ok（dur=1,852,428ms）、`13ac4b5a` 健康回報 08:05 ok、`58fe15dc` 論文 ok（07:03）、`88810bfe` BBC ok（07:00）、`b37129c0` ok（08:09）、`89e2cfe7` clean-code ok（09:00）、`29c2d630` gengar watchdog ok（08:04）、`ca222989` 系統維護 ok（09:04）、`537bd0dd` 轉錄監控 ok（10:00）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Provider 429 / DNS（07:02→10:02 窗，journal 1,477 行）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **正向對照**：model-fetch 行 738 → status 分布 **200×363 / 429×5 / 500×1**；**same-model retry 4 次**：07:03:01 (1/3)、08:01:03 (1/3)、09:01:42 (1/3)、09:04:26 (2/3) → **硬失敗 0、全部 ≤2/3 恢復**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429 逐時：07h×2、08h×1、09h×2（≈1.7/h，**低於上輪 5 次**）→ checkpoint ② ✅ 不升級為 provider 容量問題。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Token Plan usage limit reached` = **0**（連續第 5 輪零配額窗）。**真實 DNS 失敗（getaddrinfo/EAI_AGAIN）= 0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ✅ checkpoint ①：dreaming 04:25 槽的每日風暴**原樣重現**（反證因果成立）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db` dreaming 排程**仍在 `25 4 * * *`**（last 11-22 04:25、dur=1,852,428ms、ok）→ 未被挪動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:20–05:10 視窗（1,220 行）簽章：**host timing gap 6、admission suspend 46、did-not-reach-READY 28、channel exited 14、delaying provider startup 21、channels resolved 15** → **與 11-21 完全同型同量**（上輪：6 / 28 / 14 / 21）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 第 2 輪 §5 的結論（dreaming admission suspend → Discord 30s READY 握手超時 → 8 帳號約 23 分鐘重連風暴）**今日再次完整重現＝結構性、每日固定，非偶發**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Discord 現況：8/8 connected（checkpoint ④ ✅）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled=預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實收發：celesteela in:5m、charizard in/out:55m、mrmime in/out:57m、gengar in/out:3h、roaringmoon in:2h、rowlet in/out:3h；picturecat／flaaffy 無近期 inbound 但 transport=1m/just now。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **reconnect 速率**：07:02–10:02 共 **9 次 ≈ 3/h**（07h×3、08h×4、09h×2）→ 與上輪「安靜時段 ≈3/h」一致 ✅；同期 did-not-reach-READY 0、channel exited 0 → **08:00 槽的 provider 500 沒有牽動 Discord**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 第 2 輪 §10 五項交辦逐項核對<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| # | 項目 | 結果 |
|---|---|---|
| ① | dreaming 是否仍在 04:25 槽 | ✅ 仍在；**今日同型風暴重現**（6 timing gap / 28 READY fail / 14 channel exited / 21 delaying startup）→ 因果結論成立 |
| ② | same-model retry 是否再增 | ✅ 4 次（上輪 5 次），硬失敗 0、Token Plan 0 → 未升級 |
| ③ | `c5352a84` 是否仍唯一紅單 | ⚠️ **否**——新增 `45ccf4e9`（08:00 槽 provider 500 HTML，next 11-23 08:00 自癒） |
| ④ | reconnect 是否 ≤6/h | ✅ 3/h，且 0 次 READY 失敗 |
| ⑤ | picturecat lane 是否恢復自發回覆 | ⚠️ **仍無**：04:00 後 `agent:picturecat:main` 僅 3 個時點（04:03 / 07:02 / 10:02，**全是 KA 觸發**）→ lane 活著但自發活動為零（該 channel 本身閒置，非故障）|

### 8) 本輪動作：無（觀測為主）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal（Discord 健康）、未動 `scripts/discord-selfheal.sh` 守門、未碰憑證、未改 DNS/網路。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **未手動重跑 `45ccf4e9`**：屬 roaringmoon lane 的 job，且 next=11-23 08:00 每日自動重試（與 11-22 第 1 輪對 `c5352a84` 的處置一致：不越界代跑別人 lane）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user`、`systemctl --user show`、`curl /health`、bridge probe。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（第 3 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新・中】`45ccf4e9 晨間情報 pipeline` 08:00 槽連續兩天不穩**（11-20 timeout、11-22 provider 500 HTML），且與 `b37129c0 群體智能架構研究`（同 `0 8 * * *`、stagger 15 分）**同一秒撞 provider edge**。建議錯開：`45ccf4e9` → **08:45**、`b37129c0` → **09:15**（它今天 08:09 成功、dur 491,901ms，移到 09:15 仍在 timeout 內）。**改的是別人 lane 的排程，未經你點頭我不動。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【中】dreaming 04:25 風暴（延續上輪）**：今日已二次驗證結構性重現，二選一 —— (a) 把 Discord READY 握手上限拉高到 ≥300s；(b) dreaming admission suspend 期間保留既有連線的 READY deadline。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】跨廠 fallback 仍是 0**：`openai/*` 全 Auth=no → provider edge 出狀況時只能靠同模型重試（本輪 45ccf4e9 正是死在沒有 fallback 的時刻）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【低】picturecat lane 自發活動為零**（近 6h 只有 KA 觸發）：屬 channel 本身閒置，非故障；若希望它主動巡檢需另排 watchdog（不建議加在 3h KA 之外）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 量測備忘（本輪新增／修正）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **shell 引號陷阱（本輪踩到）**：把 `journalctl --since "2026-11-22 07:02:00"` 寫進 shell 變數 `J="journalctl ... --since '2026-11-22 07:02:00' ..."` 再展開時，**引號不會保留** → `--since 2026-11-22 07:02:00` 被拆成兩個參數 → journalctl 報 `Failed to parse timestamp` → **所有 grep 靜默回傳 0，會被誤讀成「零事件」**。正解＝先落地成檔（`journalctl ... > /tmp/ka.log`）再對檔案 grep。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **必須做正向對照**：任何「grep 計數＝0」的結論都要先用已知會命中的字串（如 `model-fetch`）確認視窗真的有資料（上限 1,477 行、738 次 model-fetch），否則「0」可能只是撈不到資料。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- provider 錯誤的新分類：**HTML 錯誤頁（status=500 + contentType=text/html）** 是**第三種** provider 故障型態（既非 429 配額、也非 429 busy、也不同於 DNS/timeout）→ 判讀時要單獨看 `contentType`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw cron runs` 的 `ts` 為**結束時間**：本輪 `45ccf4e9` ts=1795306537300 → 2026-11-22 08:15:37（dur 937,285ms → 起跑 08:00:00，與 cron 槽吻合）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 下一輪（13:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① `45ccf4e9` 是否已因為 daily 排程在 11-23 08:00 自癒（本輪無法驗證，只能下輪看 ce 是否歸 0）；② 10:00–13:00 是否出現新的 429 尖峰（這輪 4 次全在 07/08/09 整點後 1–4 分鐘）；③ Discord 安靜時段 reconnect 是否仍 ≤6/h；④ dreaming 風暴是否有別的解法被套用（(a)/(b)）；⑤ 三支 KA 的 anchor 是否仍同時起跑（`openclaw cron list` 的 `state.nextRunAtMs` 才是權威）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-22 16:02 — Picturecat Keep-Alive 第 5 輪（今日第 5 輪 picturecat KA 觸發；**13:02 為第 4 輪，但其紀錄遺失**——見 §5），runId `195b9f56`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

**總結：🟢 lane 存活、Discord 穩定、**13:00–16:02 出現今日最乾淨的 provider 窗（141 次呼叫零錯誤）**；但本輪最大發現是「**13:02 那一輪是降級巡檢，而且把結論寫錯了**」→ 這比 provider 抖動更值得處理。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，status=ok）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- runId `195b9f56-1bb6-43b2-8135-e6f1f401bbc2`，回覆：「pong — 1) lane alive/responsive 2) no errors or provider 429 in the last ~3h 3) no in-flight or pending tasks 4) Discord inbound/outbound normal, just quiet 5) nothing needing attention from rowlet.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **本輪是 13:02 之後第一次 ping 這條 lane**（13:02 那輪根本沒 ping，見 §5）；`agent:picturecat:main` updatedAt 16:02:38。
- ⚠️ `sessions_list` 顯示 `agent:picturecat:main` **status="failed" 是假訊號**：每次 KA ping 後都會跟兩行 `lane task error: lane=nested/session:agent:picturecat:main durationMs=4~6 error="prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/picturecat/agent"` → 良性 race，回覆本身成功（journal 16:02:23 有 `run=195b9f56 ... pong`）。**不要把它當故障。** ★ 但它其實是**三支 KA anchor 競態的指紋**（MEMORY.md「三支 Keep-Alive 的 anchor 錯峰要自己驗」條目）：本輪實測 picturecat 13:02:05.**360** vs gengar 13:02:05.**365** → 只差 **5ms**，picturecat 的 plugin generation 就是被這個重疊窗 supersede 掉的。**這條診斷訊息不是雜訊，是 anchor 競態的感測器。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 本機量測（rowlet 側 shell，16:02）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- uptime **41d21:49**；load `0.85 / 0.58 / 0.48`；RAM 31,797MB 總 / 9,204MB used / **avail 21,006MB**；swap 0/2047；disk `/` 60%（266G/468G，剩 179G）→ 全正常。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：MainPID **3573532**、NRestarts=**0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST** → **連續 1d13h50m 未重開**；`/health`（18789）**HTTP 200 in 1.65ms**；4188 → 401（要認證，正常）、**14177`/health` → 200**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 44 / skipped 5 / error 3 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **活紅單只有兩支**（皆會自癒，與上輪同）：`45ccf4e9` ce=1、last 11-22 08:00、dur 937,285ms、**next 11-23 08:00**（每日）；`c5352a84` ce=1、last 11-20 03:56、**next 11-27 03:56**（11-20 DNS 舊因）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 第三支 error `a94330a9 tmp-openai-probe`（ce=2、last 11-19、**next=None、enabled=false**）→ **停用殘留物，不是活紅單**；它讓 error 計數看起來是 3。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skipped 5 支全是 heartbeat（no-route 長態、良性）：celesteela / picturecat / roaringmoon / greninja / rowlet。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 三支 KA：`02eb0989` picturecat / `9d8b6001` gengar / `880b5c17` celesteela 全 **enabled、everyMs=10800000（3h）**、上輪 13:02 全 **ok / ce=0**（dur 22,038 / 15,227 / 48,704ms）、本輪 16:02 準時觸發；anchor 偏移 0 / 39 / 72ms → **三支仍幾乎同時起跑**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal-after-dreaming`：`13,43 * * * *`（每 30 分）→ 連續回「discord healthy (no startup-not-ready) - no action」。**它是事後健康檢查，不是緩解手段** → 擋不住 dreaming 窗的重連風暴（見 §6）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Provider 429 / DNS（10:02→16:02 窗，journal 2,134 行，正向對照 model-fetch 400 行）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- response 分布：**200 × 199、429 × 1**（無 5xx、無 HTML 錯誤頁）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯一一次 429：**12:03:23**（elapsed 164,892ms、contentType=application/json）→ 同 runId `5bb3df15` `embedded run agent end isError=true error=⚠️ API rate limit reached` → **same-model retry 1/3**（12:03:23.894，delayMs=10000）→ **12:03:35 回 status=200（1,874ms）** → **硬失敗 0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🔹 **13:00→16:02 子窗：141 次 model-fetch response，status=200 全部，零錯誤** → **今日最乾淨的 3 小時窗**（對照：第 2 輪 5 次、第 3 輪 4 次 retry）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **真實 DNS（EAI_AGAIN/getaddrinfo）= 0**；`Token Plan usage limit` = **0**（連續第 6 輪零配額窗）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ★ 本輪最大發現：13:02 那一輪是「降級巡檢」，而且把結論寫錯了<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **事實 1（紀錄遺失）**：13:02 那一輪 cron **有跑**（`openclaw cron runs` → runAt 13:02:05、end 13:02:27、status=ok、dur 22,038ms、sessionKey `agent:rowlet:cron:02eb0989-...:run:a64ed3e4`），但**沒有寫進 `keepalive-picturecat-2026-11-22.md`**（該檔 mtime 停在 10:03、headers 只到 10:02）→ 它把內容寫去了 **`memory/2026-11-22.md`** 的檔尾（兩行 bullet，`grep -n "Keep-Alive cron 執行"` → line 47–48）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **事實 2（巡檢降級）**：13:02 那輪**沒有 ping picturecat lane**（picturecat main session 從 03:03:54 之後的 4 筆訊息全部是 KA ping：04:02 / 07:02 / 10:02 / 16:02 → **13:02 缺席**）、沒有 cron fleet 盤點、沒有 journal/provider 分析、沒有 Discord 狀態 → 整輪只有「agent 正常喚醒、tool 可用、gateway 存活」三句。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **事實 3（結論寫錯）**：13:02 那輪寫「`automations.list` 回空、`get` 回 job not found → **該 job 非本 agent 所有（應屬其他 agent scope）**，不是排程故障」。**這是錯的。** 本 job 確實屬於 rowlet：sessionKey `agent:rowlet:cron:02eb0989-891b-43fe-8a6e-dbcb059a4124:run:*`、cron json 內 `id=02eb0989-891b-43fe-8a6e-dbcb059a4124`、schedule `every 3h`。**正解＝restricted automation-run session 內 `automations` 工具看不到自身 job**（第 3 輪 §9 已記，本次實測再確認：`list` 回 jobs:[]、`get` 回 not found）→ 用 `openclaw cron list --all --json`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **影響**：那兩行錯誤結論留在 `memory/2026-11-22.md`（與 05:55 巡讀、07:20 論文、08:12 晨間情報等**實質工作筆記同一個檔案**），會污染一般每日記憶，也會讓後續輪次誤以為「KA 紀錄在 daily 檔」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **補救**：本輪已把 13:02 的事實重建回本檔（§5），並在 §9 給 Linder 一個不需動 cron 的解法（把巡檢步驟固定成 checklist）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) ⚠️ 修正第 3 輪的時間戳誤讀：`b37129c0` 不是「08:15 啟動」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 第 3 輪寫「`b37129c0` 恰在 **08:15** 啟動，與 provider 500 同一秒 → 撞 provider edge」。**實際時間窗不同**（`openclaw cron runs --id <完整uuid>`）：`b37129c0` **runAt 08:09:28 → end 08:17:40**（dur 491,901ms、status=ok）。它的 `staggerMs=900000`（15 分）**只是 jitter 上限，不是固定 +15 分**，實際只加了 9m28s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **但結論反而更站得住**：45ccf4e9 的 500 發生在 **08:15:37.125**，**確實落在 b37129c0 的執行窗（08:09:28–08:17:40）內** → 「08:00 槽兩支 job 併發撞 provider edge」成立（45ccf4e9 `staggerMs=0`、b37129c0 jitter +9m28s → 重疊 8 分鐘）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 補充一項上輪沒寫的細節：**45ccf4e9 在 11-22 其實「有交付」**——08:01 先吃 429（elapsed 62,382ms）→ 重試後 **08:12 已把 4 則晨間情報寫進 `memory/2026-11-22.md`** → 最後 08:15:37 的收尾呼叫才吃 500 HTML → run 才被標 error。**紅燈 ≠ 沒交付**，但連續不穩是真的。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) Discord 現況：8/8 connected（checkpoint ④ ✅）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled=預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 10:02→16:02 窗：**did-not-reach-READY 0、channel exited 0、channels resolved 1、client initialized 1、delaying provider startup 1** → reconnect **≈0.17/h**（遠低於上輪 3/h 基線）✅。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實收發：mrmime in/out just now、celesteela in:2m、charizard 7h、gengar 9h、rowlet 9h、roaringmoon 8h；**picturecat／flaaffy 無近期 inbound 但 transport=just now**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming：`36b493db` 排程**仍在 `25 4 * * *`**（last 11-22 04:25 ok、dur 1,852,428ms、next **11-23 04:25**）→ 未被挪動，本窗（10:02 後）無 dreaming、無 admission suspend（timing gap 0 / suspend 0）→ **今日的 dreaming 風暴不落在本窗**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 第 3 輪 §11 五項交辦逐項核對<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| # | 項目 | 結果 |
|---|---|---|
| ① | dreaming 是否仍在 04:25 槽 | ✅ 仍在（next 11-23 04:25），本窗無風暴 |
| ② | same-model retry 是否再增 | ✅ **未增反降**：10:02→16:02 僅 1 次 retry，13:00→16:02 子窗 0 次、141 呼叫零錯誤 → 不升級為 provider 容量問題 |
| ③ | `c5352a84` 是否仍唯一紅單 | ⚠️ 仍非唯一，但**沒有新增活紅單**：`45ccf4e9`（11-23 08:00 自癒）+ `c5352a84`（11-27 03:56 自癒）+ `a94330a9`（**停用殘留**，不算）|
| ④ | Discord 安靜時段 reconnect ≤6/h | ✅ ≈0.17/h，READY 失敗 0 |
| ⑤ | picturecat lane 是否恢復自發回覆 | ⚠️ **仍無**：自 03:03:54（唯一一次使用者自己打的 "ping"）之後，picturecat main session 的訊息全是 rowlet 的 KA ping；且 **13:02 那輪連 ping 都漏了**（§5）。Discord 通道 session 最後活動停在 ~09-02 → channel 本身長態閒置，非故障 |

### 9) 本輪動作：無（觀測為主）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal（Discord 健康）、未刪 job、未動 `scripts/discord-selfheal.sh` 守門、未碰憑證、未改 DNS/網路。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **未手動重跑 `45ccf4e9`**（屬 roaringmoon lane，next 11-23 08:00 每日自動重試，與前輪對 `c5352a84` 的處置一致：不越界代跑別人 lane）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **未刪 `a94330a9 tmp-openai-probe`**（停用殘留，刪 job 屬破壞性動作，等 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`sessions_history`、`sessions_list`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id <uuid>`、`journalctl --user`、`systemctl --user show`、`curl /health`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 給 Linder 的待決事項（本輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新・高】KA 巡檢會降級成三行字，而且會寫錯檔、寫錯結論**——13:02 那一輪就是活樣本（沒 ping lane、沒巡檢、寫進 daily 檔、還斷言「job 不屬 rowlet scope」）。建議把巡檢步驟**固化成 checklist**（必做：①ping `agent:picturecat:main` ②`openclaw cron list --all --json` 盤點 ③journal 窗格分析＋正向對照 ④Discord 狀態 ⑤寫入 `memory/keepalive-picturecat-<date>.md`），並在 job payload 裡點名檔名，避免 unattended 輪次漂移。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【中】dreaming 04:25 風暴**：排程未挪動 → 明日 04:25 幾乎確定原樣重現。仍是二選一 —— (a) Discord READY 握手上限拉到 ≥300s；(b) dreaming admission suspend 期間保留既有連線的 READY deadline。**注意 `d4cd45bc` 只是每 30 分的事後健康檢查，不構成緩解。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】45ccf4e9 08:00 槽**：證據更新後建議改為「**把 `b37129c0` 的 jitter 釘在 +30 分（08:30 起）**」而非改 45ccf4e9 的槽——因為紅燈出現在 45ccf4e9，而它 08:00 起跑、08:12 已交付、08:15 收尾才死；錯開重疊窗即可。**屬 roaringmoon lane，未經你點頭我不動。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】跨廠 fallback 仍是 0**（`openai/*` 全 Auth=no）→ provider edge 出狀況時只能靠同模型重試；45ccf4e9 正是在沒有 fallback 的時刻死的。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】`a94330a9 tmp-openai-probe`** 是停用殘留紅燈（ce=2、next=None），刪掉可讓紅燈計數乾淨（目前 3 支裡只有 2 支是活的）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【低】`keepalive-picturecat-2026-11-20.md` 不存在**——已查明原因：11-20 是 DNS 風暴日，picturecat KA 本身 ce=2 直接死掉（gengar 的 11-20 檔 line 51 記載「`02eb0989` picturecat ce=2 → 16:02 死於 DNS + 被重啟砍」），不是漏寫。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【低・但已擱置 3 天】三支 KA 仍實質同時起跑**（本輪 picturecat 13:02:05.360 vs gengar 13:02:05.365 → **差 5ms**；anchor 偏移 0/39/72ms）→ 每輪都會生出 §1 那兩行 `plugin generation was superseded` 診斷。MEMORY.md 早就寫了「姊妹 job 至少錯開 ≥3 分鐘」，**但排程一直没動**。想要消掉這條假訊號 + 降低三支互踩，就把它們的 anchor 拉開。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 量測備忘（本輪新增／修正）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw cron runs --id` **只接受完整 uuid**（給短 id 或隨便前綴都回 "Automation not found"）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `cron runs` 的 **`runAtMs` = 開始、`ts` = 結束**（本輪用 45ccf4e9 與 b37129c0 雙向對齊驗證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `staggerMs` 是 **jitter 上限不是固定偏移** → 不要用「槽 + stagger」推算實際起跑時間，要看 `runAtMs`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **restricted automation-run session 內 `automations` 工具看不到自身 job**（`list` 空、`get` not found）→ 一律改用 `openclaw cron list --all --json`；journal 會留下 `cron.get ... not found` 噪音行，別誤判成故障。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_list` 的 `status:"failed"` **不等於** lane 壞掉 → 看 journal 有沒有對應 runId 的成功結束 + 回覆內容。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 14177 服務要用 **`/health`** 探（打 `/` 會 404，會被誤讀成服務掛掉）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 「0 次 provider 錯誤」這種結論一定要附**正向對照**（本輪 model-fetch 400 行 / 13:00 後 141 次 response）才敢下。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 12) 下一輪（19:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① KA 巡檢是否維持完整（13:02 那種降級有沒有再出現、紀錄有沒有又寫錯檔）；② 16:00–19:00 是否仍零 provider 錯誤（若 19:00 仍是 0 → 12:03 那次 429 可視為孤立事件，429 尖峰已退潮）；③ dreaming 是否仍在 04:25 槽；④ `45ccf4e9` / `c5352a84` 是否仍是唯一兩支活紅單；⑤ Discord reconnect 是否仍 <1/h；⑥ gateway 是否連續第 3 天未重開（MainPID 3573532 / NRestarts=0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-22 19:02 — Picturecat Keep-Alive 第 6 輪（今日第 6 輪 picturecat KA 觸發；13:02 為第 4 輪已於第 5 輪補建），runId `a5252b7e`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

**總結：🟢 lane 存活、Discord 8/8 connected、429 尖峰退潮（本窗 1 次、已被同模型重試救回）、紅單未新增。唯一新發現是「17 支 skill 因缺 `description` 被 OpenClaw 整天跳過」——長期存在、功能上等於不存在。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，status=ok）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- runId `7fdd894d-c369-456f-afc4-7a4cd6c8e784`、delivery announce pending、回覆：「pong — 1) lane 存活且空閒 2) 近 3 小時無錯誤或 provider 429 3) 無進行中／待處理任務 4) Discord inbound/outbound 正常，目前閒置無流量。」
- 本 job `02eb0989`：上輪（16:02）**ok / ce=0 / dur=165,666ms**；本輪 19:02 準時觸發。
- `sessions_list` 仍顯示 `agent:picturecat:main` status="failed" → **假訊號**（KA ping 後的 `plugin generation was superseded` race，回覆本身成功、journal 有 pong）。

### 2) 本機量測（rowlet 側 shell，19:02）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- uptime **42d00:49**；load `0.89 / 0.52 / 0.48`；RAM 31,797MB 總 / 9,301MB used / **avail 20,940MB**；swap 0/2,047；disk `/` 60%（266G/468G，剩 179G）→ 全正常。
- gateway：MainPID **3573532**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST** → **連續 1d16h51m 未重開**（第 3 天）；`/health` 18789 → **HTTP 200 in 2.9ms**；14177 → **HTTP 200 in 0.5ms**。

### 3) Cron fleet：53 jobs / 46 enabled — ok 38 / skipped 5 / error 2 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **活紅單仍只有兩支**（皆自癒、與上輪同）：`45ccf4e9 晨間情報 pipeline` ce=1（last 11-22 08:00、dur 937,285ms、**next 11-23 08:00**）；`c5352a84 skill-collection-review-roaringmoon` ce=1（last 11-20 03:56、**next 11-27 03:56**）。第三支 `a94330a9 tmp-openai-probe` 仍是 **enabled=false 的停用殘留**（ce=2、next=None）→ 不算活紅單。
- skipped 5 支全為 heartbeat（no-route 長態、良性）；`ffc90b7d heartbeat-charizard` / `c29eca0f heartbeat-gengar` 本輪 ok。
- 三支 KA 全 enabled、everyMs=10,800,000（3h）、anchor 同為 `06-03 10:02:02` → next 19:02:**06**（picturecat）/ 19:02:**06**（gengar）/ 19:02:**08**（celesteela）→ **picturecat 與 gengar anchor 完全相同（差 0ms）**，競態窗仍在。
- `36b493db dreaming` 排程**仍在 `25 4 * * *`**（last 11-22 04:25 ok、dur 1,852,428ms、next **11-23 04:25**）→ 未挪動，§5 的每日風暴明日預期原樣重現。
- 今日最長執行：`36b493db` 1,852,428ms、`ae91b967` 792,986ms、`a72cb46b` 772,096ms、`09c7940b` 706,200ms、`b37129c0` 491,901ms。

### 4) Provider 429 / DNS（16:02→19:02 窗，journal 772 行）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **正向對照**：model-fetch **413 行**（起 + 回），response status = **200 × 205、429 × 1**、無 5xx、無 HTML 錯誤頁。
- **唯一 1 次 429**：**18:02:25.788**（elapsed **112,184ms**、contentType=application/json）→ 同 runId `53027989` `isError=true error=⚠️ API rate limit reached` → **same-model retry 1/3**（delayMs=10,000）→ **18:02:37 回 status=200（1,164ms）** → **硬失敗 0**。屬 job `d7b0355b Jormungand mrmime Codex A2A heartbeat`（18:00:30 起跑、dur 259,122ms、**status=ok ce=0**）。
- **真實 DNS（EAI_AGAIN/getaddrinfo）= 0**：grep 命中 2 筆全是 agent 回覆內文（gengar 16:04 自報、rowlet 16:07 自報）——老陷阱再踩第 4 次，已能用「看原始行」分辨。
- **`Token Plan usage limit` = 0（真實）**：grep 命中 2 筆同樣是 agent 回覆內文的關鍵字；全日 `2056` 配額碼 = 0 筆。

### 5) ⭐ 429 尖峰退潮曲線（今日逐 3h 窗，正向對照齐全）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 窗 (11-22) | model-fetch | 429 | same-model retry | isError | Token Plan(真實) |
|---|---|---|---|---|---|
| 00:00–03:00 | 252 | 3 | 2 | 2 | 0 |
| 03:00–06:00 | 562 | 6 | 5 | 7 | 0 |
| 06:00–09:00 | 916 | 4 | 3 | 5 | 0 |
| 09:00–12:00 | 152 | 2 | 2 | 2 | 0 |
| 12:00–15:00 | 196 | 1 | 1 | 1 | 0 |
| **15:00–18:00** | 364 | **0** | **0** | **0** | 0 |
| 18:00–19:10 | 149 | 1 | 1 | 1 | 0 |
→ **上輪 §12 ②「16:00–19:00 是否仍零錯誤」的答案是：不完全成立**（18:02 有 1 次，但同模型重試 1/3 即恢復、所屬 job 收尾仍 ok）。同時 15:00–18:00 是**今日最乾淨的 3 小時窗**。→ 429 已從凌晨 3–6 次/窗退到 **0–1 次/窗**，可判為尖峰退潮，但**尚未歸零**。

### 6) Discord 現況：8/8 connected<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled=預期）。
- 真實收發：celesteela in:5m、mrmime in/out:58m、charizard in/out:10h、gengar 12h、roaringmoon 11h、rowlet 3h；**picturecat／flaaffy 無近期 inbound 但 transport=just now / 1m ago**。
- **簽章全 0**：did-not-reach-READY **0**、channel exited **0**、client initialized 0、channels resolved 0、delaying provider startup 0、host timing gap 0、admission suspend 0 → 本窗無 dreaming 風暴、無握手失敗。
- ⚠️ **指標定義修正**：上輪（16:02）報「reconnect ≈0.17/h」是**只數 READY 失敗簽章**；改用完整簽章（`Gateway reconnect scheduled` / `websocket closed code=1005`）後，今日逐窗 = 4.7/h（00–03）→ **17/h（03–06，dreaming 風暴）** → 4/h → 3/h → 3/h → **2.7/h（15–18）** → **2.6/h（18–19:10）**。→ **安靜時段基線 ≈2.6–3/h**（與 07:02／10:02 兩輪的 ≈3/h 一致），**本窗 8 次 reconnect 全為 resume=true 的健康重連**。24h 合計 reconnect 131 / ws-closed 165 / READY-fail 28 / channel-exited 14（後兩者全落在 dreaming 窗）。

### 7) ★ 新發現：17 支 skill 因缺 `description` 被 OpenClaw **整天跳過**（功能性缺失，非雜訊）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 簽章：`[skills] Skipping invalid skill: file=…/SKILL.md error=description is required` → 本窗 **204 筆**、24h **3,349 筆**、逐日：11-15:918 / 11-16:4,644 / 11-17:4,896 / 11-18:3,888 / 11-19:5,598 / 11-20:5,544 / 11-21:4,676 / 11-22:2,720 → **長期存在**（至少 8 天），但從未被回報過。
- **精確分類（24h 逐檔矩陣，每檔各 197 次 = 每天 197 輪 skill 載入）**：
  - **13 支 `description is required`**（frontmatter 整段不存在）：`card-lookup`、`meta-analyzer`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-download`、`ptcgp-card-lookup`、`system-design-six-dimensions-analyzer`、`web-fetch-troubleshooting`，＋ `rosclaw/extensions/openclaw-plugin/skills/` 下 4 支（`check-status`／`navigate-to`／`pick-object`／`take-photo`）。
    抽驗：`network-security-defense/SKILL.md` 首行即 `# 網路攻擊與防禦完整指南`（**零 frontmatter**）；`card-lookup/SKILL.md` 首行即 `# Card Lookup Skill`。
  - **4 支 `invalid frontmatter: BAD_INDENT`**（frontmatter 存在但 YAML 壞）：`excel-image-pipeline`、`human-behavior-simulation`、`image-attendant`、`ocr-confidence-mark`。
    抽驗 `excel-image-pipeline/SKILL.md`：`description: "|` 開頭的 block scalar 內含多行中文與 `-` 清單 → YAML 報 `All mapping items must start at the same column`。
- **後果（可驗證）**：這 17 支**從未進入 `<available_skills>`** → 等於不存在（`prompt-injection-defense`、`network-security-defense`、`ocr-confidence-mark` 等全不在可用清單中）。
- **修法**：13 支補 `---`／`name:`／`description:`（單行）frontmatter；4 支把多行 block scalar 折成**單行** description。**本輪未動**：數支屬其他 agent lane（ptcgp-* 疑 gengar、card-lookup 疑 picturecat）且 rosclaw 4 支屬第三方 plugin（plugin 更新會覆寫），跨 lane / 跨 plugin 寫檔未經 Linder 點頭不做。

### 8) 第 5 輪 §12 六項交辦逐項核對<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| # | 項目 | 結果 |
|---|---|---|
| ① | KA 巡檢是否維持完整、紀錄有沒有寫錯檔 | ✅ 本輪五步 checklist 全做（ping lane / cron fleet 盤點 / journal 窗格＋正向對照 / Discord 狀態 / 寫入本檔）；13:02 降級輪未再出現 |
| ② | 16:00–19:00 是否仍零 provider 錯誤 | ⚠️ **非零**：18:02 有 1 次 429（retry 1/3 救回、所屬 job 收尾 ok）；15–18 窗本身零錯誤 |
| ③ | dreaming 是否仍在 04:25 槽 | ✅ 仍在（next 11-23 04:25），本窗無風暴 |
| ④ | 紅單是否仍只有 `45ccf4e9` / `c5352a84` | ✅ 兩支活紅單未變，無新增 |
| ⑤ | Discord reconnect 是否 <1/h | ⚠️ 以完整簽章算 ≈2.6/h（修正上輪只數 READY 簽章的 0.17/h）；仍遠低於 dreaming 窗 17/h |
| ⑥ | gateway 是否連續第 3 天未重開 | ✅ MainPID 3573532 / NRestarts=0 / 連續 1d16h51m |

### 9) 本輪動作：無（觀測為主）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal（Discord 健康）、未刪 job、未改 skill 檔、未碰憑證、未改 DNS/網路。
- 未手動重跑 `45ccf4e9`（roaringmoon lane，11-23 08:00 每日自癒）；未刪 `a94330a9`（停用殘留，刪 job 屬破壞性動作）。

### 10) 給 Linder 的待決事項（本輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新・中】17 支 skill 每天被跳過 197 次**（§7）＝**功能上等於不存在**，且每日 3,000+ 筆 log 噪音：13 支缺 `description`（無 frontmatter）、4 支 frontmatter YAML 壞（BAD_INDENT）。授權後由我一次性修好本地 9 支（ptcgp/card-lookup 等屬其他 lane 者不動）、rosclaw 4 支走 plugin 上游。**這是本輪最值得處理的一項。**
2. **【中】dreaming 04:25 風暴**：排程未挪動 → 明日 04:25 幾乎確定原樣重現（今日簽章：timing gap 6 / READY-fail 28 / channel-exited 14 / reconnect 17/h）。仍是二選一 —— (a) Discord READY 握手上限拉到 ≥300s；(b) dreaming admission suspend 期間保留既有連線的 READY deadline。**注意 `d4cd45bc` 只是每 30 分的事後健康檢查，不構成緩解。**
3. **【中】三支 KA 仍實質同時起跑**（picturecat 19:02:06 vs gengar 19:02:06 → 差 0ms）→ 每輪都會生出 `plugin generation was superseded` 假訊號。已擱置 4 天。
4. **【中】45ccf4e9 08:00 槽**：建議把 `b37129c0` jitter 釘在 +30 分（08:30 起）以錯開重疊窗（今日 500 發生在 45ccf4e9 執行窗內）。
5. **【中】跨廠 fallback 仍為 0**（`openai/*` 全 Auth=no）→ provider edge 出狀況只能靠同模型重試（18:02 與 08:15 兩次都靠這招救回，但無冗餘）。
6. **【低】`a94330a9 tmp-openai-probe`** 停用殘留紅燈（ce=2）→ 刪掉可讓紅燈計數乾淨（目前 error 計數 2 支全是活的）。

### 11) 量測備忘（本輪新增／沿用）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`Token Plan usage limit` / `EAI_AGAIN` 的 grep 命中必須看原始行**——今日兩者各命中 2 筆，全部是 agent 回覆內文的關鍵字（老陷阱第 4、5 次）。
- **Discord reconnect 要兩種簽章都數**：`Gateway reconnect scheduled`（reconnect-opcode）≈ 完整重連數；`did not reach READY` / `channel exited` ≈ 握手失敗數。**只數後者會低估 10 倍以上**（本輪 0.17/h vs 真實 2.6/h）——這是上輪的指標定義錯誤，已修正。
- 「provider 零錯誤」結論必須附正向對照數（本輪 model-fetch 413 行、response 206 筆）。
- `openclaw cron runs --id` 只吃完整 uuid；`runAtMs`=開始、`ts`=結束（今日 6 輪 04:02/07:02/10:02/13:02/16:02/19:02 的 runAt 都對得上 3h 槽）。
- restricted automation-run session 內 `automations` 工具看不到自身 job（list 空、get not found）→ 一律 `openclaw cron list --all --json`。

### 12) 下一輪（22:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① 18:02 之後 429 是否歸零（19–22 窗）；② `45ccf4e9` 11-23 08:00 是否自癒（ce 是否歸 0）；③ dreaming 是否仍在 04:25 槽；④ 紅單是否仍只有兩支活；⑤ skill 缺 description 是否有補（若 Linder 授權則下輪驗 17 支載入狀態）；⑥ gateway 是否仍 NRestarts=0；⑦ 三支 KA anchor 是否仍 0ms 重疊。

---

## 2026-11-22 22:02 — Picturecat Keep-Alive 第 7 輪（今日第 7 輪 picturecat KA 觸發），runId `dbd176e3`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

**總結：🟢 lane 存活、Discord 8/8 connected、gateway 連續第 3 天未重開、紅單未新增。19–22 窗有 1 次 429（21:02:49，elapsed 162,646ms），同模型重試 1/3 於 21:03:01 救回，所屬 job `911eee45` 收尾 ok / ce=0 → 硬失敗 0。17 支 skill 缺 description 的問題**仍未修**（24h 3,298 筆、本窗 255 筆，每檔仍 194 次）**。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) picturecat lane 自報（`sessions_send` → `agent:picturecat:main`，runId `dbd176e3`，status=ok）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 回覆：「pong — 1) lane 存活且空閒 2) 近 3 小時（19:00–22:00）無錯誤或 provider 429 3) 無進行中／待處理任務 4) Discord inbound/outbound 正常。」
- 本 job `02eb0989`：上輪（19:02）**ok / ce=0 / dur=256,865ms**；本輪 22:02:06.118 準時觸發。

### 2) 本機量測（rowlet 側 shell，22:02）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- uptime **42d03:49**；load `0.69 / 0.49 / 0.46`；RAM 31,797MB 總 / 9,175MB used / **avail 21,062MB**；swap 0/2,047；disk `/` 60%（267G/468G，剩 178G）→ 全正常。
- gateway（**user unit** `openclaw-gateway.service`）：MainPID **3573532**、**NRestarts=0**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST**、ps elapsed **1-19:50:45** → **連續 1d19h50m 未重開**（第 3 天）；`/health` 18789 → **HTTP 200 in 4.9ms**、14177 → **HTTP 200 in 0.3ms**。
- ⚠️ **量測備忘**：gateway 是 **user unit**，用 `systemctl --user show openclaw-gateway`；用 `systemctl show`（system scope）會拿到 `MainPID=0 / inactive / dead` 的**假訊號**（本輪踩到，已修正）。

### 3) Cron fleet：53 jobs / 46 enabled / 7 disabled — ok 38 / skipped 5 / error 2 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **活紅單仍只有兩支**（與上輪同，皆自癒）：`45ccf4e9 晨間情報 pipeline (Roaringmoon)` ce=1（last 11-22 08:00、dur 937,285ms、**next 11-23 08:00**）；`c5352a84 skill-collection-review-roaringmoon` ce=1（last 11-20 03:56、**next 11-27 03:56**）。第三支 `a94330a9 tmp-openai-probe` 仍是 **enabled=false 的停用殘留**（ce=2、next=None）→ 不算活紅單。
- skipped 5 支全為 heartbeat（no-route 長態、良性）：`d82f78e3 heartbeat-rowlet`、`46242a4c heartbeat-celesteela`、`7d633ff4 heartbeat-greninja`、`6525d155 heartbeat-picturecat`、`3acd15c2 heartbeat-roaringmoon`。
- 三支 KA 全 enabled、everyMs=10,800,000（3h）、anchor 同為 `06-03 10:02:02`：本輪 picturecat **22:02:06.118** / celesteela **22:02:08.142** / gengar **22:02:08.151** → **picturecat↔celesteela 差 1.9s、celesteela↔gengar 差 0.009s** → **重疊競態窗仍在（第 9 次）**（上輪是 picturecat↔gengar 差 0ms，本輪換成 celesteela↔gengar 差 9ms）。
- `36b493db Memory Dreaming Promotion` 排程**仍在 `25 4 * * *`**（last 11-22 04:25 ok、dur 1,852,428ms、next **11-23 04:25**）→ 未挪動。
- 今日最長執行：`36b493db` 1,852,428ms、`45ccf4e9` 937,285ms、`ae91b967` 792,986ms、`a72cb46b` 772,096ms、**`911eee45` 每日資安建議 624,182ms**、`09c7940b` 544,739ms、`b37129c0` 491,901ms。

### 4) Provider 429 / DNS（19:02→22:03 窗，journal 984 行，正向對照 model-fetch 566 行、response 283 筆）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **正向對照**：response status = **200 × 282、429 × 1**、無 5xx（唯一異常數字 `266` 是 `[ws] res ✓ status 266ms` 的耗時誤判，非 HTTP code）。
- **唯一 1 次 429**：**21:02:49.085**（elapsed **162,646ms**、contentType=application/json）→ 同 runId `c7d4aaa0`（discord embedded run，屬 cron `911eee45 每日資安建議`）`isError=true error=⚠️ API rate limit reached` → **same-model retry 1/3** → **21:03:01.666 回 status=200（2,364ms）** → **硬失敗 0**；該 job 收尾 **ok / ce=0**（21:10:29 完成，dur 624,182ms）。
- **真實 DNS（EAI_AGAIN/getaddrinfo）= 0**；**真實 `Token Plan usage limit` = 0**；本窗 `rate limit` 字樣僅 1 筆＝就是上面那筆 429 本身。
- **跨廠 fallback 仍為 0**：今日 provider 呼叫 100% `minimax-portal`（3,115 筆），`openai/*` 仍全無使用 → provider edge 出狀況只能靠同模型重試（今日 08:15、18:02、21:02 三次都靠這招救回，但無冗餘）。
- **新增觀察**：24h `auth profile failure` 3 筆（profile `sha256:9e08bd6be9c1`、provider=minimax-portal，全在 dreaming 窗）+ `failover decision` 2 筆（`decision=fallback_model reason=timeout`，04:39 dreaming 期間）→ **failback 走的是同廠 fallback_model，不是跨廠**。

### 5) ⭐ 429 尖峰退潮曲線（本輪統一口徑重算：所有窗一律 `model-fetch.*status=429`）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 窗 (11-22) | model-fetch | 429 | isError | Token Plan(真實) |
|---|---|---|---|---|
| 00:00–03:00 | 252 | 2 | 2 | 0 |
| 03:00–06:00 | 562 | 5 | 7 | 0 |
| 06:00–09:00 | 916 | 4 | 5 | 0 |
| 09:00–12:00 | 152 | 2 | 2 | 0 |
| 12:00–15:00 | 196 | 1 | 1 | 0 |
| **15:00–18:00** | 364 | **0** | **0** | 0 |
| 18:00–19:02 | 74 | 1 | 1 | 0 |
| **19:00–22:03** | 574 | **1**（21:02:49） | 1 | 0 |
→ 尖峰已退到 **0–1 次/3h 窗**（凌晨 4–5 次/窗），**尚未歸零**；所有 429 的 isError 都被 same-model retry 救回，**今日硬失敗仍為 0**。

### 6) Discord 現況：8/8 connected<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela／charizard／flaaffy／gengar／mrmime／picturecat／roaringmoon／rowlet 全 **enabled, configured, running, connected**（greninja disabled=預期）。
- 真實收發：celesteela in:1m、mrmime in/out:52m、charizard in/out:13h、gengar 15h、roaringmoon 14h、rowlet 3h；**picturecat／flaaffy 無近期 inbound 但 transport=just now**。
- **握手失敗簽章全 0**：did-not-reach-READY **0**、channel exited **0**、client initialized 0、channels resolved 0、delaying provider startup 0、host timing gap 0、admission suspend 0 → 本窗無 dreaming 風暴、無握手失敗。
- **reconnect 基線**：本窗 `Gateway reconnect scheduled` **10 次 / 3.05h ≈ 3.3/h**，全部 `resume=true`（健康重連）；24h 合計 reconnect 129、READY-fail 28、channel-exited 14、host-timing-gap 6（後三者全落在 dreaming 窗）。

### 7) ⚠️ 17 支 skill 缺 description：仍未修（本輪驗證）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 簽章 `[skills] Skipping invalid skill`：本窗 **255 筆**、24h **3,298 筆**（24h 唯一 skill 檔 = **17 支**，每檔各 **194 次**＝每天 194 輪 skill 載入）→ **一支都沒修**。
- 分類不變：**13 支 `description is required`**（零 frontmatter：`card-lookup`、`meta-analyzer`、`network-security-defense`、`prompt-injection-defense`、`prompt-injection-filter`、`ptcgp-card-download`、`ptcgp-card-lookup`、`system-design-six-dimensions-analyzer`、`web-fetch-troubleshooting` ＋ rosclaw plugin 下 `check-status`／`navigate-to`／`pick-object`／`take-photo`）＋ **4 支 `invalid frontmatter: BAD_INDENT`**（`excel-image-pipeline`、`human-behavior-simulation`、`image-attendant`、`ocr-confidence-mark`）。
- 抽驗 rosclaw 4 支首行：`# Check Status` / `# Navigate To` / `# Pick Object` / `# Take Photo` → **確認仍是零 frontmatter**。
- ⚠️ **老陷阱第 6 次**：24h 唯一檔名清單會多出 `sha256:9e08bd6be9c1`（5 筆）——那是 dreaming 的 `auth profile failure` 行裡的 profile 指紋，**不是 skill 檔**。用 `file=… .md` 過濾才準。

### 8) 第 6 輪 §12 七項交辦逐項核對<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| # | 項目 | 結果 |
|---|---|---|
| ① | 18:02 之後 429 是否歸零（19–22 窗） | ⚠️ **未歸零**：21:02:49 有 1 次（elapsed 162,646ms），retry 1/3 於 21:03:01 救回，所屬 job `911eee45` 收尾 ok / ce=0 → 硬失敗 0 |
| ② | `45ccf4e9` 11-23 08:00 是否自癒（ce→0） | ⏳ **尚未到點**（本輪 22:02 時 ce 仍 1、next 11-23 08:00）→ 下輪（11-23 01:02）仍無法驗，須 11-23 08:00 之後 |
| ③ | dreaming 是否仍在 04:25 槽 | ✅ 仍在（next 11-23 04:25），本窗無風暴 |
| ④ | 紅單是否仍只有兩支活 | ✅ `45ccf4e9` / `c5352a84` 未變，無新增 |
| ⑤ | skill 缺 description 是否有補 | ❌ **未補**：17 支全部仍每天跳過 194 次（24h 3,298 筆） |
| ⑥ | gateway 是否仍 NRestarts=0 | ✅ MainPID 3573532 / NRestarts=0 / 連續 **1d19h50m** 未重開（第 3 天） |
| ⑦ | 三支 KA anchor 是否仍 0ms 重疊 | ⚠️ **仍重疊**（第 9 次）：本輪 picturecat 22:02:06.118 ↔ celesteela 22:02:08.142 ↔ gengar 22:02:08.151（celesteela↔gengar 差 9ms） |

### 9) 本輪動作：無（觀測為主）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未重啟 gateway、未觸發 selfheal（Discord 健康）、未刪 job、未改 skill 檔、未碰憑證、未改 DNS/網路。
- 未手動重跑 `45ccf4e9`（roaringmoon lane，11-23 08:00 每日自癒）；未刪 `a94330a9`（停用殘留，刪 job 屬破壞性動作）；未修 17 支 skill（跨 lane / 跨 plugin 寫檔未經 Linder 點頭不做）。

### 10) 給 Linder 的待決事項（本輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新・高】gateway 是 user unit，system scope 查詢會給假訊號**——若哪天有人（人或 agent）用 `systemctl show openclaw-gateway` 判斷「gateway 已死」並誤觸發重啟/selfheal，會造成一次不必要的重開。建議把「只查 user scope」寫進維運腳本。（本輪已修正量測方式。）
2. **【中・待授權】17 支 skill 每天被跳過 194 次**（§7）＝功能上等於不存在（`prompt-injection-defense`、`network-security-defense`、`ocr-confidence-mark` 全不在 `<available_skills>`）。授權後我一次性修好本地 9 支（其他 lane 者不動）、rosclaw 4 支走 plugin 上游。**目前已連續 2 輪回報、仍未見動靜。**
3. **【中】dreaming 04:25 風暴**：排程未挪動 → 明日 04:25 幾乎確定原樣重現（今日簽章：timing gap 6 / READY-fail 28 / channel-exited 14 / reconnect 17/h）。仍是二選一 —— (a) Discord READY 握手上限拉到 ≥300s；(b) dreaming admission suspend 期間保留既有連線的 READY deadline。
4. **【中】三支 KA 仍實質同時起跑**（本輪 celesteela 22:02:08.142 vs gengar 22:02:08.151 → 差 9ms）→ 每輪都會生出 `plugin generation was superseded` 假訊號。已擱置 5 天。
5. **【中】跨廠 fallback 仍為 0**（今日 3,115 筆呼叫 100% minimax-portal，`openai/*` 全無使用）→ 今日三次 429（08:15／18:02／21:02）全靠同模型重試救回，無跨廠冗餘。
6. **【低】`a94330a9 tmp-openai-probe`** 停用殘留紅燈（ce=2）→ 刪掉可讓紅燈計數乾淨（目前活紅單 2 支）。
7. **【低】`45ccf4e9` 08:00 槽**建議把 `b37129c0` jitter 釘在 +30 分（08:30 起）以錯開重疊窗（今日 500 發生在 45ccf4e9 執行窗內）。

### 11) 量測備忘（本輪新增／沿用）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **gateway 狀態務必 `systemctl --user show openclaw-gateway`**（system scope 會回 `MainPID=0 / dead` 假訊號）。
- **本輪把 429 統計口徑統一**（所有窗一律 `model-fetch.*status=429`）→ 今日逐窗 2/5/4/2/1/0/1/1；上輪混用了不同 grep（3/6/4/2/1/0/1），**兩輪數字不可直接比較**，本輪起以此口徑為準。
- **`status=266` 是 `[ws] res ✓ status 266ms` 的耗時誤判**，不是 HTTP code —— 統計 status 碼時要用 `status[=: ]` 邊界避免誤抓。
- **`file=` 過濾要加 `.md`**，否則 dreaming 的 `profile=sha256:…` 會混進 skill 清單（老陷阱第 6 次）。
- 「provider 零錯誤」結論必須附正向對照數（本輪 model-fetch 566 行、response 283 筆）。
- restricted automation-run session 內 `automations` 工具看不到自身 job（list 空、get not found）→ 一律 `openclaw cron list --all --json`。

### 12) 下一輪（11-23 01:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
① 21:02 之後 429 是否歸零（22–01 窗）；② `45ccf4e9` ce（11-23 08:00 前仍應為 1，08:00 後才可能歸 0）；③ dreaming 是否仍在 04:25 槽；④ 紅單是否仍只有兩支活；⑤ skill 缺 description 是否有補（若授權則驗 17 支載入狀態）；⑥ gateway 是否仍 NRestarts=0；⑦ 三支 KA anchor 是否仍重疊。
