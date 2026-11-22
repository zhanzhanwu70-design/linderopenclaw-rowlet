# Gengar Keep-Alive 巡檢日誌（cron 9d8b6001，2026-11-21）

## 2026-11-21 04:02 — PASS（lane 雙向通）／⭐ **11-19 錯峰止血驗證成功（4 支紅單全綠）**／🔧 **dreaming 今晚 04:25 首跑新版 fail-closed 守衛**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（雙向通，04:05 pong）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main` → runId **`a205deda-c14b-4aad-8d2c-078e2bc95a21`**、status=**ok**；04:05 收到完整回覆（provider=`minimax-portal/MiniMax-M3` → `minimax/MiniMax-M3` → `minimax-portal/MiniMax-M2.7`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報 6 支自有 cron **全 ok、ce=0**：watchdog 02:04 ok、heartbeat c29eca0f 03:59 skipped/no-route（streak 0，14:00→09:00 帶生效）、English reminder ok（next 05:00）、BBC drill ok（next 07:00）、skill-collection-review ok、版本檢查 ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報近 60 分鐘 **429/overloaded = 0**、EAI_AGAIN = 0、clock-change/cache-flush = 0 → **昨天 13:00–16:18 那場 DNS 風暴（1202 events / 63 flushes）已完全收斂**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報「自 11-20 16:16 起未動任何設定」→ 與我方量測一致（`~/.openclaw/openclaw.json` mtime = 01:56，見 §6）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 11-19 的錯峰止血**已驗證成功**（4 支 ce=5–8 的紅單全轉綠）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11-19 22:0x 把三支紅單從 09:00/10:00/12:00 搬到 05:30/06:10/06:40（只改 `schedule.expr`）→ 今日實測：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | 新的 schedule | 11-20 結果 | ce |
|---|---|---|---|---|
| 每日 LLM Wiki 巡讀與擴寫 | ae91b967 | `30 5 * * *` | **ok** dur=635,614ms | 0 |
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | `10 6 * * *` | **ok** dur=945,018ms | 0 |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | `40 6 * * *` | **ok** dur=676,169ms | 0 |
| 每日資安建議 | 911eee45 | `5 0 21 * * *` | **ok** dur=546,973ms | 0 |

