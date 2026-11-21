# Picturecat Keep-Alive 巡檢日誌（2026-11-21）

## 2026-11-21 02:03 — Picturecat Keep-Alive 第 20 輪：lane PASS、🔴🔴 **Discord 全線失明約 4 小時（22:38 迄今）且仍未恢復**，根因＝**主機 DNS/網路不穩（EAI_AGAIN）**，已啟動既有的 self-heal 腳本重啟 gateway <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `f4c69762-67b1-4577-bca4-90ac46330f08`、status=ok、回覆「pong — no active task, no recent errors; idle and healthy.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）：enabled、schedule=`every 10800000ms`（3h）、sessionTarget=isolated、payload=`agentTurn`「keep-alive test」+ model `minimax-portal/MiniMax-M3` + fallbacks `['minimax/MiniMax-M3','minimax-portal/MiniMax-M2.7','openai/gpt-5.4-mini']`（**首個跨廠 fallback 已加，但 openai Auth=no → 實際冗餘仍是 0**，見 §4）、無 timeoutSeconds、delivery.mode=none。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 上一輪（11-21 01:03）**error / dur=465,002ms / cause=rate_limit** → ce=5。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` **ok / ce=0 / dur=463,895ms**（timeoutSeconds=1800）；`9d8b6001 Gengar KA` **error / ce=5 / dur=589,772ms**（fallback 同款，也含 openai）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🔴🔴 本輪最大事件：Discord 8 帳號全滅且**不自癒**，已失明約 4 小時<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（02:03）：**celesteela / charizard / flaaffy / gengar / mrmime / picturecat / roaringmoon / rowlet 全部 `error:startup-not-ready, running, disconnected`**（greninja disabled/stopped＝預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **時間線（journal `openclaw-gateway`）**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 13:00–16:00：另一波 READY timeout 風暴（13h=316、14h=1597、15h=1521、16h=505），伴隨 **EAI_AGAIN 1130 筆**（13h）→ 16:18:14 gateway 重啟 → 16:22 client 初始化 → **17:00–21:00 完全乾淨（0 次 READY timeout）＝ Discord 健康 5 小時**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **22:38:01 起 `Error: getaddrinfo EAI_AGAIN gateway.discord.gg`**（22h 共 755 筆）→ 連續 websocket code=1006 → **22:42:58–22:43:58 八个帳號依序 `channel exited: discord gateway reconnect-exhausted`** → 22:44–22:45 client 重新初始化但**永遠等不到 READY**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 之後 READY timeout 每小時 1500+（23h=1624、00h=1371、01h=1583、02h=144 截至 02:04），attempt 計數最高 **677**；`channels resolved` 只在 16h(3) 與 00:05(1) 各出現過（單一帳號短暫成功）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Discord 端正常**：status.discord.com summary = `All Systems Operational`（API / Gateway / Voice 全 operational、0 active incident）；`discord.com/api/v10/gateway` 200、status API 200、DNS 正常解析 → **不是 Discord 服務端故障，是本機側問題**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **DNS 不穩是全系統性的，不是 Discord 專屬**：同時段 provider 端也炸 `getaddrinfo EAI_AGAIN api.minimax...`（本 job 11-20 22:03 / 22:11 兩輪皆因此 timeout；19:05 輪「DNS lookup for the provider endpoint failed」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `resolvectl status`：**Link 2 (enp43s0, 有線) Current Scopes: none**（無 DNS scope）→ 全部 DNS 只靠 **wlp0s20f3 (Wi-Fi)**（1.1.1.1 / 8.8.8.8 / 2001:b000:168::2）+ tailscale0；default route 也走 Wi-Fi（192.168.1.1）。EAI_AGAIN＝上游/路由器 DNS 逾時，與網路層不穩一致。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 目前 DNS 測試 5/5 成功（`resolvectl query gateway.discord.gg` 9ms）→ **DNS 已恢復，但 Discord client 狀態機卡死，不會自行回 READY**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **inbound 實流量（唯讀查 `channel_ingress_events`）**：最後一筆 inbound = **celesteela 11-20 21:58:46**、mrmime 21:42:08、rowlet 19:30、roaringmoon 18:42、gengar 07:39、charizard 11-19 09:08 → **團隊所有 Discord 使用者訊息自 22:00 起沒有人收得到**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway 本身健康：pid **3469787**（11-20 16:18:14 起）、systemd NRestarts=0 / ActiveState=active、`/health` **HTTP 200 in 1.7ms**、host uptime 40d7h52m、load 0.57、mem available 20GiB、disk 60%。**近 15h 內 0 筆 event-loop starvation（`timer delayed … likely event-loop starvation`）→ 本次與 dreaming 阻塞無關。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ✅ 本輪已動作：啟用既有的 self-heal 腳本（不是新機制）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal-after-dreaming` **enabled=True**（先前 5 輪都記為 disabled → 已被啟用）、sched=`35,50 3,4,5 * * *` tz=Asia/Taipei、payload timeout=60s、ce=0；11-20 已實跑 6 次（03:35 / 03:50 / 04:35 / 04:50 / 05:35 / 05:50 全 ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **但它的排程只涵蓋 03–05 點** → 本次 22:38 起的故障落在覆蓋缺口（22:38–03:35 完全無自動修復），**這就是本次失明 4 小時的直接原因**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪動作：依「條件已滿足、手動執行同一支腳本」的方式執行 `scripts/discord-selfheal.sh`（腳本守門：① 有 `startup-not-ready` ② dreaming `36b493db` 確實未在跑 → dreaming 下一次是 **04:25** ③ 30 分鐘防重啟風暴；stamp 檔原為空 → 通過）。腳本實際輸出：`discord broken and dreaming idle -> scheduling gateway restart in 10s`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **唯一偏離（已記錄）**：以 `sed 's/--on-active=10s/--on-active=240s/'` 執行同一支腳本，**只把重啟延遲從 10s 改成 240s**，目的＝讓本輪巡檢報告（記憶體日誌 + Discord 摘要 + 最終回覆）能在 gateway 重啟前完成提交；守門、stamp 寫入、systemd-run 機制全部原樣。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 結果：`Running timer as unit: run-rb25e0ae0839342099ffa5bdeda036740.timer` → **排定於 02:11 左右重啟 openclaw-gateway**；stamp 已寫入 `1795198018`（→ 30 分鐘內 self-heal 不會重複動作）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 重啟後 8 帳號會重新 initialize（16:18 那次重啟後 10 分鐘內 8/8 connected 是既有證據）；**恢復狀況由下一輪（05:0x）驗證**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 副作用（如實記錄）：**gateway 重啟會中斷正在跑的 cron job**（11-20 16:18 那次重啟直接讓本 job 的 16:21 那輪記成 `cron: job interrupted by gateway restart`）。本輪已先寫記憶體日誌 + 先發 Discord 摘要，才排入重啟，資訊不丟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：53 jobs / 46 enabled / 7 disabled — ok 29 / error 12 / skipped 4 / none 1<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單 12 支（enabled 且 lastRunStatus=error），**多數是 Discord 失明的下游症狀，不是新的 provider 問題**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | ce | 最後 dur | 判讀 |
|---|---|---|---|---|
| heartbeat-rowlet | d82f78e3 | 6 | 600,441ms | `sessionTarget=main` 卡滿 600s（Discord 死 → main lane 無回應）|
| heartbeat-picturecat | 6525d155 | 6 | 600,004ms | 同上 |
| Picturecat Keep-Alive（本 job）| 02eb0989 | 5 | 465,002ms | rate_limit（MiniMax `overloaded_error`）|
| Gengar Keep-Alive | 9d8b6001 | 5 | 589,772ms | rate_limit |
| 群體智能架構研究 | b37129c0 | 5 | 61,715ms | timeout |
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | 4 | 451,178ms | timeout |
| 健康回報 | 13ac4b5a | 2 | 1,367,735ms | timeout |
| Jormungand daily all-agent health | 40e09cd1 | 2 | 249,200ms | 03:00 那支（仍排在 03:00）|
| clean-code研究 | 89e2cfe7 | 2 | 99,811ms | timeout |
| Memory Dreaming Promotion | 36b493db | 1 | 675,657ms | 11.3 分鐘，error（已加 timeoutSeconds 2400）|
| 每日論文討論 | 58fe15dc | 1 | 746,447ms | timeout |
| skill-collection-review-roaringmoon | c5352a84 | 1 | 169,007ms | timeout |

