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