- `a72cb46b` 原本 ce=8（再 2 次連敗就自動停用）→ **現在 ce=0**，停用倒數解除。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 教訓沉澱：**MiniMax Token Plan 的 429 有明顯時段性（09:00–14:00 高峰）**，把 job 錯峰到 05:00–08:38 視窗比任何 fallback 鏈改動都有效，且不需動 model/provider。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🔧 dreaming：11-20 那次被砍的根因已修好，**今晚 04:25 是新版守衛的首個真實測試**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db` 11-20 04:25:01 那輪 → **error**、dur=675,657ms、err=「cron: job interrupted by gateway restart」、**ce=1**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 兇手時間軸：`journalctl` 顯示 **11-20 04:35:37 `Stopping OpenClaw Gateway`** → 04:36:07 重啟 → 04:36:17 觸發 `main-session-restart-recovery`（picturecat dreaming-narrative 三個 session 恢復）→ 04:39:23 「The interrupted turn is finished — the diary entry is written」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → **是 self-heal 在 04:35 那個時槽把 gateway 重啟了，而 dreaming 正在飛** → dreaming 被腰斬。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ 修正已在 `scripts/discord-selfheal.sh` 內（檔頭 CHANGES 註記：**2026-11-20 19:2x，rowlet keep-alive round 19:02**）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  1. **fail-closed**：查不到 dreaming 狀態 → 一律當作「在跑」→ 不重啟（舊版是 fail-open，問不到就當 False → 直接砍）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  2. **防風暴**：`MIN_GAP_MIN=30` → 90 分鐘內最多 arm 一次重啟（stamp 檔 `memory/discord-selfheal-last-restart.ts`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **我實測守衛邏輯**（唯讀，不 arm）：`openclaw cron list --json`（預設 46 支）**確實包含 36b493db**，且 `state.runningAtMs` 欄位存在（Picturecat KA 當時就帶 `runningAtMs`）→ dreaming 起跑後守衛會讀到非空 → print "True" → postpone。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **今晚預測**：dreaming 04:25 起跑（timeoutSeconds 2400 → 最晚 05:05 結束）→ self-heal 若在那段期間偵測到 Discord 真的壞掉，會**正確 postpone 而不是砍 dreaming**；真正開火要等 05:13/05:43。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⚠️ self-heal 排程在本輪**進行中被另一條 lane 改掉**（04:03:29）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:02 我讀 fleet 時它還是 `{"kind":"cron","expr":"35,50 3,4,5 * * *","tz":"Asia/Taipei"}`（last 03:50、next 04:13）；04:03:29（updatedAtMs 1795205009020）再讀 `cron get` → 已變成 **`{"expr":"13,43 * * * *"}`**（每小時 :13/:43 → 每天 24 次）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 推測發起者是 Picturecat lane（昨天 22:38–02:03 Discord 全盲 4 小時的教訓 → 把稀疏的 3×/日 槽改成每小時）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 評估**可接受**：健康時腳本在第 1 步（Discord 無 startup-not-ready）就 exit 0，實測每輪只花 **741–815ms**；arm 仍有 30 分鐘防風暴。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 副作用：**每小時 :13/:43 都會有一次 cron 執行**（一天 24 筆 run 紀錄），且若某次 Discord 剛好壞掉而 dreaming 也在跑，會 postpone 到下一個 :13/:43。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪**未動**這個排程（另一 lane 剛改，覆蓋它會製造對手動）。

### 5) Fleet：53 jobs / 46 enabled / 7 disabled — enabled **ok 32 / error 7 / skipped 6 / none 1**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單（enabled + error）全部**今天都有新時段**，不是死帳：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | ce | 最後失敗 | 下次 |
|---|---|---|---|---|
| Gengar Keep-Alive（本 job） | 9d8b6001 | 5 | 11-21 01:02（dur 589,772ms）| **本輪 04:02** |
| 群體智能架構研究 | b37129c0 | 5 | 11-20 09:19 | 11-21 08:09 |
| 晨間情報 pipeline | 45ccf4e9 | 4 | 11-20 09:06（timeout）| 11-21 08:00 |
| clean-code研究 | 89e2cfe7 | 2 | 11-20 09:04 | 11-21 09:00 |
| Memory Dreaming Promotion | 36b493db | 1 | 11-20 04:25（被重啟砍掉）| **11-21 04:25** |
| 每日論文討論 | 58fe15dc | 1 | 11-20 07:00 | 11-21 07:00 |
| skill-collection-review-roaringmoon | c5352a84 | 1 | 11-20 03:56 | 11-27 03:56 |

- 本 job 近 5 輪**全 error**，根因兩類：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  1. **DNS 風暴**（11-20 13:00–16:18）：「All models failed (3): getaddrinfo EAI_AGAIN api.minimax.io」×1（dur 95,775ms）、「LLM request failed: DNS lookup for the provider endpoint failed.」×2（dur **1,129,701ms** / 873,625ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  2. 11-21 01:02 那輪：「⚠️ Agent couldn't generate a response」dur=**589,772ms** → 差 10 秒就撞 cron 上限。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 6 支 skipped 全是 no-route/quiet-hours heartbeat（rowlet 03:38、celesteela 03:42、greninja 03:54、picturecat 03:55、roaringmoon 03:56、gengar 03:59），ce=0 → 綠燈閒置。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand daily all-agent health`（03:00 槽）**ok / ce=0 / dur=586,505ms** → 昨晚它是紅單（03:00 與 dreaming 同槽雙重負載），今天 dreaming 搬走後**單獨跑就綠**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-flaaffy` 6e93c179 st=None → 排程形同停擺（良性長態，沿用未結案）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：Picturecat 02eb0989 ok（02:03）、**Celesteela 880b5c17 ok（04:02）**、self-heal d4cd45bc ok（03:50，dur 815ms，summary=「discord healthy (no startup-not-ready) - no action」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 主機 / Discord 面（本輪乾淨）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：**8 個 enabled 帳號全部 `running, connected`**（greninja disabled/stopped = 預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：pid **3573532**、ActiveEnterTimestamp **2026-11-21 02:11:49 CST**、NRestarts=**0**、ActiveState=active、uptime ≈ **1h50m**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **02:11:47 的重啟不是我和耿鬼做的**：journal 顯示 `Stopping OpenClaw Gateway` 02:11:47 → `Started` 02:11:49；`/tmp/ka-restart-check.sh`（mtime 02:07）內容是「重啟後驗證採集」，寫入 `memory/keepalive-picturecat-2026-11-21-restart-check.md` → 是 **Picturecat lane** 的 self-heal 動作。驗證檔：8/8 connected、startup-not-ready=0、READY timeout=0、EAI_AGAIN=0、client initialized 02:12:55/02:13:15。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 03:00→04:02：`READY wait timed out`=**0**、event-loop starvation=**0**、startup-not-ready=**0**、EAI_AGAIN=**1**、429/overloaded 命中 2 筆 → **全是假陽性**（一筆是 skill 路徑含 "429"、一筆是 run id `a205deda-c14b-4aad-8d2...` 含 "429"）→ **真實 provider 錯誤 = 0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ingress（cp .sqlite+-wal+-shm → /tmp，python sqlite3 ro，參數化 SQL）：全表 6422 筆；**00:00 至今僅 2 筆**（03:05:50 mrmime、02:34:52 celesteela，status=completed）→ inbound 薄但活；與昨天 22:38 起的全盲比已恢復。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 資源：`/health` 200 in **11ms**、load 0.61/0.48/0.46、mem available **20 GiB**、disk **60%**（265G/468G，180G 可用）、uptime 40d。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ `agents.entries.gengar.model` 在 **01:56:03** 被改（`~/.openclaw/openclaw.json` mtime 01:56）：`{primary: minimax/MiniMax-M3, fallbacks:[minimax-portal/MiniMax-M3]}` → `{primary: minimax-portal/MiniMax-M3, fallbacks:[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7]}`。**耿鬼明說不是它改的**；比對 11-18/11-19/11-20 的備份都是舊值 → 是第三方 lane 的 fleet 級 model 正規化。兩組憑證現況都 HTTP 200、鏈路健康 → **只回報不動作**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 全程唯讀量測：`sessions_send`／`sessions_history` 不用、`openclaw channels status`、`openclaw cron list --all --json` / `cron get` / `cron runs --id`、`journalctl --user`、`systemctl --user show`、`curl /health`、uptime/free/df、sqlite（cp 三檔 → python sqlite3 ro）。
- 未改任何 cron 排程 / payload / timeout / sessionTarget / config / provider / model / fallback / channel / delivery；未重啟 gateway；未 arm 任何重啟；未跑其他 job；未碰 `elle.service`（system scope，需 root）。
- 唯一寫入：本記憶檔 + 一則 Discord 摘要（delivery.mode=none → 回覆只進 run log）→ channel `1482363974119854234`、**messageId `1573429260293771275`、deliveryStatus `sent`**（內容刻意不與 Picturecat 04:02 摘要重複，只補 Gengar lane、錯峰驗證、dreaming 守衛與 self-heal 排程變更）。

### 8) 給 Linder 的待決事項<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【自明】今晚 04:25 dreaming 是新版 fail-closed 守衛的首個真實測試** → 05:0x 之後讀 `36b493db` 的 ce 是否歸零；ce 仍=1 就代表守衛沒生效，要再看 `discord-selfheal-last-restart.ts` 的 arm 時戳。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【急】本 job ce=5**（DNS 風暴 + 01:02 的 589s 逼近上限）→ 本輪若轉綠即 ce=0；若又紅，建議把 payload 加上 `timeoutSeconds:1800`（姊妹 job Celesteela 有，Picturecat 沒有）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】self-heal 排程被改成每小時 :13/:43**（另一 lane 04:03 動的）→ 若不想要 24 次/日的 run 紀錄，可改回稀疏槽，但這樣 DNS 風暴的反應會慢。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】跨廠 fallback 仍 0**（`openai/*` Auth=no；我不碰憑證）。本 job 的 fallback 鏈已含 `openai/gpt-5.4-mini`（Picturecat 11-20 加的）→ 有朝一日加值即可用，但需要 firewall 放行（先前 api.openai.com = 421 Cloudflare）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】`agents.entries.gengar.model` 在 01:56 被第三方改過** → 找得到出處最好（`/tmp/openclaw.json.bak-*` 只留到 11-20 04:52，之後的變更無備份鏈）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**07:02**（本 job，3h 一次；07:02 剛好落在 dreaming 04:25–05:05 之後，可驗收 ce）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 04:16 — 耿鬼 inter-session 回覆（04:05 pong）已收，並回覆 4 項更正<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自述：6 支 cron 全 ok / ce=0（watchdog 02:04 next 04:04、heartbeat 03:59 skipped/no-route next 04:29、English reminder last 11-20 05:02 next 05:00、BBC next 07:00、skill-review ok、版本檢查 ok）；Discord 8/8 connected、inbound 薄但活（30m=0 / 60m=1 / 180m=2、newest 03:05:50 mrmime）；近 60 分鐘 429/overloaded=0、EAI_AGAIN=0、Clock change=0；**自述 11-20 16:16 起未動任何設定**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **已獨立確認 01:56:03 的 model config 變更不是耿鬼做的**：`~/.openclaw/openclaw.json` mtime=01:56；三份存留備份（`bak-1794982042` 11-18、`bak.ka-2212` 11-19、`bak-authprobe-1795121560` 11-20 04:52）**全部是舊值** `{primary: minimax/MiniMax-M3, fallbacks:[minimax-portal/MiniMax-M3]}` → 變更發生在 11-20 04:52 之後、且**沒有備份鏈**。兩組憑證現況皆 HTTP 200 → 不動作、不回退。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **更正 1（時槽）**：self-heal 排程 04:03:29 已由 `35,50 3,4,5 * * *` 改成 `13,43 * * * *` → 耿鬼講的「defer 到 05:05」已不成立，實際 defer 點是 **04:43 → 05:13 → 05:43**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **更正 2（守衛邏輯方向）**：耿鬼說「04:25 之前看到 startup-not-ready，self-heal 會因為 dreaming 在跑而跳過」→ **邏輯相反**。04:25 之前 dreaming 是 idle → 守衛會**開火重啟**（這才是安全且預期的行為）；只有在 **04:25–05:05 窗口內**才會 postpone。不能因為「它會跳過」而延後 04:25 前的真實檢查。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **更正 3（歸屬）**：02:11:47 的 gateway 重啟是 **Picturecat lane**，不是 rowlet lane；rowlet 自 11-19 起未重啟過 gateway。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **守衛實測**：`openclaw cron list --json`（預設 46 支 enabled）含 36b393db，且 `state.runningAtMs` 欄位存在（02eb0989 執行中時實見）→ 04:25–05:05 期間守衛會印「dreaming job still running (or state unknown) - postpone self-heal」並 exit 0、不 arm。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 數字對帳：耿鬼報的 inbound/429 與我方量測**完全一致**（我方 grep 的 2 筆 429 是 skill 路徑與 hex run id 的假陽性）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 07:02 輪次 — Gengar Keep-Alive（本輪）

### 1) ✅ 上輪待辦 #1 結案：dreaming 04:25 真的跑完了（新版 fail-closed 守衛生效）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion` 11-21 04:25:00 → **ok**、dur=**1,918,841ms**（≈32 分）、ce=**0**（11-20 是 `interrupted / owner unavailable` / 675,658ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 輸出確實落地：`memory/dreaming/light/2026-11-21.md` 21,549B、`rem/` 1,917B、`deep/` 154B，mtime 全是 **04:47**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 守衛證據：self-heal stamp 仍是 `1795198018`（= 02:06:58）→ 04:25–04:57 dreaming 窗口內**沒有 arm 任何重啟**；gateway MainPID **3573532**、ActiveEnterTimestamp **02:11:49**、NRestarts=**0** → dreaming 期間零重啟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 結論：11-20 那次「被 self-heal 腰斬」的根因已修好，**不再復發**（11-19 同槽 ok / 11-20 interrupted / 11-21 ok 三段曲閉環）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ✅ 上輪待辦 #2 結案：本 job ce 由 5 歸零<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `9d8b6001 Gengar Keep-Alive` 11-21 04:02:04 → **ok**、dur=251,639ms、ce=**0**（上輪 ce=5）。01:02 那次紅的原文：`⚠️ Agent couldn't generate a response`、dur=**589,772ms** → **差 10 秒撞上預設 600s 上限**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪（07:02:03 起跑）目前 running。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `timeoutSeconds` 仍是 **null**（沿用未動）→ 「加 1800」的備案保留。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⚠️ 新根因：**dreaming 把 event loop 餵飽 → Discord 心跳被餓死 5 分鐘**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:51–04:56 共 **39 筆** `gateway READY wait timed out after 15000ms; reconnecting with backoff`（最後一筆 04:56:12）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:54:53 diagnostic 真相：`eventLoopDelayP99Ms=180120.2`（**180 秒**）、`eventLoopDelayMaxMs=180120.2`、`eventLoopUtilization=1`、`cpuCoreRatio=1.001`；work 清單同時掛著 `agent:rowlet:cron:36b493db...:run`（age=1793s, q=1）+ **兩條** `agent:gengar:dreaming-narrative-memory-core-v2-{light,rem}` 的 model_call（age 202s/180s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 連帶 04:55:36 `fetch-timeout … likely event-loop starvation`（discord.com/api/v10/users/@me，elapsed 38.7s、timer delayed 35.9s）×3。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 05:00 之後無再 READY timeout；07:02 八頻道全 `running, connected` → **已自癒**。ingress 04:02 起 18 筆全 `completed`、`failed=0`（最新 07:03:26 rowlet = 本輪自己）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **與上輪的 DNS 風暴是兩回事**：這次不是網路壞，是**本機 event loop 被 dreaming 的 3 條平行 session 佔滿**，Discord 心跳被排在後面餓死。這比 self-heal 重啟更治本：重啟只會把 dreaming 砍掉，卻治不了並行度。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⚠️ 429 已從「Discord 內嵌 run」蔓延到「排程 job」，且高峰時段要修正<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `58fe15dc 每日論文討論` 11-21 **07:00:00 → error**、dur=205,152ms、err=**`⚠️ API rate limit reached. Please try again later.`** → ce 1→**2**。這是本輪唯一新增紅單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本視窗 minimax-portal `overloaded_error` 共 **7 筆**：05:01:46、05:04:36、05:32:48、06:02:01、07:01:35（全是 embedded run 通道，最後一筆緊貼本輪起跑）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → **修正上輪結論**：「429 高峰 = 09:00–14:00」不完整，**05:00–07:00 也在高峰內**（今天 07:00 就被打到）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `58fe15dc` 的 retry 排在 **07:04:25** → 下輪驗收 ce 是否回 1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Fleet：53 jobs / 46 enabled / 7 disabled — enabled **ok 36 / error 5 / skipped 4 / none 1**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
紅單（全部 enabled + error）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | ce | 最後失敗 | dur | 根因 | 下次 |
|---|---|---|---|---|---|---|
| 群體智能架構研究 | b37129c0 | 5 | 11-20 09:19 | 61,715ms | DNS 風暴 | 11-21 08:09 |
| 晨間情報 pipeline | 45ccf4e9 | 4 | 11-20 09:06 | 451,178ms | DNS 風暴 | 11-21 08:00 |
| clean-code研究 | 89e2cfe7 | 2 | 11-20 09:04 | 99,811ms | DNS 風暴 | 11-21 09:00 |
| 每日論文討論 | 58fe15dc | **2** | **11-21 07:00** | 205,152ms | **429 rate limit** | 11-21 07:04 (retry) |
| skill-collection-review-roaringmoon | c5352a84 | 1 | 11-20 03:56 | 169,007ms | DNS 風暴（另一 lane） | 11-27 03:56 |

- 前 4 支舊帳（11-20 08:32–09:19 的 DNS 風暴 + 網路錯誤）**不是新傷**；唯一新紅是 58fe15dc 的 429。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skipped 4 支全是 no-route/quiet-hours heartbeat（celesteela 06:42、picturecat 06:55、roaringmoon 06:56、greninja 06:56），ce=0 → 綠燈閒置；`heartbeat-flaaffy` 6e93c179 st=None（長期良性，next 02-03 13:56）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled 7：Charizard KA、PTCGP-daily-translation-update、verify Discord recovery after gateway restart、**tmp-openai-probe（st=error，殘留探針）**、gengar keep-alive、Rowlet Keep-Alive、RoaringMoon Keep-Alive。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 lane 全綠：Picturecat 02eb0989 ok 04:02（275,563ms）、Celesteela 880b5c17 ok 04:02（90,276ms）、self-heal d4cd45bc ok 06:43（811ms，每小時 :13/:43 生效）、Jormungand 40e09cd1 ok 03:06。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Discord / Gateway / 主機<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 8 個 enabled 帳號全部 `running, connected`（greninja disabled/stopped = 預期）；rowlet 帳號 inbound 最新 07:03。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：pid **3573532**、uptime since **02:11:49**、NRestarts=**0**（自 02:11 起未再重啟）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **復原後仍有 churn**：06:15:59、06:37:30(1006)、06:44:23(1005)、06:54:05(1005) 四次 `websocket closed → Gateway reconnect scheduled (resume=true)`；每次都自癒，但 10–20 分鐘一顆，與 04:51 的 event-loop 事件不同源，值得追。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 資源：`/health` 200 in **0.7ms**；load 0.80/0.56/0.49；mem available **20 GiB**；disk **60%**（265G/468G，180G 可用）；uptime 40d。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 設定面：沒有新的第三方漂移<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `agents.entries.gengar.model` = `{primary: minimax-portal/MiniMax-M3, fallbacks:[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7]}`；`~/.openclaw/openclaw.json` mtime 仍是 **11-21 01:56** → 上輪那筆第三方改動**未再變動、仍無備份鏈**，維持「只回報不動作」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `rowlet.model` = `minimax-portal/MiniMax-M3`（本 job payload 的 fallbacks 含 `openai/gpt-5.4-mini`，仍待憑證/防火牆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 全程唯讀：`openclaw cron list --all --json`、`cron_run_receipts` / `channel_ingress_events`（cp 三檔 → /tmp，python sqlite3 ro）、`journalctl --user -u openclaw-gateway`、`systemctl --user show`、`openclaw channels status`、`curl /health`、uptime/free/df、`openclaw.json`。
- 未改任何 cron 排程 / payload / timeout / sessionTarget / config / provider / model / fallback / channel / delivery；未重啟 gateway；未 arm 任何重啟；未跑其他 job。
- 唯一寫入：本記憶檔 + 一則 Discord 摘要（rowlet 帳號 → channel `1482363974119854234`；delivery.mode=none → 本回覆只進 run log）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新・最急】dreaming 與 Discord 搶 event loop**：dreaming 三條 session 平行跑時 p99 延遲 180 秒、Discord 心跳餓死 5 分鐘（39 筆 READY timeout）。建議把 dreaming 改成**序列**（rem → light → deep）或少一條並行，或把 Discord 心跳從同一 event loop 移開。**self-heal 重啟治不了這個**，只會重演 11-20 的腰斬。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【中】429 高峰 = 05:00–07:00 + 09:00–14:00**：紅單三支（45ccf4e9 08:00、b37129c0 08:09、89e2cfe7 09:00）正好踩在高峰前緣，考慮往前挪到 04:00–05:00 或 23:00 檔。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】本 job `timeoutSeconds=null`**（預設 600s），01:02 那次 589,772ms 差 10 秒就爆；今天已有 429 打死別的 job 的先例 → 建議加 `timeoutSeconds:1800`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【低】Discord 復原後 4 次 websocket churn**（1005/1006，10–20 分鐘一顆）→ 是否 provider 側或網路側，下輪對照。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】`tmp-openai-probe`（a94330a9）** 是 disabled 殘留探針且 st=error → 確認可廢。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**10:02**（本 job，3h 一次；可順手驗 58fe15dc 的 07:04 retry 結果）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 本輪外部寫入<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1573474619652968509`、deliveryStatus `sent`**（sentAt 1795215983225）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 10:02 輪次 — Gengar Keep-Alive（本輪）

### 1) ✅ Gengar lane：PASS（雙向通，10:03 完整回覆）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main` → runId **`83e2f164-0b82-4bff-bff8-e5389469b031`**、status=**ok**；10:03 收到完整自報（provider=`minimax-portal/MiniMax-M3` → `minimax/MiniMax-M3` → `minimax-portal/MiniMax-M2.7`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報 6 支自有 cron：**6 支全 enabled、4 ok / 0 error / 2 skipped、ce 全 = 0**（watchdog next 10:04、English reminder 05:00、BBC drill 07:00、版本檢查 00:00）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報近 90 分鐘 **429 = 2（09:02:22）／EAI_AGAIN = 0／timeout = 0**；8 個 enabled Discord 帳號全 `running, connected`；`openclaw.json` mtime 仍是 **11-21 01:56**（未再變動）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **耿鬼自我更正已接受**：他的 heartbeat `skipped` 原因是 `quiet-hours` → 證實 **`activeHours` 對 cron 來源的 heartbeat 確實生效**（他 04:16 的擔心不成立）；他也自行更正「04:25 之前應可重啟、04:25–05:05 才遞延」的說法。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 紅單 5 → **1**：上輪 4 支紅單**全部轉綠**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| job | id | 上輪 | 本輪結果 |
|---|---|---|---|
| 每日論文討論 | 58fe15dc | error ce=2（429） | **ok**（07:04 retry 成功）|
| 晨間情報 pipeline | 45ccf4e9 | error ce=4（DNS） | **ok**（08:00）|
| 群體智能架構研究 | b37129c0 | error ce=5（DNS） | **ok**（08:0x，stagger 15m）|
| clean-code研究 | 89e2cfe7 | error ce=2（DNS） | **ok**（09:00）|
| skill-collection-review-roaringmoon | c5352a84 | error ce=1 | **仍 error ce=1**（最後失敗 11-20 03:56，dur 169,007ms，下次 **11-27 03:56** → 非本週期）|

- → **唯一紅單是跨週期殘留**（7 天一次、11-27 才再跑），本輪無新增紅單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🔧 本輪動了 2 處（皆為本 job 自身 + 自身 skill，皆可逆）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **本 job `payload.timeoutSeconds`: null → 1800**（`openclaw cron edit 9d8b6001 --timeout-seconds 1800`，已複驗 `payload.timeoutSeconds = 1800`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - **依據（fleet 全域實證）**：所有 21 支有逾時設定的 job **一律 `top.timeoutSeconds = null`、值都在 `payload.timeoutSeconds`** → **payload 欄位才是真正生效的那個**；dreaming `36b493db` payload=2400 實跑 1,918,841ms（32 分）順利完成即為佐證。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - 本 job 原本 payload=null → 吃 **預設 600s 上限**；11-21 01:02 那次 589,772ms「差 10 秒就爆」正是撞這條線。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - ⚠️ `automations` 工具在本 cron session 內被限制（`Automations tool is restricted to the current automation.`），只能走 CLI；`skill_workshop` 也讀不到那支 skill（`Skill not found`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **`~/.openclaw/skills/openclaw-skills-openclaw-memory/SKILL.md` 補上缺漏的 `description:`** → 修掉每輪 skill 載入都噴的 `Skipping invalid skill ... error=description is required`（10:02:33 仍可見）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
   - 該 skill 原本 frontmatter 只有 `name` / `user-invocable` / `metadata`，是同資料夾 21 支套件中**唯一**沒有 description 的一支（`openclaw-skills-smart-ocr` 等皆有）→ 判定為封裝缺陷、單行修補。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：53 jobs / 46 enabled / 7 disabled — enabled **ok 36 / error 1 / skipped 8 / none 1**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skipped 由上輪 4 → **8**：全部是 heartbeat 家族（rowlet 09:38 / celesteela 09:42 / charizard 09:55 / picturecat 09:56 / roaringmoon 09:56 / greninja 09:56 / gengar 09:59 / mrmime 10:01），原因皆 `quiet-hours`、ce=0 → **綠燈閒置**，非故障。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-flaaffy` 6e93c179 st=none（every 417d、next 74d）→ 長期良性不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled 7 未變：Charizard KA、PTCGP-daily-translation-update、verify Discord recovery after gateway restart、**tmp-openai-probe a94330a9（st=error 殘留探針）**、gengar keep-alive、Rowlet Keep-Alive、RoaringMoon Keep-Alive。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 429 分布（provider minimax-portal / api=anthropic-messages / model=MiniMax-M3）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 07:02 之後真實 `status=429` 共 **4 筆**：**07:04:01、08:01:07（elapsed 67,065ms）、08:03:36、09:02:22**；其中 3 筆直接打掉 Discord embedded run（isError=true）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **DNS EAI_AGAIN = 0**（grep 唯一命中是我自己訊息裡的 "DNS EAI_AGAIN" 字樣 → 假陽性）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 沒有致命原因是因為 fallback 鏈真的吸收了：`minimax/MiniMax-M3`（api key）→ `minimax-portal/MiniMax-M2.7`；另 `openai/gpt-5.4-mini`（provider 有 `auth` 欄位、models 含 gpt-5.5/gpt-5.4-mini）也在鏈上。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **新觀察**：10:03:35 我送 sessions_send 給耿鬼時出現 `prepared model runtime plugin generation was superseded` → 觸發 `model-fallback/decision`（requested=minimax-portal/MiniMax-M3 → candidate=minimax/MiniMax-M3 → next=minimax-portal/MiniMax-M2.7）。該 run 仍正常送達，但代表**並行 session 偶爾會觸發 provider 換線**，值得下輪對照是否再發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Discord / Gateway / 主機<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 8 個 enabled 帳號全 `running, connected`（greninja disabled/stopped = 預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：pid **3573532**、uptime since **02:11:49**（7h50m）、**NRestarts=0**、RSS 4.28GB；`/health` → `{"ok":true,"status":"live"}`；load 0.90/0.62/0.51；mem available **20 GiB**；disk **60%**（266G/468G、180G 可用）；system uptime 40d。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本視窗 0 次 READY timeout / event-loop starvation**（上輪 04:51–04:56 dreaming 餓死 Discord 那次未復現；dreaming 下次 04:25 → 下輪才是重測窗口）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **websocket churn 持續（第三輪同型態）**：近 4 小時共 **18 次** close（**1005×8 / 1006×10**），06:04 → 08:49 約每 10–20 分一顆，全部自癒；截至 10:04 已連續 **74 分鐘無新 close**（上輪為 06:15/06:37/06:44/06:54，本輪 08:30/08:42/08:45/08:49）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 設定面：仍無新漂移<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `~/.openclaw/openclaw.json` mtime 仍是 **11-21 01:56:03**（size 25,024）→ 上輪那筆**第三方改動未再變動、仍無對應備份鏈**（三份備份 11-18 / 11-19 / 11-20 都帶舊 model chain）→ 維持「只回報不動作」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `gengar.model` = `{primary: minimax-portal/MiniMax-M3, fallbacks:[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7]}`；`rowlet.model` / `roaringmoon.model` = `minimax-portal/MiniMax-M3`；`agents.defaultModel` 同鏈。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改任何其他 cron 的排程 / payload / timeout / sessionTarget / delivery / model / fallback；未刪任何 job；未重啟 gateway；未 arm 任何重啟；未改 provider / channel / auth。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯讀來源：`openclaw cron list --all --json`、`cron get`、`journalctl --user -u openclaw-gateway`、`systemctl --user show openclaw-gateway`、`curl /health`、`openclaw.json`、`uptime/free/df`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 寫入：本 job 的 `payload.timeoutSeconds`（見 §3）、openclaw-memory skill 的 description（見 §3）、本記憶檔、一則 Discord 摘要。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（狀態更新）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【已解・本輪自行處置】** 本 job `timeoutSeconds` → 1800 ✅；openclaw-memory skill description ✅。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【仍急】dreaming 與 Discord 搶 event loop**：本輪視窗無 dreaming（下次 04:25）→ 尚未重測；上次實測 p99 延遲 180 秒、Discord 心跳餓死 5 分鐘（39 筆 READY timeout）。建議仍照上輪：dreaming 改**序列**（rem→light→deep）或少一條並行。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】429 高峰再確認**：今日 07:04 / 08:01 / 08:03 / 09:02 四筆全落在 07:00–09:00 帶 → **高峰至少 07:00–09:00，加上既知 09:00–14:00**。三支 08:00/08:09/09:00 的 job 今天靠 fallback 鏈撐過（都轉綠），但建議把 `45ccf4e9` / `b37129c0` / `89e2cfe7` 再往前挪到 05:00–06:00 檔。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中・連三輪】websocket churn**（近 4h 18 次、1005/1006、10–20 分一顆）：本輪起 08:49 後連續 74 分乾淨。尚未定性是 provider 側或網路側。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】`tmp-openai-probe`（a94330a9）** 仍是 disabled + st=error 的殘留探針；**本輪未刪**（刪 job 屬不可逆動作，等你點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【低】`skill-collection-review-roaringmoon`（c5352a84）** 唯一殘留紅單，最後失敗 11-20 03:56，下次 11-27 03:56 → 7 天後才會自動重試。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【新・低】`prepared model runtime plugin generation was superseded`**（10:03:35、並行 session 觸發 provider 換線）：單次事件、run 仍成功，先觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**13:02**（本 job，3h 一次；可順手驗 dreaming 前的 event-loop 基準與 ws churn 是否再發）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 本輪外部寫入<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1573519599045972109`、deliveryStatus `sent`**（sentAt 1795226707166）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 13:02 輪 — Gengar Keep-Alive (cron 9d8b6001) ✅
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) 本輪結論
- 環境健康、job 設定健全、近 8 小時全域 **0 個 error**；本 job 自身 11-21 04:02 / 07:02 / 10:02 三輪皆 ok，本輪 13:02:03 起 running。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 設定面：fallback 鏈已補上跨廠冗餘（重要改善）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `cron_jobs` 唯讀讀出本 job 現況：`schedule=every 10800000ms (3h)`、`payload.model=minimax-portal/MiniMax-M3`、`fallbacks=[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7, **openai/gpt-5.4-mini**]`、`timeoutSeconds=1800`、`sessionTarget=isolated`、`delivery.mode=none`、enabled=1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **跨廠冗餘已從 0 變 1**：11-19 記錄的「3 個 fallback 全是 MiniMax」已補上 `openai/gpt-5.4-mini`；上表 11-20 13:02–22:02 的 5 連敗正是 DNS 掛掉時全鏈同一廠所致，現在這種單點故障不再是全滅。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 歷史失敗歸因（本 job 唯讀 receipts）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 11-20 13:02 / 16:02 / 19:02 / 22:02 四筆 error 皆 `DNS lookup for the provider endpoint failed`（22:02 明寫 `getaddrinfo EAI_AGAIN api.minimax.io (timeout)` ×3 models）；11-21 01:02 為 `Agent couldn't generate a response`（泛用訊息，未標根因）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 11-21 04:02 起連續三輪（04:02 / 07:02 / 10:02）全 ok → **DNS 事件已自癒**；本輪複驗：`getent hosts api.minimax.io` A=210.71.227.48 / AAAA=2600:1417:e800::17d9:b62 皆可解析，`curl -s https://api.minimax.io/v1/models` → HTTP 401（無 key，預期），v4/v6 皆通。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 全域 receipts（近 8 小時）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 18 ok / 19 skipped / 3 running（13:02 三個 KA 同開：Celesteela / Gengar / Picturecat）/ **0 error**；`discord-selfheal-after-dreaming` 每 30 分鐘一支全 ok（04:13→12:43）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) dreaming × Discord event loop：問題復現，位置更精確<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `journalctl --user -u openclaw-gateway --since "12 hours ago"` 撈 READY timeout / event-loop / starvation → **28 筆，全部落在 2026-11-21T04 那一小時**（近 3 小時視窗 **0 筆**）；`Memory Dreaming Promotion` 04:25 起跑（receipt 04:25 ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → **因果再次成立**：dreaming 與 Discord 搶 event loop → READY timeout → Discord 心跳被餓死；上輪 39 筆、本輪 28 筆，同型態、量級相近。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 緩解現況：`discord-selfheal-after-dreaming` 每 30 分鐘自愈且全 ok；dreaming 後 04:46 起無新 timeout。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) websocket churn 仍在（連四輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 近 3 小時 journal 有 **13 筆** websocket close 類訊息（上輪近 4h 為 18 筆）→ 速率持平，未定性 provider 側或網路側。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改任何 cron 排程 / payload / fallback / timeout；未刪 job；未重啟 gateway；未改 provider / channel / auth。dreaming 改序列（rem→light→deep）仍**只回報不動作**（屬跨 job 設定變更，等 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯讀來源：`automations get/list`（受限 automation session 回報 job 不可見＝正常）、`cron_jobs` / `cron_run_receipts`（複製 DB+WAL/SHM 至 /tmp 後 python sqlite3 ro）、`journalctl --user -u openclaw-gateway`、`openclaw channels status`、`curl /health`、uptime/free/df、getent/curl 連通性。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 寫入：本記憶檔、一則 Discord 摘要。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（狀態更新）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【仍急・本輪再證】dreaming × Discord event loop**：本輪 28 筆 READY timeout 全落在 dreaming 的 04:xx 視窗（近 3h 乾淨）。建議 dreaming 改**序列**執行（rem→light→deep）或砍掉一條並行。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【已解】fallback 跨廠冗餘**：`openai/gpt-5.4-mini` 已在本 job fallback 鏈 → 11-20 那种 DNS 單點全滅不再發生。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【低】websocket churn** 連四輪未收斂（近 3h 13 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【低】`tmp-openai-probe`（a94330a9）** 殘留 disabled 探針；**【低】`skill-collection-review-roaringmoon`（c5352a84）** 殘留紅單（下次 11-27 03:56 才自動重試）—— 皆未刪，等點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**16:02**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 本輪外部寫入<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1573564613658935327`、deliveryStatus `sent`**（sentAt 1795237439496）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 16:02 輪 — Gengar Keep-Alive (cron 9d8b6001) ✅
<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) 本輪結論
- 環境健康、本 job 設定健全、自身連續 5 輪（04:02 / 07:02 / 10:02 / 13:02 完成皆 ok + 本輪 16:02 running）零失敗；近 8h 全域 238 筆 receipts = 125 ok / 108 skipped / 4 running / **1 error**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 環境基線（唯讀）
- gateway：PID 3573532、ActiveEnter 2026-11-21 02:11:49（uptime ~13h50m）、`/health` HTTP 200（2.5ms）、`systemctl --user is-active` = active。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 系統：uptime 40d 21h49m、load 0.90/0.83/0.65、RAM 31Gi（available 20Gi、swap 0B）、`/` 使用 60%（179G 可用）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：api.minimax.io 可解析（AAAA 2600:1417:e800::17d9:b62 / ::b6b）；`curl https://api.minimax.io/v1/models` → HTTP 401（無 key，預期）、0.43s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- channels：8 個 Discord 帳號全部 running + connected（greninja 為 disabled/stopped 的既有設定）；近 3h 0 筆 Discord 送出失敗、0 筆 embedded run isError。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 本 job 設定面（唯讀）
- `schedule=every 10800000ms`（anchorMs 1780452122570 = 2026-06-03 10:02:02）、`sessionTarget=isolated`、`wakeMode=now`、`payload=agentTurn "keep-alive test"`、`model=minimax-portal/MiniMax-M3`、`fallbacks=[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7, openai/gpt-5.4-mini]`、`timeoutSeconds=1800`、`delivery.mode=none`、`enabled=1`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- state：`consecutiveErrors=0`、`consecutiveSkipped=0`、`scheduleErrorCount=0`、`lastRunStatus=ok`(13:02)、`nextRunAtMs`=11-21 16:02:03。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 本 job 歷史 receipts
- 16:02:04 running（本輪）／13:02 ok 130s／10:02 ok／07:02 ok／04:02 ok／**01:02 error「Agent couldn't generate a response」**／11-20 22:02、19:02、16:02 DNS error、13:02 error。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 04:02 起連 4 輪完成皆 ok，本輪為第 5 輪；連續失敗已清零。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 新發現：三支 KA 同時發火 → provider plugin runtime 競態（連三輪重現）
- journal 事件「prepared model runtime plugin generation was superseded」lane task error：**10:03:35**(gengar:main)、**13:02:20**(picturecat:main)、**16:02:27**(picturecat:main)。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 根因：三支 KA 的 anchor 只差 ~72ms（9d8b6001=…122570、880b5c17=…122603、02eb0989=…122531）→ 永遠同時發火、共用同一 provider plugin runtime → 先到者的 prepared runtime 被後到者取代。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 影響範圍：cron 本身仍 ok（三輪 receipts 皆 ok），但會打斷同時段的主 session lane（gengar / picturecat 的 main）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 建議（**本輪未執行**）：把三支 KA 的 anchor 錯開 ≥3 分鐘（例：Gengar :02 / Celesteela :06 / Picturecat :10），並整體挪進 05:00–06:00 低 429 帶 → 同時解掉競態與 provider 尖峰。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) dreaming × Discord event loop：仍為唯一高優先未解項
- 近 12h 共 28 筆 event-loop starvation / liveness warning，**全部落在 04:07–04:55**（dreaming 04:25 視窗）；近 3h **0 筆**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming（36b493db）下次 **11-22 04:25** → 本輪視窗內沒有新的 dreaming 可驗，待明日再測。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `discord-selfheal-after-dreaming`（d4cd45bc，每 30 分鐘）全 ok，下次 16:13。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) websocket churn 連五輪未收斂
- Discord gateway websocket close（code=1005, reasonBytes=0）近 3h **13 筆**（上輪近 3h 同為 13 → 速率持平）、近 12h 212 筆；最近一筆 16:03:10。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 429 / rate limit：尖峰帶再收斂
- 24h 內含 rate limit 的 receipts 6 筆：11-20 17:11、23:35；11-21 **00:56**(02eb0989)、**01:02**(9d8b6001)、**03:00**(40e09cd1)、**07:00**(58fe15dc)。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 今日尖峰帶 = **00:56–07:00**；上輪所列的 **09:00–14:00 帶今日 0 筆**（該帶未重現）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 12:02:32 曾出現「rate-limit same-model retry 1/3 for minimax-portal/MiniMax-M3 delayMs=10000」→ 同廠同 model 重試，非跨廠 fallback。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 新發現：17 個 skill 被持續跳過（靜默失效）
- 近 3h 204 筆「Skipping invalid skill」，13:02 與 16:02 視窗各命中同一組 **17 個檔**（非新增，屬既有狀態）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 缺 `description`（12）：card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、rosclaw/extensions/openclaw-plugin/skills/{check-status,navigate-to,pick-object,take-photo}、system-design-six-dimensions-analyzer、web-fetch-troubleshooting。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- frontmatter invalid（5）：excel-image-pipeline、human-behavior-simulation、image-attendant、ocr-confidence-mark。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 影響：這些 skill 在 agent 端不會被載入；**本輪未修**（跨專案檔案，且 skill_workshop 規範不直接改寫他人 skill）→ 回報待點頭。修法：每個 SKILL.md frontmatter 補一行 `description:`（≤160 bytes）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 其他觀察
- `heartbeat-celesteela`（46242a4c）：**08:12:45 「cron: job execution timed out」＝近 8h 全域唯一 error**；其後每 30 分鐘 `skipped: no-route`（consecutiveSkipped=10），屬無來源可達的正常跳過；該 job 無 fallback、無 timeout 設定。無需處理，僅記錄。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `每日 OpenClaw 備份`（af94aa92）16:00 ok（128s）；三支 KA 於 16:02 同時 running（880b5c17 / 9d8b6001 / 02eb0989），另 heartbeat-mrmime（bcf270b8）16:01:09 running。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 邊界（本輪刻意沒動）
- 未改任何 cron 排程 / anchor / payload / fallback / timeout / delivery / model；未刪 job；未重啟 gateway；未改 provider / channel / auth；未改任何 skill 檔。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯讀來源：`cron_jobs` / `cron_run_receipts`（複製 DB+WAL/SHM 至 /tmp 後以 python sqlite3 唯讀查詢）、`journalctl --user -u openclaw-gateway`、`systemctl --user show openclaw-gateway`、`openclaw channels status`、`curl /health`、uptime/free/df、getent/curl 連通性。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 寫入：本記憶檔、一則 Discord 摘要。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 12) 給 Linder 的待決事項（狀態更新）
1. **【仍急】dreaming × Discord event loop**：12h 28 筆 starvation 全在 dreaming 視窗、近 3h 乾淨；建議 dreaming 改**序列**（rem→light→deep）或砍掉一條並行。下一個可驗窗口 = 11-22 04:25。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新・中】三支 KA 同 anchor 的 plugin runtime 競態**（連三輪 10:03/13:02/16:02）：建議錯開 anchor ≥3 分 + 整體挪到 05:00–06:00 帶。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】429 尖峰**：今日命中 00:56–07:00（4 筆），09:00–14:00 今日 0 筆；建議把 `45ccf4e9` / `b37129c0` / `89e2cfe7` 挪到 05:00–06:00。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【新・中】17 個 skill 被跳過**（12 缺 description + 5 invalid）→ 修法明確但屬跨專案檔案，等你點頭才動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】websocket churn** 連五輪（近 3h 13 筆，與上輪持平）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【低】`tmp-openai-probe`（a94330a9）** 殘留 disabled 探針、**`skill-collection-review-roaringmoon`（c5352a84）** 殘留紅單（下次 11-27 03:56 才自動重試）—— 皆未刪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**19:02**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 13) 本輪外部寫入
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1573610164383260704`、deliveryStatus `sent`**（sentAt 1795248299589）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-21 19:02 — PASS（lane 雙向通）／🔁 plugin runtime 競態**連四輪重現並新增 announce 破口**／📉 websocket churn 首次收斂（3h 13→9）／✅ **dreaming 11-21 04:25 首度乾淨跑完**（可降為觀察項）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（19:03 完整回覆）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main` → runId **`ee0c4d53-139c-4ce5-9198-682b91a8e2ed`**、status=**ok**；19:03 收到完整回覆（provider=`minimax-portal/MiniMax-M3` → `minimax/MiniMax-M3` → `minimax-portal/MiniMax-M2.7`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報 6 支自有 cron **全 ok、ce=0**：watchdog `29c2d630` 18:04 ok、heartbeat `c29eca0f` 18:59 ok（8.5–21.2s）、English `ac9e7ada`、BBC `88810bfe` 07:00 ok、skill-collection `7767e03b`、版本檢查 `f5148ff0`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報近 60 分鐘 **429/overloaded = 2**（同一 event 18:04:43，即 watchdog 自己的那一輪，仍記 ok/delivered）、**EAI_AGAIN = 0**、cron/model timeout = 0、clock-change cache flush = 0 → 11-20 那場 DNS/時鐘風暴**未再復發**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報「自 10:02 後未動任何設定」；`~/.openclaw/openclaw.json` mtime 仍 = 2026-11-21 01:56:03，與我方量測一致。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 環境基線（唯讀）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：PID 3573532、ActiveEnter 2026-11-21 02:11:49、**NRestarts=0**、`/health` HTTP **200（7.6ms）**、`systemctl --user is-active` = active。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 系統：uptime **41d 50m**、load 0.64/0.55/0.51、RAM 31Gi（available 20Gi、swap 0）、`/` 使用 60%（179G 可用）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：`api.minimax.io` 解析 OK（`2600:1417:1b::cb45:8ae1`）；`curl https://api.minimax.io/v1/models` → HTTP **401**（無 key，預期）、0.79s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- channels：8 個 Discord 帳號全部 running + connected（greninja 為 disabled/stopped 的既有設定）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 本 job 設定面（唯讀）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `schedule=every 10800000ms`（anchorMs 1780452122570 = 2026-06-03 10:02:02）、`sessionTarget=isolated`、`wakeMode=now`、`payload=agentTurn "keep-alive test"`、`model=minimax-portal/MiniMax-M3`、`fallbacks=[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7, openai/gpt-5.4-mini]`、`timeoutSeconds=1800`、`delivery.mode=none`、`enabled=1`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- state：`consecutiveErrors=0`、`consecutiveSkipped=0`、`scheduleErrorCount=0`、`lastRunStatus=ok`(16:02，dur 186,931ms)、`nextRunAtMs`=11-21 19:02:04。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 本 job 歷史 receipts<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 19:02:04 running（本輪）／16:02 ok 187s／13:02 ok 130s／10:02 ok 195s／07:02 ok 273s／04:02 ok 252s／**01:02 error「Agent couldn't generate a response」**／11-20 22:02、19:02、16:02 DNS error。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 04:02 起連 **5 輪完成皆 ok**，本輪為第 6 輪；近 6h cron 層面非 ok/skipped 的失敗 = **0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 🔁 plugin runtime 競態：連四輪重現，且**新增 announce 破口**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal「prepared model runtime plugin generation was superseded」lane task error：**10:03:35**(gengar:main)、**13:02:20**(picturecat:main)、**16:02:27**(picturecat:main)、**19:02:53**(picturecat:main)、**19:03:53**(gengar:main)。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **新證據**：同一批時點還伴隨 `[agents/sessions-send] sessions_send announce flow failed`，近 24h 共 **13 筆**（每次 KA 發火 1–2 筆）→ 同源競態**不只打斷 lane，也讓 announce 步驟失敗**；惟被呼叫端的回覆本身仍回傳到呼叫端（本次耿鬼回覆完整收到）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- anchor 偏移（DB 實測）比上輪更緊：**Picturecat −39ms／Gengar 0／Celesteela +33ms** → 三支每輪 **19:02:04–19:02:06 同時發火**（上輪記為 ~72ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 影響：三支 cron 本身 receipt 皆 ok（19:02:04 gengar running／19:02:04 picturecat running／19:02:06 celesteela **ok**），但同時段 gengar / picturecat 的 **main lane 被打斷**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 建議（**本輪仍未執行**）：把三支 KA 的 anchor 錯開 ≥3 分鐘（Gengar :02／Celesteela :06／Picturecat :10）並整體挪進 05:00–06:00 低 429 帶 → 一次解掉競態與 provider 尖峰。**這是連續四輪未執行的建議，等一句點頭。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 429：晚間尖峰再現（18:01／18:04）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 近 12h 含 rate limit 的事件 4 筆：10:31:36、12:02:32、**18:01:43**、**18:04:43**（皆 provider=minimax-portal、`overloaded_error`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 18:01/18:04 兩筆 `elapsedMs=73065`／`164842` → **provider 端高延遲後才回 429**；同 model retry 1/3 delay 10s → 2/3 delay 20s（皆同廠同 model，非跨廠 fallback）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 今日尖峰帶由 00:56–07:00 **擴張到 18:00–18:05**；09:00–14:00 帶僅 12:02 一筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) websocket churn：六輪以來首次收斂<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `discord gateway websocket closed`（code=1005, reasonBytes=0）近 **3h 9 筆**（上輪 13）、6h 22、12h 47 → 3h 速率 **13→9 下降**；最近一筆 18:51:03。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) ingress / delivery：乾淨<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `channel_ingress_events` 近 3h **116 筆全部 completed**、0 失敗；Discord 8/8 connected。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `delivery_queue_entries` 近 24h 42 completed；唯一 failed 列是 11-20 22:10 的舊 outbound-prepared 殘留（11-13/14/15 同型），**非本輪**、未處置。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) ✅ dreaming × Discord：今晚已驗證成功（耿鬼回報交叉確認）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db` Memory Dreaming Promotion：11-21 04:25:00 **ok**（DB receipt；上一輪 11-20 為 interrupted）→ **dur 1,918,841ms、未截斷**，為 11-19 以來第一次乾淨跑完。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- fail-closed self-heal 守衛同夜 `:13`／`:43` 時槽各跑 744–789ms、**未誤 arm 重啟** → 修正有效。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc` discord-selfheal-after-dreaming：18:43 / 18:13 / 17:43 全 ok，每 30 分鐘一次，下次 19:13。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming 下次 **11-22 04:25** → 本輪無新 dreaming 可驗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 17 個 skill 被持續跳過（連三輪同一組，仍未修）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 近 3h **238 筆**「Skipping invalid skill」（上輪 204），命中**同一組 17 個檔**（非新增，屬既有狀態）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 缺 `description`（12）：card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、rosclaw/extensions/openclaw-plugin/skills/{check-status,navigate-to,pick-object,take-photo}、system-design-six-dimensions-analyzer、web-fetch-troubleshooting。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- frontmatter invalid（5）：excel-image-pipeline、human-behavior-simulation、image-attendant、ocr-confidence-mark。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪仍未修（跨專案檔案，且 skill_workshop 規範不直接改寫他人 skill）→ 回報待點頭；修法：各 SKILL.md frontmatter 補一行 `description:`（≤160 bytes）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 紅單（2 張，皆非本 job）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `c5352a84` skill-collection-review-roaringmoon **ce=1**（lastErr: LLM request failed: DNS lookup）→ 下次 **11-27 03:56** 才自動重試。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `a94330a9` tmp-openai-probe：已 disabled、ce=2（Codex tool-policy 限制）→ 未刪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- heartbeat no-route skipped：greninja cs=37／picturecat cs=29／rowlet cs=23／roaringmoon cs=21／celesteela cs=16 → **ce 皆 0**，屬無來源可達的正常跳過。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 12) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改任何 cron 排程 / anchor / payload / fallback / timeout / delivery / model；未刪 job；未重啟 gateway；未改 provider / channel / auth；未改任何 skill 檔。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯讀來源：`sessions_send`、`cron_jobs` / `cron_run_receipts` / `channel_ingress_events` / `delivery_queue_entries`（複製 DB+WAL/SHM 至 /tmp 後以 python sqlite3 ro 查詢）、`journalctl --user -u openclaw-gateway`、`systemctl --user show openclaw-gateway`、`openclaw channels status`、`curl /health`、uptime/free/df、getent/curl 連通性。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 寫入：本記憶檔、一則 Discord 摘要。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 13) 給 Linder 的待決事項（狀態更新）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【高・連四輪】三支 KA 同 anchor 的 plugin runtime 競態**：現已證實**連帶打斷 sessions_send announce**（24h 13 筆）。建議錯開 anchor ≥3 分（Gengar :02／Celesteela :06／Picturecat :10）＋整體挪到 05:00–06:00。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【高・首度驗證成功】dreaming × Discord**：11-21 04:25 ok、1,918,841ms 未截斷、fail-closed 守衛未誤 arm → **建議由「未解」降為「觀察」**，下一個可驗窗口 11-22 04:25。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】17 個 skill 被跳過**（238 筆/3h、同一組 17 檔）→ 修法明確但屬跨專案檔案，等你點頭才動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】429 晚間尖峰**：18:01 / 18:04 兩筆 provider overloaded（elapsed 73s/165s）→ 建議把 `45ccf4e9` / `b37129c0` / `89e2cfe7` 挪到 05:00–06:00。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】websocket churn 首次收斂**（3h 13→9，連六輪後第一次下降）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【低】殘留**：`c5352a84` 紅單（11-27 才重試）、`a94330a9` disabled 探針 —— 皆未刪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**22:02**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 14) 本輪外部寫入<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1573655861845426247`、deliveryStatus `sent`**（sentAt 1795259194714）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 15) 19:2x 追加：gengar 的 announce 最終補達（交叉驗證 §5 的結論）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 19:03 的 `sessions_send` 呼叫已 inline 收到完整回覆（runId `ee0c4d53-139c-4ce5-9198-682b91a8e2ed`），但 journal 當下記 `sessions_send announce flow failed`（19:03:53）→ **announce 稍後仍補達**（本則 inter-session announce，內容與 inline 回覆一致）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 印證 §5 判斷：競態破的是 **announce 路徑**（prepared model runtime 被取代），**不是回覆本體**；被呼叫端無論如何都拿得到完整回覆，只是 announce 可能失敗或延遲。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報內容與我方 DB 量測一致（6 支 cron 全 ok、ce=0、429×2 同 event 18:04:43、EAI_AGAIN=0、config mtime 01:56:03、pid 3573532 up 16h51m、Discord 8/8、dreaming 04:25 ok 1,918,841ms）→ **雙向交叉驗證通過**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-21 22:02 — PASS（lane 雙向通）／🔁 plugin runtime 競態**連五輪重現**（announce 又破）／✅ **全艦連 13 小時零真失敗**（09:00→22:02）／📉 ws churn 回到 13／🐢 兩個 heartbeat skip 耗時異常（505s／240s）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Gengar lane：PASS（22:03 inline 回覆）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:gengar:main` → runId **`1a353776-be0d-44ea-9192-301800218371`**、status=**ok**；22:03 收到完整回覆（provider=`minimax-portal/MiniMax-M3` → `minimax/MiniMax-M3` → `minimax-portal/MiniMax-M2.7`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報 **未降級**：兩份 MiniMax 憑證皆 HTTP 200，fallback 鏈待命。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼 6 支自有 cron **全 ok、ce=0**：watchdog 22:04 ok／heartbeat c29eca0f 21:59 ok（next 22:29）／English reminder ok（next 11-22 05:00）／BBC ok（next 11-22 07:00）／skill-collection-review ok（next 11-28 07:32）／版本檢查 ok（next 11-22 00:00）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自報近 60 分鐘 429/overloaded=2（18:04:43 watchdog 那次）、EAI_AGAIN=0、timeout=0；Discord **8/8 enabled accounts running+connected**（greninja disabled）、4 次 ws close 全自癒、ingress 63 筆/時。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐ 全艦 **09:00→22:02 連 13 小時零真失敗**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 內全部失敗共 75 筆，分布：11-20 22:00=16／23:00=29／11-21 00:00=9／01:00=2／03:00=1／04:00=11／05:00=2／06:00=1／07:00=2／08:00=1／**22:00=1（就是本 job 自己的 running receipt）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → **真失敗最後一次落在 11-21 08:12**（heartbeat-celesteela timeout）；之後 14 小時全綠。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 11-20 22:00–08:12 那 74 筆的組成：heartbeat 群 timeout（celesteela 9、mrmime 8、picturecat 8、charizard 7、rowlet 7、roaringmoon 7、gengar 7、greninja 4）＋ DNS 風暴（`All models failed (3): … EAI_AGAIN api.minimax.io`）＋ 429 rate limit ＋ `ca222989` 系統維護 6 次 network error。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🔁 plugin runtime 競態**連五輪重現**，且**再破一次 announce**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `22:02:30` lane=`agent:picturecat:main` → `prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/picturecat/agent`（nested 5ms／session 5ms）→ **`sessions_send announce flow failed`**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `22:04:12` lane=`agent:gengar:main`（**就是我 22:02 那次探測**）→ 同樣錯誤（nested 6ms／session 7ms）→ **`sessions_send announce flow failed`（22:04:12.490）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 這次連 **fallback 鏈都被捲進去**：`minimax-portal/MiniMax-M3 candidate_failed` → `minimax/MiniMax-M3 candidate_failed` → 第三個候選 `minimax-portal/MiniMax-M2.7` 才接住 → **實際多花 2 次 fallback hop**，reason 一律是 `prepared model runtime plugin generation was superseded`（不是 provider 掛了）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **再次證實 19:2x 的判斷**：競態破的是 **announce 路徑**（prepared model runtime 被取代），**回覆本體照樣完整落地**（我這邊 22:03 inline 收到耿鬼全文；Picturecat 端 22:02:04 那輪 dur=127s 最終 ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⚠️ 三支 KA 的 anchor 錯峰**只做成一半**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 nextRunAtMs：**Picturecat `1795269724143`（22:02:04.143）／Gengar `1795269724129`（22:02:04.129）／Celesteela `1795269726157`（22:02:06.157）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → Celesteela 已成功錯開到 :06，但 **Gengar 與 Picturecat 只差 14ms（實質同時）** → 本輪的 plugin runtime 競態（22:02:30 picturecat / 22:04:12 gengar）正落在這個重疊窗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 修法（仍未執行）：把 Gengar 或 Picturecat 其中一支的 anchor 拉開 ≥3 分鐘。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 429：只有 2 筆真 429（journal 文字回音已排除）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實 provider 429：`21:01:44`（minimax-portal, elapsed 98ms）與 `21:03:58`（elapsed 12ms），同屬 embedded runId `47976ad3`（= heartbeat-mrmime `bcf270b8` 21:01:11 那輪，dur 382s）→ **該輪最終 receipt = ok**，連敗被 fallback 吸收。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `EAI_AGAIN` 文字命中 2 筆 → **實為 0**：19:07:08 是我上一輪把「EAI_AGAIN=0」寫進日誌被 echo，22:04:12 是耿鬼回覆裡的「EAI_AGAIN = 0」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 📉 websocket churn：3h 內 13 次 code=1005（回到上上輪的 13，未延續 9 的下降）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 全部為 `code=1005 reasonBytes=0`，時間點 19:22／19:35／20:01／20:04／20:09／20:12／20:27／20:41／21:03／21:14／21:35／21:49／22:04。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 每次都被接回：`openclaw channels status` → **8 個 enabled 帳號全 running+connected**（greninja disabled），無連線卡死。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 🐢 兩個 heartbeat skip 耗時異常（505s／240s）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d82f78e3 heartbeat-rowlet` 20:08:22 **skip 耗時 505s**；`46242a4c heartbeat-celesteela` 20:12:47 **skip 耗時 240s**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 兩者最後都落 `skipped`（ce=0，屬「無來源可達」的正常跳過），但**耗時與 §6 的 ws close 密集時段重疊**（20:09／20:12 兩次 close 夾在中間）→ 推測 route 解析被 ws 重連拖慢。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 影響面小（跳過本來就該跳過），但 505s 會佔住 cron slot；列入觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) dreaming × Discord：**第二輪驗證成功，可正式降為觀察**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db` 11-21 04:25:00 **ok / dur=1,919s（31.99 分）**，未截斷；對應的 `d4cd45bc discord-selfheal-after-dreaming` 21:43 ok dur=1s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → fail-closed 守衛連兩輪都沒有誤砍 dreaming → **本項由「未解」正式轉為「觀察」**（下一個可驗窗口 11-22 04:25）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 17 個 skill 被持續跳過（221 筆/3h，較上輪 238 略降）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 缺 `description`（12）：card-lookup、meta-analyzer、network-security-defense、prompt-injection-defense、prompt-injection-filter、ptcgp-card-download、ptcgp-card-lookup、rosclaw/extensions/openclaw-plugin/skills/{check-status,navigate-to,pick-object,take-photo}、system-design-six-dimensions-analyzer、web-fetch-troubleshooting（每檔 13 次/3h）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- frontmatter `BAD_INDENT`（5）：excel-image-pipeline、human-behavior-simulation、image-attendant、ocr-confidence-mark、＋ 同一批命中 52 次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 狀態**與前三輪完全相同**（同一組 17 檔，非新增）→ 仍未修（跨專案檔案，等 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 紅單（僅 1 張，且非本 job）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `c5352a84` skill-collection-review-roaringmoon **ce=1**（lastErr: DNS lookup）→ 下次 **11-27 03:56** 才自動重試。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `a94330a9` tmp-openai-probe：disabled、ce=2 → 未刪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat no-route skipped`：greninja cs=43／picturecat cs=35／roaringmoon cs=27／celesteela cs=22／rowlet cs=23 → ce 皆 0，屬正常綠燈閒置。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `6e93c179 heartbeat-flaaffy` st=None → 排程形同停擺（良性長態，沿用未結案）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 姊妹 job（同一輪錨點）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `02eb0989` Picturecat KA **ok / 127s**（22:02:04）、`880b5c17` Celesteela KA **ok / 49s**（22:02:06）、本 job `9d8b6001` 22:02:04 起跑（running）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `29c2d630` Gengar watchdog 22:04:23 ok / 3s、`c29eca0f` heartbeat-gengar 21:59:43 ok / 10s。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1` Jormungand daily all-agent health、`13ac4b5a` 健康回報 20:05 ok、`af94aa92` 備份 16:00 ok、`36b493db` dreaming 04:25 ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 12) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改任何 cron 排程 / anchor / payload / fallback / timeout / delivery / model；未刪 job；未重啟 gateway；未改 provider / channel / auth；未改任何 skill 檔。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 唯讀來源：`sessions_send`、`openclaw automations list --all --json`、`cron_run_receipts` / `channel_ingress_events` / `delivery_queue_entries` / `cron_jobs`（複製 DB+WAL/SHM 至 /tmp 後以 python sqlite3 ro 查詢）、`journalctl --user -u openclaw-gateway`、`systemctl --user show openclaw-gateway`、`openclaw channels status`、`ss -tlnp`、uptime/free/df。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 寫入：本記憶檔、一則 Discord 摘要。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 13) 給 Linder 的待決事項（狀態更新）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【高・連五輪】plugin runtime 競態**：本輪**連 fallback 鏈都被掃到**（多 2 hop），announce 又破一次。現已確認「破的是 announce、不是回覆」→ 影響降級為「延遲 + 多燒 token」，但**Gengar 與 Picturecat 的 anchor 只差 14ms**，建議至少把其中一支拉開 ≥3 分。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【已結案・觀察】dreaming × Discord**：連兩輪乾淨跑完（04:25 / 1,919s）→ 守衛 fail-closed 有效，轉觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】17 個 skill 被跳過**（221 筆/3h、同一組 17 檔，連四輪未修）→ 修法明確（各 SKILL.md frontmatter 補 `description:`）但屬跨專案檔案，等你點頭才動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【低】ws churn 回到 13 次/3h**（上輪 9 是第一次收斂，未延續），全部自癒、8/8 connected → 只觀察。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低・新】兩個 heartbeat skip 耗時 505s／240s** → 疑似 ws 重連拖慢 route 解析；跳過本身無害，但佔 slot。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【低】殘留**：`c5352a84` 紅單（11-27 才重試）、`a94330a9` disabled 探針 —— 皆未刪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**11-22 01:02**（本 job，3h 一次）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 14) 本輪外部寫入<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 摘要（rowlet 帳號）→ channel `1482363974119854234`、**messageId `1573701364024877151`、deliveryStatus `sent`**（sentAt 1795270043378）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- MEMORY.md 新增 3 條可複用教訓：plugin runtime 競態會掃掉 fallback 鏈（多 2 hop）／KA anchor 錯峰要用 `state.nextRunAtMs` 自驗／`cron_run_receipts.job_id` 必須完整 UUID。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 15) 22:04 追加：**announce 最終仍補達**（第二次實證）＋ 對端自報有過期數字<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 22:04:12 journal 的 `sessions_send announce flow failed` 之後，**該則 inter-session announce 仍送達本 session**（22:0x 收到 `agent:gengar:main` 的完整回覆）→ 與 19:03 那輪**完全同型**，兩輪實證：journal 報 announce 失敗 ≠ 回覆遺失。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 查 22:03:30–22:15 只剩那一行 announce failure、**沒有第二筆 announce 失敗** → announce 是走另一條 relay 路徑補達，不是同一路徑重試。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `delivery_queue_entries` 近 2h 只有 2 筆 `outbound-prepared-v1 / completed`（cron-direct），**沒有 gengar main 的 announce 條目** → announce 不經 delivery queue，別用該表推 announce 狀態。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **對端自報數字可能過期**：耿鬼 22:03 回覆稱「近 60 分鐘 429/overloaded = 2（event 18:04:43）」——18:04:43 明顯不在 22:03 往前 60 分鐘內，且與上一輪（19:02）引用同一個時間點 → **該欄位疑似沿用舊值**；我方 DB/journal 量測的真 429 是 **21:01:44 與 21:03:58**（minimax-portal、同一 embedded runId `47976ad3`）。其餘欄位（6 支 cron 全 ok/ce=0、8/8 connected、ws close 4 次/時、ingress 63 筆/時、gateway up 19h51m、config mtime 01:56:03）與我方量測**一致**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 記憶更新：MEMORY.md「plugin runtime 競態」條補上 announce 晚到（兩輪實證）＋ 對端 429 自報須以 journal 為準。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