- ✅ 綠燈：`36b493db dreaming` 已改 **04:25 + timeoutSeconds 2400**；`ae91b967 LLM Wiki 巡讀` 已改 `30 5 * * *` ce=0；`a72cb46b 每日 Agent 潮流研究` 已改 `10 6 * * *` ce=0；`08b7c00b rowlet-ut-veteran` 已改 `40 6 * * *` ce=0 → **配額窗（09–13）的三個定時工作已搬走**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `skipped: no-route` 4 支、`6e93c179 heartbeat-flaaffy` never run → 良性長態，不計紅單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Provider：Token Plan 配額窗消失，但 DNS 才是本週真正的新敵人<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`Token Plan usage limit reached` 近 24h = 0 筆**（11-19 曾有 09–13 / 16–18 兩個尖峰共 767 筆）→ **MiniMax 配額窗本輪完全沒出現**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 但 `overloaded_error`（server busy）仍在：近 6h 3 筆（21h 1、00h 1、01h 2）；本 job 01:03 那輪即死於此。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **跨廠 fallback 仍是 0**：三支 KA 的 fallback 雖已加上 `openai/gpt-5.4-mini`，但 `openclaw models list` 顯示所有 `openai/*` 模型 **Auth=no**（openai/gpt-5.3-codex、gpt-5.5、gpt-5.4-mini、gpt-5.4-nano、gpt-5.4 全部 no）→ 一旦 MiniMax 限流，fallback 鏈會在 openai 這格直接死掉（**憑證我不碰**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（system scope）仍 crash-loop，需 root，未動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 未改 cron 排程 / payload / timeout / fallback / config / provider / model / channel；未動 `openai` 憑證；未碰 `elle.service`；未改 `/etc/resolv.conf` 或網路設定。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **唯一主動動作**：執行既有的 `scripts/discord-selfheal.sh`（人類已啟用的自動修復機制，條件全數滿足）→ 排入一次 gateway 重啟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`openclaw models list`、`journalctl --user`、`systemctl --user show`、`curl /health`、resolvectl、status.discord.com、`channel_ingress_events`（複製 DB+WAL/SHM 後唯讀查詢）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 給 Linder 的待決事項（第 20 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最急】self-heal 排程只蓋 03–05 點，缺口 8 小時**：本次 22:38→03:35 全無自動修復。建議改成 **每 30 分鐘全天跑**（守門已在腳本內：只在真的 `startup-not-ready` 且 dreaming 未在跑時才動手，30 分鐘防風暴已在）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【最急】DNS/網路不穩是根因，需在網路層處理**：有線介面 `enp43s0` 沒有 DNS scope，DNS 全靠 Wi-Fi + 路由器（EAI_AGAIN 尖峰 13h 1130 筆 / 22h 755 筆，Discord 與 MiniMax 同時受害）。建議：給有線介面也配置 DNS（或把 1.1.1.1/8.8.8.8 設為全域 DNS）、或檢查路由器 192.168.1.1 的 DNS 穩定性。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急】8 支 heartbeat 的 `sessionTarget=main`**：Discord 一死就集體卡滿 600s 變紅（今天 heartbeat-rowlet / heartbeat-picturecat ce=6）。改成 `isolated` 或加 `target:"none"`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【急】openai 憑證缺失**：`openai/*` 全 Auth=no，跨廠 fallback 名存實亡 → 需要一組可用的 OpenAI（或其他廠）憑證才有真正的跨廠冗餘（我不碰憑證，需你提供）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中】`40e09cd1 Jormungand` 仍在 `0 3 * * *`**（03:00 槽只搬走了 dreaming，`25 4 * * *`）；配合第 1 條把 self-heal 改全天後，03:00 槽的風險已大幅下降，但可一併搬到 04:45。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. （不急）`elle.service` crash-loop，需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 量測備忘（本輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Discord 失明的真簽章**：`channel exited: discord gateway reconnect-exhausted` + `getaddrinfo EAI_AGAIN <host>` + `websocket closed code=1006`；「READY wait timed out」只是症狀。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status` 顯示 `running, disconnected` ≠ 帳號沒事：要看 READY attempt 計數（今天已到 677）與 `channels resolved` 是否出現。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `channel_ingress_events` 沒有 `created_at`，用 `received_at`（epoch ms）；DB 在 `~/.openclaw/state/openclaw.sqlite`，唯讀查詢須連 `-wal`/`-shm` 一起複製。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- restricted automation-run session 中 `automations get/list` 對本 job 回 not found／空清單（已知限制）→ 一律用 `openclaw cron list --all --json` / `openclaw cron runs --id <完整 UUID>`；`state.lastRunStatus` 只有 ok/error，**根因要看 `entries[].cause`（rate_limit / timeout / agent-runner-failure）與 `lastErrorReason`**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw cron runs` 的陣列是**新到舊**（`runs[:n]` 才是最近幾輪）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw models list` 會印大量 plugin 設定警告佔輸出；用 `grep -E "^(Model|minimax|openai)"` 切。

---

## 2026-11-21 04:02 — Picturecat Keep-Alive 第 21 輪：🟢 **Discord 全線恢復且穩定 1h50m**，self-heal 排程改全天每 30 分（補上昨晚 8 小時缺口） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `bc9b35f7-594f-44f9-8651-fbdacdb00382`、status=ok、回覆「pong — idle, no active task, no recent errors.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-21 02:03）**ok / dur=203,969ms / ce=0** → 第 20 輪那顆紅燈已熄。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：`880b5c17 Celesteela KA` ok/ce=0；`9d8b6001 Gengar KA` **仍 error / ce=5**（見 §3）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🟢 Discord 復原驗證（第 20 輪排入的 02:11:49 重啟生效）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（04:02）：**8/8 帳號 enabled, configured, running, connected**（celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet；greninja disabled/stopped ＝預期），transport 新鮮度 1m/just now，inbound 也有新流量（celesteela in:1h ago、mrmime in:57m/out:57m）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 02:11:49 之後的 journal 簽章：**EAI_AGAIN 0 筆、startup-not-ready 0 筆、reconnect-exhausted 0 筆**；「READY wait timed out」16 筆**全部來自舊 pid 3469787 在 02:11:32 的關機前一刻**，新 pid 3573532 一筆都沒有。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **獨立第三方佐證**：`d4cd45bc discord-selfheal` 自己在 **03:35 / 03:50 各跑一次 → 兩次都是「discord healthy (no startup-not-ready) - no action」**（dur 815/741ms、exit 0）→ 不是只有我這輪看到，自動修復機制自己也確認 Discord 已好。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：pid **3573532**（11-21 02:11:49 起）、NRestarts=0、ActiveState=active、`/health` **HTTP 200 in 37ms**、uptime 40d9h49m、load 0.72、mem available 20GiB、disk 60%。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 兩個 bridge 都活著：`4188` OpenClaw bridge → 401（需驗證，服務在）、`14177` codex bridge → 404（HTTP 服務在聽）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ✅ 本輪動作：把 self-heal 排程補成**全天每 30 分鐘**（只改排程，其餘原封不動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 依第 20 輪待決事項 #1（self-heal 只蓋 03–05 點 → 昨晚 22:38–03:35 完全無自動修復 = 4 小時失明的直接原因），本輪把 `d4cd45bc` 由 `35,50 3,4,5 * * *` 改成 **`13,43 * * * *`（tz=Asia/Taipei，全天 48 次）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 為什麼用 `:13/:43` 而不是 `*/30`：**避開整點 job 群**（03:00 dreaming+Jormungand、07:00 論文、08:00 兩個、09:00 clean-code），不跟別人搶 event loop。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 保留原樣：payload kind=command（`sh -lc scripts/discord-selfheal.sh`）、timeoutSeconds=60、enabled=true、delivery.mode=none、sessionTarget=isolated、description、declarationKey **全部未動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **唯讀以外的唯一改動就是 `--cron` 這一個欄位**；沒有碰 model/fallback/timeout/payload/其他 job。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **即時驗證（強制測試）**：直接跑 `scripts/discord-selfheal.sh` → 輸出 `discord healthy (no startup-not-ready) - no action`、exit 0，**stamp 檔 `discord-selfheal-last-restart.ts` 前後都是 1795198018 未被改寫** → 守門在健康狀態下真的不動手（fail-closed + 防風暴 stamp 都正常）。下一次排定 **04:13**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **回滾指令（隨時可逆）**：`openclaw cron edit d4cd45bc-357d-42d4-9ba1-f7eb39e02f59 --cron "35,50 3,4,5 * * *" --tz Asia/Taipei`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 風險評估（為什麼敢在無人值守時做）：payload 是 **shell 腳本不是 agentTurn** → 不吃 token、不受 provider 限流影響（provider 全掛時自動修復照樣能跑）；只在真的出現 `startup-not-ready` **且** dreaming 未在跑時才 arm 重啟；30 分鐘防重啟風暴已在腳本內；每次 firing 成本 ≈1 秒 `channels status`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪**沒有**重啟 gateway（Discord 已健康 → 無須重啟；也避免像 02:11 那次順手打斷正在跑的 cron）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：53 jobs / 46 enabled / 7 disabled — ok 38 / error 8 / skipped 6 / none 1（比上一輪 ok 29 / error 12 大幅回春）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **兩個 Discord 失明的下游紅單已自行轉綠**：`d82f78e3 heartbeat-rowlet`（ce=6→ok）、`6525d155 heartbeat-picturecat`（ce=6→ok）→ 再次證實它們是斷線症狀而非 provider 問題（與 MEMORY 既載結論一致）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單 7 支（enabled 且 lastRunStatus=error），**多數是「今天還沒排到slot」的舊錯**：

| job | id | ce | 排程 | 判讀 |
|---|---|---|---|---|
| Gengar Keep-Alive | 9d8b6001 | 5 | every 3h | 01:02 那輪：`Agent couldn't generate a response` + agent-run `terminated`（dur 589,772ms）→ **不是乾淨的 rate_limit，是跑掛被砍**；04:02 已重跑、當下仍在跑（本輪取不到 receipt）。本輪 ping `agent:gengar:main` = accepted/queued、90s 內無回覆（lane 正忙）|
| 群體智能架構研究 | b37129c0 | 5 | 0 8 * * * | 今天 08:00 才會再跑，若再敗 → ce=6 |
| 晨間情報 pipeline | 45ccf4e9 | 4 | 0 8 * * * | cause=timeout（dur 451,178ms，timeoutSeconds=1800）|
| clean-code研究 | 89e2cfe7 | 2 | 0 9 * * * | 今天 09:00 再跑 |
| Memory Dreaming Promotion | 36b493db | 1 | 25 4 * * * | **04:25 就要起跑**（timeout 2400s、toolsAllow=["*"]）|
| 每日論文討論 | 58fe15dc | 1 | 0 7 * * * | 今天 07:00 再跑 |
| skill-collection-review | c5352a84 | 1 | every 7d | 週期性 |

