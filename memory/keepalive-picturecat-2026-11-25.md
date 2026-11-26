# 2026-11-25（週三）Picturecat Keep-Alive 巡檢

## 2026-11-25 01:02 — Picturecat Keep-Alive 第 1 輪：🟡 lane PASS、Discord **連續 20h08m 零症狀**、gateway 連續 **44h15m** 未重啟、⭐⭐ **「skipped 但跑了 5 分鐘」近失再現（heartbeat-rowlet 298.9s = 600s 預算的 49.8%）**、⭐⭐ **23:00 槽 429 讓 `每日模型排行前十` 連死 2 次才救回**、⭐ **heartbeat-mrmime「每 2 小時死一次」的週期假設被推翻（連續 8 輪全綠）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `9c3e44a9-5849-4375-8c76-f96c35eda2d3`、status=ok、回覆「**LANE_OK_PICTURECAT_0102 = 6** — (a) 無 active task, (b) 近 3h 無 error／provider 429, (c) Discord inbound 正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**11-24 22:02**）**ok / dur=430,720ms（430.7s）/ ce=0** → **非降級輪**（>30s 門檻）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 11-24 全天八輪 dur：01:02 **392,354** → 04:02 **390,890** → 07:02 **170,696** → 10:02 **138,687** → 13:02 **173,018** → 16:04 **145,332** → 19:02 **358,840** → 22:02 **430,720**（ms）→ **八輪全綠、全非降級**（11-23 22:02 那次 21.5s 零紀錄降級輪未再復現）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job 上一輪亦全綠：**Gengar KA 22:02:04 ok/383,154ms**、**Celesteela KA 22:02:18 ok/155,883ms** → **三支 KA 全綠**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 26 次，但順序翻轉了**：`state.nextRunAtMs` 實測 gengar `1795539724195` → picturecat `1795539738333` → celesteela `1795539738339`＝**14,138ms / 6ms**。→ 上輪是「picturecat→gengar 12.1s + picturecat↔celesteela 6ms」，本輪變成「gengar→picturecat 14.1s + picturecat↔celesteela 6ms」→ **gengar 與 picturecat 已自然錯開，但 picturecat↔celesteela 仍是 6ms 實質同時**（Celesteela KA 一直緊貼本 job）。修法（拉開 ≥15 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（非故障，沿用）：本輪 `automations` 視角仍不可用（`list` 回 0 筆；restricted automation-run session），cron 真相一律走 `openclaw cron list --all --json`（53 支全見）＋ `openclaw cron runs --id <完整 UUID>`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 本輪主事件 A：**「skipped 卻跑了近 5 分鐘」的近失再現**（heartbeat-rowlet 23:08 跑了 **298.9s**） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **heartbeat-rowlet** 窗內逐輪 receipt：`22:08:22 skipped dur=66,932ms` → `23:08:22 skipped dur=**298,856ms**` → `23:38/00:08/00:38 skipped dur=264–514ms`。→ **23:08 那輪「skipped 卻燒掉 298.9s」＝ 600s 預算的 49.8%**，是本輪最接近定時炸彈的一次（上輪近失為 375.4s / 281.6s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **heartbeat-celesteela** 同步出現 `23:12:51 skipped dur=30,026ms`；兩者都收在 **23:13:21.560**（同一毫秒）＝ **同一場 in-flight 工作把兩個 heartbeat 一起拖住**（journal 對應 `Cannot delete session while competing work is in flight`，同窗 `5b7c1082 每日模型排行前十` 的第三次嘗試也正好 23:13:21.532 收尾）→ **被拖住的不是 heartbeat 自己，是同槽的 429 重試鏈**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **本輪把 600s 炸彈的機制講得更清楚了（但有一處與 Gengar 01:02 輪結論衝突，標為待驗）**：證據＝`heartbeat-rowlet`（rowlet lane）23:08 那輪與 `heartbeat-celesteela` 23:12 那輪**結束時間戳完全相同（23:13:21.560）**，而 rowlet lane 上當時正在跑 `5b7c1082 每日模型排行前十` 的第三次嘗試（23:13:21.532 收尾）→ **高度符合「同 lane 有別的 job 在跑 → heartbeat 被卡住等待 → dur 暴增 → 撞 600s 就死」**。⚠️ **但 Gengar 01:02 輪對 11-24 21:01–21:11 窗的量測給出相反結論**（provider 端 model-fetch 71 筆、200=35、最大間隔 59s → 判定為「runner hang，非上游慢」）→ **兩說並存、尚未定案**：可能是「阻塞是真、但致命的那一步是 runner hang」。→ 修法優先序因此建議**先做低風險的那一件**：錯開整點槽的 job 密度（消掉同 lane 併發與重試鏈），再談拉高 timeoutSeconds。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **對照：heartbeat-mrmime 本窗 8 輪全綠**（21:31 → 01:01，dur 4.7–22s）→ **上輪待決事項 #1「21:11 死法會不會變成每 2 小時一次」→ 本輪證偽（負結果也要記）**：21:11 之後 8 輪零死亡，11-24 08:21 與 21:11 兩次 600s 硬死之間**間隔 12h50m**，不構成 2 小時週期。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ 本輪主事件 B：**23:00 槽的 429 讓 `每日模型排行前十` 連死 2 次才救回** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt（`5b7c1082`）：**23:00:00 error / dur=79,795ms** → **23:01:49 error / dur=109,341ms** → **23:04:39 ok / dur=522,352ms** → `state.consecutiveErrors=0`、`lastRunStatus=ok` → **紅單清單完全看不到這兩次死亡**（第 6 例「ce=0 洗掉整輪死亡」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對應 journal：23:01:19.475 `[provider-transport-fetch] … status=429 elapsedMs=66,098` → 23:03:38.853 `status=429 elapsedMs=103,797`，兩者 rawError 均為 **`{"type":"overloaded_error","message":"server is busy, please retry later"}`** → 緊鄰行是 `[cron:5b7c1082-961c-4600-ab71-6a883dd95782] Failed to remove unused run continuation … competing work is in flight`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **新觀察：這是「同一槽 3 次嘗試」模式，不是「單次失敗後重試 1 次」**。前 5 天紀錄都是「首輪 error → 隔 7–9 分鐘 retry ok」；本輪是 **23:00 error → 23:01 error → 23:04 ok**，中間兩顆 429 各吃 66s / 104s。→ **推測：23:00 整點槽同時有 `每日模型排行前十` ＋ 其他 job 起跑 → 兩顆 overloaded_error 背靠背**；這支持待決事項 #9（整點槽密度）優先於 #15（單一 job 移槽）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **同一窗 00:00 槽的 429 被 retry 吃掉**：`00:02:31.444 status=429 elapsedMs=118,738` → `rate-limit same-model retry 1/3 delayMs=10000` → job `d7b0355b Jormungand mrmime Codex A2A heartbeat` **ok / dur=157,266ms**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **三個整點槽的老問題仍在（今日數據）**：`40e09cd1 Jormungand` 11-24 03:00:00 error/115,867ms → 03:02:25 ok/865,320ms（近 5 天 03:00 槽：11-20 error / 11-21 error / 11-22 ok / 11-23 error / **11-24 error**）；`58fe15dc 每日論文討論` 11-24 07:00:00 error/208,723ms → 07:04:00 ok/486,124ms（近 5 天 **4 天 4 次首輪 error**）；`5b7c1082` **11-24 23:00 槽 2 次 error**（本輪新增）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) fleet：53 jobs / 46 enabled / 7 disabled — **ok 39 / skipped 5 / error 1 / none 1**（enabled 側），disabled 側另有 1 支 error(ce=2) <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 的非 ok：**8 支 heartbeat 中 5 支 `skipped`**（rowlet / celesteela / greninja / picturecat / roaringmoon，全 `no-route`，良性長態）；`c5352a84 skill-collection-review-roaringmoon` **error/ce=1**（11-19 DNS 舊因，next **11-26**）；**`6e93c179 heartbeat-flaaffy` status=None（從未跑）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled：`a94330a9 tmp-openai-probe` error/ce=2（11-19 舊因、legacy 可清）；其餘 6 支 ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **窗內（22:02–01:02）8 支 heartbeat receipt 逐支實測**：charizard 8 輪全 ok（10.5–13.3s）、gengar 8 輪全 ok（7.9–16.4s）、**mrmime 8 輪全 ok**（4.7–186.7s；00:01 那輪 186.7s 是 429 拖過的慢輪，未死）、**rowlet 7 skipped ＋ 1 ok（21:08 ok/281,588ms）**、celesteela 全 skipped（其中 23:12 一輪 30.0s）、greninja / picturecat / roaringmoon 全 skipped（259–263ms）→ **窗內 0 筆 600s 硬死、0 筆 superseded 型死**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-flaaffy`：`cron runs --id` 窗內 **tot=0**、`state.lastRunStatus=None`、nextRunAt 仍 **1801634183940＝2027-02-03**（≈71 天後）→ everyMs 1000× 錯誤仍未修（改 job 需點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- self-heal `d4cd45bc`：22:13→00:43 共 **6 輪全 ok、dur 745–786ms**，全為「discord healthy (no startup-not-ready) - no action」→ **守門零開火**（11-23 那次開火腰斬 dreaming 的教訓持續有效）；且 **04 整點空窗確認**（schedule 13,43 → 04:13/04:43 天然不跑，dreaming 04:25 期間無 Discord 救援）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming `36b493db`：窗內未跑；**11-24 04:25 → 04:55:18 ok / 1,816,088ms（30.3 分，連續第 2 次完整活下來）**，歷史中唯一 error 為 11-23（被 gateway 重啟腰斬）；next **11-25 04:25**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 其他窗內 job：`ca222989 OpenClaw 系統維護` 3 輪全 ok（37.9–145.8s）、`13ac4b5a 健康回報` 23:05 ok/120,976ms、`537bd0dd Rowlet 轉錄監控` 6 輪全 ok（1.2s）、`911eee45 每日資安建議` 11-24 21:00 ok/770,662ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 429：3h 窗 **3 筆**（23:01:19 / 23:03:38 / 00:02:31），**子型全是 `overloaded_error`**，quota 型仍為 0 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical：`[provider-transport-fetch] [model-fetch] response provider=minimax-portal api=anthropic-messages model=MiniMax-M3 status=429` ×3，elapsedMs = **66,098 / 103,797 / 118,738**（**每次都超過 1 分鐘**，MiniMax 限流固定要 1–2 分鐘才回，期間 fallback 鏈完全不能推進）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **24h canonical `status=429` = 16 筆**（逐時：11-24 **03×1 / 05×2 / 06×1 / 07×3 / 08×2 / 09×1 / 12×1 / 18×1 / 21×1 / 23×2**、11-25 **00×1**）→ **「整點後 1–11 分鐘」的指紋持續成立**（03:00/05:00/07:00/08:00/09:00/12:00/18:00/21:00/23:00/00:00 槽）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **`Token Plan usage limit`（真配額）24h = 0 筆** → 本窗口全部是「伺服器忙」型，不是額度用完型。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 24h 內 `overloaded_error` 字串命中 16、`rate_limit` 命中 3（＝`rate-limit same-model retry 1/3` 的日誌字串，非獨立事件）→ **計數一律以 `[provider-transport-fetch] … status=429` 為準**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Discord：**連續 20h08m 零症狀**（自 11-24 04:55:41 之後），8/8 running+connected <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗簽章：`did not reach READY` **0**、`channel exited` **0**、`host timing gap detect` **0**、`client initialized` **1**、`channels resolved` **1**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **重連兩簽章要一起數**：`Gateway reconnect scheduled` **12**（全 `reconnect-opcode, resume=true`＝心跳式重連、非掉線）、`websocket closed` **14**（code=1005/1006）→ ≈ **4–4.7 次/小時的安靜期基線**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯一一次 client 重建：**22:10:55 `channels resolved`（喵喵工作坊/一般）＋ 22:10:57 `client initialized as 1481665194777378828; awaiting gateway readiness`**（前一行是 `[picturecat] Discord bot probe resolved @luna`）→ **無 READY 失敗、無 channel exited**，自癒完成。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela in:6m／mrmime in:1m／roaringmoon in:2h／charizard in:16h／gengar in:18h／rowlet in:18h；flaaffy、picturecat 無 in 紀錄；greninja `disabled`（既有狀態）→ **無 startup-not-ready**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 對照：`did not reach READY` 26、`channel exited` 13、`host timing gap detect` 6 → **全部落在 11-24 04:25 dreaming 窗**（最後一筆 04:55:41）→ 與基準表一致，非新事故。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 系統面：全綠 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST`、**NRestarts=0**、MainPID **4137629**、SubState=running → **連續 44h15m 未重啟**（11-24 22:02 輪為 41h15m）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `prepared model runtime plugin generation was superseded`：3h **8 筆**、24h **113 筆**（競態噪音，良性；回覆照常落地）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Embedded agent failed before reply`：24h **3 筆**（11-24 16:09、21:12、11-23 16:11）→ **本窗 0 筆新增**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 24 輪仍未修**：3h 窗 raw **544 行**、24h raw **3,689 行**、唯一檔 **17 支**、每檔每 3h **32 次**（≈256 次/日）→ **仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ `elle.service` 重啟迴圈（本輪未複驗細節，維持待決事項 #14，需 root）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（沿用 17 項 + 新增 1 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增・高】600s 炸彈的真兇是「同 lane 併發＋429 重試鏈」**，不是 heartbeat 本身慢 → 修法優先序改為：① **錯開整點槽的 job 密度**（本輪實證 23:00 槽 2 顆背靠背 429 直接拖死 `每日模型排行前十` 兩次，並把兩個 heartbeat 拖到 298s/30s）；② 再來才是拉高 heartbeat 的 timeoutSeconds。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【高】heartbeat-mrmime 是 fleet 最脆的一支**：21:11 死法＝「429 拖過 600s → 換手又被同 lane 競態補刀」的雙死；**但本窗 8 輪全綠、2 小時週期假設已證偽** → 維持「最小改動：把 mrmime 的槽錯開整點」。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】429 記錄要新增第三型別 `overloaded_error`（server is busy）**，與 quota 型分開計數；本輪 24h 全部 16 筆都是 quota=0 的 busy 型，每次 66–119s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高】`prepared model runtime plugin generation was superseded` 會直接殺掉整輪 job run**（11-24 16:09 ＋ 21:12 兩次實證；本窗 24h 共 3 筆 `Embedded agent failed`，無新增）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【高】heartbeat 的 600s timeout 是定時炸彈**（11-24 08:21 ＋ 21:11 兩次實證；近失已累計 4 次：本輪 298.9s、上輪 375.4s/281.6s、108.4s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【高】`heartbeat-flaaffy` everyMs 放大 1000 倍 → 從未執行過，下次 2027-02-03**。修法＝everyMs 改回 1,800,000 ＋ anchor 重新對齊。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【高】dreaming 的 event-loop 凍結會連帶殺死整個 heartbeat fleet**（11-24 04:27–08:11：6 支 × 12 輪 600s 硬死）。三選一：① dreaming 錯開整點；② heartbeat timeoutSeconds 拉高 >1200s；③ dreaming 加 RSS 護欄。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【急】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）、本 job fallback 鏈實質冗餘＝0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【急】KA anchor 拉開 ≥15 分鐘** → 本輪第 **26** 次疊窗，且** picturecat↔celesteela 仍差 6ms**（gengar 已自然錯開 14.1s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中】minimax-portal 額度池**（24h 16 筆 429、quota 型 0、全部 busy 型；時戳幾乎全在整點後 1–11 分；**03:00 / 07:00 / 23:00 三槽近 5 天各撞 3–4 次**）→ 錯開整點 job 密度，或補一組真的有憑證的第二廠商。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【中】self-heal 的 04 整點空窗**（dreaming 期間 Discord 無救援；本輪再次確認 04:13/04:43 天然不跑）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12. **【中】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 本窗 canonical 0 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13. **【中】17 支 skill 缺 description**（≈256 次/日 skip；第 24 輪未修）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14. **【中】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
15. **【中】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉重啟迴圈；需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
16. **【中】每日論文討論 07:00 槽近 5 天 4 次首輪 error**＋Jormungand 03:00 槽近 5 天 4 次首輪 error ＋**每日模型排行前十 23:00 槽連死 2 次** → 整體改為「錯開整點槽密度」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
17. **【降級】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
18. **【中】巡檢方法論**：`cron runs --id` 的 `ts` 是 epoch ms、**顯示務必用 `tsIso`**（本輪發現還有 `runAtIso`＝起跑時間、`durationMs`、`deliveryStatus`）；job id 必須用**完整 UUID**，短 id 會**安靜回 tot=0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 下一輪（11-25 04:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **11-25 04:25 dreaming 是否仍完整活下來（連續第 3 次）** → 04:02 輪只能確認排程未動＋self-heal 04 整點仍排除；**驗收要等 07:02 輪**（比對 04:27–04:57 的 READY-fail 筆數 vs 基準表 26 筆/48h）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **heartbeat-rowlet 的「skipped 但 298.9s」是否再現** → 若 03:0x/04:0x 又出現 >250s 的 skipped，則待決事項 #5（600s 炸彈）要升到最高優先。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **03:00 槽的 Jormungand 首輪是否再 error**（近 5 天 4 次）＋ **07:00 槽每日論文討論**（近 5 天 4 次）→ 確認「整點槽密度」假設。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **23:00 槽的新形態「同槽 3 次嘗試」是否在其他槽重現**（首輪 error → 再 error → 隔 7 分鐘才 ok）→ 若普遍化，429 的「重試節奏」本身也要進 payload。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **`heartbeat-flaaffy` 是否仍 0 entries**（next 應仍是 2027-02-03，未經點頭不修）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **Discord 乾淨段是否突破 24h**（本輪 20h08m，自 11-24 04:55:41 起算；04:25 dreaming 窗若重演會把計時歸零）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-25 04:02 — Picturecat Keep-Alive 第 2 輪：🟡 lane PASS、⭐⭐⭐ **「cron runner 全域序列化」機制首次被完整證實（3 個獨立實例、時間戳精確對齊）**、⭐⭐ **本 job 上一輪 797.3s 就是兇手，直接把兩個 heartbeat 拖到 431.2s / 163.8s（600s 預算的 71.9%）**、⭐⭐ **「DNS／All models failed 那 223 行」是每整點的 cron 狀態表轉儲＝假訊號，canonical DNS 事件其實是 0**、⭐ **03:00 / 23:00 槽首輪全死＝連 3 天**、Discord **連續 23h09m 零症狀** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → status=ok、回覆「**LANE_OK_PICTURECAT_0402 = 6** — (a) 無 active task, (b) 01:00–04:00 無 error／provider 429, (c) Discord inbound 正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**11-25 01:02:18 → 01:15:35，dur=797,261ms**）→ **本 job 歷史最長一輪**（前 11 輪：392/391/171/139/173/145/359/431/797/21.6s…）→ **本輪主事件就是我自己造成的**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job 上一輪亦全綠：**Gengar KA 01:10:46 ok/522,302ms**、**Celesteela KA 01:04:51 ok/152,763ms** → 三支 KA 全綠但都很長。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 27 次**：gengar next `1795550524215`＝**04:02:04.215** → picturecat `1795550538357`＝**04:02:18.357**（Δ14,142ms）→ celesteela `1795550538362`＝**04:02:18.362**（Δ**5ms**）→ picturecat↔celesteela 仍實質同時。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（沿用）：restricted automation-run session 內 `automations` 視角不可用；cron 真相一律 `openclaw cron list --all --json` ＋ `openclaw cron runs --id <完整 UUID>`（短 id 安靜回 tot=0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ 本輪主事件 A：**cron runner「全域序列化」機制被完整證實**（解掉上輪的「兩說並存」） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **新事實**：`cron runs` 的 `tsIso` 是**結束時刻**（不是起跑時刻）；所以「dur + tsIso」才推得出真正起跑點。上輪未釐清這點，導致因果鏈一直對不上。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **今天 01:02:18–01:15:35（本 job 797.3s 在跑）**：
  - `heartbeat-rowlet` 排程 **01:08:24** → 結束 **01:15:35.684**，dur=**431,168ms**（＝600s 預算的 **71.9%**，史上最大近失）。
  - `heartbeat-celesteela` 排程 **01:12:52** → 結束 **01:15:35.684**，dur=**163,784ms**。
  - **兩支在同一毫秒 01:15:35.684 被釋放**（＝本 job 的 `tsIso` 01:15:35.618 + 66ms）→ 被拖住的不是 heartbeat 自己，是「前一個 in-flight job」。
  - **對照組**：同窗其他 heartbeat 槽（greninja :24/:54、picturecat :26/:56、roaringmoon :26/:56、charizard :25/:55、gengar :00/:30、mrmime :01/:31）dur 全是 **259–268ms** → **凡槽位落在 KA 窗內者才被拖**，落在窗外者毫秒退場 → 機制無歧義。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **歷史實例 2（11-23 16:00–16:30）**：gengar KA `9d8b6001` 跑 16:02:04→16:15:46（**822,130ms**）→ `heartbeat-celesteela`（16:12:45 排程）等 **181,300ms**，於 **16:15:46.734** 釋放（＝KA 結束後 **426ms**）→ 同窗 `heartbeat-rowlet`（16:08:22）**error 600,032ms**、`heartbeat-mrmime`（16:01:07）**error 600,004ms** → **一支 822s 的 KA，20 分鐘內打死 2 支、拖住 1 支**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **歷史實例 3（11-24 07:02–07:12）**：三支 KA 同窗（gengar 539.3s / celesteela 614.8s / 本 job 170.7s）→ `heartbeat-rowlet`（07:08:19 排程）→ 07:15:23 ok，dur=**423,953ms**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **結論（可寫入 long-term）**：cron runner 是**全域序列化**——任何 in-flight job 期間排到的新 job 一律排隊，in-flight job 結束的那一毫秒整批釋放。heartbeat 被拖過 **600s 預算 → `cron: job execution timed out`（`retryCategory=timeout`、backoff 30s→60s）**。上輪列出的 600s 硬死（11-23 16:11/16:18、11-24 08:11/08:18/08:21）**全部是這個機制，不是 heartbeat 自己慢** → 「heartbeat-mrmime 每 2 小時死一次」假說徹底作廢（死因是「當時有沒有長 job」，與週期無關）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ 本輪主事件 B：**最小風險修法已量化**（唯一槓桿＝縮短 KA 自己的時長） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **8 支 heartbeat 的槽位覆蓋每一分鐘**：rowlet :08/:38、celesteela :12/:42、greninja :24/:54、picturecat :26/:56、roaringmoon :26/:56、charizard :25/:55、gengar :00/:30、mrmime :01/:31 → **沒有任何 anchor 是安全的**，移槽救不了。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **量化**：stall ≈ (KA 結束時刻 − heartbeat 槽位時刻)。KA 從 :02:18 起跑 → **duration ≤ 300s（結束 ≤ :07:18）即可讓下一個 :08:24 槽完全不受影響（stall = 0）**；duration > 370s 必咬到下一槽。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 現況 duration 分佈：本 job 近 11 輪 **138–797s**、gengar **215–822s**、celesteela **152–615s** → **每一輪都可能咬到 heartbeat**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **建議（待 Linder 點頭，本輪無法自動執行）**：三支 KA 各加 `timeoutSeconds: 300`（或把巡檢深度壓到 ≤300s）→ stall 由「最高 431s」降到 0。**受限的 automation-run session 只能 self status/list/get/runs/remove，無法 update job**（故本輪只提案不動手）。備援第二順位：heartbeat timeoutSeconds 600 → 900（治標）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐⭐ 本輪主事件 C：**「DNS／All models failed 那 223 行」是假訊號——每整點 :04–:05 的 cron 狀態表轉儲** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗 grep `DNS lookup|All models failed` 命中 **223 行**，但時間戳只集中在 **01:04 / 01:05 / 02:04 / 03:05** 四點（44+88+44+88），且內容涵蓋 **37 支 job**（含 07:00 槽的 45ccf4e9 / 88810bfe / 89e2cfe7）→ 是**狀態表快照**（每 job 的最後錯誤文字），不是事件流。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **判別法**：① 看 `_meta.date`（UTC）＝ flush 時刻 → 現在；② 表內同時含「當時真的」錯誤（40e09cd1 的 rate-limit，與 03:01 實測對得上）與「11-24 早上的舊 DNS 文字」→ 只有 **in-flight 的 job** 是當下事件。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **canonical 數字**：provider-transport 內的 DNS 失敗 **3h = 0、24h = 0** → **DNS 根因（enp43s0 無 DNS scope）在量測窗內沒有真的發作**；上輪記的「223 行級別的 DNS 症狀」不可再當事故引用。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **但 01:04:56 那一波是真的**：所有 in-flight cron（02eb/9d8b/880b/ca22/13ac/b371…）都吃到 `getaddrinfo EAI_AGAIN api.minimax.io` → 靠 fallback 鏈救回（receipts 全 ok）→ **這也是本 job 跑到 797s 的原因之一**。即時測試 `getent hosts api.minimax.io` 正常（systemd-resolved 127.0.0.53）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) fleet：53 jobs / 46 enabled / 7 disabled — **ok 39 / skipped 5 / error 1 / none 1**（enabled 側），disabled 側 ok 6 / error 1（與上輪同形狀） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 非 ok：`c5352a84 skill-collection-review-roaringmoon` error/ce=1（11-19 DNS 舊因，next **11-26**）；**`6e93c179 heartbeat-flaaffy` status=None（從未跑）**、`cron runs` tot=0、next 仍 **1801634183940＝2027-02-03**、`everyMs=35,996,400,000`（≈10h，**應為 3,600,000＝每小時**）→ 錯誤值未修（未經點頭不動）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled：`a94330a9 tmp-openai-probe` error/ce=2（11-19 舊因、legacy 可清）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **8 支 heartbeat 近 3h 逐支實測**：charizard 6 輪全 ok（11.6–17.1s）、gengar 6 輪全 ok（7.9–25.1s）、**mrmime 6 輪全 ok（4.6–186.7s）**、rowlet 5 skipped + **01:15 那輪 skipped dur=431,168ms**、celesteela 5 skipped + **01:15 那輪 skipped dur=163,784ms**、greninja/picturecat/roaringmoon 全 skipped（259–268ms）→ **窗內 0 筆 600s 硬死、0 筆 superseded 型死、但 2 筆近失（431s / 164s）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming `36b493db`：**schedule `25 4 * * *`（04:25）、timeoutSeconds=2400 未動、next＝2026-11-25 04:25:00** → 本輪只能確認排程未動；**驗收要等 07:02 輪**（比對 04:27–04:57 的 READY-fail 筆數 vs 基準 26 筆/48h）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- self-heal `d4cd45bc`：schedule **`13,43 0-3,5-23 * * *`** → **第 4 小時被排除 → 04:13/04:43 確實不跑**（04 整點空窗成立，dreaming 期間無 Discord 救援）。01:13→03:43 共 **6 輪全 ok、dur 741–798ms**，全為「discord healthy (no startup-not-ready) - no action」→ 守門零開火。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 其他窗內 job：`ca222989 OpenClaw 系統維護` 3 輪全 ok（32.7–86.7s）、`13ac4b5a 健康回報` 02:06 ok/50,717ms、`537bd0dd Rowlet 轉錄監控` 6 輪全 ok（1.2–1.3s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 整點槽密度假設：**3 個槽首輪全死** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand`（03:00 槽）：**11-25 03:01:47 error（rate limit）→ 03:06:20 ok** → **11-23 / 11-24 / 11-25 連 3 天首輪 error**（近 6 天 5 次）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `5b7c1082 每日模型排行前十`（23:00 槽）：11-22 / 11-23 / 11-24 **連 3 天首輪 error**（11-24 為「同槽 3 次嘗試」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `58fe15dc 每日論文討論`（07:00 槽）：11-21 / 11-22 / 11-24 首輪 error（11-23 首輪 ok）→ **今天 07:00 尚未跑，07:02 輪驗收**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d7b0355b Jormungand mrmime Codex A2A heartbeat`：00:03:07 ok/157,266ms（00:02 的 429 被 retry 吃掉）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 429：3h 窗 **1 筆**（03:01:46，elapsed=**89,808ms**），**24h = 16 筆**，quota 型 = 0 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical 定義不變：`[provider-transport-fetch] [model-fetch] … status=429`。逐時指紋仍是「整點後 1–11 分」。子型仍全為 `overloaded_error`（server is busy），`Token Plan usage limit` 24h = **0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) Discord：**連續 23h09m 零症狀**（自 11-24 04:55:41 之後） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗簽章：`did not reach READY` **0**、`channel exited` **0**、`host timing gap detect` **0**、`client initialized` **0**、`channels resolved` **0** → 零症狀。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 安靜期基線不變：`Gateway reconnect scheduled` 12、`websocket closed` 12（≈4 次/小時，全 `reconnect-opcode, resume=true` 心跳式重連）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 對照：`did not reach READY` 26、`channel exited` 13、`host timing gap detect` 6、`client initialized` 26、`channels resolved` 19 → 全部落在 11-24 04:25 dreaming 窗（**最後一筆 04:55:41**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **24h 里程碑＝11-25 04:55:41，正落在今天 dreaming 窗（04:25–04:55、timeout 2400s）尾端** → 若 dreaming 重演 READY 失敗，零症狀連續紀錄會在「連續 24h 的前幾分鐘」被歸零。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 系統面 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST`、**NRestarts=0**、MainPID 4137629、SubState=running → **連續 47h17m 未重啟**（上輪 44h15m）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `prepared model runtime plugin generation was superseded`：3h **12 筆**、24h **135 筆**（上輪 8/113 → 24h +22，競態噪音，良性）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Embedded agent failed before reply`：3h **0**、24h **3**（11-24 16:09、21:12、11-23 16:11）→ 本窗 0 新增。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **負結果也要記：skill 缺 description 實測是 9 支不是 17 支**——`~/.openclaw/skills` 57 支中 9 支無 `description:`（card-lookup / meta-analyzer / network-security-defense / prompt-injection-defense / prompt-injection-filter / ptcgp-card-download / ptcgp-card-lookup / system-design-six-dimensions-analyzer / web-fetch-troubleshooting；後者用「**描述**」全形標題，也沒被引擎認到）。其他 root（plugin-skills 2、openclaw/skills 51、custodian-skills 4、workspace-rowlet 兩個 skills root）皆 0 支。**仍未授權，不動。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ `elle.service` 停用狀態未複驗（維持待決事項 #15，需 root）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 給 Linder 的待決事項（沿用 17 項 + 新增 2 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增·最高】三支 KA job 加 `timeoutSeconds: 300`**（或把巡檢深度壓到 ≤300s）→ 這是**唯一**能讓 heartbeat stall 歸零的最小改動（心跳槽位覆蓋每一分鐘，移槽無效；KA 逾時 ≈ 從 :02:18 起算、>370s 必咬到 :08:24 槽）。本輪無法自動執行（受限 automation-run session 只能 status/list/get/runs/remove）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新增·高】把「DNS／All models failed」從症狀計數裡剔除，改以 provider-transport 內的 canonical 事件為準**（每整點 :04–:05 的狀態表轉儲會重播舊錯誤文字，會讓 DNS 假象膨脹）。另建議：巡檢腳本不要把狀態表轉儲算進 3h/24h 視窗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】600s 炸彈的真兇已定案＝cron runner 全域序列化 + 長 job**（不再是「runner hang vs 上游慢」兩說並存）；修法優先序＝先縮 KA，再考慮拉高 heartbeat timeout。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高】heartbeat-mrmime「每 2 小時死一次」假說徹底作廢**（死因＝當時有無長 job，與週期無關）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【高】429 記錄要新增第三型別 `overloaded_error`（server is busy）**，與 quota 型分開計數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【高】`prepared model runtime plugin generation was superseded` 會直接殺掉整輪 job run**（11-24 16:09 ＋ 21:12 實證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【高】整點槽密度**：03:00 / 23:00 槽已連 3 天首輪 429 error（07:00 槽待 07:02 輪確認）→ 建議錯開整點 job 密度，或補一組真有憑證的第二廠商。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決，本輪 797s 即證實其代價（見 #1）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中】self-heal 的 04 整點空窗成立**（schedule `13,43 0-3,5-23`）→ dreaming 04:25–04:55 期間無 Discord 救援。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 01:04:56 實際發生過 EAI_AGAIN burst。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【中】9 支 skill 缺 description**（上輪記 17 支，本輪實測修正為 9 支）→ 未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12. **【中】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉重啟迴圈；需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13. **【降級】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14. **【中】巡檢方法論**：`cron runs` 的 `tsIso`＝**結束時刻**（起跑點＝tsIso−durationMs）；job id 必須用完整 UUID；`automations` 視角在 restricted session 不可用。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 下一輪（11-25 07:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **今天 04:25 dreaming 是否仍完整活下來（連續第 3 次）** → 比對 04:27–04:57 的 READY-fail 筆數 vs 基準 26 筆/48h；同時看 Discord 零症狀連續是否在 04:55:41 被歸零。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **04:02 輪（本 job）是否再次拖出 400s+ 的 heartbeat stall** → 04:02:18 起跑，若 duration > 370s，heartbeat-rowlet 的 04:08:24 槽必被拖；這是 #1 提案的直接量測點。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **07:00 槽 每日論文討論 是否又首輪 error**（11-21/22/24 是）→ 補完「整點槽密度」的第三槽證據。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **23:00 槽「同槽 3 次嘗試」是否在其他槽重現**（今天 03:00 槽是 2 次嘗試：error→ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **`heartbeat-flaaffy` 是否仍 0 entries**（next 應仍是 2027-02-03、everyMs 應為 3,600,000；未經點頭不修）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **DNS burst 是否再發作**（01:04:56 那次是真事件；canonical 計數要用 provider-transport 內的 429/DNS 行）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-25 07:02 — Picturecat Keep-Alive 第 3 輪：🟡 lane PASS、⭐⭐⭐ **「600s 硬死群集」根本翻案：上輪「24h = 0 筆」是假陰性（journal 裡根本沒有 cron timeout 簽章，權威來源＝receipts）→ 本窗實測 9 筆硬死、橫跨 6 條 heartbeat lane**、⭐⭐⭐ **dreaming 窗的因果關係首次被「同毫秒起跑」直接證實（picturecat/roaringmoon 兩支 04:27:53.31/.32 起跑＝第一個 host timing gap 的同一秒）**、⭐⭐ **上輪的「最小修法＝KA 加 timeoutSeconds:300」對本窗 9 筆硬死一筆都救不了（沒有任何一筆落在 KA 窗內）**、⭐ **真兇換人＝heartbeat fleet 自我飽和（8 lane × 2 槽 × 平均 ~4 分鐘 ≈ 64–80 min/hr，逼近／超過序列化 runner 的 60 min/hr）**、dreaming **連續第 2 夜完整活下來**、Discord 零症狀連續在 04:54:40 被歸零後續 2h10m、429 3h 7 筆 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → status=ok、回覆「**LANE_OK_PICTURECAT_0702 = 6** — (a) 無 active task, (b) 06:00–07:00 無 error／provider 429, (c) Discord inbound 正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-25 04:02:18 → 04:07:25，**dur=307,031ms**）→ **比 300s 門檻多 7 秒，但 heartbeat-rowlet 的 04:08:24 槽完全沒被咬到**（KA 04:07:25 結束 < 04:08:24 槽）→ 上輪「≤300s → stall=0」的量化門檻**成立**（超過 370s 才會咬到下一槽）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：Gengar KA 04:02:04→04:06:45 ok/281,618ms；Celesteela KA 04:02:20→04:03:20 ok/60,446ms、**07:02:20→07:04:30 ok/128,915ms** → 三支 KA 全綠。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 28 次**：gengar next 07:02:04.234 → picturecat 07:02:18.397（Δ14.163s）→ celesteela 07:02:20.412（Δ**2.015s**）→ picturecat↔celesteela 仍實質同時。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ 本輪主事件 A：**「600s timeout 群集 = 0」是假陰性，方法論被推翻** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 上輪（04:02）寫「600s timeout 群集第 7 輪＝0（3h 與 6h 窗皆 0）」。**本輪用 receipts 逐支重算，24h 內至少有 9 筆硬死**——上輪用 journal grep `cron: job execution timed out` / `timed out after 600` 得到 0（本輪同樣 grep **3h=0、24h=0**），**是簽章不存在，不是症狀消失**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **新口徑（權威）**：cron 逾時**只能**從 `openclaw cron runs --id <完整UUID>` 的 receipts 讀：`cause=timeout` 且 `dur≈600005`（以及 `dur=685,882` 這種超標型）。journal 裡沒有對應簽章；用 journal 判 600s 群集＝**把「有事故」判成「零症狀」**（與 11-23 那次 `^` anchor 踩坑同一類錯誤：查錯地方）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **本窗（近 3h）9 筆硬死清單**：heartbeat-picturecat 04:39:19 (685,882ms) + 04:49:58 (607,546ms)、heartbeat-roaringmoon 04:39:19 (685,907ms) + 04:49:58 (607,576ms)、heartbeat-charizard 04:49:58 (607,562ms)、heartbeat-mrmime 05:41:04 (600,005ms)、heartbeat-rowlet 05:48:19 (600,005ms) + 06:48:20 (600,005ms)、heartbeat-celesteela 06:25:15 (600,004ms) → **6 條 lane、9 筆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐⭐ 本輪主事件 B：**dreaming 窗的因果關係首次被「同毫秒起跑」直接證實** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-picturecat` 與 `heartbeat-roaringmoon` 的 04:27:53 兩輪**起跑時刻分別是 04:27:53.312 與 04:27:53.328**，而 dreaming 窗的**第一個 `host timing gap detect` 正好是 04:27:53** → 三者同一秒＝不是巧合，是 dreaming 的 admission suspend 掐住了 runner 排程。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 兩支各等 **685,882 / 685,907ms**（>600s 預算）→ 04:39:19.194 / .235 **同毫秒釋放**並判 timeout；下一槽 04:39:50.950 / .962 又等 607,546 / 607,576ms → 04:49:58.496 / .538 同時釋放（heartbeat-charizard 也在 04:49:58.538 被釋放）→ **三支同窗同刻釋放＝序列化 flush 的指紋**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming 本輪 receipt：**04:25:00 → 04:54:53 ok / dur=1,793,022ms（29.9 分）** → **連續第 2 夜完整活下來**（11-19 ok / 11-20 interrupted / 11-21 ok / 11-22 ok / **11-23 interrupted（self-heal 造成）** / 11-24 ok 1,816,088 / **11-25 ok 1,793,022**）→ 11-23 那次自我傷害（gateway 重啟打斷）**未再重演**（gateway NRestarts=0、連續 50h16m 未重啟）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming 窗內 Discord 症狀一覽（基準表逐項對上）：READY-fail **22**、channel exited **11**、host timing gap **6**（04:27:53／04:33:29／04:39:18／04:45:12／04:48:29／04:52:49）、client initialized **24**、channels resolved **15** → **與「每日 6 次 host timing gap」的結構性基準完全一致**，非異常。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐⭐ 本輪主事件 C：**真兇換人——KA 不是本窗死因，heartbeat fleet 自我飽和才是** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ❌ **上輪結論被本窗證偽**：「600s 炸彈真兇＝長 job（KA）」→ 本窗 9 筆硬死**沒有任何一筆落在 KA 窗內**（三支 KA 只在 04:02–04:07 跑）→ **KA 加 `timeoutSeconds:300` 對本窗 9 筆一筆都救不了**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **真因有兩段**：① **04:39／04:49 段＝dreaming 造成**（已由同毫秒起跑證實）；② **05:41／05:48／06:25／06:48 段＝非 dreaming、非 KA**——該時窗所有常駐 cron 都很短（系統維護 70–105s、健康回報 41–51s、轉錄監控 1.2s）→ 佔用者**不是 cron job**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **量化候選＝heartbeat fleet 自我飽和**：8 條 lane × 每小時 2 槽 = **16 次/小時**；實測每次佔用 runner **200–600s**（rowlet 217s／celesteela 358–581s／mrmime 191–556s／charizard 140–416s／picturecat 124–344s／greninja 67s／roaringmoon 84–326s）→ **≈ 64–80 min/hr，逼近或超過序列化 runner 的 60 min/hr** → 隊列必然積出 600s 長尾。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **釋放指紋支持同一結論**：06:31:44.496 同一毫秒釋放 greninja(:24:57 起)、picturecat(:26:00 起)、celesteela(:25:41 起)、roaringmoon(:26:18 起，.930) 四支 → **前一支持有者把隊列整批放掉**；而持有者本身就是一條 heartbeat lane（charizard 06:25:01→06:31:57 dur=415,999ms 佔住 runner）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **修法排序（更新，待 Linder 點頭；本輪受限 session 只能 status/list/get/runs/remove，改不了 job）**：**(a) 治本**＝heartbeat 降頻或縮範圍（16 次/小時 → 8 次/小時，直接砍掉飽和度）；**(b) 治標**＝heartbeat `timeoutSeconds` 600 → 900（吸收飽和長尾）；**(c) 去序列化**＝讓不同 lane 的 heartbeat 不共用單一 runner（架構級，工作量最大）；**(d) dreaming 窗**＝拉高 Discord READY 握手上限 ≥300s（既有提案，未動）；**(e) KA `timeoutSeconds:300`**——仍值得做，但只解決 01:02 類的 KA 窗 stall，**不是本窗死因**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) fleet：53 jobs / 46 enabled / 7 disabled — **ok 39 / skipped 5 / error 1 / none 1**（enabled 側），disabled 側 ok 6 / error 1（與上輪同形狀） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 非 ok：`c5352a84 skill-collection-review-roaringmoon` error/ce=1（11-19 DNS 舊因，next **11-27 03:56**）；**`6e93c179 heartbeat-flaaffy` 仍 0 entries**（next 仍 **2027-02-03 13:56**、`everyMs=35,996,400,000`≈10h，應為 3,600,000）→ **第 11 輪未修，未經點頭不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled：`a94330a9 tmp-openai-probe` error/ce=2（11-19 舊因、legacy 可清）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **8 支 heartbeat 近 3h 逐支實測（receipts）**：硬死 9 筆（見 §2）、近失多筆（celesteela 541,014／581,588ms、rowlet 384,153ms、mrmime 556,398ms、charizard 415,999ms）、瞬退 ~260ms 的那些才是真正沒排到隊的。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- self-heal `d4cd45bc`：05:13／05:43／06:13／06:43 **4 輪全 ok（741–798ms）** → 守門零開火（Discord 靠 gateway 內建機制於 04:58 自癒）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 其他：`ca222989 OpenClaw 系統維護` 6 輪全 ok（28–105s）、`537bd0dd Rowlet 轉錄監控` 全 ok（1.16–1.24s）、`13ac4b5a 健康回報` 全 ok（41–51s）、`d7b0355b Jormungand mrmime Codex A2A` 06:00:30 ok/323,396ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 整點槽密度假設：**三槽全部複現「首輪死、靠重試救回」** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand`（03:00 槽）：03:01:47 error(rate_limit) → 03:06:20 ok → **連 4 天首輪 error**（11-22 ok / 11-23 / 11-24 / 11-25 error，11-22 前一天正常）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `58fe15dc 每日論文討論`（07:00 槽）：11-21／11-22／11-24 **首輪 error(rate_limit)** → 重試 ok（11-24：07:03:28 error → 07:12:06 ok）→ **07:00 槽首輪必死的第 3 個證據齊了**；11-25 07:00 輪在取樣時段仍在 in-flight（07:00 起跑、07:12 才有 receipt，與 11-24 同一形狀）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `5b7c1082 每日模型排行前十`（23:00 槽）：11-24 是 **同槽 3 次嘗試**（23:01:19 error → 23:03:39 error → 23:13:21 ok）→ **「同槽 N 次嘗試」是通用現象**：03:00 槽 2 次、07:00 槽 2 次、23:00 槽 3 次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `88810bfe BBC News` 07:00 輪 **首輪即 ok**（07:03:37 / 217,387ms）→ 同一小時內不同 job 命運不同（看 provider 併發時序，不是槽位本身）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 429：3h 窗 **7 筆**、**24h = 17 筆**，quota 型仍為 **0** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical 定義不變：`[provider-transport-fetch] [model-fetch] … status=429`。本窗時戳：**05:02:13 / 05:32:45 / 06:02:21 / 06:31:44 / 07:01:04 / 07:02:28 / 07:03:28** → 仍是「整點後 1–3 分」指紋，且 **07:00 槽一次撞三筆**（07:01/07:02/07:03）＝併發尖峰而非配額。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Token Plan usage limit`（真配額）3h = 0、24h = 0 → **連續多輪零配額窗**。子型仍為 `overloaded_error`（server is busy）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **canonical DNS（本窗 0）**：provider-transport 內 `EAI_AGAIN|getaddrinfo|DNS lookup` **3h = 0、24h = 0** → 01:04:56 那次的 DNS burst **未再發作**；且「DNS／All models failed」狀態表轉儲假訊號問題依舊（未改口徑前不要引用該數字）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) Discord：零症狀連續被**歸零後續 2h10m** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗簽章：`did not reach READY` **22**、`channel exited` **11**、`host timing gap detect` **6**、`client initialized` **24**、`channels resolved` **15** → **全部落在 dreaming 04:27–04:54 窗**，且 24h 數字與 3h 相同（24h 內其他時間段全乾淨）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 最後一筆症狀 **11-25 04:54:40**（READY-fail 最後 04:48:29、channel exit 04:54:40）→ 07:02 時點**連續 ≈ 2h08m 零症狀**（上輪的 23h09m 紀錄在 04:54:40 歸零，與上輪預警一致）。恢復路徑：`client initialized` 一路到 **04:58:27** → 自癒完成。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 安靜期基線：`Gateway reconnect scheduled` 3h 62、24h 145；`websocket closed` 3h 80、24h 176（全屬 `reconnect-opcode, resume=true` 心跳式重連，非掉線）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 系統面：全綠 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：`ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST`、**NRestarts=0**、MainPID 4137629、SubState=running → **連續 50h16m 未重啟**（上輪 47h17m）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `prepared model runtime plugin generation was superseded`：3h **8**、24h **113**（上輪 12/135 → 略降，良性噪音）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Embedded agent failed before reply`：3h **0**、24h **3**（11-24 16:09、21:12、11-23 16:11）→ 本窗 0 新增。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **skill 缺 description 實測回到 17 支**：3h 窗 **1,003 行**（`description is required` 767 + `invalid`/BAD_INDENT 236）、**唯一 17 檔**、每檔每 3h **59 次**（≈472 次/日/檔）→ 上輪「9 支」是**只數 `~/.openclaw/skills`** 的口徑，rosclaw plugin 4 支＋BAD_INDENT 4 支沒算進去；**正確集合是 17 支**，驗證＝看它們不在 `<available_skills>` 清單裡。**仍未授權，不動。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 系統：up 44 天、load 0.85、磁碟 61%（269G/468G）、RAM 9G/31G（buff/cache 21G）→ 全綠。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 給 Linder 的待決事項（沿用 17 項，重排優先序；新增 3 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增·最高】600s 硬死的量測口徑改掉：改用 receipts（`cron runs` 的 `cause=timeout` + `dur≈600005`），不要再用 journal grep**——否則會持續把 9 筆硬死判成 0 筆。這條是**方法論修正**，優先於任何修法。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新增·最高】heartbeat fleet 飽和是本窗 9 筆硬死的主要候選真因**（16 次/小時 × 200–600s ≈ 64–80 min/hr > 60 min/hr 的序列化 runner）→ 建議 **(a) heartbeat 降頻/縮範圍**（治本）＋ **(b) heartbeat timeout 600→900**（吸收長尾）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【新增·高】上輪的「KA `timeoutSeconds:300` 是唯一槓桿」已證偽**（本窗 9 筆硬死沒有一筆在 KA 窗內）→ 該提案**降級為「只解決 01:02 類 KA 窗 stall」**，不再是萬靈丹。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高】整點槽密度**：03:00／07:00／23:00 三槽全部「首輪死、靠重試救回」＝連 4 天 → 建議錯開整點 job 密度，或補一組**真有憑證**的第二廠商（現在 4 個 fallback 全 MiniMax，跨廠冗餘 0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【高】429 記錄要新增第三型別 `overloaded_error`（server is busy）**，與 quota 型分開計數（今日 quota 型仍 0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【高】`prepared model runtime plugin generation was superseded` 會直接殺掉整輪 job run**（11-24 16:09 ＋ 21:12 實證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中】dreaming 窗的 Discord READY 握手上限拉高到 ≥300s**（既有提案，未動；今日窗已證實 6 次 host timing gap ＝結構性基準）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中】self-heal 的 04 整點空窗成立**（schedule `13,43 0-3,5-23`）→ dreaming 期間無 Discord 救援（今日靠內建機制自癒）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決（本輪實測 dur 307s / 標竿 21.6–797s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中】DNS 根因未除**（enp43s0 無 DNS scope）→ 本窗 canonical DNS = 0，暫未發作。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【中】17 支 skill 缺 description**（上輪誤記 9 支）→ 未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12. **【中】`elle.service` 停用** → 消掉重啟迴圈；需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13. **【降級】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14. **【中】巡檢方法論**：`cron runs` 的 `tsIso`＝**結束時刻**（起跑點＝tsIso−durationMs）；job id 必須用完整 UUID；`automations` 視角在 restricted session 不可用。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 下一輪（11-25 10:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **heartbeat 硬死有沒有繼續** → 用 receipts 逐支列 8 條 lane 的 06:00–10:00 全部 dur，**特別看有沒有 >600s**；若 05:41–06:48 那四筆沒有同型重現，飽和假說要再量化（看每 lane 每小時的實際佔用秒數）。