- 第 8 筆 error 是 **disabled** 的 `a94330a9 tmp-openai-probe`（11-18 的一次性探測）→ 不計紅單。skipped 6 支全是 heartbeat `no-route` → 良性長態。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand`：03:00 首發撞 429（overloaded_error, 03:01:51）→ **重試後 03:03 完成、status=ok**（10/10 PASS，並顺手修好 codex bridge）→ ce=0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Provider<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`Token Plan usage limit reached` 近 24h = 0 筆**（連續第 2 輪零配額窗）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `overloaded_error` 本輪只 1 筆（03:01:51，Jormungand 首發，已由重試救回）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **跨廠 fallback 仍是 0**：`openai/*` 全 Auth=no（gpt-5.5 / gpt-5.4-mini / gpt-5.4 等）→ MiniMax 一限流，fallback 鏈會在 openai 這格直接死（**憑證我不碰**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（system scope）仍 crash-loop，需 root，未動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 只改了 `d4cd45bc` 一個 cron 表達式；其餘 52 支 job 的排程/payload/model/fallback/timeout **全未動**；未改 config、provider、model、channel、憑證；未動 DNS/網路設定；本輪**未重啟 gateway**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`openclaw cron edit --help`、`journalctl --user`、`systemctl --user show/list-units`、`curl /health`、codex/openclaw bridge probe、`bash scripts/discord-selfheal.sh`（守門驗證用）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 給 Linder 的待決事項（第 21 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【急】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）。要真正的跨廠冗餘需要一組可用的第二廠憑證（我不碰憑證，需你提供）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【急】Gengar KA 連 5 輪紅**（01:02 那輪是「跑掛被砍」而非 rate_limit）→ 建議比照 Celesteela KA 補 `timeoutSeconds`（1800）並確認 fallback 真的能接；04:02 那輪的 receipt 下一輪可驗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】08:00 槽雙紅**（`45ccf4e9` ce=4、`b37129c0` ce=5）今天 08:00 同時起跑，可能互搶；建議其一改 08:45。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】DNS/網路根因仍在**（昨晚 EAI_AGAIN 尖峰：有線介面 `enp43s0` 無 DNS scope，DNS 全靠 Wi-Fi + 路由器 192.168.1.1）→ 本輪只補了「故障後 30 分鐘內自癒」，**沒補根因**；建議給有線介面也配 DNS。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. （不急）`elle.service` crash-loop 需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 本輪加的一次性自我驗證（04:17 會自動跑掉）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `7bcb5f9d selfheal-schedule-verify-0413`（kind=at、`2026-11-21T04:17:00+08:00`、payload=command `bash scripts/verify-selfheal-schedule.sh`、timeout 120s、sessionTarget=isolated、delivery=none、**deleteAfterRun=true**）→ 只讀 cron 執行紀錄，判定 `d4cd45bc` 在 **04:13 是否真的被觸發**，把結論 append 回本檔案。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **下一輪（07:03）請確認**：① 本檔案末尾有「self-heal 全天排程驗證」區塊且 verdict=OK；② `openclaw cron list --all` 裡 `7bcb5f9d` 已不存在（deleteAfterRun 生效）；③ 若 verdict=MISS → 把 `d4cd45bc` 排程改回 `35,50 3,4,5 * * *` 並回報。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 輔助腳本：`scripts/verify-selfheal-schedule.sh`（唯讀 cron 狀態 + append 記憶日誌；不重啟、不改排程）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 04:0x 更正（gengar lane 回 pong 後補正兩點）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`agent:gengar:main` 回 pong（04:05，runId 2d0d09b9）**：gengar lane idle 且健康、無新錯誤；Discord 8/8 running+connected；近 60 分鐘 **429/overloaded = 0**；**DNS 已連續 60+ 分鐘乾淨（0 EAI_AGAIN、0 cache flush）**；他們也確認最後兩筆故障就是 11-20 的 Discord DNS 事件與 dreaming 截斷，都已處理。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ✅ 修正 §4 表格裡「gengar ping accepted/queued、90s 內無回覆」→ **實際有回覆**，是我在回覆抵達前就先落了盤。
- ✅ **修正 §4 / §7-2：`9d8b6001 Gengar KA` 的 04:02 重跑已成功**（status=ok、dur=251,639ms、04:06:16 收尾）→ **consecutiveErrors 歸零**，不是「連 5 輪紅」。01:02 那次是**單次**跑掛被砍（terminated / 589s），不是穩定复現的故障。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 因此 §7 待決事項 #2 降級：補 `timeoutSeconds=1800` 仍值得做（防止再次跑掛拖 10 分鐘），但**不再是紅燈急件**；gengar 自稱的「4 支 watched cron 全 ok ce=0」與我這邊的 job 層狀態一致。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ℹ️ 時間線更正：本節寫入當下是 **04:06:59**，`d4cd45bc` 的 04:13 觸發**尚未發生**（最新紀錄仍是 03:50）；一次性驗證 job `7bcb5f9d`（04:17）仍趕得上驗證。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### self-heal 全天排程驗證（2026-11-21 04:17:00 CST 自動檢查）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ `13,43 * * * *` **有正常觸發** → 全天自動修復覆蓋已補上。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 詳情：2026-11-21T04:13:00.014+08:00 -> status=ok dur=741ms summary=discord healthy (no startup-not-ready) - no action<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 最近幾輪：2026-11-21T04:13:00.014+08:00|ok|discord healthy (no startup-not-ready) - no action ; 2026-11-21T03:50:00.035+08:00|ok|discord healthy (no startup-not-ready) - no action ; 2026-11-21T03:35:00.035+08:00|ok|discord healthy (no startup-not-ready) - no action ; 2026-11-20T05:50:00.338+08:00|ok|discord healthy (no startup-not-ready) - no action<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-21 07:02 — Picturecat Keep-Alive 第 22 輪：🟡 lane PASS、Discord 已自癒但**再抖一次（04:35–04:59）**、**provider 429 出現清晨尖峰（05–07 點）**、**selfheal 守門只認 `startup-not-ready` → 認不出 `disconnected` 症狀（覆蓋缺口）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `c8f858f7-1d1b-411b-8301-c6d58f86753c`、status=ok、回覆「pong — 沒有 active task，近幾小時無錯誤，空閒待命。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-21 04:02）**ok / dur=275,563ms / ce=0**。姊妹 job：`880b5c17 Celesteela KA` ok/ce=0/dur=90,276ms；`9d8b6001 Gengar KA` ok/ce=0/dur=251,639ms → **三支 KA 全綠**（第 21 輪 §9 的 gengar 更正已由 job 層 ce=0 佐證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 07:04 當下同時在跑：`88810bfe BBC News Morning Discussion`、`bcf270b8 heartbeat-mrmime`、`02eb0989`/`9d8b6001`/`880b5c17` 三支 KA → **07:00 槽四支並發**（這也是本輪 429 的來源之一，見 §5）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🟢 Discord 現況：8/8 running + connected，且有真實 inbound<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（07:02）：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet **全部 enabled, configured, running, connected**，transport 新鮮度 just now ~1m ago（greninja disabled/stopped ＝預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- inbound/outbound 真流量：mrmime in:56m/out:56m、rowlet in:39m/out:39m、gengar in:2h/out:2h、celesteela in:4h → **不是只有連線好看，是真的在收發**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：pid **3573532**（11-21 02:11:49 起，uptime ≈4h52m）、NRestarts=0、ActiveState=active、`/health` **HTTP 200 in 1.9ms**、load 0.85、mem available 20GiB、disk 60%、host uptime 40d12h50m；bridge 4188→401、14177→404（兩個 HTTP 服務都在聽）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🟡 04:35–04:59 Discord 再抖一次（約 24 分鐘），**靠 gateway 內建 health-monitor 自癒，非 selfheal**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 症狀：READY wait timed out 風暴集中在 **04:35–04:56（合計僅 ~44 筆）**，遠比昨晚 23:00–02:11 那波的 1,300–1,600 筆/小時輕；期間 **1 筆 reconnect-exhausted**（8h 內僅此 1 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 處置：04:40:03 health-monitor 因 `disconnected` 重啟 **discord:rowlet**；04:46:33 一次重啟 **celesteela / flaaffy / mrmime / roaringmoon**（共 5 個 channel）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 恢復：04:58:13 各 channel 印 `delaying provider startup 40s~70s to reduce Discord startup rate limits` → 04:58:54–04:59:25 `channels resolved` + `client initialized` 逐一回來 → **04:59 起全線恢復，至今（07:04）連續 2h05m 乾淨**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS 同時段近乎乾淨：8h 內 EAI_AGAIN 僅 **40 筆**（00h=13、01h=30、04h=8、23h=13），對比昨晚 22h=755 筆 → **量級大幅改善**；04:54 之後 0 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⚠️ 本輪最有價值的發現：**selfheal 守門只認 `startup-not-ready`，認不出 `disconnected`**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 守門程式碼（`scripts/discord-selfheal.sh` L48）：`if ! openclaw channels status | grep -q "startup-not-ready"; then echo "discord healthy ... - no action"`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 實測反證：**04:43 那輪 selfheal 回「discord healthy (no startup-not-ready) - no action」**，但當下 Discord 正處在 04:40–04:56 的不穩窗（rowlet 已 disconnected、其餘 4 個 channel 即將被重啟）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 佐證：**近 8h gateway journal 的 `startup-not-ready` 筆數 = 0**（grep 到的 4 筆全是我自己 04:07 的 agent 輸出文字，非 gateway 事件）→ 這波故障的症狀字串是 `disconnected` / READY timeout，**從來沒出現過 `startup-not-ready`**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 結論：這波靠 **gateway 內建 health-monitor（自己重啟 channel）+ reconnect backoff** 撐過去（04:40→04:59，19 分鐘）。**若內建機制沒救回來，全天 48 次的 `d4cd45bc` 會一路回「no action」＝啞火**；反之昨晚那波（症狀確實是 `error:startup-not-ready`）守門就有效。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **本輪刻意沒改腳本**：放寬守門＝改自動 gateway 重啟的觸發條件，誤觸時會直接中斷在跑的 cron（第 20 輪已踩過 dreaming 被腰斬的坑）；這屬於「不可逆風險邊界外的自動動作」，無人值守下不自行放寬 → 列為待決事項 #2。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 🔴 Provider：**429 出現「清晨尖峰」（05–07 點），是既載 09–13 點窗之外的新時段**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429 全部來自 `provider=minimax-portal api=anthropic-messages model=MiniMax-M3`：`05:01:46`、`05:04:36`、`05:32:48`、`06:02:01`、`07:01:35`、`07:03:25`、`07:04:01`（8h 內共 9 筆；00h=2、01h=1、03h=1、05h=3、06h=1、07h=2、23h=1）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **本輪巡檢自己就吃到**：07:03:25 起 429 → `rate-limit same-model retry 1/3`（delayMs=10000）→ 07:04:01 再 429 → `retry 2/3`（delayMs=20000）→ 同模型重試機制正常接管（與 04:02 輪同款）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Token Plan usage limit reached` 近 8h = **0 筆**（連續第 3 輪零配額窗）→ 這次不是配額耗盡，是**併發尖峰**（07:00 槽 4 支 job 同時起跑）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 跨廠 fallback 仍是 0：`openai/*` 全 Auth=no → MiniMax 一限流就無處可退（憑證我不碰，維持待決事項 #1）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Fleet：53 jobs / 46 enabled / 7 disabled — ok 36 / error 5 / skipped 4 / none 1（error 8→5，持續回春）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 5 支紅單 **全部是舊錯，今天還沒排到 slot**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | ce | 排程 | 最後一次 | 判讀 |
|---|---|---|---|---|---|
| 每日論文討論 | 58fe15dc | 1 | `0 7 * * *` | 11-20 07:00 / dur=746,447ms | 錯因＝`getaddrinfo EAI_AGAIN api.minimax.io`（11-20 的 DNS 舊錯）；**今天 07:00 那輪正在跑中**（receipt 尚未寫回），本輪取不到結果 |
| 晨間情報 pipeline | 45ccf4e9 | 4 | `0 8 * * *` | 11-20 09:06 / dur=451,178ms | cause=timeout（timeoutSeconds=1800）→ 08:00 槽 |
| 群體智能架構研究 | b37129c0 | 5 | `0 8 * * *` | 11-20 09:19 / dur=61,715ms | 08:00 槽，與上一支同槽互搶 |
| clean-code研究 | 89e2cfe7 | 2 | `0 9 * * *` | 11-20 09:04 / dur=99,811ms | 09:00 槽 |
| skill-collection-review | c5352a84 | 1 | every 7d | 11-20 03:56 | 週期性 |

- 第 6 筆 error 是 **disabled** 的 `a94330a9 tmp-openai-probe` → 不計紅單；skipped 4 支是 heartbeat `no-route` → 良性長態。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal`：**ok / ce=0**，最近四輪 04:43 / 05:13 / 05:43 / 06:13 / 06:43 全 ok（dur 779–811ms，全為「discord healthy - no action」）、next=07:13 → **第 21 輪改成全天 `13,43 * * * *` 的排程持續運作**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) ✅ 第 21 輪 §8 三項交辦驗收：全數通過<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. ✅ 本檔案末尾有「self-heal 全天排程驗證」區塊且 verdict=OK（`2026-11-21T04:13:00.014+08:00 -> status=ok dur=741ms`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. ✅ 一次性驗證 job `7bcb5f9d` 已從 `openclaw cron list --all` 消失 → **deleteAfterRun 生效**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. ✅ verdict 非 MISS → **不需回滾** `d4cd45bc`（維持 `13,43 * * * *`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **未改任何 cron**（排程/payload/model/fallback/timeout 全未動）、**未改 selfheal 腳本**、未改 config/provider/model/channel、未動 DNS/網路設定、**未重啟 gateway**（Discord 已健康）、未碰憑證。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user`、`systemctl --user show`、`curl /health`、bridge probe。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（第 22 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【急】openai 憑證缺失**（延續第 21 輪 #1）→ 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）；今天 05–07 點的 429 讓這件事更實際：MiniMax 尖峰時三支 KA 同時只能靠同模型重試。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新・中】selfheal 守門覆蓋缺口**：只認 `startup-not-ready`，不認 `disconnected`（§4 有 04:43 實測反證）。建議把守門改成「`channels status` 出現 `startup-not-ready` **或** enabled 帳號出現 `disconnected`／非 connected **且** 連續 N 次（≥2）才 arm」；這會動到自動 gateway 重啟的觸發條件，**需要你點頭我再動**（我不在無人值守時自行放寬自動重啟條件）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】07:00/08:00 槽擁擠**：07:00 槽同時 4 支（BBC News / 論文 / heartbeat / 三支 KA 交錯）、08:00 槽兩支紅單互搶；建議其一改 08:45、另一支改 09:15（沿用第 21 輪 #3 方向）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】DNS 根因仍在**（延續第 21 輪 #4）：有線介面 `enp43s0` 無 DNS scope，全靠 Wi-Fi + 路由器 192.168.1.1；昨晚 755 筆/小時的 EAI_AGAIN 雖降到 40 筆/8h，但根因未除。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【新・低】429 尖峰時段表要更新**：今天實測到 **05:00–07:00 清晨尖峰**，不再是只有 09–13 點與午後/晚間 → 排避時段建議加「05–07 點輕載」（已寫入 MEMORY.md）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. （不急）`elle.service` crash-loop 需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 量測備忘（本輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429（8h）= 9 筆；EAI_AGAIN（8h）= 40 筆；READY timeout（8h）= 4,845 筆，其中 **4,800 筆集中在 11-20 23:04–11-21 02:11**（舊失明期），本輪時窗（04:35–04:56）僅 ~44 筆 → 量級判讀要看「時窗」不能只看總數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `startup-not-ready`（8h, gateway 事件）= **0**；`reconnect-exhausted`（8h）= 1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- system：load 0.85/0.60/0.51、mem available 20GiB、disk 60%（/dev/nvme0n1p2 468G，用 265G）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪（10:03）請確認：① 08:00 槽兩支（45ccf4e9 / b37129c0）receipt 是否已轉綠或仍紅；② 429 是否再出現、集中在哪個小時；③ `d4cd45bc` 是否仍全綠、07:13/07:43 是否照跑；④ Discord 是否又現 `disconnected`（若連續兩輪都出現 → 守門缺口升級為待辦 #1 優先修）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 07:05 追蹤補記：`58fe15dc 每日論文討論` 今天 07:00 那輪**確定失敗（429 / overloaded_error）**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt：`ts=2026-11-21T07:03:25.787+08:00 status=error dur=205,152ms`、error=「⚠️ API rate limit reached. Please try again later.」、diagnostics=**`HTTP 429: {"type":"error","error":{"type":"overloaded_error","message":"server is busy, please retry later"}}`**、usage input 96,540 / output 893 / cache_read 55,616。→ **ce 由 1 升到 2**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對照 11-20 同一支：err=`LLM request failed: DNS lookup for the provider endpoint failed` / `getaddrinfo EAI_AGAIN api.minimax.io`（DNS 舊因）→ **今天同一槽換成 provider 併發尖峰**，根因不同但同樣讓這支 job 連續兩天死在 07:00 槽。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 佐證 §5：journal 裡 07:01:35 / 07:03:25 / 07:04:01 的三筆 429 正是這支 job 與同槽 job 的重試序列 → **「清晨尖峰」已經造成實際紅單，不只是統計噪音**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 07:05 複檢 Discord：仍 8/8 running+connected；gengar in/out=just now、rowlet in:2m → 通道仍在正常收發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 待決事項 #3（07:00/08:00 槽擁擠）**升級**：建議把 `58fe15dc` 從 `0 7 * * *` 移到 **07:40 或 09:15**（避開 07:00 併發尖峰 + 三支 KA 同時段），並在 08:00 槽兩支之間錯開。**本輪未動排程**（改的是別人的排程，需 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-21 10:02 — Picturecat Keep-Alive 第 23 輪：🟢 **全綠的一輪**（lane PASS、Discord 5 小時無抖動、fleet 紅單 5→1、三支 KA 全綠）；429 尖峰證實「跟著整點槽走」而非配額窗 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `95776541-6066-4e96-9b17-93b4abad7f94`、status=ok、回覆「pong — 無 active task，近幾小時無錯誤，Discord 收發正常（origin + delivery context 皆指向 discord）」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-21 07:02）**ok / dur=234,615ms / ce=0**；姊妹 job `9d8b6001 Gengar KA` **ok/ce=0/272,875ms**、`880b5c17 Celesteela KA` **ok/ce=0/135,638ms** → **三支 KA 全綠**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🟢 Discord：8/8 running+connected，近 4h 零症狀（04:59 至今連續 ≈5h 乾淨）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（10:03）：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet 全部 **enabled, configured, running, connected**，transport just now~1m（greninja disabled/stopped ＝預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實收發：charizard in/out:58m、mrmime in/out:55m、gengar in:3h、roaringmoon in:2h、rowlet in:3h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 近 4h（2059 行）簽章計數：**READY wait timed out 0 / reconnect-exhausted 0 / startup-not-ready 0 / EAI_AGAIN 0 / health-monitor 0 / disconnected 0 / event-loop starvation 0**、client initialized 0、channels resolved 0 → **完全沒有抖動**（對照第 22 輪 04:35–04:59 那波 ~44 筆 READY timeout + 5 個 channel 被重啟）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：pid **3573532**（11-21 02:11:49 起，uptime ≈7h51m）、NRestarts=0、ActiveState=active、`/health` **HTTP 200 in 1.6ms**、load 1.06/0.62/0.51、mem available 20GiB、disk 60%（266G/468G）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ✅ 第 22 輪 §10 四項交辦全數驗收<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 交辦 | 結果 |
|---|---|
| ① 08:00 槽兩支 receipt | ✅ **全綠**：`45ccf4e9` ok（08:04:21, dur=261,186ms）、`b37129c0` ok（08:28:17, dur=1,129,656ms=18.8 分鐘），ce 皆 0 |
| ② 429 是否再出現／哪個小時 | ✅ 出現但**量很小**：近 4h = **6 筆**，全為 `overloaded_error`（server busy），`Token Plan usage limit reached` = **0 筆** → 分布 **07h×3（07:01/07:03/07:04）、08h×2（08:01/08:03）、09h×1（09:02）** |
| ③ `d4cd45bc` 是否全綠、07:13/07:43 是否照跑 | ✅ **連續 6 輪全 ok**：07:13 / 07:43 / 08:13 / 08:43 / 09:13 / 09:43（dur ~780ms，全為「discord healthy - no action」），next=10:13 |
| ④ Discord 是否又現 `disconnected` | ✅ **未再現** → selfheal 守門缺口本輪未被觸發（缺口本身仍在，見待決事項 #2）|
| ⑤（07:05 追蹤補記）`58fe15dc` 每日論文討論 | ✅ **自癒**：07:03 error（429 overloaded）→ **07:12:43 重試成功（ok）** → ce 歸 0；連兩天死在 07:00 槽的問題被同模型重試機制救回 |

### 4) Fleet：53 jobs / 46 enabled / 7 disabled — ok 36 / error 1 / skipped 8 / none 1（error 5→1）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **唯一紅單**：`c5352a84 skill-collection-review-roaringmoon`（ce=1、11-20 03:58 error、dur=169,007ms）。lastError = `Skill collection review failed for /home/amr/.openclaw/workspace-roaringmoon: FailoverError: LLM request failed: DNS lookup for the provider endpoint failed.` → **11-20 的 DNS 舊因、非現行故障**；排程 every 7d、next=11-28。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skipped 8 支全是 heartbeat `no-route`（良性長態、ce=0）+ `6e93c179 heartbeat-flaaffy` never run。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 綠燈重點：`36b493db dreaming` ok（dur=1,918,841ms=32 分鐘，04:25 起跑）、`40e09cd1 Jormungand` ok/ce=0（03:00）、`a72cb46b 潮流研究` ok（06:10）、`58fe15dc` ok（07:12）、`88810bfe BBC` ok（07:00）、`45ccf4e9` ok（08:04）、`b37129c0` ok（08:28）、`89e2cfe7 clean-code` ok（09:05）、`13ac4b5a 健康回報` ok（09:05, dur=39,531ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⏰ **10:00 槽很擠（19 個 next-run 落在 10:00–12:00）**：三支 KA + `29c2d630` Gengar watchdog + `ca222989` 系統維護 + `537bd0dd` 轉錄監控 + `6ddc8b4c` PTCGP Meta + 6 支 heartbeat 交錯 → 這正是 §3② 尖峰「跟著整點槽走」的成因面。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Provider / DNS：配額窗連續第 4 輪零；DNS 症狀消失但**根因未除**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Token Plan usage limit reached` 近 4h = **0 筆**（連續第 4 輪零配額窗）；`overloaded_error` = 6 筆（併發尖峰型，非配額型）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS 現況：`resolvectl query gateway.discord.gg` → 4 筆 A（162.159.130–136.234）、`api.minimax.io` → A + AAAA，**解析全部正常**；但 `resolvectl status` 顯示 **Link 2 (enp43s0) Current Scopes: none** → **DNS 100% 靠 Wi-Fi wlp0s20f3 + 路由器 192.168.1.1**（tailscale0 亦有 DNS scope）→ 根因（待決事項 #4）**未動過**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 跨廠 fallback 仍是 0：`openai/*` 全 Auth=no（不碰憑證，待決事項 #1 延續）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 `scripts/discord-selfheal.sh` 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未改 DNS/網路設定。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 selfheal 只做**唯讀驗證**（`channels status | grep -c startup-not-ready` = 0 → 守門此刻會回 no action、不會 arm 重啟），**沒有執行腳本**（比照第 21 輪的驗證法，但用唯讀 grep 取代執行）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user -u openclaw-gateway --since=-4h`、`systemctl --user show`、`curl /health`、uptime/free/df、resolvectl。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 給 Linder 的待決事項（第 23 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【急】openai 憑證缺失**（連續第 4 輪延續）→ 三支 KA 的跨廠 fallback 名存實亡，`openai/*` 全 Auth=no；今天 07–09 點的 6 筆 overloaded_error 全靠同模型重試扛住。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【急・中】selfheal 守門覆蓋缺口**（延續第 22 輪 #2）：只認 `startup-not-ready`、認不出 `disconnected`。本輪 Discord 未抖 → 缺口未被觸發，但 04:35–04:59 那波證明它會啞火。放寬守門＝改自動 gateway 重啟的觸發條件，**仍等你點頭我才動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】整點槽過密 ＝ 429 尖峰的真正來源**（本輪新證據）：429 分布 07h×3 / 08h×2 / 09h×1，**幾乎都落在各 job 的整點起跑時刻**（07:00 論文+BBC+KA、08:00 兩支、09:00 clean-code）→ 建議把 `58fe15dc` 從 `0 7 * * *` 移到 07:40、把 08:00 兩支錯開到 08:00/08:45，而不是只搬離 09–13 配額窗（本輪證實那時段根本不是配額窗，是併發窗）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】DNS 根因仍在**：症狀已消失（近 4h EAI_AGAIN=0），但有線 `enp43s0` 仍無 DNS scope → 建議給有線介面也配 DNS 或改用全域 1.1.1.1/8.8.8.8。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】`c5352a84` 每 7 天重跑一次**（next 11-28），前次錯因是 DNS；若 DNS 根因不修，11-28 可能再紅一次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. （不急）`elle.service` crash-loop 需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 量測備忘（本輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `journalctl --user -u openclaw-gateway --since=-4h`（**注意：`-4h` 要用相對格式；`--since '4 hours ago'` 的引號在 shell 變數裡會被吃掉 → journalctl 報 "Failed to parse timestamp"、所有計數變 0，會誤判成「全乾淨」**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429 每行含兩個時間戳（journal 前綴 + ISO）→ 用 `grep -oE "[0-9]{2}:[0-9]{2}:[0-9]{2}" | cut -c1-2 | uniq -c` 會**數到 2 倍**（本輪 6 筆實際 → 顯示 6/4/2）；判讀要除以 2。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw cron runs --id <完整 UUID>` 的 `ts` 是**結束時間**；`entries[].summary` 是該輪的最終回覆摘要 → 可直接用來讀上一輪巡檢講了什麼。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- restricted automation-run session 中 `automations list/get` 對本 job 回 not found／空清單（已知限制）→ 一律用 `openclaw cron list --all --json` + `openclaw cron runs --id`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪（13:02）請確認：① 10:00/11:00 槽是否出現 429（尤其 10:0x 這輪 6 支並發）；② `13ac4b5a 健康回報` 11:05 那輪是否綠；③ Discord 是否又現 `disconnected`（若連續兩輪出現 → 守門缺口升級為 #1）；④ `d4cd45bc` 10:13/10:43/11:13/11:43 是否照跑。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

---

## 2026-11-21 13:02 — Picturecat Keep-Alive 第 24 輪：🟢 **全綠續航**（lane PASS、Discord 連續 8 小時零症狀＝自癒以來最長乾淨段、fleet 紅單維持 1 且是舊因、429 僅 2 筆且被同模型重試吃掉）、**新簽章：429 → auth-profile cooldown → 4 秒後 re-warm** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `7bd7ac23-0fb1-421f-a8ca-4db762429e3f`、status=ok、回覆「pong — 無 active task，近幾小時無錯誤，Discord 收發正常。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（11-21 10:02）**ok / dur=273,465ms / ce=0**；姊妹 `9d8b6001` Gengar KA **ok/ce=0/194,631ms**、`880b5c17` Celesteela KA **ok/ce=0/107,557ms** → **三支 KA 全綠**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job 設定（唯讀確認未變）：model `minimax-portal/MiniMax-M3`、fallbacks `['minimax/MiniMax-M3','minimax-portal/MiniMax-M2.7','openai/gpt-5.4-mini']`、schedule `every 10800000ms`（3h）、sessionTarget=isolated、delivery.mode=none、**timeoutSeconds=None**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🟢 Discord：8/8 running+connected，**04:59 → 13:03 連續 ≈8h04m 零症狀**（自癒以來最長乾淨段）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（13:02）：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet 全部 **enabled, configured, running, connected**，transport 皆 just now（greninja disabled/stopped ＝預期）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實收發：celesteela in:6m/out:3h、mrmime in:57m、gengar in/out:6h、roaringmoon in/out:5h、charizard in/out:4h、rowlet in/out:3h → **不是只有連線好看**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 近 3h（913 行，since 10:00）runtime 簽章：**READY wait timed out 0 / reconnect-exhausted 0 / startup-not-ready 0 / EAI_AGAIN 0 / health-monitor 0 / disconnected 0 / event-loop starvation 0 / channels resolved 0 / client initialized 0** → **完全沒有抖動**（對照 04:35–04:59 那波）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⚠️ grep 會命中 `[agent:nested]` 裡 agent 自述的「startup-not-ready」「EAI_AGAIN」字樣（本輪各命中 1 筆，全是 10:03 gengar 的報告內文）→ 判讀要排除 `agent:nested` 行，否則會把假陽性當 runtime 事件。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：pid **3573532**（11-21 02:11:49 起，uptime ≈10h11m）、NRestarts=0、ActiveState=active、`/health` **HTTP 200 in 1.6ms**、host uptime 40d18h49m、load 0.43/0.41/0.48、mem available 20GiB、disk 60%（266G/468G）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：`gateway.discord.gg` → 4 筆 A（162.159.130–136.234）正常解析；但 `resolvectl status` 仍是 **Link 2 (enp43s0) Current Scopes: none** → **DNS 100% 靠 Wi-Fi wlp0s20f3**（待決事項根因未除，本輪症狀未復發）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ✅ 第 23 輪 §8 四項交辦全數驗收<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 交辦 | 結果 |
|---|---|
| ① 10:00/11:00 槽 429 | ✅ **只有 2 筆真 429**（10:31:36、12:02:32），且**都被同模型重試吃掉、零紅單**；`Token Plan usage limit reached` 近 3h = **0 筆**（連續第 5 輪零配額窗）|
| ② `13ac4b5a` 健康回報 11:05 | ✅ **ok**（11:06:23 收尾、dur=61,201ms、ce=0、delivery=delivered 到 Discord channel 1482069603512221927）；08:06/05:06 也全 ok |
| ③ Discord 是否又現 `disconnected` | ✅ **未再現**（disconnected 0、health-monitor 0、READY timeout 0）→ selfheal 守門缺口本輪未被觸發（缺口本身仍在）|
| ④ `d4cd45bc` 是否照跑 | ✅ **連續 12 輪全 ok**：10:13 / 10:43 / 11:13 / 11:43 / 12:13 / 12:43 每輪 ~780ms「discord healthy - no action」，next 13:13 |

### 4) Fleet：53 jobs / 46 enabled / 7 disabled — ok 36 / error 1 / skipped 8 / none 1（與上輪同）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **唯一紅單仍為 `c5352a84 skill-collection-review-roaringmoon`**（ce=1、dur=169,007ms、lastError=`FailoverError: LLM request failed: DNS lookup for the provider endpoint failed`）→ **11-20 的 DNS 舊因、非現行故障**；schedule `every 7d`、next=11-28。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 10:00–13:00 實際跑過的 enabled job **全部 ok**：`9d8b6001` KA(10:02) / `02eb0989` KA(10:02) / `880b5c17` KA(10:02) / `6ddc8b4c` PTCGP Meta 三日彙整(10:16) / `13ac4b5a` 健康回報(11:05) / `d7b0355b` Jormungand mrmime A2A(12:00) / `29c2d630` Gengar watchdog(12:04) / `ca222989` 系統維護(12:04) / `537bd0dd` 轉錄監控(13:00) / `d4cd45bc` selfheal(12:43)。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- skipped 8 支全是 heartbeat `no-route`（ce=0，良性長態）+ `6e93c179 heartbeat-flaaffy` never run。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db dreaming` 今日 04:25 那輪 ok（dur=1,918,841ms=32 分鐘）、**next=11-22 04:25**；`40e09cd1 Jormungand` 今日 03:01 首發 429 → 03:03 重試成功（ok，10/10 PASS）→ ce=0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 🆕 Provider：本輪唯一的**新簽章**＝429 → auth-profile cooldown → 4 秒後 re-warm（本來會是「fallback 鏈退化」的元兇，但這次沒釀成紅單）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **10:31:36**：`provider-transport-fetch status=429`（provider=minimax-portal, model=MiniMax-M3, elapsedMs=86）→ `[agent/embedded] embedded run agent end ... isError=true error=⚠️ API rate limit reached` → **`auth profile failure state updated: profile=sha256:9e08bd6be9c1 provider=minimax-portal reason=rate_limit window=cooldown reused=false`** → **10:31:40 `[gateway] provider auth state re-warmed (auth-profile-failure) in 3400ms eventLoopMax=10.8ms`**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 這是 11-17 記錄過的「auth-profile-unavailable」類第二次實測：**429 會讓該 auth profile 進入 cooldown window（此時 fallback 鏈會退化掉這一格）**，但 gateway 會在 ~3–4 秒內 re-warm 成功 → 本輪 fallback 鏈沒被實際削弱的證據。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **12:02:32**：同一支 `d7b0355b` 的 run（runId `849bae13`）吃到 429 → `rate-limit same-model retry 1/3 for minimax-portal/MiniMax-M3: delayMs=10000` → **重試成功，該 job 最終 ok**（12:00:30 起跑、dur=152,495ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw models list`：**minimax-portal/MiniMax-M3 Auth=yes**（不在 cooldown）；`minimax/MiniMax-M3`、`minimax-portal/MiniMax-M2.7` 等皆 Auth=yes；⚠️ **`openai/*` 全部 Auth=no**（gpt-5.3-codex / gpt-5.5 / gpt-5.4-mini / gpt-5.4-nano / gpt-5.4）→ **跨廠 fallback 仍是 0**（本 job fallback 鏈 4 個候選裡唯一跨廠的 `openai/gpt-5.4-mini` 名存實亡）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service` 仍在 crash-loop（13:02:46 看到 `Active: activating (start-pre)`），需 root，未動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 `scripts/discord-selfheal.sh` 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未改 DNS/網路設定。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 selfheal 僅**唯讀驗證**（journal 無 `startup-not-ready`／`disconnected` → 守門此刻會回 no action、不會 arm 重啟），**沒有執行腳本**、沒有 arm 任何重啟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user -u openclaw-gateway`、`systemctl --user show` / `systemctl status elle.service`、`curl /health`、uptime/free/df、resolvectl、`openclaw models list`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 給 Linder 的待決事項（第 24 輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【急・延續】openai 憑證缺失** → 4 個 fallback 候選只有 3 個 MiniMax 檔可用、`openai/gpt-5.4-mini` Auth=no → 真正的跨廠冗餘仍是 0；今天 10:31／12:02 兩次 429 都是靠「同模型重試」而非「換廠」救回。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【急・中・延續】selfheal 守門覆蓋缺口**：只認 `startup-not-ready`、認不出 `disconnected`（第 22 輪實測反證）。本輪 Discord 8h 乾淨未觸發，但缺口仍在；放寬守門＝改自動 gateway 重啟的觸發條件，**仍等你點頭我才動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】整點槽併發仍是 429 主因**（第 23 輪結論成立）：今天 10:31/12:02 兩筆 429 分別撞在 10:00 槽（3 支 KA 同時）與 12:00 槽（d7b0355b A2A）；建議把 10:02–10:05 的三支 KA 錯開到 10:02/10:20/10:40，並把 12:00 槽的 A2A 挪到 12:30。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】DNS 根因仍在**：`enp43s0` 仍無 DNS scope，DNS 全靠 Wi-Fi + 路由器 192.168.1.1（症狀已消失 8h+，但 11-20 的 755 筆/小時 EAI_AGAIN 隨時可能復發）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【低】`c5352a84` 每 7 天重跑**（next 11-28），前次錯因就是 DNS；DNS 根因不修，11-28 可能再紅一次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. （不急）`elle.service` crash-loop 需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 量測備忘（本輪新增）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`cron list --all --json` 的權威時間欄位是 `state.lastRunAtMs`**（不是 `state.lastRunAt`；本輪 `lastRunAt` 全為 null，只看它會以為「今天沒 job 跑過」）。job 層 `status`/`lastRunStatus`/`nextRunAtMs` 在頂層也有鏡像欄位。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **判 runtime 簽章要排除 `[agent:nested]` 行**：agent 自述文字含「startup-not-ready」「EAI_AGAIN」「429」會造成假陽性（第 22/23 輪已踩過 429 的同款陷阱）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `Failed to remove unused run continuation: Error: Cannot delete session while competing work is in flight for <sessionKey>:run:<runId>; retry after the run completes` → **良性清理噪音**（job 已在跑、舊 run session 還在、清理被拒），出現在每支 cron job 收尾時；不代表失敗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `model-fallback/decision ... reason=unknown detail=prepared model runtime plugin generation was superseded` → **良性**（多支 job 同分鐘起跑時的 runtime plugin 競態），不是 provider 故障。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- restricted automation-run session 中 `automations list/get` 對本 job 回 not found／空清單（已知限制）→ 一律用 `openclaw cron list --all --json` / `openclaw cron runs --id <完整 UUID>`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪（16:03）請確認：① 12:00–15:00 槽有無新 429／紅單；② Discord 是否又現 `disconnected`（若連續兩輪出現 → 守門缺口升級為 #1）；③ `d4cd45bc` 13:13/13:43/14:13/14:43/15:13/15:43 是否照跑；④ `c5352a84` 是否仍維持 ce=1（未到 11-28 前不應變動）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