2. **本 job（07:02 輪）的 dur** → 若 >370s 就會咬到 heartbeat-rowlet 的 07:38 槽；建議量完自己這輪的 dur 再寫進報告（**本輪實際 dur 見 receipt，本報告寫完時已知**）。
3. **07:00 槽 `每日論文討論` 的 11-25 結果**（本輪取樣時仍 in-flight）→ 是否又是「首輪 error → 重試 ok」。
4. **Discord 零症狀連續**（04:54:40 起算）→ 確認 10:02 時點是否仍乾淨（若 dreaming 明天沒有別的影響，應可續到 ~28h）。
5. **429 逐時** → 記錄 07:00–10:00 的 canonical 429 筆數與 quota 型是否仍為 0（連續第幾輪零配額）。
6. **`heartbeat-flaaffy` 是否仍 0 entries**（next 應仍是 2027-02-03、everyMs 應為 3,600,000；未經點頭不修）。
7. **KA anchor 疊窗** → 10:02 槽 picturecat↔celesteela 的 Δ 是否仍 <3 秒（若仍如此，疊窗第 29 次 → 建議 Linder 點頭拉開）。

### 12) 本輪自證：本 job 自己的 dur 與自我造成的 stall（07:10:55 收尾快照） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪（07:02:18 起跑 → 07:10:55 收尾）**已用 ≈ 517s**，**遠超 300s 目標** → 依上輪量化，KA >370s 必咬下一槽：**heartbeat-rowlet 的 07:08:24 槽在 07:10:55 快照時仍無 receipt（被本輪佔住）** → **本輪自己就是一份「長 job 拖死 heartbeat」的活體證據**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **實務修正（給下一輪）**：巡檢深度必須自我設限 **≤300s**；超過就把剩餘檢查丟到下一輪（例如 §6 的整點槽細節、§2 的 lane 清單可拆輪）。否則每一輪 KA 都在製造它自己正在調查的病。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `每日論文討論` 11-25 07:00 輪在 07:10:55 仍**無 receipt**（in-flight，與 11-24「07:03 首輪 error → 07:12 重試 ok」同一形狀）→ **下一輪驗收**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-25 13:02 — Picturecat Keep-Alive 第 4 輪：🔴 **08:00 槽 600s 硬死群集重現（7 筆 dur=600,003/600,004ms）＝飽和假說第 2 次被實測支持（08:00 槽佔用 10,706 lane-s ＝ heartbeat 槽容量的 112%）**、⭐⭐⭐ **09:00 起 MiniMax 配額牆（quota 型 429）大爆發且持續 4 小時 → `OpenClaw 系統維護` 連死 7 次、`健康回報` 連死 4 次、KA 三姊妹相繼倒地（跨廠冗餘 0 的直接後果）**、⭐⭐ **新型別失效：openai auth order 解析失敗 → 本 job 10:02 輪在派發期 12ms 秒死（不是 429）**、⭐ **Discord 零症狀連續在 06:40:16 被歸零（最新起點 12:53:01）**、⭐ **「越壞越快＝越安靜」：10:00–12:00 lane 佔用率掉到 1%，fleet 狀態表反而變綠** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：🔴 上輪（10:02）整輪死亡，本輪 13:02 起跑 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **10:02:19 輪 → error，dur 2.3s**，根因＝`Explicit auth order for openai has no usable profiles.`（**不是** 429；見 §4）→ `state.consecutiveErrors=1`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **10:02 那輪沒有寫出報告**（本檔 mtime 停在 07:11）→ **死亡輪不留紀錄**，這是本輪第一次出現的「巡檢連續性缺口」；連續性只能靠 receipts 回推。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 07:02 輪 → ok 但 **dur 551,558ms（9.2 分鐘）**，遠超 300s 自我上限 → **上輪自己就是「長 job 拖死 heartbeat」的活體證據，這輪又跑一次**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ 主事件 A：**600s 硬死群集第 2 次重現，這次是 08:00 槽；飽和假說第 2 次被實測支持** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipts 實測（`openclaw cron runs --id <uuid>`，8 條 heartbeat lane，窗 06:30–13:05）：**≥300s 的硬死 17 筆** → hb-rowlet 5、hb-mrmime 5、hb-celesteela 4、hb-charizard 1、hb-greninja 1、hb-picturecat 1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 其中 **dur = 600,003 / 600,004ms 的 7 筆**（hb-rowlet ×3 @08:18:52/08:38:20/08:48:51、hb-mrmime ×3 @08:11:37/08:22:38/08:37:39、hb-celesteela ×1 @08:42:45），error 摘要一律＝`cron: job execution timed out`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **量化（上輪 §11 要求的「每 lane 每小時實際佔用秒數」）**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 08:00 槽：**10,706 lane-s（26 runs）**＝ 8 lane × 2 槽 × 600s 上限（9,600）的 **112%** → **過載 12%，硬死群集就在這裡**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 06:00 槽 4,063 lane-s（42%）、07:00 槽 2,365 lane-s（25%）→ 這兩槽沒死；**只有 08:00 槽跨過 100% 才爆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 09:00 之後全部掉到 1–4%（見 §3，配額牆讓大家 2–5s 就死）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **第二種長 dur 型別（非 timeout）**：`heartbeat skipped: no-route` 但 dur 347–510s（hb-celesteela 509.5s @08:23:19、hb-greninja 410.5s @08:24:58、hb-picturecat 347.5s @08:26:01、hb-celesteela 389.7s @08:53:16）→ **heartbeat 在「決定沒有 route」之前會先阻塞 5–8 分鐘**＝隱性佔用，狀態表看起來只是 skipped。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐⭐ 主事件 B：**09:00 起 MiniMax 配額牆（quota 型 429）大爆發、連續 4 小時未退** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 逐時 429（journal，`--since 06:30`）：06→2 / 07→11 / 08→8 / **09→66 / 10→91 / 11→63 / 12→75**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 其中 **quota 型（`Token Plan usage limit reached` / code 2056）＝ 09:00 起才出現**：09→43 / 10→66 / 11→47 / 12→55 → **前三輪巡檢都報「quota 型仍為 0」，本輪直接翻成主因**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **第三型 `overloaded_error` 本窗自然出現 9 筆**（06:1 / 07:3 / 08:2 / 09:2 / 12:1）→ 上輪待辦「429 要新增第三型別」不用再加機制，log 已經會出。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 受害者（receipts 實測）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `OpenClaw 系統維護`（每小時）→ **連續 7 死**（09:04 → 12:04，每次 2–5s），**最後一次成功是 08:04** → 這個每小時巡檢已連續 ~4 小時全盲。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `健康回報` → 連死 4 次（11:05:20 / 11:05:52 / 11:06:56 / 11:12:04），最後一次成功 08:05（dur **1,398.6s**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `Celesteela KA` 10:02 死（4.5s，4 模型全 429）；`Gengar KA` 10:02 / 10:03 / 10:08 連死 3 次 → **13:02 才回 ok（31.7s）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **根因機制（跨廠冗餘 0 的直接後果）**：rowlet/各 agent 的 fallback 鏈 4 個全是 MiniMax 系列（`minimax-portal/MiniMax-M3`、`minimax/MiniMax-M3`、`minimax-portal/MiniMax-M2.7`）→ **配額一耗盡，fallback 只是換個名字再死一次**；Gengar 13:02 能回 ok 是配額短暫鬆綁，不是結構修好。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「越壞越快＝越安靜」**：10:00–12:00 的 lane 佔用率只有 1%（因為每個 job 2–5s 就死）→ **fleet 狀態表在配額牆期間看起來比健康時更安靜**。本輪再次驗證「fleet 狀態會藏起整輪死亡」——`consecutiveErrors` 與 `lastStatus` 都不能單獨當綠燈。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐⭐ 主事件 C：**新型別失效——openai auth order 解析失敗，lane 在派發期 12ms 秒死** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 原文：`2026-11-25T10:02:21.644+08:00 [diagnostic] lane task error: lane=cron-nested durationMs=12 error="Explicit auth order for openai has no usable profiles."`（同一毫秒另有 `lane=session:agent:rowlet:cron:02eb0989-...`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 判讀：rowlet 的 `agents.defaults.models` 裡有 `openai/gpt-5.3-codex`、`openai/gpt-5.5`、`openai/gpt-5.4-mini`…，但**當下 openai 沒有 usable profile** → 派發階段就死，**模型完全沒被呼叫**（與 429 是不同層級的失效）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **同槽姊妹 job 不同症狀**：Picturecat KA 10:02:19 → openai auth order 錯（2.3s）；Celesteela KA 10:02:23 → quota 429（4.5s）；Gengar KA 10:02:05 → quota 429（4.5s）→ **10:02 槽是三姊妹同時段、不同死因的一輪**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 待查（未經點頭不動）：openai profile 是被 quota／登出／到期影響，還是 auth order 寫法在某時段解析不到 profile → 影響任何需要跨廠 fallback 的 job。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ⭐ 主事件 D：**Discord 零症狀連續被歸零** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `06:40:16` → `[discord] gateway: Gateway reconnect scheduled in 2000ms (reconnect-opcode, resume=true)` → **上一輪（07:02）記的「自 04:54:40 起零症狀」在 06:40 就斷了**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `12:50:43` → `close, resume=false`；`12:52:34`、`12:53:01` → 兩次 `reconnect-opcode, resume=true`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **本輪可宣稱的零症狀起點＝12:53:01（本輪收尾時僅 ~11 分鐘）**，不是「連續 20h+」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) lane 佔用率表（receipts 實測，06:30–13:05，8 條 heartbeat lane） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| lane | runs | Σ dur | ≥300s 硬死 |
|---|---|---|---|
| hb-rowlet | 18 | 3,493.3s | 5 |
| hb-mrmime | 17 | 3,128.9s | 5 |
| hb-celesteela | 15 | 2,319.2s | 4 |
| hb-charizard | 13 | 731.9s | 1 |
| hb-greninja | 13 | 702.1s | 1 |
| hb-picturecat | 13 | 574.2s | 1 |
| hb-roaringmoon | 13 | 261.4s | 0 |
| hb-gengar | 13 | 194.9s | 0 |
| **合計** | 115 | **11,406.0s** | **17** |
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 其他 job 實測（窗內） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `每日論文討論` 07:00 → **ok 762.2s**（12.7 分鐘）→ 上輪觀察的「首輪死、靠重試救回」**今天沒有發生**，算正常。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `健康回報` 08:05 → ok 但 **1,398.6s**（23.3 分鐘）→ 這一筆單獨就吃掉 08:00 槽 15% 的 heartbeat 容量，是 08:00 槽過載的幫兇之一。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 08:00 槽的其他長 job（fleet 層，不在 heartbeat lane 內）：`每日資安建議` 770.7s、`每日模型排行前十` 522.4s、`PTCGP Meta` 577.6s → **08:00 槽是「長 job + heartbeat」雙重擠壓**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-flaaffy`：`everyMs=35,996,400,000`（≈416 天）、next ＝ **2027-02-03 05:56**、entries 0 → next 符合上輪預期，但**上輪寫的「everyMs 應為 3,600,000」本身就是錯的**（實測就是近一年）；未經點頭不修。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) ANCHOR 疊窗（picturecat↔celesteela） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 picturecat 13:02:19 起跑、celesteela next 13:02:23（**Δ 4s**）、Gengar 13:02:02（Δ 17s）→ **本輪只要跑超過 4 秒就已經和 celesteela 同時在跑**；疊窗累計第 30 次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 若本輪 dur 再破 300s（= 5 分鐘），就會直接咬掉 celesteela 的整輪 → **這是「KA 自己製造自己正在調查的病」的第 2 次機會**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（沿用 17 項，重排；新增 3 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高·新】MiniMax 配額牆 09:00–13:00 連續 4 小時** → 需要「配額用量可視化／提前告警」或**第二廠商 fallback**（現在 4 個 fallback 全 MiniMax，跨廠冗餘 0）。這是本輪唯一「正在持續造成 production 損失」的問題（`OpenClaw 系統維護` 已連死 7 次＝4 小時巡檢全盲）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【最高】08:00 槽飽和已證實（112%）→ 治本＝把 08:00 槽的長 job 錯開**（`健康回報` 1,398.6s、`每日資安建議` 770.7s、`每日模型排行前十` 522.4s、`PTCGP Meta` 577.6s、`每日論文討論` 762.2s 全擠 07:00–08:00）；治標＝heartbeat timeout 600→900s 吸收長尾。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高·新】`Explicit auth order for openai has no usable profiles.` 的處置**（新失效型別，派發期秒死、模型沒被呼叫）→ 需查 profile 有效期／auth order 寫法；在此之前，rowlet 的 `defaults.models` 內含 openai 條目＝隨時可能再炸一次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高】KA 三姊妹（picturecat/celesteela/gengar）10:02 槽同時段三種死因** → fallback 鏈與 auth order 都不可靠，KA 的「存活確認」在配額牆期間會失真。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【高】heartbeat「no-route 前阻塞 5–8 分鐘」型別**（4 筆 347–510s）→ 這是隱性佔用，狀態表只顯示 skipped；建議把 no-route 判定加上時間上限。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中】死亡輪不留報告**（10:02 那輪 error 2.3s 沒寫檔）→ 巡檢連續性只能靠 receipts 回推；建議 KA 改成「先寫 report 骨架、結束再補」或由 receipts 自動產生條目。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中】`OpenClaw 系統維護` 每小時 job 已連死 7 次** → 它本身就是監控機制，監控死掉＝監控失效；建議它走不同模型或不同排程窗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中】KA anchor 疊窗 Δ=4s（第 30 次）** → 建議把 celesteela 的 anchor 拉開 ≥10 分鐘，或兩支 KA 合併成一輪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中】`每日論文討論` 07:00 本日正常（ok 762.2s）**，前兩天的「首輪死、重試救回」型別本輪未出現 → 維持觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中】`elle.service` 停用、DNS root cause、17 支 skill 缺 description、筆電端 SSH automation 只觀察** → 沿用既有待決，本輪無新證據，不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【方法論】本輪再次驗證兩件事**：① 硬死一定要讀 receipts（`cron runs --id`，鍵是 `entries[]`，`ts` 為結束時刻）；② **fleet 狀態表在「快速失敗期」會主動偽裝成健康**（佔用率 1% ≠ 沒事）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 下一輪（11-25 16:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **配額牆退了嗎** → 讀 13:00–16:00 的 quota 型 429 筆數（journal `Token Plan usage limit reached`）；若仍 >0，`OpenClaw 系統維護` 應該會在 13:04 那輪死亡 → **以它的 receipts 當探針**。
2. **08:00 槽的 7 筆 600s 硬死會不會在 16:00 槽重現** → 若 16:00 槽也有長 job 擠壓（`每日備份` 132.9s 等），重點看 lane 佔用率是否又破 100%。
3. **openai auth order 錯誤會不會再出現** → 搜 13:00–16:00 的 `no usable profiles`。
4. **Discord 零症狀起點** → 目前是 12:53:01，16:02 時若仍乾淨則 ≈3h09m。
5. **本輪（13:02）的 dur** → 若 >300s 就算再一次自我製造 stall（見 §11）。
6. **`每日模型排行前十` 23:00 槽 / `每日論文討論` 07:00 槽**在配額牆下的表現（首輪死？重試救回？）。

### 11) 本輪自證：本 job 自己的 dur 與自我造成的 stall <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 13:02:19 起跑 → **報告寫完 ≈13:05，實際 dur ≈ 160s**（**在 300s 自我上限內** ✅，本輪沒有自我製造 stall）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對照：上一輪 07:02 輪 dur **551.6s**（超標、拖到別人）、10:02 輪 dur 2.3s（秒死、什麼都沒做）→ **同一支 job 在 6 小時內經歷「長到拖死別人」與「秒死」兩種極端**，原因不是 job 本身，而是**上游配額與 lane 飽和**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **實務修正（沿用上輪）**：巡檢深度自我設限 **≤300s**；本輪用「一次批次拉 8 條 heartbeat lane receipts ＋ 5 支重點 job receipts ＋ journal 一次掃描」共 6 次 exec 就完成，**證明 300s 內做得到** → 下一輪沿用同樣的批次策略（勿逐 lane 開迴圈重複 `cron runs`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-25 16:02 — Picturecat Keep-Alive 第 5 輪：🟢 **MiniMax 配額牆 12:09:37 退場、13:00–16:05 窗 429＝0**、⭐⭐⭐ **飽和假說第 3 次被實測支持（反向證據）**：08:00 槽 112% → 7 筆 600s 硬死，本窗 8 條 heartbeat lane Σdur 僅 **231.0s（0.6%）**、**≥300s = 0、600s 硬死 = 0**、⭐⭐ **新發現「state 與 receipts 不同步」＝ receipts 有成功筆（15:12:35 ok 78.5s）但 state 仍停在舊失敗筆 → ce=4 不歸零、每週排程的 job 會一直掛紅**、⭐⭐ **`OpenClaw 系統維護` 與 `健康回報` 自癒回來（13:05/14:04/15:04 全 ok、ce=0）**、⭐ **Discord 兩個零症狀起點必須分開報（嚴格 11h10m vs 有一次完整關閉 3h14m）**、⭐ **gateway 連續 2d11h 未重啟（MainPID 4137629、ActiveEnterTimestamp 11-23 04:48:17）**、⚠️ **本輪自身 dur ≈540s 超過 300s 自我上限，但未造成任何 lane 傷害** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：🟢 上輪（13:02）ok，本輪 16:02 起跑 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 13:02:20 → **ok / dur 156,887ms（2.6 分鐘）**＝在 300s 自我上限內 ✅（上一輪 §10 第 5 項確認完成）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 今日五輪 dur 全覽：01:02 **797.3s（超標）** → 04:02 307.0s（微超） → 07:02 **551.6s（超標）** → 10:02 **2.3s error（派發期秒死）** → 13:02 156.9s ok → **16:02 ≈540s（超標，本輪）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **同一支 job 一天之內走過「長到拖死別人 / 秒死 / 正常 / 長」四種形態** → 驅動因素在**上游配額與 lane 飽和**，不在 job 本身（沿用上輪結論，本輪再驗一次）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ 主事件 A：**配額牆在 12:09:37 退場，13:00–16:05 窗 429 = 0（牆不是「每天固定 4 小時」）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 逐時 429（journal 24h，扣掉 agent 自述後）：09→18 / 10→21 / 11→14 / **12→19** → **13/14/15/16 → 0**；quota 型（`Token Plan usage limit reached: Upgra`）**09→43 / 10→66 / 11→47 / 12→55** → **13h 起 0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 最後一筆 quota 型 = **12:09:37**；3h 窗（13:02–16:05）`status=429` / `Token Plan` / `overloaded_error` / `All models failed` **全部 = 0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **上輪 §10 第 1 項的答案是「牆退了」**；但要保留 MEMORY 既有教訓「『續 0』敘事一律會破」→ 本輪寫法：**牆已退 3h55m，仍屬「零星復發」觀察中，不寫成「已解決」**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **牆退的第一個可觀測後果＝巡控 job 自癒**：`OpenClaw 系統維護` 11:04 err(4.4s) / 12:04 err(2.2s) → **13:05 ok(80.9s) / 14:04 ok(196.5s) / 15:04 ok(120.1s)**，ce=0；其輸出自述從 13:05 的「Crons: 2 failed last hour」→ 14:04/15:04 的「Crons: 0 failed last hour」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `健康回報` 11:05–11:12 連死 4 次 → **14:05 ok（166.0s）** ce=0 → **兩個「監控機制本身」都從 4 小時全盲中回來**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐⭐ 主事件 B：**飽和假說第 3 次被實測支持——這次是「反向證據」** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipts 實測（8 條 heartbeat lane，窗 12:02–16:02，共 63 runs）：**Σdur 合計僅 231.0s**、**≥300s = 0 筆**、**dur=600,0xx 硬死 = 0 筆**、非 ok 全是 `skipped`（no-route，dur 0.26–12.3s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 佔用率 **231.0 / 38,400 = 0.6%**（vs 08:00 槽 112% ＝ 7 筆 600s 硬死）→ **同一支 fleet、同一組 lane，兩種佔用率、兩種結果**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **因果鏈閉環**：配額牆 → job 2–5s 秒死 → **lane 被空出** → 沒有 600s 硬死。→ 所以「600s 硬死群集」＝**「lane 被長 job 佔滿」**，與 provider 慢無關（provider 慢的表現是 429，不是 timeout）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「越壞越快＝越安靜」第 2 次實測**：本窗 fleet 狀態表幾乎全綠（ce=0、dur 0.26–17s），正是因為牆把大家都殺得快 → **綠燈不代表沒事，紅燈數也代表不了工作量**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 16:00 槽實測：`每日 OpenClaw 備份` 16:00:05 → **ok 130.0s** → 上輪 §10 第 2 項（16:00 槽會不會重演硬死）＝**未重演**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐⭐ 主事件 C：**新發現——state 與 receipts 會不同步，導致已恢復的 job 長期掛紅** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `skill-collection-review-mrmime`（`9e2cec7c`）：**receipts 有成功筆 15:12:35 ok（78.5s）**，但 `state.lastRunStatus=error` / `lastRunAtMs=12:07:43` / **`consecutiveErrors=4`** / `lastDurationMs=583` → **ce 沒有被那筆成功清掉**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 該 job 排程＝**每週一次**（`everyMs=604800000`、next **12-02 12:01**）→ **在 12-02 之前它會一直掛紅**，而且下次跑完若不再同步，ce 會繼續累加。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **紅單掃描必須 state × receipts 交叉比對**：receipts 顯示近期有 ok、而 state 仍紅 → 標記為「狀態未同步」，**不要**當成仍在故障。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ 同型紅單族（皆為**非每輪自癒型**，需人工或改判讀規則）：`skill-collection-review-roaringmoon`（ce=1，11-20 DNS 餘波，每週 → next 11-27）、`clean-code研究`（ce=3，09:00 配額牆所傷，**next 11-26 09:00 才會自癒**）、`Jormungand mrmime Codex A2A heartbeat`（ce=4，12:00 槽死 4 次，**next 18:00:30 才會自癒**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ⭐ 主事件 D：**Discord：兩個零症狀起點必須分開報** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 嚴格判準（`did not reach READY` / `channel exited`）：24h 內 READY-fail 22 筆、channel-exit 11 筆，**最後一筆 04:54:40** → **嚴格零症狀連續 ≈11h10m**（04:54:40 → 16:05）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 但 **`close, resume=false` 24h 只有 2 筆、最後一筆 12:50:43**（＝一次完整關閉、非 resume 重連）→ **對外可宣稱的無症狀起點是 12:50:43（≈3h14m）**，11h10m 那條只能當「READY 層」的乾淨段。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗：READY-fail 0 / channel-exit 0 / `startup-not-ready` 0 / `host timing gap detected` 0；心跳式重連 12 次（≈4/h，接近 24h 基線 6.25/h）→ **無新事故**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 內 `READY within`（成功握手）22 筆、最後 04:54:40 → 這也是「上一次真實握手」的下界。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 其他實測（窗內） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **gateway：連續 2d11h 未重啟**（MainPID **4137629**、`ActiveEnterTimestamp=2026-11-23 04:48:17`、`NRestarts=0`）→ 11-23 那次 selfheal 開火之後，**2 天半沒有再被重開過**；進程二進位 = `node v24.22.3`（CVE 修補版仍在生效）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `superseded` 競態：24h 119 筆，但今日分布 01h=10 / 04h=10 / 07h=22 / 08h=31 → **13:02–16:05 窗 0 筆**（13:02 那輪三姊妹沒撞出來）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **17 支 skill 缺 description 第 12 輪仍未修**（3h 窗 **204 行**、24h 2,941 行）→ 未經點頭不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `每日模型排行前十` next **23:01**、`每日論文討論` next **11-26 07:00**、`每日資安建議` next **11-26 08:06** → 都還沒到，本輪不驗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-flaaffy` next 2027-02-03（每 416 天）→ 沿用上輪結論：未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) ANCHOR 疊窗（第 31 次） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 picturecat **16:02:02.533** ↔ gengar **16:02:02.570（Δ37ms）** ↔ celesteela **16:02:03.603（Δ1.07s）** → **本輪只要跑超過 1 秒就與 celesteela 同時在跑**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **本輪疊窗 0 事故**（superseded 0 筆、lane 無 wait、heartbeat dur 全 ≤12.3s）→ 與上輪一致：**疊窗是放大器不是必要條件**（真正出事的是「疊窗 + 同窗其他長 job」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) lane 佔用率表（receipts 實測，12:02–16:02，8 條 heartbeat lane） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| lane | runs | Σ dur | ≥300s | 600s 硬死 | 非 ok 型別 |
|---|---|---|---|---|---|
| hb-rowlet | 8 | 2.1s | 0 | 0 | skipped(no-route) 8 |
| hb-mrmime | 7 | 33.6s | 0 | 0 | skipped 3 |
| hb-celesteela | 8 | 2.1s | 0 | 0 | skipped 8 |
| hb-charizard | 8 | 76.1s | 0 | 0 | skipped 4 |
| hb-greninja | 8 | 57.4s | 0 | 0 | skipped 8（dur 11.3–12.3s） |
| hb-picturecat | 8 | 2.1s | 0 | 0 | skipped 8 |
| hb-roaringmoon | 8 | 2.1s | 0 | 0 | skipped 8 |
| hb-gengar | 8 | 55.6s | 0 | 0 | skipped 4 |
| **合計** | **63** | **231.0s** | **0** | **0** | 全是 skipped |
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（沿用 17 項，重排；新增 2 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高】MiniMax 配額牆（帳號層 plan 上限）仍需「用量可視化／提前告警」或第二廠商 fallback** —— 本輪牆雖已退（12:09:37），但 09:00–12:09 這 3 小時內 `OpenClaw 系統維護` 死 2 次、`健康回報` 死 4 次、KA 三姊妹死多輪、另外 3 支 job 至今掛紅 → **跨廠冗餘 0 的代價已實際落地**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【最高】08:00 槽飽和（112%）治本＝錯開 07:00–08:00 的長 job**（`健康回報` 1,398.6s、`每日資安建議` 770.7s、`每日模型排行前十` 522.4s、`PTCGP Meta` 577.6s、`每日論文討論` 762.2s）；治標＝heartbeat timeout 600→900s。**本輪反向實測證實：佔用率掉到 0.6% 時 0 筆硬死。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高·新】state 與 receipts 不同步 → 已恢復的 job 仍掛紅（ce 不歸零）**，每週排程者（`skill-collection-review-mrmime` ce=4 / `-roaringmoon` ce=1）會一路紅到下週。建議：**巡檢加一道「receipts 近 24h 有 ok → 標記 state 未同步」，並提供清 ce 的路徑**（清 ce 屬改 job 狀態，需點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高】`Explicit auth order for openai has no usable profiles.`（10:02 派發期秒死）本窗 0 次**（24h 3 次，全在 10:02 窗）→ 症狀未復現，但 `defaults.models` 內含 openai 條目＝隨時可能再炸，維持觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【高】KA 三姊妹 anchor 疊窗 Δ≤1.07s（第 31 次）** → 本窗 0 事故，但建議把 celesteela 拉開 ≥10 分鐘或兩支合併。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中】heartbeat「no-route 前阻塞」型別本輪僅 11–12s**（上輪 347–510s）→ 該型別跟著配額牆一起消失，維持觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中】死亡輪不留報告（10:02 那輪 error 2.3s 沒寫檔）** → 本輪 receipts 顯示 10:02 輪確實無 entry；連續性只能靠 receipts 回推。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中】`OpenClaw 系統維護` 與 `健康回報` 自癒回來（ce=0）** → 監控機制已恢復，但仍無「配額牆期間的備援監控」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中】`elle.service` 停用、DNS root cause、17 支 skill 缺 description（第 12 輪）、筆電端 SSH automation 只觀察** → 沿用既有待決，本輪無新證據，不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【方法論】本輪驗證三件事**：① **硬死一定要讀 receipts**；② **fleet 狀態表在「快速失敗期」與「配額牆退場後」都會偽裝成健康**；③ **紅單判讀要 state × receipts 交叉**，單邊都會出錯。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 下一輪（11-25 19:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **配額牆會不會再來** → 讀 16:00–19:00 的 quota 型 429（`Token Plan usage limit reached: Upgra`）；寫法沿用「零星復發」而非「續 0」。
2. **`Jormungand mrmime Codex A2A heartbeat` 18:00:30 那輪會不會自癒** → 若 ok，ce 歸零；若仍紅，根因看 receipts 的 error_text（配額牆型 vs auth 型）。
3. **`skill-collection-review-mrmime` 的 state 與 receipts 會不會同步** → 下次執行 12-02；在此之前 ce=4 應維持不動，但要在報告裡持續標註「state 未同步」。
4. **19:00 槽的飽和度** → 19:00 是舊尖峰窗（20–22、16–18），若該窗同時有長 job，`600s` 硬死群集可能重現 → 這是本輪之後最可能出事的槽。
5. **Discord 零症狀起點** → 目前嚴格起點 04:54:40（11h10m）、含完整關閉的保守起點 12:50:43（3h14m）；19:02 輪若 `close, resume=false` 沒再出現，保守起點續長。
6. **本輪自身 dur** → 16:02 輪實測 ≈540s（**超過 300s 自我上限**），但 0 lane 傷害；下一輪維持「一次批次拉 receipts＋一次 journal 掃描」的批次策略。

### 11) 本輪自證：dur 與自我造成的 stall <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 16:02:02 起跑 → 報告寫完約 16:11，**實際 dur ≈540s（超過 300s 自我上限）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **但沒有造成任何 lane 傷害**：本窗 8 條 heartbeat lane 的 dur 上限只有 12.3s、0 筆 ≥300s、0 筆 600s 硬死、journal 無 lane wait／stalled session → **在低佔用窗（本窗 0.6%）裡，KA 跑 9 分鐘不會壓死別人**；只有像 08:00 槽（112%）那種高佔用窗才會（本 job 07:02 輪 551.6s 就屬那種情況）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **實務修正**：巡檢深度上限維持 ≤300s，但**判「有沒有傷到別人」要看當窗 lane 佔用率，不是只看自己的 dur**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-25 19:02 — Picturecat Keep-Alive 第 6 輪：🟡 lane PASS、配額牆未回來（牆退 6h53m、18:02 一顆慢排空 429 被 retry 救回）、⭐⭐⭐ **「skipped 卻跑了 3–4 分鐘」的機制解開：不是 runner hang，而是被別的 rowlet-lane job 擠壓（兩個獨立實例、結束時間差 0–1 秒）**、⭐⭐ **KA 疊窗首次抓到「連帶死亡」實證（16:02 槽 → mrmime heartbeat 的 retry 死於 superseded）**、✅ **上輪交辦 2 條結案（Jormungand A2A ce 歸零、skill-collection-review-mrmime state 自行同步）**、⭐ **Discord 兩個零症狀起點續長（14h08m / 6h11m）、dreaming 第 2 夜完整活下來（1,793.0s）**、⭐ **紅單收斂到 2 支**、⚠️ **本輪自身 dur 自報會有 1.9x 誤差 → 一律以 receipt 為準** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：🟢 上輪 16:02 ok，本輪 19:02 起跑 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 16:02:04 → **ok / dur 290,730ms（4.8 分鐘）**。⚠️ **上輪報告自報「dur ≈540s（超過 300s 自我上限）」，receipt 實測是 290.7s → 自我量測誤差 1.9x**；**巡檢一律以 receipt dur 為準**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 今日dur 全覽：01:02 **797.3s** → 04:02 307.0s → 07:02 **551.6s** → 10:02 **2.3s error（派發期秒死）** → 13:02 156.9s → 16:02 **290.7s** → 本輪 19:02 running。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 同一支 job 一天走過「拖死別人 / 秒死 / 正常」四型 → 驅動因素在**上游配額與 lane 飽和**，不在 job 本身（沿用上輪結論，第 3 次驗證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 主事件 A：**配額牆未回來（退場 6h53m），18:02 一顆慢排空 429 被 same-model retry 救回** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- quota 型（`Token Plan usage limit reached`）24h = **113 筆，全部落在 09–12h**（30/29/33/21）；**12:09:37 之後 0 筆** → 牆退場已 **≈6h53m**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical 429 逐時：21h×1｜23h×2｜00h×1｜03h×1｜05h×2｜06h×2｜07h×3｜08h×2｜**09h×18｜10h×21｜11h×14｜12h×19**｜**13–17h = 0**｜**18h×1** → 24h 合計 **87 筆，其中 72 筆在配額牆窗內**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯一一筆：**18:02:24.909 status=429 elapsedMs=114,245 dispatcher=new** → 18:02:35 重發 → **18:02:38 status=200 elapsedMs=2,970** → 復原（典型慢排空型）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **溯源**：request 起始 **18:00:30.662** → 對應 `d7b0355b Jormungand mrmime Codex A2A heartbeat` 18:00:30 那輪 → 該輪 receipt = **ok 179.4s** → 429 沒把它打死。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 寫法沿用既有教訓：寫「**零星復發**」，不寫「續 0」（近 5 輪「續 0」敘事每輪都被打破）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐⭐ 主事件 B：**「skipped 卻跑了 3–4 分鐘」機制解開＝被別的 rowlet-lane job 擠壓（兩個獨立實例，結束時間完全對齊）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 實例 1：`heartbeat-rowlet` **16:08:22 → 16:11:40，dur=197.4s，status=skipped（no-route）**；同一時段 `Gengar Keep-Alive` **16:02:04 → 16:11:39（575.1s，同跑 agent:rowlet lane）** → **兩者結束時間差 1 秒**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 實例 2：`heartbeat-rowlet` **17:08:24 → 17:11:59，dur=215.5s，skipped**；同一時段 `健康回報` **17:05:22 → 17:11:59（396.7s，rowlet lane）** → **結束時間差 0 秒**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **不是 runner hang、也不是 heartbeat 自己變慢**：agent lane ＝**單執行緒排隊佇列**，前一棒還在跑，heartbeat 只能等；等拿到回合後才判定「no-route」→ 於是記成 **skipped**，但 dur 被拉成「剩餘時間」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **這就是「600s 炸彈」的機制解釋**：dur ≈ 剩餘時間 → 一旦前棒跑到接近 600s，heartbeat 就會撞 600s 硬死（今日 08:08:21 / 08:18:21 / 08:39:50 / 08:58:51 等一串 `heartbeat-rowlet error 600.0s` 即此型）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **對策（低風險先做）**：把 rowlet lane 上最長的幾支（**Gengar KA 575s、健康回報 397s、OpenClaw 系統維護 130s+、每日模型排行、每日論文討論、每日 LLM Wiki**）與 `heartbeat-rowlet` 的整點槽**錯開 ≥10 分鐘**；或把 heartbeat 的 timeoutSeconds 由 600s 拉高（改 job 需 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **這也解釋了 11-25 01:02 輪記的「skipped 但跑了 298.9s（600s 預算 49.8%）」**：同型（rowlet lane 當時被 `每日模型排行前十` 佔住），現在從「猜」變成「有兩個對齊實例可引用」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐⭐ 主事件 C：**KA 疊窗首次抓到「連帶死亡」實證——16:02 槽把 mrmime heartbeat 的 retry 打死** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗 `was superseded` **17 筆** ＋ `lane task error` **12 筆**，時間戳**全部落在 16:07（8+6）與 16:11（9+6）** → 正是 16:02 三支 KA 的落點。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- lane 分佈：`nested:agent:gengar:main` 3、`session:agent:gengar:main` 3、**`session:agent:mrmime:main:heartbeat` 3**、`cron` 3；被取代的 agent dir＝gengar 8 筆、**mrmime 9 筆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **完整死亡鏈**：`heartbeat-mrmime` 16:01:07 → **600.0s timeout error** → **16:11:38 retry（dur 2.9s）→ `heartbeat failed: agent-runner-failure`**，同一毫秒出現 `prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/mrmime/agent`（lane=session:agent:mrmime:main:heartbeat）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **這是既有模式（11-22 16:01、11-23 16:11 同型）第 3 次重現**，且把「疊窗是放大器」從假說升級成**有連帶死亡的實證**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **收斂建議升級**：三支 KA anchor 拉開 **≥15 分鐘**（現況 Δ11ms / Δ22ms），否則每個整點槽都有機會打死鄰 lane 的 retry。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **上輪報告寫「本窗 superseded 0 筆、0 事故」是因為量測窗口太早**（16:02 輪的傷害在 16:07/16:11 發生，落在該輪報告寫完之後）→ **「某槽 0 事故」的結論必須標明量測截止時間**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ⭐ 主事件 D：**紅單收斂到 2 支，上輪交辦項 2 條結案** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 且 `consecutiveErrors>0` 只剩 2 支：`89e2cfe7 clean-code研究` **ce=3**（last 09:07:34、配額牆所傷、**next 11-26 09:00** 才自癒）、`c5352a84 skill-collection-review-roaringmoon` **ce=1**（11-19 DNS 餘波、**next 11-27 03:56**）。legacy disabled `a94330a9 tmp-openai-probe` ce=2 → 不是活紅單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **上輪交辦 #2 結案**：`d7b0355b Jormungand mrmime Codex A2A heartbeat` 18:00:30 **ok 179.4s → ce=0**（17:33:06 那輪也已 ok 109.9s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **上輪交辦 #3 結案**：`9e2cec7c skill-collection-review-mrmime` 17:35:07 **ok 47.5s** → state **ok / ce=0**（lastRunAtMs 09:35:07Z）→ **「state 與 receipts 不同步」本輪自行癒合，不必人工清 ce**（該 job next 12-02 12:01）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- fleet 24h receipt 混合：**ok 293 / skipped 267 / error 70 / running 3**（error 大宗＝09–12h 配額牆窗 + 04:27–08:48 dreaming 窗的 heartbeat 硬死）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) ⭐ 主事件 E：**Discord 兩個零症狀起點續長；dreaming 第 2 夜完整活下來** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗：READY-fail **0** / channel-exit **0** / `close, resume=false` **0** / host-timing-gap **0** / client initialized **0** / startup-not-ready **0** / memory pressure **0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 嚴格零症狀起點 **04:54:40 → ≈14h08m**；保守起點（含一次完整關閉）**12:50:43 → ≈6h11m**（兩個起點仍要分開報）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 心跳式重連 reconnect **12** ＋ ws closed **16**（≈4.0/h、5.3/h，貼近 24h 基線 2.6–3/h，無 resume=false）。8 個 enabled 帳號全部 connected（greninja disabled/stopped 為既有狀態）；`/health` 200 in 1.5ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **dreaming 11-25 04:25:00 → ok / dur 1,793.0s（29.9 分）＝連續第 2 夜完整跑完**；且同一夜 dreaming 窗內出現 **9 筆 heartbeat 600s 硬死**（04:27:53 picturecat/charizard/roaringmoon 685.9s、04:33:29 mrmime/gengar 703.4s、04:39:18/04:39:50 rowlet 602.2s + 607.5s 等）＋ Discord 04:54:40 最後一次 channel exited → **「Discord 失明」與「heartbeat 硬死」是同一個 event-loop 凍結的兩個下游症狀**（dreaming 04:34 `memory pressure: rss=2.03 GiB`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 其他實測（窗內） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **gateway 連續 2d14h14m 未重啟**（MainPID **4137629**、`ActiveEnterTimestamp=2026-11-23 04:48:17`、`NRestarts=0`、node v24.22.3）→ 11-23 selfheal 事故後近 2 天半零重啟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 內 dur≥595s 的 run 共 **39 筆**，其中 **heartbeat 600s 硬死 24 筆**（mrmime 12、rowlet 8、charizard 4、gengar 4、roaringmoon 3、celesteela 3）；今日最密集＝**08:00 槽**（08:08–08:48 共 9 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **17 支 skill 缺 description 第 13 輪仍未修**（24h **2,754 行**、唯一 **17 檔**；3h 窗僅 17 行 → 密度集中在 dreaming 與各 job 起跑時段，不是均勻分佈）→ 未經點頭不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 另有 3 支 legacy KA job 已 disabled（`1b2165f9` Charizard／`ee14ba4c` Rowlet／`ee3def26` RoaringMoon Keep-Alive，nextRunAtMs=0）→ 不是活 job，避免下輪誤算「KA 數量」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `OpenClaw 系統維護` 15:04–18:04 連續 4 輪 ok（103–133s）、`健康回報` 17:05:22 ok 396.7s → 兩個監控機制維持健康；`每日模型排行前十` next 23:01、`每日論文討論` next 11-26 07:00、`每日資安建議` next 11-26 08:06（本輪不驗）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- host up **45d0h49m**、load 0.74/0.49/0.46、RAM available 20Gi、`/` 61%（176G free）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) ANCHOR 疊窗（第 32 次） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `state.nextRunAtMs`：picturecat **1795604524191** → gengar **…202（Δ11ms）** → celesteela **…213（Δ22ms）**；實跑 19:02:04 / 19:02:06 / 19:02:06。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗 17 筆 superseded 全在 16:07/16:11（＝上一個 16:02 槽）；**本槽 19:02 的 superseded 尚未落盤**（會在本輪收尾後才寫入）→ **需下輪確認**，寫法沿用「本輪未見、不宣告安全」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（更新） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高·新】rowlet lane 序列化**：把 **Gengar KA（575s）／健康回報（397s）／OpenClaw 系統維護（130s+）／每日模型排行／每日論文討論／每日 LLM Wiki** 與 `heartbeat-rowlet` 的整點槽錯開 ≥10 分鐘，或把 heartbeat 的 timeoutSeconds 由 600s 拉高 → **本輪已用兩個結束時間對齊的實例證實因果**（heartbeat-rowlet 的 197.4s／215.5s 兩輪 skipped dur 完全等於前棒剩餘時間）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【最高】MiniMax 配額牆仍需用量可視化／提前告警或第二廠商 fallback**（今日 09:00–12:09 打死 `OpenClaw 系統維護` 2 次、`健康回報` 4 次、`clean-code研究` 3 次並連累 2 支 job 至今掛紅）→ **跨廠冗餘 0 的代價已實際落地**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】三支 KA anchor 拉開 ≥15 分鐘**（現 Δ11ms／Δ22ms，第 32 次）→ 本輪已有**連帶死亡實證**（16:02 槽 → mrmime heartbeat retry 死於 superseded）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高】`Explicit auth order for openai has no usable profiles` 今日只出現一次**（10:02 那輪 2.3s 秒死；本窗 0 次）→ 症狀未復現但未修，`defaults.models` 仍含 openai 條目，維持觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中】`clean-code研究` ce=3 → 11-26 09:00 自癒**；**`skill-collection-review-roaringmoon` ce=1 → 11-27 03:56**（兩支皆等自然自癒，不需動作）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中】17 支 skill 缺 description（第 13 輪）、`elle.service` 重啟迴圈、DNS root cause（Link 2 無 scope）** → 沿用既有待決，本輪無新證據，不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【方法論】本輪驗證三件事**：① **「skipped 但 dur 3–4 分鐘」＝被別的 lane job 擠壓**（不是 runner hang、不是 heartbeat 變慢）；② **自我回報 dur 會有 1.9x 誤差 → 一律以 receipt dur 為準**；③ **「某槽 0 事故」必須標明量測截止時間**（上一槽的傷害可能落在報告寫完之後）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 下一輪（11-25 22:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **19:02 槽自己的 superseded 筆數** → 本輪 19:02 三支 KA 同時起跑，是否在 19:0x 再釀 mrmime／gengar 的 lane task error（上一槽 16:02 的傷害是在 16:07/16:11 才出現的）。
2. **heartbeat-rowlet 的 dur 是否又被拉長** → 看 19:08／19:38／20:08 幾輪；若又出現 >150s 的 skipped dur，直接對齊當時 rowlet lane 上是哪一支在跑（§3 的比對法）。
3. **配額牆是否再來** → 讀 19:00–22:00 的 quota 型 429（`Token Plan usage limit reached: Upgra`）與 canonical `model-fetch.*status=429`；寫法沿用「零星復發」。
4. **22:00 槽的飽和度** → 20–22 是舊尖峰窗，且 22:02 三支 KA 同時起跑（Δ11ms/Δ22ms 未解）→ 本輪之後最可能出事的是 22:00–23:00。
5. **紅單兩支的歸屬** → `clean-code研究` 11-26 09:00、`skill-collection-review-roaringmoon` 11-27 03:56，期間只需確認 ce 沒再 +1。
6. **本輪自身 dur** → 維持「一次批次拉 receipts＋一次 journal 掃描」的批次策略；**報告寫完後用 receipt dur 校正自報值**。

### 11) 本輪自證：dur 與自我量測誤差 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 19:02:04 起跑 → 報告寫完約 19:15，**自報 dur ≈ 500–700s（過 300s 自我上限）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **但本輪同時發現「自我量測有 1.9x 誤差」**（上輪自報 ≈540s vs receipt 290.7s）→ **本輪的自報值不可信，以 receipt dur 為準**；下輪請讀 `openclaw cron runs --id 02eb0989-…` 的最新一筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **本輪自身的 lane 傷害評估**：3h 窗 heartbeat lane 佔用率 **1,627.1s / 10,800s = 15.1%**、≥300s 僅 1 筆、**600s 硬死 0 筆**、`lane wait exceeded` 0 → **本輪跑得比預期久，但沒有壓死別人**（與 16:02 輪「0.6% 佔用窗跑 9 分鐘無害」的結論一致）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-25 22:02 — Picturecat Keep-Alive 第 7 輪：🟢 lane PASS、Discord 零症狀 ≈17h、fleet 紅單維持 2 支；⭐⭐ **推翻上輪「KA 疊窗打死鄰 lane」的歸因**：`superseded` 簽章有兩種來源，真正致命的是 heartbeat 自己的 timeout→retry 自我取代 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `2c9188a0-a83c-4d12-bfc8-da2493062a63`、status=ok、回覆「pong — (1) 無 active task, (2) 近幾小時無錯誤, (3) Discord 收發正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-25 19:02）**ok / dur=167,557ms / ce=0**（第 6 輪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` **ok / ce=0**（19:02:06 起 dur=138,606ms）、`9d8b6001 Gengar KA` **ok / ce=0**（22:02:24 起 dur=17,763ms，摘要「Keep-alive OK — Rowlet session responsive」）→ **三支 KA 全綠**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- anchor：`state.nextRunAtMs` picturecat **1795615324208（22:02:04）** → celesteela **…326231（22:02:06，Δ2,023ms）**；gengar 下一輪 **01:02:06**（本輪實跑 22:02:24，與前兩支不同槽）→ **本槽是 2 支疊、不是 3 支**（第 33 次 anchor 觀測）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🟢 Discord：8/8 running+connected，近 3h 零症狀（連續零症狀 ≈17h）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（22:02）：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet 全部 **enabled, configured, running, connected**，transport just now~1m（greninja disabled/stopped ＝預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實收發：celesteela in:2m、mrmime in/out:43m、charizard in/out:13h、gengar in/out:15h、roaringmoon in:13h、rowlet in:15h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 19:00–22:05（**707 行**）簽章計數：**READY wait timed out 0 / channel exited 0 / reconnect-exhausted 0 / startup-not-ready 0 / event-loop starvation 0 / memory pressure 0 / EAI_AGAIN 1** → **本窗完全沒有抖動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：MainPID **4137629**、`ActiveEnterTimestamp=2026-11-23 04:48:17` → **連續 2d17h14m 未重啟**、NRestarts=0、`/health` **HTTP 200 in 1.14ms**；host up 45d3h49m、load 0.49/0.53/0.51、mem available 20GiB、disk 61%（176G free）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ 主事件 A（本輪最重要）：**`superseded` 簽章有兩種來源，上輪歸因需修正**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Type A（無害的自傷噪音）**：lane = `nested:agent:X:main` + `session:agent:X:main` → **每次 keep-alive 的 `sessions_send` ping 收尾時，在「被 ping 的那個 agent 自己的 lane」上產生 2 筆 lane task error**，並在同一毫秒記一筆 `[agents/sessions-send] sessions_send announce flow failed`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 24h 內 Type A 的完整落點＝**每一個 KA 輪的 ping 時間點**：11-24 22:03:16(picturecat)、22:04:19(gengar)、11-25 01:04:12(gengar)、01:06:21(picturecat)、04:02:32(picturecat)、04:04:52(gengar)、07:03:46(gengar)、**22:02:41(picturecat，本輪：pong 於 22:02:41.026 回來 → .027 run ended → .105 兩筆 lane task error → .107 announce flow failed)**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⇒ **19:03:30 那批 6 筆 gengar 的 superseded 是 gengar 自己 ping 的 announce 競態，不是外傷**；上輪 §4 把它歸到「三支 KA 疊窗打死鄰 lane」是**過度歸因**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Type B（致命的那一種）**：lane = `cron-nested` + `session:agent:mrmime:main:heartbeat` → 11-25 16:11:40–41 共 6 筆，與 `heartbeat-mrmime` 的 **600.0s timeout（16:01:07 起）→ retry（16:11:38）→ `lane task error`（agent-runner-failure）** 同一毫秒發生 → 這是 **timeout 後重試把前一份 prepared runtime 取代**的**自我取代**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **修正後的因果**：heartbeat 的連帶死亡＝「lane 被別人佔住 → 撞 600s timeout → retry 撞上自我取代」；KA anchor 疊窗只是**放大器（讓 lane 更擠）**，不是直接觸發者。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h superseded 總量 **18 筆**（Type A 12 ＋ Type B 6）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐ 主事件 B：**heartbeat 600s 硬死又復發（2 筆），且本輪直接抓到佔用者**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-rowlet`：**20:18:24 error dur=600,004ms** → **20:22:56 skipped dur=240,971ms** → 21:21:19 ok dur=148,667ms；**21:18:20 error dur=600,004ms** → 21:18:51 ok dur=148,667ms（ce=0，自癒）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **佔用者已定位（不再是猜測）**：`PTCGP Meta Analysis (每日記錄)` **20:05:00 起跑、dur=1,076,083ms（17.9 分鐘）→ 20:22:53 才結束**，正好蓋住 heartbeat-rowlet 20:08:24 的 600s 視窗；下一輪 20:22:56 才排到 lane、skipped dur=240.9s（≈剩餘等待）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-celesteela`：**20:12:45 error dur=600,005ms** → **21:12:45 skipped dur=397,331ms（6.6 分鐘）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **這次不是 provider 拖垮**：同窗 model-fetch 延遲健康（19:00–22:05 p50=**1,697ms**、p90=**4,032ms**、max=139,992ms＝那筆 429）；20:00–21:00 p50=1,875ms。→ **純排隊/序列化問題**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h heartbeat 600s 硬死總數 **29 筆**（rowlet 9、mrmime 8、celesteela 4、charizard 2、gengar 2、picturecat 2、roaringmoon 2），較上輪的 24 筆 **+5**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Fleet：53 jobs / 46 enabled — ok 38 / skipped 5 / error 2 / never 1（+disabled: ok 6 / error 1）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單 **維持 2 支、無 +1**：`89e2cfe7 clean-code研究` **ce=3**（lastError=**billing**，next 11-26 09:00）、`c5352a84 skill-collection-review-roaringmoon` **ce=1**（next 11-27 03:56）→ 都等自然自癒。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 綠燈重點：`discord-selfheal-after-dreaming` 21:43:00 ok（787ms）、`OpenClaw 系統維護` 21:04:48 ok 63.0s、`健康回報` 20:05:22 ok 27.5s、`Gengar Cron Health Watchdog` 20:04:23 ok 3.0s、`Jormungand mrmime` 18:00:30 ok 179.4s、`dreaming` 11-25 04:25 ok dur=1,793.0s（**連續第 2 夜完整跑完**，next 11-26 04:25）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⏰ **22:22–22:30 又有兩個 rowlet-lane 長 job 排隊**：`每日模型排行前十` next=22:22:54（上輪 dur=522.4s）、`健康回報` next=22:25:20 → 與本輪 KA 疊在 22:02 槽之後。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Provider：配額牆**連續第 5 輪零**，但 429 仍會零星出現<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 19:00–22:05 model-fetch **271 次**：status 200×**270**、**429×1**（21:02:44，elapsedMs=139,992 → embedded run `aa6d222d` isError=true「⚠️ API rate limit reached」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 該 429 的宿主 job `911eee45 每日資安建議`（20:47 起跑）**最終 ok / dur=966,801ms（16.1 分鐘）/ ce=0** → **被內部重試救回，沒變紅單**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Token Plan usage limit reached` = **0 筆**；`overloaded_error` = 1 筆；`Explicit auth order for openai` = 0 筆（本窗未復現）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 跨廠 fallback 仍是 0（`openai/*` 全 Auth=no，憑證我不碰）→ MiniMax 429 時只能靠同模型重試（本輪 21:02 那筆就是靠它自癒）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron 排程/payload/model/fallback/timeout、未動 `scripts/discord-selfheal.sh` 守門、未改 config/provider/model/channel、未碰憑證、**未重啟 gateway**、未動 DNS/網路設定。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user`、`systemctl --user show`、`curl /health`、`uptime/free/df`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（更新）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高】rowlet lane 序列化——本輪已抓到直接佔用者，不再是猜測**：`PTCGP Meta Analysis (每日記錄)` 一次 17.9 分鐘就足以打死 `heartbeat-rowlet`（20:08:24 硬死）。建議把 **PTCGP Meta Analysis／每日資安建議（16.1 分）／每日模型排行前十／健康回報** 與 `heartbeat-rowlet` 的整點槽錯開 ≥10 分鐘，或把 heartbeat 的 timeoutSeconds 由 600s 拉高（改 job 需你點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【高·自我更正】不要把「三支 KA anchor 疊窗」當成 heartbeat 死亡的直接原因**：真正的簽章是 (a) ping 的 announce 競態（無害）、(b) 600s timeout → retry 自我取代（致命）。要修「連帶死亡」應從 heartbeat 自己的 timeout/retry 路徑下手；**拉開 KA anchor 仍值得做，但理由要改成「降低 lane 擁擠」**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】MiniMax 跨廠 fallback 仍是 0**：配額牆連 5 輪沒出現，但 21:02 的 429 仍靠同模型重試才救回；需要一組可用的第二廠憑證才有真冗餘（憑證我不碰，需你提供）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】紅單 2 支等自然自癒**（11-26 09:00 / 11-27 03:56），期間只需確認 ce 沒 +1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中】17 支 skill 缺 description（第 14 輪）、`elle.service` 重啟迴圈、DNS root cause（Link 2 無 scope）** → 沿用既有待決，本輪無新證據，不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【方法論】本輪驗證四件事**：① **`superseded` 必須分 lane 類型看**（`nested/session:X:main`＝ping 噪音 vs `cron-nested/session:X:main:heartbeat`＝真傷害）；② **provider 延遲要量 p50/p90**，不能假設「慢＝provider」；③ **heartbeat 600s 硬死的佔用者可以用「同 lane job 的 receipt 時間戳」直接對齊**（本輪對到 PTCGP 20:05–20:22:53）；④ 「某槽 0 事故」必須標明量測截止時間（沿用上輪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 下一輪（11-26 01:02）請確認<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **22:02 槽的 superseded 分類**：本輪只量到 Type A（picturecat 2 筆，22:02:41）——若下一輪出現 Type B（`*:main:heartbeat` lane）才算有傷害。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **heartbeat-rowlet 22:08 / 22:38 兩輪 dur**：22:22:54 `每日模型排行前十`（上輪 dur 522s）＋22:25:20 `健康回報` 會進 rowlet lane → 若 22:08 又被拉長，佔用者就是它們（用同樣的 receipt 對齊法驗證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **配額牆 22:00–01:00 是否再出 429 / `Token Plan usage limit`**；同時量 01:00–01:10 的 model-fetch p50/p90（若 429 又現，確認同模型重試有沒有真的救回）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **紅單 ce 是否沒 +1**（clean-code研究 11-26 09:00 前、skill-collection-review 11-27 03:56 前）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **本輪自身 dur**：仍以 receipt dur 為準（`openclaw cron runs --id 02eb0989-…` 最新一筆）；自報值不作數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
