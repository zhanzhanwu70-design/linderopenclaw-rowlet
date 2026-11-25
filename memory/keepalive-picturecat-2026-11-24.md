# Picturecat Keep-Alive 巡檢日誌（2026-11-24）

## 2026-11-24 01:02 — Picturecat Keep-Alive 第 1 輪：🟢 lane PASS、Discord **連續 6h 零症狀**、fleet 紅單僅 2 支（皆舊因）；⭐⭐⭐ **本輪最大發現：11-23 04:48 那次 gateway 重啟是 self-heal 自己開火造成的，被腰斬的正是 dreaming 本體** → 今晚 04:25 槽是決定性復驗 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `f285c8f0-f9bf-4876-a946-daca66b82cfa`、status=ok、回覆「pong — no active task, no recent errors; Discord send/receive OK.」（01:02:39 落地）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**11-23 22:02**）**ok / dur=21,550ms（21.5s）→ 降級輪**（<30s 門檻）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 該輪 summary 是通用模板（「**Keep-alive OK** — scheduled run fired and executed cleanly」＋ automations list 空、uptime、disk 三句），**沒有寫 memory 檔**：11-23 檔 mtime 仍停在 19:05、內容無 22:02 段落（`grep -c "2026-11-23 22:02 —"` = 0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - → **11-23 全天 = 8 次 run、7 個 `## ` 段落 + 1 個「零紀錄降級輪」**。19:02 輪寫進 MEMORY 的「查漏做＝cron_run_receipts dur 明細 vs 當日檔 `^## ` 段落數」方法**第一次抓到實例**，且是「本 job 自己的側」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job 上輪（11-23 22:02）全綠 ce=0：`9d8b6001` Gengar KA ok / dur=265,655ms；`880b5c17` Celesteela KA ok / dur=415,570ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪三支 KA 同時在跑：gengar **01:02:02.639** → picturecat **01:02:12.745** → celesteela **01:02:12.730** → **anchor 疊窗第 18 次**（gengar↔picturecat 間距 **10.1 秒**， celesteela↔picturecat 僅 15ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - celesteela 01:02 輪已收尾（ok / dur=196,420ms）；**gengar 01:02 輪仍在跑**（01:04:10 有 3 次 superseded + 2 次 model-fallback decision，尚未寫 receipt）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ 本輪最大發現：**11-23 04:48 的 gateway 重啟是 self-heal 自己開火造成的，被腰斬的正是 dreaming 本體**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
完整因果鏈（journal × cron receipt 交叉驗證，非推測）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **04:25** `36b493db Memory Dreaming Promotion` 起跑（payload.timeoutSeconds=2400、lightContext、toolsAllow=["*"]、fallbacks=[minimax/MiniMax-M3, minimax-portal/MiniMax-M2.7]、sessionTarget=isolated）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. dreaming 併行觸發各 agent 的 deep-phase narrative（celesteela / charizard…）→ **event loop 凍結**：04:33:56 `eventLoopDelayP99Ms=286,689ms`（4.8 分）、04:46:16 `=306,285ms`（5.1 分）、`eventLoopUtilization=1`、`cpuCoreRatio=1.003` → `host timing gap detected: process was frozen ~146s / ~266s / ~279s`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. health-monitor 想重啟 channel 卻連續 `host thaw channel restart deferred: gateway still has active work` → Discord channel 掉線 → `[picturecat] channel exited: discord gateway opened but did not reach READY within 30000ms`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **04:46:17 `d4cd45bc` self-heal 開火**（slot 應為 04:43，**因 event loop 凍結延遲 3 分鐘才跑**）→ stdout `discord broken and dreaming idle -> scheduling gateway restart in 10s` → **守門判定「dreaming idle」是錯的**：dreaming 當時正在跑（sessionKey `agent:rowlet:cron:36b493db:…:run:7e6f09dd` state=processing、age=206s），卻被判定為 idle → arm 重啟。stamp 寫入 `1795380377`（=04:46:17 ✓）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **04:48:17 gateway 重啟**（systemd；NRestarts=0、ActiveEnterTimestamp=04:48:17）→ **dreaming 在 04:48:26 被砍**（dur=**1,406,869ms**＝23.4 分）→ receipt error `cron: job interrupted by gateway restart` → **ce=1**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **05:13 self-heal**：`self-heal skipped: a restart was armed 26 min ago (< 30 min) - avoiding restart storm` → 30 分防風暴 stamp 守門**有效**（✓）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **04:49:37 client initialized** → Discord 1.5 分鐘內自癒（gateway 內建 health-monitor 自行恢復）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **11-23 07:02 的兩項修法正好切斷這條鏈**：① 守門 fail-closed（含 API 失敗信封、未完成 receipt 列、dreaming 時鐘窗三條 arm 路徑）② 排程改成 `13,43 0-3,5-23 * * *`（**04 整點不跑**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⏰ **今晚 04:25 槽是決定性復驗**：即使 event loop 再凍結、Discord 再掉線，**不會再有外部重啟去砍 dreaming**；殘餘風險只剩兩項——gateway 內建 health-monitor（idle 時才重啟 channel）與 dreaming 自身 2400s timeout（最晚 05:05 收）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 該窗內其他 job：`ac9e7ada` 英文教練 05:00、`e2ffd70d` push-llm-wiki 05:05（其餘 04:25–05:10 空檔）→ 05:00 那支落在 dreaming 窗內，可能再加一層 event loop 壓力。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🟢 Discord：8/8 running+connected，**6h 窗零症狀**（近幾輪最乾淨）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（01:02）：celesteela / charizard / flaaffy / gengar / mrmime / picturecat / roaringmoon / rowlet **全部 enabled, configured, running, connected**（greninja disabled/stopped ＝預期）；transport 新鮮度 just now～1m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 真實收發：celesteela in:8m、mrmime in/out:57m、roaringmoon in/out:2h、rowlet in/out:18h、gengar in/out:18h、charizard in/out:16h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 6h 窗（19:02→01:02，journal 1,308 行）簽章計數：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **READY wait timed out 0 / channel exited 0 / client initialized 0 / channels resolved 0 / disconnected 0 / health-monitor 0**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **host timing gap 0 / event-loop starvation 0 / lane wait exceeded 0**（⇒ 6h 內無排隊症狀，16:07/19:02 的 lane 序列化瓶頸本窗未復發）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `Gateway reconnect scheduled` 23 ＋ `websocket closed` 23 ≈ **3.8/h**（基線 2.6–3/h，心跳式 resume=true 屬健康）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **EAI_AGAIN 僅 1 筆**（對照 11-20 22h 755 筆 → 症狀幾乎消失，但根因未除，見 §5）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `Cannot delete session while competing work is in flight` 19 筆 → fleet 級常態雜訊（橫跨 880b5c17 / ca222989 等）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：MainPID **4137629**、ActiveEnterTimestamp **11-23 04:48:17**、**連續 20h14m 未重啟**、NRestarts=0、ActiveState=active、`/health` **200 in 1.3ms**（port 18789）、load 1.02/0.61/0.56、mem available 20GiB、disk 60%（267G/468G）、host uptime 43d6h49m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：53 jobs / 46 enabled / 7 disabled — **ok 38 / error 2 / skipped 5 / none 1**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單僅 2 支，**皆已知、非新生**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | ce | 最後一次 | 判讀 |
|---|---|---|---|---|
| Memory Dreaming Promotion | 36b493db | 1 | 11-23 04:25 error / dur=1,406,869ms | **被 self-heal 觸發的 gateway 重啟腰斬**（§2）→ 今晚 04:25 槽是復驗；`lastRunError=cron: job interrupted by gateway restart` |
| skill-collection-review-roaringmoon | c5352a84 | 1 | dur=169,007ms | 11-20 的 DNS 舊因（`FailoverError: LLM request failed: DNS lookup for the provider endpoint failed`）、next=**11-28**（每 7 天）→ 會自然到期 |

- `a94330a9 tmp-openai-probe` error=**disabled** → 不計紅單；skipped 5 支 = heartbeat `no-route`（良性長態，`6e93c179 heartbeat-flaaffy` never run）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal`：**19:13→00:43 共 12 槽全 ok**（dur 736–834ms，全為「discord healthy (no startup-not-ready) - no action」）→ fail-closed 守門 + hour-04 排除**持續有效、零誤開火**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 本輪唯讀守門驗證：`openclaw channels status | grep -c startup-not-ready` = **0** → 此刻守門會回「no action」、不會 arm 重啟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Provider / DNS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **canonical 429（6h）= 4 筆**：21:01:52 / 23:01:29 / 23:03:42 / 00:02:35 → **其中 23:01、00:02 兩組直接落在 :02 的 KA 槽**（三支 KA 同 agent lane 同時起跑）→ 再次支持「把 anchor 拉開 ≥15 分鐘」的建議（11-23 19:02 輪已升級建議）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **真實配額 `Token Plan usage limit reached`：24h = 58 筆，全在 07h**（11-23 07:29–07:59）＝**07:00 槽的配額牆**；**近 3h = 0 筆**。`status=529` = 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：`resolvectl status` 仍顯示 **Link 2 (enp43s0) Current Scopes: none** → DNS 100% 靠 wlp0s20f3（Wi-Fi）+ tailscale0 → **根因未除**（待決事項延續，本輪未動網路設定）。本輪實測解析正常：`gateway.discord.gg` → 5 筆 A（162.159.130–136.234）、`api.minimax.io` → A + AAAA。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) ⚠️ 跨 lane ping 不是免費的（本輪新觀察）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 01:02:39 我的 ping 得到 pong 的**同一毫秒區間**，picturecat agent dir 立刻出現 2 筆 `prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/picturecat/agent`（lane=nested + lane=session、durationMs=**5**）→ **ping 觸發了目標 agent 的 runtime 重新生成，並與既有生成撞車**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 01:04:10 gengar agent dir 同款 3 筆（durationMs 5–6）＋ 2 次 `model-fallback/decision candidate_failed`（minimax-portal/MiniMax-M3 → minimax/MiniMax-M3 → minimax-portal/MiniMax-M2.7）→ 這是 **KA lane** 上的 superseded，落在 KA lane 屬良性（回覆照常落地，本輪 picturecat pong 與 celesteela receipt 都正常）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → **判讀**：16:07 的教訓是「不要投遞進**正在跑的 cron run session**」；本輪 ping 的是 `agent:picturecat:main`（main lane，非 cron run session），回覆乾淨、0 lane wait → **仍可做，但要知道它會在目標 agent dir 製造 superseded 競態**。下一輪（04:02）再觀察一次；若出現 lane wait 就全面停用 `sessions_send`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 `scripts/discord-selfheal.sh` 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未改 DNS/網路設定、未新增 job。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 一次）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`、`journalctl --user`、`systemctl --user show`、`curl /health`、`resolvectl`、journal 簽章計數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（沿用 + 新增）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【急・沿用】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【急・沿用】KA anchor 拉開 ≥15 分鐘**（原 ≥3 分鐘不足）＋ 讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 18 次疊窗，且 6h 內 2 筆 canonical 429 直接落在 :02 KA 槽。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中・沿用】DNS 根因未除**（enp43s0 無 DNS scope，全靠 Wi-Fi + 路由器 192.168.1.1）→ 本輪症狀僅 1 筆/6h，但結構性風險仍在。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中・沿用】heartbeat 類 job 的 600s timeout 與 `target:"none"` / `sessionTarget=isolated`**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中・沿用】17 支 skill 缺 description**（13 支 `description is required` ＋ 4 支 BAD_INDENT）→ 每日 ≈196 次 skip，未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【新增・中】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決，本輪抓到本 job 自己的降級輪（11-23 22:02、21.5s、零紀錄）。修法＝把必做五步與檔名寫進 payload（屬改 job，需 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. （不急）`elle.service` crash-loop 需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 交辦給下一輪（04:02）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. ⏰ **04:02 輪務必驗收今晚 04:25 dreaming 之前的準備態**：`d4cd45bc` 排程仍為 `13,43 0-3,5-23`（04:13／04:43 **不應出現**任何 self-heal run）→ 04:02 輪確認 cron 表达式未被改回。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. ⏰ **07:02 輪務必驗收 04:25 dreaming 的結果**：`36b493db` receipt（status / dur / lastRunError）、gateway MainPID 與 ActiveEnterTimestamp 是否變（被腰斬＝重啟）、04:25–05:15 窗的 host timing gap / channel exited 筆數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. 觀察 04:02 輪自己的 ping 是否再產生 picturecat agent dir 的 superseded 競態（§6）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. 確認 11-23 降級輪（22:02）是否需要補寫段落以讓當日檔案覆蓋率完整（目前 7 段/8 run）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 量測備忘（本輪）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 cron CLI 的 JSON 欄位修正：**`timeoutSeconds` / `fallbacks` / `model` 都在 `.payload` 底下**，不在 job 頂層（我第一版查 `.timeoutSeconds` 全拿到 null，誤判 dreaming 沒 timeout；實際 dreaming payload.timeoutSeconds=**2400**）。`state.lastDurationMs`（不是 lastRunDurationMs）、`state.lastRunAtMs`、`state.nextRunAtMs` 才是權威時間。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `automations list/get` 在 restricted automation-run session 內對本 job 回 not found／空清單（已知限制）→ 一律用 `openclaw cron list --all --json` 與 `openclaw cron runs --id <完整 UUID>`（短 id 會回 "Automation not found"）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- self-heal stamp 檔在 `memory/discord-selfheal-last-restart.ts`（**不是** `~/.openclaw/state/`）→ 內容 `1795380377` ＝ 11-23 04:46:17 arm 時點。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429 口徑維持 canonical：`model-fetch.*status=429` ＋ 排除 `[agent:nested]`；`Token Plan usage limit reached`（真配額）與 `overloaded_error`（併發尖峰）必須分開判讀。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming 併行時 **cron slot 會被凍結拖遲**（04:43 的 slot 實跑 04:46:17，延遲 3 分）→ 觀察 self-heal 觸發時間時要用實際 runAtIso，不要用 expr 推算。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-24 04:02 — Picturecat Keep-Alive 第 2 輪：🟢 lane PASS、Discord **連續 3h 零症狀**、fleet 紅單仍 2 支（皆舊因）；⭐⭐ **本輪抓到 ce=0 洗掉的第 3 例死亡（同一場 3 分鐘網路事故）**；⭐⭐ **新發現：`elle.service` 是 43 天的崩潰重啟迴圈（NRestarts=119,872）**；⏰ **04:25 dreaming 槽前置條件全數就位（20 分鐘後）**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS（但跨 lane ping 的副作用第 2 次重現）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `d7a4b226-39c8-49f8-86d3-6952e02a852e`、status=ok、回覆「pong — lane 存活且空閒，無 active task，最近無錯誤」（04:0x 落地）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **01:02 輪發現的「跨 lane ping 會在目標 agent dir 製造 superseded 競態」第 2 次重現**：04:05:00 出現 2 筆 `[diagnostic] lane task error: lane=nested/session:agent:picturecat:main durationMs=6/7 error="prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/picturecat/agent"` → **本輪 3h 窗 `lane wait exceeded` ＝ 0** → 落在 KA lane 仍屬良性（回覆照常落地），但副作用是**可重現的**，不是偶發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job 上一輪（11-24 01:02）ok / **dur=392,354ms（392s）** → **非降級輪**（>30s 門檻）。姊妹 job 上輪全綠 ce=0：gengar `9d8b6001` ok / 390,673ms、celesteela `880b5c17` ok / 196,420ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA anchor 疊窗第 19 次**：gengar **04:02:02.639** → picturecat **04:02:12.745** → celesteela **04:02:12.750**（gengar↔picturecat **10.1 秒**，picturecat↔celesteela **5ms**）→ 與前兩輪同一組數字，**「拉開 ≥15 分鐘」的建議持續成立**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 「ce=0 洗掉整輪死亡」第 3 例 —— 而且兩支死在**同一場 3 分鐘網路事故**裡<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪改用**全 fleet 掃描**（53 支 job 各取最近 6 筆 receipt，逐一比對 `status=error`）→ 抓到 **`cron list` 完全看不到的兩支死亡**（兩支 `consecutiveErrors` 都已被後續 ok 洗成 0）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

| job | id | error receipt | 內容 | 後續 |
|---|---|---|---|---|
| Jormungand daily all-agent health | 40e09cd1 | 11-24 03:00:00 / dur=115,867ms | `⚠️ API rate limit reached` | 03:02:25 重跑 **ok / dur=865,320ms** |
| OpenClaw 系統維護 | ca222989 | 11-24 03:04:49 / dur=12,597ms | `All models failed (3): fetch failed` | 03:05:32 重跑 **ok / dur=52,162ms** |

- **根因是同一場事故**：03:04:50 `ENETUNREACH fetch failed`（15ms）→ 03:04:51 `ENETUNREACH`（1,032ms）→ 03:05:02 `EAI_AGAIN api.minimax.io`（10,014ms）→ **fallback 鏈三個候選全滅（`model fallback decision: candidate_failed … next=none`）** → 03:05:02 `outcome=error error="All models failed (3)"`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 三次 `embedded run failover decision: decision=fallback_model reason=timeout rawError=fetch failed` → **reason 寫 timeout、實際是網路層斷線**（receipt 文字同樣誤導歸因：得看 journal 的 `rawError`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 另有 03:14:48 一筆 `LLM idle timeout (600s): no response from model`（elapsedMs=600,104）→ 同一波之後的尾巴。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → **教訓再確認：`cron list --all --json` 的 `lastStatus` 只反映「最後一次」**，本週期內死過的 job 一律被洗白；**每輪必做全 fleet receipt 掃描**（53 支 × 6 筆，約 1.5 分鐘）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🟢 Discord：8/8 running+connected，**3h 窗零症狀**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（04:03）：celesteela / charizard / flaaffy / gengar / mrmime / picturecat / roaringmoon / rowlet **全部 enabled, configured, running, connected**（greninja disabled/stopped ＝預期）；transport 新鮮度 just now～1m。真實收發：celesteela in:2h、mrmime in/out:57m、roaringmoon in:5h out:1m、rowlet in/out:21h、gengar in/out:21h、charizard in/out:19h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗（01:02→04:02，journal **1,335 行**）簽章計數：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **READY wait timed out 0 / channel exited 0 / client initialized 0 / channels resolved 0 / health-monitor 0 / host timing gap 0 / event-loop starvation 0 / eventLoopDelayP99Ms 0 / lane wait exceeded 0**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⚠️ **naive grep `disconnected` = 54 是假的** —— 逐行看全是 **sshd 的 `Received disconnect from 192.168.50.2`**（＝筆電 tunnel），**Discord disconnected 實際為 0**；這是「簽章 grep 會被同名字串污染」的新樣本（與 `[agent:nested]` 自述迴音同類）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `Gateway reconnect scheduled` 15 ＋ `websocket closed` 20（3h 窗 → 合併 ≈11.7/h，基線 2.6–3/h 各一支；凌晨三支 KA 同時起跑會抬高，與 §1 疊窗一致）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `was superseded` 10 筆、`Cannot delete session while competing work is in flight` 9 筆（fleet 常態雜訊；本窗唯一一支是 celesteela 的 880b5c17 04:05:07「Failed to remove unused run continuation」，**未疊 lane wait → 良性**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway：MainPID **4137629**、ActiveEnterTimestamp **11-23 04:48:17**、**連續 23h14m 未重啟**、NRestarts=0、ActiveState=active、`/health` **200 in 1.3ms**、load 0.51/0.47/0.48、mem available 20GiB、disk 61%（267G/468G）、host uptime 43d9h49m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) Fleet：53 jobs / 46 enabled / 7 disabled — **ok 38 / error 2 / skipped 5 / none 1**（與 01:02 完全相同）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 紅單 2 支，**皆舊因、非新生**：`36b493db` dreaming ce=1（11-23 04:25 被 gateway 重啟腰斬 → **今晚 04:25 槽是復驗**）、`c5352a84` skill-collection-review-roaringmoon ce=1（11-20 DNS 舊因，next 11-28）。`a94330a9 tmp-openai-probe` 為 enabled=false 殘留，不算紅單；skipped 5 支 = heartbeat `no-route`（良性長態）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal`：**01:43→03:43 連續 6 槽全 ok**（dur 747–796ms，全為「discord healthy (no startup-not-ready) - no action」）→ **fail-closed 守門 + hour-04 排除持續有效、零誤開火**；下一槽 **05:13**（04:13/04:43 不存在 ⇒ **排程確實排除 04 整點**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `bcf270b8 heartbeat-mrmime` 02:01→04:01 **4 槽全 ok**（dur 4.2s–54.0s）→ 11-23 16:01 那種 600s timeout 未復發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Provider / DNS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **canonical 429：3h 窗 1 筆**（03:01:55、elapsedMs=**105,849**、dispatcher=reused、model=MiniMax-M3）；**24h = 40 筆**，逐時：11-23 `05×2 06×1 07×26 08×3 09×1 12×1 18×1 21×1 23×2` / 11-24 `00×1 03×1`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **真實配額 `Token Plan usage limit`：24h = 58 筆，全在 07h**（11-23 07:29–07:59）→ 07:00 槽配額牆未復發；近 3h = 0；`status=529` = 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **429 回應延遲仍在「100–180 秒帶」**：24h 尾段 elapsedMs = 179,436 / 141,751 / 151,471 / 130,017 / 116,722 / 106,578 / 105,849 → 每次真 429 仍白燒 1.5–3 分鐘 job wall-clock。（序列中間那段 350–3,526ms 是 retry 的快速失敗，不是限流回應，別混算。）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **真實 DNS/網路錯誤（24h）：EAI_AGAIN 1 筆 + ENETUNREACH 2 筆**，全部集中在 03:04–03:05 那場（見 §2）→ 症狀極輕但**根因未除**：`resolvectl status` 仍顯示 **Link 2 (enp43s0) Current Scopes: none** → DNS 100% 靠 wlp0s20f3（Wi-Fi）+ tailscale0（待 Linder 點頭，本輪未動網路設定）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) ⭐⭐ **新發現：`elle.service` 是跑了 43 天的崩潰重啟迴圈（NRestarts = 119,872）**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `systemctl status elle.service` → `Active: activating (start-pre)`、`Cntrl PID: 214610 (/bin/sleep 30)`、`Memory: 192.0K`、`CPU: 1ms`；`Restart=on-failure`、**NRestarts=119,872**、StartLimitBurst=5（但因 restart counter 巨大而無限流）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ExecStart = `/etc/elle.sh`（72 bytes，只有一行 `. /home/amr/elle_builder_package/exec/simulation.sh`）→ 腳本 sleep 30 秒後 **exit 1** → systemd 每 ~31 秒重啟一次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **量級對得上**：119,872 次 ≈ 43 天 × 3 次/分鐘（host uptime 43d9h49m）→ **這個迴圈從開機起就沒停過**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **影響**：CPU 佔用極低（1ms/次），但**每 30 秒 fork 一組 bash+sleep 行程、systemd 每次寫 4–6 行 journal**（本窗 journal 1,335 行裡有相當比例來自它）→ 永久系統層噪音源；**與 openclaw 完全無關**，別誤判成 openclaw 的自癒機制在動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **修法＝停用該單元**（`systemctl disable --now elle.service`）或修 `/etc/elle.sh` / `simulation.sh`（`/etc/elle.sh` mtime 5-22、unit 檔同日建立）。**屬 root 擁有的系統單元，未經 Linder 點頭不動；本輪零改動。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) ⭐ SSH 來源追蹤續作：**筆電 automation 不是元凶，待決事項可降級**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 192.168.50.2（金鑰 `SHA256:BC2BuwA+zg3+yyNgs6bNP8xNawoVsSLfrKCpYVRiB6A` ＝ 本機 `authorized_keys` 的 `linder@LAPTOP-MCBJQ92A`）仍**每 10 分鐘 3 次**登入（3h 內 54 筆、30m 內 9 筆，末筆 03:57:48）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **關鍵新事實：這些 session 全部「沒有 `Starting session: command`」** → 登入後**未執行任何指令**（純 tunnel/keepalive）；且 **23h14m 內 gateway 零重啟** → **筆電端那支 automation 與 11-23 04:47 那次重啟無關**（那次由 self-heal 開火，01:02 輪已定案）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- → 前輪待決事項「11-24 04:25 前必須確認筆電端排程」**可以降級**：即便 04:27 那 3 次登入落在 dreaming 窗內，也不會砍 dreaming。**殘餘風險只剩兩項**：gateway 內建 health-monitor（idle 時才重啟 channel）＋ dreaming 自身 2400s timeout（最晚 05:05 收）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) ⏰ 04:25 dreaming 槽（20 分鐘後）的前置條件檢查：全數就位<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
| 前置條件 | 狀態 | 證據 |
|---|---|---|
| self-heal 不在 04 整點跑 | ✅ | expr `13,43 0-3,5-23 * * *`；01:43→03:43 全 ok；next **05:13** |
| dreaming 守門（3 支 arm 路徑共用檢查器） | ✅ | `scripts/dreaming-running-check.py`（07:27, 9,589B）＋ `discord-selfheal.sh`(07:26) / `gw-node-guard.sh`(13:12) / `apply-dreaming-schedule.sh`(13:12) |
| 重啟 stamp 未被更新 | ✅ | `memory/discord-selfheal-last-restart.ts` = 1795380377（11-23 04:46）→ 04:48 之後零重啟 |
| gateway 穩定 | ✅ | MainPID 4137629 連續 23h14m 未重啟、NRestarts=0、/health 200 in 1.3ms |
| 窗內其他 job 壓力 | ⚠️ 3 支 | `ac9e7ada` 英文教練 05:00、`e2ffd70d` push-llm-wiki 05:05、`13ac4b5a` 健康回報 05:05:20（`d4cd45bc` 05:13 在窗外） |

- dreaming 前兩輪 dur：11-22 **ok 1,852,428ms（30.9 分）**／11-21 ok 1,918,841ms → 今日最晚 05:05 收尾。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **判定標準（本輪只能給前置條件）＝ 07:02 槽驗 receipt（status/dur）＋ gateway MainPID/ActiveEnterTimestamp 是否變**；若 dur < 1,800,000ms 或 receipt error → 復驗失敗，紅單維持。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) ⚠️ 17 支 skill 缺 description 第 17 輪仍未修<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 3h 窗 **255 行**（`Skipping invalid skill`）、**唯一 17 檔**：13 支 `description is required`（web-fetch-troubleshooting / system-design-six-dimensions-analyzer / rosclaw×4 / ptcgp-card-lookup / ptcgp-card-download / prompt-injection-filter / prompt-injection-defense / network-security-defense / meta-analyzer / card-lookup）＋ 4 支 `invalid frontmatter`（ocr-confidence-mark / image-attendant / human-behavior-simulation / excel-image-pipeline）。每檔每 3h 15 次 ≈ **120 次/日**。→ **仍未授權，不動。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 邊界（本次刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 self-heal 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未停用 `elle.service`、未改 DNS/網路設定、未新增 job。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 一次）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`（全 fleet 掃描）、`journalctl --user`、`journalctl`（system）、`systemctl show/status`、`curl /health`、`resolvectl`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 給 Linder 的待決事項（沿用 + 新增）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增・中】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉 43 天的重啟迴圈與 journal 噪音；需 root，且與 openclaw 無關故一直沒人碰。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【急・沿用】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）；**本輪 03:04–03:05 的 fallback 全滅（next=none）正好演了一遍**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急・沿用】KA anchor 拉開 ≥15 分鐘** ＋ 讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 19 次疊窗（10.1s / 5ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中・沿用】DNS 根因未除**（enp43s0 無 DNS scope，全靠 Wi-Fi + tailscale0）→ 本窗症狀僅 1 筆 EAI_AGAIN + 2 筆 ENETUNREACH（同一場），但 03:04 那場直接打死一支 job。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中・沿用】17 支 skill 缺 description**（13 支 `description is required` ＋ 4 支 BAD_INDENT）→ 每日 ≈120 次 skip，未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中・沿用】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決（本 job 11-23 22:02 曾降級成 21.5s 零紀錄）。修法＝把必做五步與檔名寫進 payload（屬改 job，需 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【降級・沿用】筆電端每 10 分鐘 3 次的 SSH automation** → 本輪證實它**不執行任何指令**、且 23h14m 內零重啟 → 從「04:25 前必須確認」降為「觀察」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-24 07:02 — Picturecat Keep-Alive 第 3 輪：🟢 lane PASS、Discord **04:25 dreaming 造成的 33 分鐘失明已自然恢復**、gateway 連續 26h 未重啟、fleet 新增 1 筆新鮮紅單（429）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `f85c67f8-4a54-4afd-b243-8b351aaf38b0`、status=ok、回覆「pong — 无活跃任务，最近无错误，空闲待命。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**04:02**）**ok / dur=390,890ms / ce=0**（非降級輪）；本輪 runningAt=07:02:15、next=10:02:14；schedule=`every 10800000ms`（3h）、sessionTarget=isolated、payload=`agentTurn`「keep-alive test」+ model `minimax-portal/MiniMax-M3` + fallbacks `['minimax/MiniMax-M3','minimax-portal/MiniMax-M2.7','openai/gpt-5.4-mini']`、無 timeoutSeconds、delivery.mode=none。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：Gengar KA 04:02 ok（dur 541,066ms）、Celesteela KA 04:02 ok（dur 172,670ms），兩者 ce=0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA anchor 疊窗第 20 次**：gengar 07:02:03.291 → picturecat 07:02:15.412 → celesteela 07:02:15.418（**12.1s / 6ms**）——三支 KA 同一槽同時在跑，彼此搶同一條 minimax-portal 額度池。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（非故障）：本輪 `automations list` 回 `jobs: []`、`get/runs` 對本 job id 回「not found」，但 CLI `openclaw cron list --all --json` 53 支全見、本 job enabled=True、正常排程 → **restricted automation-run session 的視角限制**，**不是 job 遺失**；照舊不可據此刪 job。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐ 本輪主事件：04:25 dreaming → Discord 風暴 → **自然恢復**（04:02 輪的決定性驗收點已可結案）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion`（cron `25 4 * * *`、timeoutSeconds=2400、toolsAllow=["*"]、lightContext）**04:25:01 起跑，dur=1,816,088ms（30.3 分），status=ok、ce=0** → **本次未被腰斬**（對比 11-23：self-heal 在 04:48 開火把 dreaming 砍斷）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 風暴時間軸（journal `openclaw-gateway` 實測）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:27:53** 8 筆 `Gateway websocket closed: 1000`（code 1000＝乾淨關閉，gateway 內部把 client 整批換掉）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:28:42** 8 筆 `gateway websocket closed flow=…`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:33:30** 7 個 client 同時 `[帳號] channel exited: discord gateway opened but did not reach READY within 30000ms`（roaringmoon/flaaffy/charizard/celesteela/gengar/rowlet/mrmime）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:34–04:55** READY timeout 連環（attempt 爬到 11），**04:00 整點計 38 筆 READY wait timed out**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **04:55:02 / 04:55:31 / 04:55:41** flaaffy / celesteela / gengar 再次 channel exited（末次）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **05:00 起** 11 筆 `client initialized` → client 重新起；**05:00 之後 0 筆 READY timeout**，只剩 `Gateway reconnect scheduled (resume=true / reconnect-opcode)` 的良性續連。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⇒ **Discord 失明窗口 ≈ 33 分鐘（04:27 → 05:00），於 dreaming 結束（04:55:17）後自行恢復**，未靠任何重啟。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **gateway 未重啟**：MainPID `4137629`、ActiveEnterTimestamp `Mon 2026-11-23 04:48:17 CST`、NRestarts=0 → **連續 26h14m 未重啟**；本輪 self-heal 於 04 整點**沒有也不應該**開火（`discord-selfheal-after-dreaming` 的 expr `13,43 0-3,5-23` **刻意排除 04 整點**，正是 11-23 腰斬事故後的修法）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **設計取捨已可量化**：現行 self-heal 排程**同時排除了 dreaming 的 04 整點**，代價＝dreaming 期間 Discord **沒有任何自動救援**；好處＝dreaming 不再被腰斬。dreaming 預算 2400s、實際 1816s → **最壞情況失明窗口可達 ~40 分鐘**，而目前是靠「dreaming 自己結束」收斂，不是靠防護。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：本 3h 窗僅 1 筆 EAI_AGAIN/ENETUNREACH（04:06:36，gengar nested session 行內），量級較 11-21 的 1130 筆大幅回落。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) 🔴 fleet 新增 1 筆「新鮮」紅單：429 額度不是舊因<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `每日論文討論`（`58fe15dc-46e1-445d-89bc-ddd123881c98`，cron `0 7 * * *`）**07:00:00 起跑 → status=error、dur=208,723ms、ce=1**，retry next=07:03:58。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 對應 journal：`07:01:20` `provider-transport-fetch status=429 provider=minimax-portal api=anthropic-messages model=MiniMax-M3 elapsedMs=79059` → `embedded run agent end … isError=true error=⚠️ API rate limit reached`；`07:02:05` 另一筆同型（elapsedMs=124312）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429 量測：近 6h **7 筆**（03h 1 / 05h 2 / 06h 1 / 07h 3）、近 24h **44 筆**，**全部**來自 `minimax-portal`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 本 job 的 fallback 鏈實質冗餘＝0：`minimax/MiniMax-M3` 與 `minimax-portal/*` **共用同一額度池**、`openai/gpt-5.4-mini` **Auth=no** → 額度一緊就 next=none（11-24 03:04 那場已演過一次）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 現況紅單共 3 支（53 支中）：`每日論文討論`（ce=1，**新鮮，429**）、`skill-collection-review-roaringmoon`（ce=1，11-20 DNS 舊因）、`tmp-openai-probe`（ce=2，11-19 舊因，legacy 可清）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 系統面：全綠（唯一噪音仍是 elle.service）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- uptime **43d12:50**、load 0.86/0.60/0.53、RAM available 20Gi、`/` 61%（剩 178G）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service` 重啟迴圈仍在跑：**NRestarts=120,229、ActiveState=activating、24h 內 5,712 次啟動**（43 天未解）；與 openclaw 無關、需 root，故歷輪不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 self-heal 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未停用 `elle.service`、未改 DNS/網路、未新增 job。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 1 次）、`openclaw channels status`（2 次）、`openclaw cron list --all --json`（3 次）、`openclaw cron runs --id`（4 次）、`journalctl --user`、`journalctl`（system）、`systemctl show`、`uptime/free/df`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 現況（07:05 複驗）：**8/8 全部 `running, connected`**，transport 均 ≤1m。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 給 Linder 的待決事項（沿用 7 項 + 新增 2 項）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增・中】minimax-portal 額度池**（44 筆/24h，已打出一支新鮮紅單）→ 要嘛錯開 07:00 前後的 job 密度，要嘛補一組**真的**有憑證的第二廠商（見第 2 項）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新增・中】self-heal 的 04 整點空窗**：現行設計保護 dreaming 但放掉 Discord（今日實測失明 33 分鐘）。可選：(a) dreaming 槽平移到 self-heal 有在跑的時段；(b) 讓 self-heal 在 04 整點也跑，但守門改成「dreaming 超過預算（例如 >2400s）才准重啟」；(c) 接受現狀。**改 expr 屬改 job，需點頭。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急・沿用】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【急・沿用】KA anchor 拉開 ≥15 分鐘**＋讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 20 次疊窗（12.1s / 6ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中・沿用】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 本窗僅 1 筆症狀。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中・沿用】17 支 skill 缺 description**（13 支 `description is required`＋4 支 BAD_INDENT）→ 每日 ≈120 次 skip，未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中・沿用】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決（本 job 11-23 22:02 曾降級成 21.5s 零紀錄）。修法＝把必做五步與檔名寫進 payload。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中・沿用】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉 43 天重啟迴圈與 journal 噪音；需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【降級・沿用】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-24 10:02 — Picturecat Keep-Alive 第 4 輪：🟢 lane PASS、Discord **連續 5h 零症狀**（0 READY / 0 channel exited）、gateway 連續 **29h14m** 未重啟、⭐⭐ **「ce=0 洗掉整輪死亡」第 4 例實例：heartbeat-mrmime 08:21 硬死（600s timeout）**、⭐⭐ **新坑：`systemctl show openclaw-gateway`（system 層）回 inactive/MainPID=0 —— gateway 是 user unit**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `d77abcf1-0c16-4648-908b-86be72b11df4`、status=ok、回覆「pong — 近 3 小時無錯誤、無活躍任務。」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**07:02**）**ok / dur=170,696ms / ce=0**（非降級輪，summary 完整）；本輪 runningAt=10:02:15、next=13:02:15；schedule=`every 10800000ms`（3h）、sessionTarget=isolated、payload=`agentTurn`「keep-alive test」+ model `minimax-portal/MiniMax-M3` + fallbacks `['minimax/MiniMax-M3','minimax-portal/MiniMax-M2.7','openai/gpt-5.4-mini']`、無 timeoutSeconds、delivery.mode=none。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job（receipt 實測）：Gengar KA 07:02 ok（539,317ms）、Celesteela KA 07:02 ok（614,821ms），兩者 ce=0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA anchor 疊窗第 21 次**（`state.nextRunAtMs` 實測）：gengar `1795485723291` → picturecat `1795485735412` → celesteela `1795485735418`＝**12,121ms / 6ms**。三支同槽同搶 minimax-portal 額度池。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（非故障，沿用）：本輪 `automations` 視角仍不可用（restricted automation-run session），cron 真相一律走 `openclaw cron list --all --json`（53 支全見）＋ `openclaw cron runs --id`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 本輪主事件：「ce=0 洗掉整輪死亡」第 4 例 —— heartbeat-mrmime 08:21 硬死（600s timeout）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `bcf270b8 heartbeat-mrmime` receipt 時間線（`openclaw cron runs --id bcf270b8-b49b-407b-9bfe-b893e008f3b4 --limit 6`）：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **08:11:35 → 08:21:35**（ts=00:21:35Z）**status=error、dur=600,000ms、err=`cron: job execution timed out`** ← **本輪新事件**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 08:30:57 ok（501s）→ 08:31:13 ok（7s）→ 09:01 / 09:31 / 10:01 三輪 `skipped: quiet-hours`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⇒ **10:02 的紅單掃描完全看不到這次硬死**（`state.lastRunStatus=ok`、ce=0）—— **第 4 例「ce=0 洗掉整輪死亡」**（前 3 例：11-23 07:29 Gengar KA、11-23 16:01 heartbeat-mrmime、11-24 03:04 額度事故）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⭐ **這是 mrmime heartbeat 第二次同型死法**（11-23 16:01 是 `600s timeout` → `16:11 heartbeat failed: agent-runner-failure`；本輪 08:21 是 `600s timeout` → 下一輪自癒）→ **heartbeat 類 job 的 10 分鐘 timeout ＝ 定時炸彈**：只要模型呼叫慢過 600s 就整輪死，而它 40 分鐘內就會自癒、把證據洗掉。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **可操作規則**：每輪巡檢固定對 `bcf270b8`（heartbeat-mrmime）跑一次 `cron runs --id`，不要只信紅單清單。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 同型對照：08:21 那段 journal 只見密集的 `provider-transport-fetch start`（08:05 起每 1–2 秒一筆）→ **懷疑是模型呼叫排隊/慢回應觸發 600s 上限**，與 08:01:50 的 429（`agent end isError=true`）同一時段；**未取得直接因果證據，僅列為假設**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐ 新坑：`systemctl show openclaw-gateway`（system 層）會誤報 gateway 掛掉<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪第一手：`systemctl show openclaw-gateway` → **`MainPID=0`、`ActiveState=inactive`、`ActiveEnterTimestamp=n/a`**（差點誤判「gateway 已死」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 正確口徑＝**user unit**：`systemctl --user show openclaw-gateway` → `MainPID=4137629`、`NRestarts=0`、`ActiveState=active`、**ActiveEnterTimestamp=Mon 2026-11-23 04:48:17 CST** → **連續 29h14m 未重啟**（`ps` etimes=105,303s 佐證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **規矩：gateway 健康一律用 `systemctl --user`＋`ps` 交叉驗證；system 層的 `openclaw-gateway` 查不到是正常的（user unit），不是故障**。同理 `elle.service` 是 **system** unit（用 system 層查，ActiveState=activating）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) fleet：紅單只剩 1 支（且是被 retry 洗過的舊因）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 53 支中 enabled 且非 ok 的僅：`c5352a84 skill-collection-review-roaringmoon`（error、ce=1、next **11-26**、11-20 DNS 舊因）；另有 disabled 的 `a94330a9 tmp-openai-probe`（ce=2、11-19 舊因、legacy 可清）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ `每日論文討論`（`58fe15dc`）**07:00 的新鮮 429 紅單已被 retry 洗成 ce=0**：receipt = 07:03:28 error/208s（`⚠️ API rate limit reached`）→ **07:12:06 retry ok/486s** → `state.consecutiveErrors=0`。**07:00 輪是真的紅過**，只是 40 分鐘後已無痕跡。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 429 量測（本輪同口徑重算）：近 3h **4 筆** status=429（07:03:28 / 08:01:50 / 08:32:20 / 09:02:50）、近 6h **9 筆**、近 24h **19 筆**（其中 16 筆明列 `provider=minimax-portal`）；24h 內「rate limit」字串 45 筆。對應 4 筆 `agent end isError=true`（07:03 / 07:04 / 08:01 / 08:32 / 09:02）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming `36b493db` 今日 04:25 輪 ok/1,816,088ms（沿用 07:02 輪定案）；self-heal `d4cd45bc` 09:13/09:43/10:13 三輪 ok/dur=0s（無動作＝守門未開火）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Discord：連續 5h 零症狀（05:00 之後）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：**8/8 全部 `running, connected`**（greninja disabled 為設計如此），transport 均 ≤1m、out 皆 ≤3h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 近 3h：**0 筆 READY**（連 READY 字樣都沒有）、**0 筆 channel exited**；13 筆 `gateway websocket closed flow=…`（09:26 / 09:28 / 09:32 / 09:45 / 09:54 / 09:58 …）＝ **resume flow 的良性續連**，與 04:27-04:55 那種「8 筆 code 1000 整批換 client」不同型。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：近 3h 3 筆 EAI_AGAIN/ENETUNREACH（07:08:57 ×1、10:03:25 ×2），**全部在 gengar nested session 行內**，本 lane 0 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 系統面：全綠（唯一噪音仍是 elle.service）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- uptime **43d15:49**、load 0.91/0.61/0.51、RAM available 20Gi、swap 0、`/` 61%（剩 178G）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（system unit）仍在重啟迴圈：**NRestarts=120,585**（07:02 輪 120,229 → **+356/3h**）、ActiveState=activating、ActiveEnterTimestamp=10:02:59、24h 內 5,712 次啟動；與 openclaw 無關、需 root，歷輪不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 self-heal 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未停用 `elle.service`、未改 DNS/網路、未刪 job（`automations` 視角雖看不到 job，也沒據此刪除）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 1 次，寫進 `agent:picturecat:main` 非 cron session）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`（6 支）、`journalctl --user -u openclaw-gateway`、`systemctl --user show` / `systemctl show`、`ps`、`uptime/free/df`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（沿用 9 項 + 新增 1 項）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增・中】heartbeat 類 job 的 600s timeout 是定時炸彈**（本輪 mrmime 08:21 實測 + 11-23 16:01 同型）→ 要嘛把 heartbeat 的 timeoutSeconds 拉高（>1200s），要嘛在 600s 內主動讓它結束。**改 job 需點頭。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新增・中】巡檢方法論再收斂**：紅單清單已證實**不足以**代表「這段時間沒出事」（第 4 例）→ 建議把「`cron runs --id` 固定檢查清單（三支 KA + dreaming + heartbeat-mrmime + 每日論文討論）」寫進 KA payload。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急・沿用】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）、本 job fallback 鏈實質冗餘＝0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【急・沿用】KA anchor 拉開 ≥15 分鐘**＋讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 21 次疊窗（12.1s / 6ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中・沿用】minimax-portal 額度池**（近 3h 4 筆 / 24h 19 筆 status=429）→ 要嘛錯開整點 job 密度，要嘛補一組真的 有憑證的第二廠商。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中・沿用】self-heal 的 04 整點空窗**（dreaming 期間 Discord 無救援，04:25 實測失明 33 分鐘）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中・沿用】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 本窗僅 gengar nested 3 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中・沿用】17 支 skill 缺 description**（13 支 `description is required`＋4 支 BAD_INDENT）→ 每日 ≈120 次 skip，未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中・沿用】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決（本 job 11-23 22:02 曾降級成 21.5s 零紀錄）。修法＝把必做五步與檔名寫進 payload。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中・沿用】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉 43 天重啟迴圈與 journal 噪音；需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【降級・沿用】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-24 13:02 — Picturecat Keep-Alive 第 5 輪：🟢 lane PASS、Discord **連續 8h 零症狀**、gateway 連續 **32h14m** 未重啟、⭐⭐⭐ **04:25 dreaming 槽「部分驗收」：dreaming 本體活下來了，但 event-loop 凍結把 6 支 heartbeat 全部打死（12 輪 600s timeout）**、⭐⭐ **新 bug：`heartbeat-flaaffy` 從未執行過（everyMs 被放大 1000 倍）**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `b876997a-7564-456e-9659-03539240aa6f`、status=ok、回覆「pong — no active task, no errors in the last 3h; Discord send/receive healthy.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**10:02**）**ok / dur=138,687ms（138.7s）** → **非降級輪**（>30s 門檻），summary 完整<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 今日四輪 dur 全量：01:02 **392,354ms** → 04:02 **390,890ms** → 07:02 **170,696ms** → 10:02 **138,687ms**；**四輪全綠、四輪全非降級**（對照 11-23 22:02 那次 21.5s 零紀錄降級輪已不再復現）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job（receipt 實測）：**Gengar KA 10:02 ok / dur=259,428ms**、**Celesteela KA 10:02 ok / dur=244,303ms**，兩者 ce=0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA anchor 疊窗第 22 次**（`state.nextRunAtMs` 實測）：gengar `1795496523312` → picturecat `1795496535443` → celesteela `1795496535448`＝**12,131ms / 5ms**。三支同槽同搶 minimax-portal 額度池。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（非故障，沿用）：本輪 `automations` 視角仍不可用（`get` 回 `cron job not found`、`list` 回 0 筆；restricted automation-run session），cron 真相一律走 `openclaw cron list --all --json`（53 支全見）＋ `openclaw cron runs --id`（`.entries[]` 形狀）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ 本輪主事件：04:25 dreaming 槽「**部分驗收通過**」—— dreaming 本體活了，heartbeat Fleet 被打死了<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
**結論先行**：11-23 07:02 那兩項修法**對 dreaming 本體有效**（不再被腰斬），但**對被連帶殺死的 heartbeat fleet 無效**。

**(a) dreaming 本體：✅ 存活，且這是決定性驗證**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion` receipt = **11-24 04:25:01 起跑 → 04:55:18 收尾、status=ok、dur=1,816,088ms（30.3 分）、ce=0**（`cron runs --id` 實測）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway **全程未重啟**：MainPID 4137629、`ps` etimes=116,090s、ActiveEnterTimestamp 仍是 **11-23 04:48:17**（唯一那次重啟是 self-heal 開火造成）→ **11-23 的因果鏈（self-heal 誤判 dreaming idle → arm 重啟 → 腰斬 dreaming）已被完全切斷**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 佐證：`d4cd45bc` self-heal 今日 **04:00–05:00 期間零執行**（排程 `13,43 0-3,5-23 * * *` 刻意不含 04 整點），且 05:13 / 05:43 / 06:13 / 06:43 四輪全 `discord healthy (no startup-not-ready) - no action` → 守門沒有開火。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

**(b) 但同期 event loop 凍結仍然發生，且殺死 12 輪 heartbeat**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 04:27:52 `[health] host timing gap detected: process was frozen ~169,157ms`（**2.8 分鐘**）；`eventLoopDelayP99Ms` = **279,709 / 237,968 / 279,441 / 168,980 ms**、`eventLoopUtilization=1` → **cron runner 的 600s timeout 就在這個洞裡燒完**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **04:34:14 `[diagnostics/memory] memory pressure: level=warning reason=rss_growth rss=2.03 GiB heap=864.8 MiB threshold=512 MiB thresholdRatio=127.4% rssGrowth=652.2 MiB`** → **最可能的根因：dreaming 的 deep-phase 平行敘事把 RSS 撐到 2 GiB，GC/事件迴圈被拖垮**（此為本輪新取得的根因證據，11-23 只有症狀沒有機制）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Discord 風暴同期：**13 筆 `channel exited` + 64 筆 READY + 23 筆 `client initialized` + 3 筆 disconnected + 7 支 agent 通道 `auto-restart attempt 1/10`**（04:33:30 roaringmoon/flaaffy/charizard/celesteela/gengar/rowlet/mrmime 同批）＋ `host thaw channel restart deferred: gateway still has active work` → **channel 重啟被正確擋下（沒有重啟 gateway），但 channel 本身已經掉了**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **12 輪硬死的完整名單（`cron runs --id` 逐支實測，24 筆/run）**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `heartbeat-picturecat` 04:27:52 (669,572ms) / 04:39:39 (602,154ms)<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `heartbeat-roaringmoon` 04:27:52 (669,588ms) / 04:39:39 (602,170ms)<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `heartbeat-gengar` 04:33:29 (681,572ms) / 04:45:34 (600,003ms)<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `heartbeat-mrmime` 04:33:29 (681,564ms) / 07:01:08 (600,004ms) / 07:11:40 (53,619ms, `heartbeat failed: agent-runner-failure`) / 08:01:04 (600,004ms) / **08:11:35 (600,009ms)**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `heartbeat-rowlet` 04:39:02 (616,973ms) / 08:08:21 (600,004ms)<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `heartbeat-celesteela` 04:44:50 (602,502ms) / 06:12:47 (600,003ms)<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `heartbeat-greninja` 0、`heartbeat-charizard` 0（此兩支 24 筆全 ok/skipped）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - ⇒ **6/8 支 heartbeat 受創、12 輪硬死，全部落在 04:27–06:13**；`heartbeat-mrmime` 額外多 3 輪（07:01 / 07:11 / 08:01 / 08:11）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **這些全部被 `state.lastRunStatus=skipped` + ce=0 洗掉** → 紅單看不到、cron list 看不到（本次巡檢若只跑 `openclaw cron list` 會完全漏掉）。**Gengar 07:02 輪已抓到「fleet 級 heartbeat 600s timeout 群集」這個症狀；本輪補上根因（169s 凍結 + 2.03GiB RSS）與完整 receipt 清單。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **自 10:02 上一輪起（3h 窗）新增硬死 = 0 筆** —— 本輪新事實只到 08:11 為止，之後 fleet 安靜。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐⭐ 新 bug：`heartbeat-flaaffy`（`6e93c179`）**從來沒有執行過**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `everyMs = 35,996,400,000`（**599,940 分 ≈ 416.6 天**），而**其餘 8 支 heartbeat 全部是 1,800,000ms（30 分）** → **差 1000 倍**，典型的 ms/單位打錯（35996400 ms ≈ 10 小時，被寫成 35,996,400,000）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `anchorMs=1,814,183,940`、`nextRunAtMs=1,801,634,180,940` → **下一次要等 ~71 天後**；`state.lastRunAtMs=None`、`lastRunStatus=None`、`consecutiveErrors=None`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw cron runs --id 6e93c179… --limit 24` → **entries = 0 筆**（`total` 欄位不存在）→ **這支 heartbeat 從註冊到現在一次都沒跑過**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **Flaaffy 的 heartbeat lane 實質上是死的**：主 KA（Picturecat Keep-Alive）有在跑，但「Flaaffy 自己覺得自己活著」的探針從未發射。**改 job 需點頭。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) fleet：53 jobs / 46 enabled / 7 disabled — **ok 36 / skipped 8 / error 1 / none 1**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 的非 ok 項：8 支 heartbeat 全是 `skipped`（`quiet-hours` / `no-route`，設計如此，非失敗）；`c5352a84 skill-collection-review-roaringmoon` error/ce=1（11-20 DNS 舊因，next **11-26**）；**`6e93c179 heartbeat-flaaffy` status=None（從未跑，見 §3）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled：`a94330a9 tmp-openai-probe` error/ce=2（11-19 舊因、legacy 可清）；其餘 5 支 ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`40e09cd1` Jormungand daily all-agent health**（cron `0 3 * * *`）：11-24 03:00 error（429 / 115,867ms）→ **03:02 retry ok / 865,320ms** → `state.lastRunStatus=ok`、ce=0 → **又是「retry 洗掉紅單」**（10:02 輪已記同一型別）。歷史 12 筆中 **7 筆 error**（4× rate limit、1× DNS、1× network、1× timeout）＝ **58% 失敗率**，其中 11-23 / 11-24 連續兩天 03:00 都中 429。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`d7b0355b` Jormungand mrmime Codex A2A heartbeat**（cron `0 */6 * * *`）：近 24 筆只有 3 筆 error，且**全在 11-19（121h 前）**＝ 429 `Token Plan usage limit reached`；本輪狀態 ok/ce=0 → 已自癒。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming `36b493db` 今日 04:25 ok/1,816,088ms（沿用 01:02 / 07:02 輪定案，本輪補完 §2）；self-heal `d4cd45bc` 05:13→12:43 共 16 輪全 ok/dur≈0.75–0.86s（**無動作＝守門未開火**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 429：數量下降但**時段結構更清楚了**——全部卡在整點 job 密度上<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical `status=429` 筆數（同口徑）：近 3h **1**、近 6h **4**、近 24h **19**（其中 **16 筆**明列 `provider=minimax-portal`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h 內 429 的時間戳（去重後）：**12:02 / 13:11 / 16:07 / 16:18 / 18:02 / 21:01 / 23:01 / 23:03 / 00:02 / 03:01 / 05:02 / 05:31 / 06:03 / 07:01 / 07:02** → **幾乎全部落在整點後 1–11 分鐘**，即「整點 cron 密度撞額度池」的直接指紋。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本窗唯一一筆（12:03:01）細節：`provider-transport-fetch … status=429 elapsedMs=108,027`（**排隊 108 秒才被拒**）→ `embedded run … isError=true` → `rate-limit same-model retry 1/3 delayMs=10000` → **12:03:20 status=200 elapsedMs=9,273** → 之後 200 連發（3,479 / 1,793 / 2,367 / 1,684 ms）→ **10 秒內自癒**。⇒ 429 本身可自癒；**真正致命的是「慢排空」把 cron 撐過 600s**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`每日論文討論`（`58fe15dc`，cron `0 7 * * *`）07:00 輪連續第 3 天撞 429**：11-21 07:03 error→07:12 ok、11-22 07:02 error→07:09 ok、**11-24 07:03 error/208,723ms（`⚠️ API rate limit reached`）→07:12:06 retry ok/486,124ms**（11-23 07:08 直接 ok）。**07:00 這個槽本身就有問題**，不是偶發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Discord：連續 **8h** 零症狀（05:00 之後）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：**8/8 全部 `running, connected`**（greninja disabled 為設計如此），transport 均 just now。真實收發：celesteela in:14m、charizard in/out:4h、gengar in/out:6h、mrmime in/out:57m、roaringmoon in/out:4h、rowlet in/out:6h。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 近 3h（623 行）：**READY 0 / channel exited 0 / client initialized 0 / disconnected 0 / host timing gap 0 / event-loop starvation 0 / lane wait exceeded 0**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 近 6h（2,851 行）：READY 0 / channel exited 0 / **client initialized 2**（即 05:00 前殘留）/ host timing gap 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 10 筆 `gateway websocket closed flow=…` ＋ 9 筆 `Gateway reconnect scheduled`（近 3h）＝ **resume flow 的良性續連**，與 04:27–04:45 那種整批換 client 不同型。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：近 3h **2 筆 EAI_AGAIN + 2 筆 ENETUNREACH**，**全部在 gengar nested session 行內**，本 lane 0 筆（根因未除，見 §7）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 系統面：全綠（唯一噪音仍是 elle.service）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway（**user unit** 口徑）：MainPID **4137629**、`ps` etimes=**116,090s（32h14m 未重啟）**、ActiveEnterTimestamp=**11-23 04:48:17**、NRestarts=**0**、ActiveState=active、SubState=running、`/health` **200 in 1.5ms**（port 18789）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 主機：uptime **43d18:49**、load 0.97/0.61/0.57、RAM available 20Gi、swap 0、`/` 61%（剩 178G）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（**system** unit）仍在重啟迴圈：**NRestarts=120,942**（10:02 輪 120,585 → **+357/3h**，與上輪 +356/3h 完全一致）、ActiveState=activating、ActiveEnterTimestamp=13:02:58。與 openclaw 無關、需 root，歷輪不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 self-heal 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未停用 `elle.service`、未改 DNS/網路、未刪 job（`automations` 視角看不到 job 也沒據此刪除）、未動任何 heartbeat 的 everyMs（含 flaaffy 的 1000× 錯誤）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 1 次，寫進 `agent:picturecat:main` 非 cron session）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`（11 支）、`journalctl --user -u openclaw-gateway`（3h/6h/24h + 04:20–05:10 精確窗）、`systemctl --user show` / `systemctl show`、`ps`、`uptime/free/df`、`curl /health`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項（沿用 11 項 + 新增 2 項）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增・高】`heartbeat-flaaffy` 的 everyMs 放大 1000 倍（35,996,400,000 vs 兄弟的 1,800,000）→ 這支 heartbeat 從未執行過，下次要等 71 天。** 修法＝把 everyMs 改回 1,800,000（30 分，與其餘 8 支一致）＋ anchor 重新對齊。**改 job 需點頭。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新增・高】dreaming 的 event-loop 凍結會連帶殺死整個 heartbeat fleet（12 輪 / 6 支），且被 ce=0 完全洗掉。** 建議三選一：① 給 dreaming 錯開整點（例：04:25 → 04:55 / 05:25），避開 heartbeat 的 30 分槽；② 把 heartbeat 的 timeoutSeconds 從隱含 600s 拉高到 >1200s；③ 給 dreaming 加 RSS 護欄（降 toolsAllow 或分批 deep-phase）。**改 job 需點頭。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急・沿用】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）、本 job fallback 鏈實質冗餘＝0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【急・沿用】KA anchor 拉開 ≥15 分鐘**＋讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 22 次疊窗（12.1s / 5ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中・沿用】minimax-portal 額度池**（24h 19 筆 status=429、16 筆明列該 provider；時戳幾乎全在整點後 1–11 分）→ 要嘛錯開整點 job 密度，要嘛補一組真的有憑證的第二廠商。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中・沿用】self-heal 的 04 整點空窗**（本輪已證實：04:00–05:00 self-heal 零執行 → dreaming 安全，但**同一個洞裡 heartbeat 也全滅**，沒有人救援）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中・沿用】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 本窗僅 gengar nested 2+2 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中・沿用】17 支 skill 缺 description**（13 支 `description is required`＋4 支 BAD_INDENT）→ 每日 ≈120 次 skip，未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中・沿用】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決（本 job 11-23 22:02 曾降級成 21.5s 零紀錄）。修法＝把必做五步與檔名寫進 payload。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中・沿用】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉 43 天重啟迴圈與 journal 噪音；需 root。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【中・沿用】`每日論文討論` 07:00 槽連續 3 天撞 429**（11-21 / 11-22 / 11-24 皆首輪 error、靠 ~07:10 retry 自癒）→ 要嘛把該 job 從 07:00 移到 07:30 錯開整點，要嘛接受 retry 作為常態並把 retry 間隔寫進 payload。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12. **【降級・沿用】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-24 16:02 — Picturecat Keep-Alive 第 6 輪：🟢 **全綠的一輪**（lane PASS、Discord 連續 11h 零症狀、3h 窗 429=0、gateway 連續 35h14m 未重啟、heartbeat fleet 3h 窗 0 筆 600s 硬死） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `7e90794a-41af-4f5c-b210-9e81171eac62`、status=ok、回覆「pong — 近 3 小時無 active task、無錯誤，Discord 收發正常。」 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**13:02**）**ok / dur=173,018ms（173s）/ ce=0** → 非降級輪（>30s 門檻），summary 完整。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 今日六輪 dur 全量：01:02 **392,354ms** → 04:02 **390,890ms** → 07:02 **170,696ms** → 10:02 **138,687ms** → 13:02 **173,018ms**；**五輪全綠、全非降級**（對照 11-23 22:02 那次 21.5s 零紀錄降級輪未再復現）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job（receipt 實測）：**Gengar KA 13:02 ok / dur=215,202ms**、**Celesteela KA 13:02 ok / dur=171,302ms**，兩者 ce=0 → **三支 KA 全綠**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA anchor 疊窗第 23 次**（`state.nextRunAtMs` 實測）：gengar `1795507323328` → picturecat `1795507335471` → celesteela `1795507335477`＝**12,143ms / 6ms**。三支同槽同搶 minimax-portal 額度池。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（非故障，沿用）：本輪 `automations` 視角仍不可用（`get` 回 `cron job not found`、`list` 回 0 筆；restricted automation-run session），cron 真相一律走 `openclaw cron list --all --json`（53 支全見）＋ `openclaw cron runs --id`（**輸出鍵是 `entries[]`，不是 `runs[]`**）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) 🟢 Discord：連續 **11h** 零症狀（05:00 之後），3h 窗簽章全為零 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（16:02）：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet **全部 enabled, configured, running, connected**，transport 均 ≤1m（greninja disabled/stopped ＝預期）。真實收發：mrmime **in/out: just now**、celesteela in:17m、charizard in/out:7h、gengar in/out:9h、roaringmoon in/out:7h。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 近 3h（550 行）簽章計數：**status=429 = 0 / READY wait timed out = 0 / channel exited = 0 / client initialized = 0 / host timing gap = 0 / event-loop starvation = 0 / reconnect-exhausted = 0 / startup-not-ready = 0 / lane wait exceeded = 0 / overloaded_error = 0 / Token Plan usage limit reached = 0 / EAI_AGAIN = 0 / ENETUNREACH = 0**（首輪量測在 −3h 邊界抓到 1 筆 EAI_AGAIN，窗口前移後即消失，非本窗事件）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 僅 18 筆 `gateway websocket closed`（code=1005/1006）＋ 12 筆 `Gateway reconnect scheduled … resume=true`（13:28 / 13:36 / 13:49 / 13:54 ×2 / 13:58 / 14:41 ×2 / 14:50 / 15:19 / 15:23 / 15:33）＝ **resume flow 的良性續連**，非 11-20 22:38 那種「8 帳號整批 reconnect-exhausted」。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 近 6h `status=429` = **1 筆**（12:03:01，minimax-portal，elapsedMs=108,027）→ **429 連續兩輪停在 12:03 那一次**，本窗完全乾淨。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) ⭐ 本窗唯一值得記的新事實：**heartbeat fleet 3h 窗 0 筆 600s 硬死**（04:27–08:11 群集後連續 8h 乾淨）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 13:02–16:02 窗內所有 heartbeat receipt（`cron runs --id` 逐支實測）：mrmime 14:01 ok/4,714ms → 14:31 ok/6,689ms → 15:01 ok/6,072ms → 15:31 ok/9,078ms；gengar 14:29 ok/15,815ms → 14:59 ok/9,895ms → 15:29 ok/9,596ms → 15:59 ok/13,390ms；charizard 14:25 ok/29,180ms → 14:55 ok/12,157ms → 15:25 ok/11,180ms → 15:55 ok/12,831ms；rowlet/celesteela/greninja/roaringmoon/picturecat 全為 `skipped: no-route`（Discord lane 心跳無路由＝良性長態）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⇒ **本窗無任何一支 heartbeat 出現 600s timeout / terminated**；11-24 04:27–08:11 那場「dreaming event-loop 凍結 → 6 支 × 12 輪硬死」是最後一次實害，此後 8 小時無復發。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⏰ 附帶觀察：`quiet-hours` 結束點 ≈13:56（13:2x–13:5x 各支仍 skipped: quiet-hours，14:xx 起轉 no-route/ok）→ 這解釋了「前幾輪 skipped=8、本輪 skipped=5」的統計差異（3 支 mrmime/gengar/charizard 在 14:xx 起轉為 ok）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`heartbeat-flaaffy`（`6e93c179`）依然一次都沒跑過**：`cron runs --id` entries = **0 筆**；`nextRunAtMs=1,801,634,180,940`（＝2027-02-03，距今約 **71 天**）。everyMs 1000× 錯誤未修（改 job 需點頭）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) fleet：53 jobs / 46 enabled / 7 disabled — **ok 39 / skipped 5 / error 1 / none 1** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 的非 ok：8 支 heartbeat 中 5 支 `skipped`（no-route / quiet-hours，設計如此）；`c5352a84 skill-collection-review-roaringmoon` error/ce=1（11-20 DNS 舊因，next **11-26**）；`6e93c179 heartbeat-flaaffy` status=None（從未跑，見 §3）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled：`a94330a9 tmp-openai-probe` error/ce=2（11-19 舊因、legacy 可清）；其餘 6 支 ok。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **13:02–16:02 窗內實際跑過的 16 支**：三支 KA（13:02 全 ok）、`29c2d630` Gengar watchdog ok/3,197ms（14:04）、`13ac4b5a` 健康回報 ok/39,250ms（14:05）、`ca222989` 系統維護 ok/61,337ms（15:04）、`537bd0dd` 轉錄監控 ok/1,183ms（16:00）、`af94aa92` 每日備份 ok/132,941ms（16:00）、self-heal 6 輪全 ok → **窗內零紅單**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `d4cd45bc discord-selfheal`：12:43 / 13:13 / 13:43 / 14:13 / 14:43 / 15:13 / 15:43 共 7 輪全 ok、dur 744–811ms、全為「discord healthy (no startup-not-ready) - no action」→ 守門未開火；next **16:13**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db Memory Dreaming Promotion`：11-24 04:25→**04:55:18 ok / 1,816,088ms（30.3 分）**（沿用 13:02 輪定案），next **11-25 04:25**；歷史 7 筆中 2 筆 error 皆為「interrupted by gateway restart」（11-20 / 11-23），11-24 是連續第 2 次完整活下來。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand`：11-24 03:01:55 error/115,867ms（429）→ **03:16:51 retry ok/865,320ms** → ce=0（又是「retry 洗掉紅單」）。近 4 天 03:00 槽：11-21 error、11-22 ok、11-23 error、**11-24 error** → **4 天 3 次撞 429**，該槽本身有問題。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `58fe15dc 每日論文討論`：07:03:28 error/208,723ms（429）→ **07:12:06 retry ok/486,124ms**；近 4 天 07:00 槽：11-21 error、11-22 error、11-23 ok、**11-24 error** → 同一型別，兩個整點槽（03:00 / 07:00）反覆中獎。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) 系統面：全綠（唯一噪音仍是 elle.service）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway（**user unit** 口徑）：MainPID **4137629**、`ps` etimes=**126,863s（35h14m 未重啟）**、ActiveEnterTimestamp=**11-23 04:48:17**、NRestarts=**0**、ActiveState=active、SubState=running、`/health` **200 in 1.1ms**（port 18789）、RSS 1.56GB（dreaming 尖峰 2.03GiB 已回落）、CPU 6.0%。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 主機：uptime **43d21:49**、load 0.81/0.68/0.60、RAM available 20Gi、swap 0、`/` 61%（剩 178G）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（**system** unit）仍在重啟迴圈：**NRestarts=121,300**（13:02 輪 120,942 → **+358/3h**，與上輪 +357/3h 幾乎一致）、ActiveState=activating、ActiveEnterTimestamp=16:03:28。與 openclaw 無關、需 root，歷輪不動。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 邊界（本輪刻意沒動）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 self-heal 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未停用 `elle.service`、未改 DNS/網路、未刪 job（`automations` 視角看不到 job 也沒據此刪除）、未動任何 heartbeat 的 everyMs（含 flaaffy 的 1000× 錯誤）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 1 次，寫進 `agent:picturecat:main` 非 cron session）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`（16 支）、`journalctl --user -u openclaw-gateway`（3h/6h）、`systemctl --user show` / `systemctl show`、`ps`、`uptime/free/df`、`curl /health`。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 給 Linder 的待決事項（沿用 13 項，本輪無新增、無解除）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【高】`heartbeat-flaaffy` everyMs 放大 1000 倍 → 該 heartbeat 從未執行過，下次要等 71 天（2027-02-03）**。修法＝everyMs 改回 1,800,000（與其餘 8 支一致）＋ anchor 重新對齊。**改 job 需點頭。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【高】dreaming 的 event-loop 凍結會連帶殺死整個 heartbeat fleet（11-24 04:27–08:11：6 支 × 12 輪 600s 硬死），且被 ce=0/skipped 完全洗掉**。三選一：① dreaming 錯開整點（04:25 → 04:55 / 05:25）；② heartbeat timeoutSeconds 拉高 >1200s；③ dreaming 加 RSS 護欄。**改 job 需點頭。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【急】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）、本 job fallback 鏈實質冗餘＝0。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【急】KA anchor 拉開 ≥15 分鐘**＋Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 23 次疊窗（12.1s / 6ms）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【中】minimax-portal 額度池**（本窗 429=0、6h=1、24h=19；時戳幾乎全在整點後 1–11 分；**03:00 / 07:00 兩個槽近 4 天各撞 2–3 次**）→ 錯開整點密度，或補一組真的有憑證的第二廠商。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中】self-heal 的 04 整點空窗**（dreaming 期間 Discord 無救援）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 本窗 0 筆。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中】17 支 skill 缺 description**（每日 ≈120 次 skip）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉 43 天重啟迴圈；需 root。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【降級】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12. **【中】巡檢方法論**：紅單清單不足以代表「這段時間沒出事」→ 建議把「`cron runs --id` 固定檢查清單（三支 KA + dreaming + 8 支 heartbeat + 每日論文討論 + Jormungand）」寫進 KA payload。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13. **【中】heartbeat 的 600s timeout 是定時炸彈** → 要嘛拉高 timeoutSeconds，要嘛在 600s 內主動結束。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 下一輪（19:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. 15:13→19:xx 的 self-heal 輪次是否仍全「no action」、Discord 是否仍 8/8 connected（連續 14h+）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. 18:00 / 19:00 槽的 429 是否再現（本輪已連續兩輪 3h 窗 429=0，若再現則確認「整點密度」而非「時段」假設）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. heartbeat fleet 是否持續 0 筆 600s 硬死（若再現 → 待決事項 #2 升級為最高優先）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. `heartbeat-flaaffy` 是否仍 0 entries（nextRunAtMs 應仍是 2027-02-03，未經點頭不修）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-24 19:02 — Picturecat Keep-Alive 第 7 輪：🟡 **lane PASS，但 heartbeat fleet 破了 1 筆**（heartbeat-mrmime 16:09 error/477s ＝「superseded」症狀首次直接殺死整輪）、3h 窗 429=1（18:02:31）、gateway 連續 38h15m 未重啟 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `efeed01b-6fdc-404e-8ac0-271d8900443f`、status=ok、回覆「pong — 近 1 小時無 active task、無錯誤。」 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**16:04**）**ok / dur=145,332ms（145s）/ ce=0** → 非降級輪。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 今日六輪 dur 全量：01:02 **392,354ms** → 04:02 **390,890ms** → 07:02 **170,696ms** → 10:02 **138,687ms** → 13:02 **173,018ms** → 16:04 **145,332ms**；**六輪全綠、全非降級**（11-23 22:02 那次 21.5s 零紀錄降級輪未再復現）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job：**Gengar KA 16:09 ok / dur=419,443ms**、**Celesteela KA 16:07 ok / dur=309,740ms**（19:04 輪 ok/151,043ms 進行中）→ **三支 KA 全綠**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA anchor 疊窗第 24 次**（`state.nextRunAtMs` 實測）：gengar `1795518124163` → picturecat `1795518136274` → celesteela `1795518136279`＝**12,111ms / 5ms**。三支同槽同搶 minimax-portal 額度池。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（非故障，沿用）：本輪 `automations` 視角仍不可用（`get` 回 `cron job not found`、`list` 回 0 筆；restricted automation-run session），cron 真相一律走 `openclaw cron list --all --json`（53 支全見）＋ `openclaw cron runs --id`（輸出鍵 `entries[]`，欄位 `ts`/`tsIso`/`durationMs`/`status`；**`ts` 是 epoch ms**、顯示請用 `tsIso`，勿用 `strftime`＝UTC 會錯位）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐ 本輪新事實：**「prepared model runtime plugin generation was superseded」首次直接殺掉一整輪 heartbeat**（16:09） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt：`heartbeat-mrmime`（`bcf270b8`）**16:09:06 → status=error / dur=477,199ms / summary 空** → **這是 11-24 04:27–08:11 群集之後 fleet 的第一筆紅單**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 根因（journal 16:09:03–16:09:06 逐行）：① `[cron:9d8b6001] Failed to remove unused run continuation: Cannot delete session while competing work is in flight`（Gengar KA 清理 run continuation 撞到 in-flight 工作）→ ② 連續 **3 組** `lane task error: "prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/mrmime/agent"`（lanes: `cron-nested` ×3 ＋ `session:agent:mrmime:main:heartbeat` ×3，各 3–6ms）→ ③ `Embedded agent failed before reply: prepared model runtime plugin generation was superseded …` → ④ `model-fallback/decision` 連發 → 整輪直接死。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 同一秒窗 **heartbeat-rowlet 16:09 → skipped 但 dur=43,742ms**（正常 skipped 僅 ~262ms）→ 同一場 16:02 KA 爆發造成的排隊震動。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **定性升級**：過去 4 輪把這個簽章視為「良性症狀（fallback 後照跑）」；本輪證實它**可以直接殺掉一整輪 job run**（不只 fallback）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 頻率：`Embedded agent failed before reply` 3h=**1**、24h=**2** → **罕見、非系統性**，但每次都在 KA 爆發窗內。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-mrmime` 近 60 筆 error 史：**8 筆**（11-24 16:09:06/477,199ms、08:21:35/**600,009ms**、08:11:04/**600,004ms**、07:12:33/53,619ms、07:11:08/**600,004ms**、04:44:51/681,564ms；11-23 16:15:48/249,653ms、16:11:07/**600,004ms**）→ 該 lane 是 fleet 最脆的一支。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 自癒但被洗：16:31 起連續 ok（16:31 4,142ms → 17:01 7,796 → 17:31 7,497 → 18:04 **224,994ms** → 18:31 10,883 → 19:01 7,300ms）→ cron state `ce=0`、紅單看不到，**只有 `cron runs --id` 看得到那筆 16:09 error**（第 3 次同型「下一輪 ok 洗掉紅單」）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) fleet：53 jobs / 46 enabled / 7 disabled — 窗內（16:02–19:02）**0 筆 600s 硬死、1 筆 error（見 §2）** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 8 支 heartbeat 窗內 receipt（`cron runs --id` 逐支實測）：charizard 6 輪全 ok（11.6–12.4s）、gengar 6 輪全 ok（11–58s）、**mrmime 6 ok ＋ 1 error**、rowlet/celesteela/greninja/picturecat/roaringmoon 全為 `skipped: no-route`（良性長態）→ **slow600=0，11-24 最後一筆 600s 硬死仍是 08:21**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-flaaffy`（`6e93c179`）：`cron runs --id` **tot=0**、state status=None、nextRunAt **2027-02-03 05:56 UTC**（≈71 天後）→ everyMs 1000× 錯誤仍未修（改 job 需點頭）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 窗內其他實際執行：三支 KA（16:04–16:09 全 ok）、`ca222989` 系統維護 16:05/17:07/18:06 ok、`13ac4b5a` 健康回報 17:06 ok、`29c2d630` watchdog 16:04/18:04 ok、`537bd0dd` 轉錄監控 14 輪×5min 全 ok、`af94aa92` 每日備份 16:02 ok/132,941ms、`d7b0355b` A2A 18:04 ok/252,190ms、`e2b00e12` Daily Codex health 18:05 ok、`d4cd45bc` selfheal 16:13–18:43 共 6 輪全 ok/dur 746–792ms → **窗內除 mrmime 那一筆外零紅單**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 的非 ok：`c5352a84 skill-collection-review-roaringmoon` error/ce=1（11-19 DNS 舊因，next 11-26）、`6e93c179` status=None（見上）。disabled：`a94330a9 tmp-openai-probe` error/ce=2（11-19 legacy，可清），其餘 6 支 ok。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `36b493db dreaming`：窗內未跑；11-24 04:25 **ok / 1,816,088ms（30.3 分，連續第 2 次完整活下來）**，next **11-25 04:25**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `40e09cd1 Jormungand`：11-24 03:01 error/115,867ms（429）→ **03:16 retry ok/865,320ms** → ce=0（第 4 次「retry 洗紅單」），next 11-25 03:00。`58fe15dc 每日論文討論`：11-24 07:03 error/208,723ms（429）→ **07:12 retry ok/486,124ms**，next 11-25 07:00。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 429：3h 窗 **1 筆**（18:02:31），形狀與 12:03 舊筆完全一致 → 「零星復發」而非「恢復」 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical（僅系統行）：`[provider-transport-fetch] [model-fetch] response provider=minimax-portal status=429 elapsedMs=120,488 dispatcher=reused` → `embedded run … isError=true error=⚠️ API rate limit reached`（runId `14297d7c…` ＝ `d7b0355b` A2A heartbeat）→ **18:04 receipt ok/252,190ms**（自癒）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 時戳：**12:02:31 → 18:02:31 正好隔 6h**（上一輪 3h 窗看到的是 12:03 的舊筆）→ 整點槽撞額度池的指紋持續。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 假陽性排除：`EAI_AGAIN`/`ENETUNREACH`/`AbortError` 各 3 筆命中**全部落在 gengar nested session 的回覆文字內**（非系統行）→ 本 lane canonical 計數 **0**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Discord：8/8 running+connected（連續 ~14h 零症狀）；12 筆 websocket closed + 12 筆 reconnect scheduled ＝良性續連 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela/charizard/flaaffy/gengar/mrmime/picturecat/roaringmoon/rowlet **全部 enabled, configured, running, connected**，transport ≤1m（greninja disabled/stopped ＝預期）。真實收發：celesteela in:9m、charizard in/out:10h、gengar in/out:12h、mrmime in/out:58m、roaringmoon in/out:10h、rowlet in/out:12h。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 3h（702 行）簽章：status=429 **1** / READY wait timed out **0** / channel exited **0** / client initialized **0** / host timing gap **0** / event-loop starvation **0** / reconnect-exhausted **0** / startup-not-ready **0** / lane wait exceeded **0** / Token Plan usage limit **0**；`gateway websocket closed`（1005/1006）**12** ＋ `Gateway reconnect scheduled … resume=true` **12**；`prepared model runtime plugin generation was superseded` **19**（含 19:03:20 本輪自身 lane 啟動 2 筆）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 系統面：全綠（唯一噪音仍是 elle.service） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway（user unit）：MainPID **4137629**、`ps` etimes=**137,741s（38h15m 未重啟）**、ActiveEnterTimestamp=**11-23 04:48:17**、NRestarts=**0**、ActiveState=active、SubState=running、`/health` **200 in 1.3ms**（port 18789）、RSS 1.59GB、CPU 5.9%。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 主機：uptime **44d00:50**、load 0.55/0.50/0.46、RAM available 20Gi、swap 0、`/` 61%（剩 178G）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（system unit）仍在重啟迴圈：**NRestarts=121,658**（16:02 輪 121,300 → **+358/3h**，與上輪 +358/3h 完全一致）、ActiveState=activating、ActiveEnterTimestamp=19:03:57。與 openclaw 無關、需 root，歷輪不動。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本輪刻意沒動） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 self-heal 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未停用 `elle.service`、未改 DNS/網路、未刪 job、未動任何 heartbeat 的 everyMs（含 flaaffy 的 1000× 錯誤）、未動 mrmime heartbeat 的 16:09 紅單（無自動重跑/無手動觸發）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 1 次，寫進 `agent:picturecat:main` 非 cron session）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`（約 25 支）、`journalctl --user -u openclaw-gateway`（3h + 24h 簽章）、`systemctl --user show` / `systemctl show`、`ps`、`uptime/free/df`、`curl /health`。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（沿用 13 項 + 新增 1 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增・高】`prepared model runtime plugin generation was superseded` 會直接殺掉整輪 job run（16:09 heartbeat-mrmime error/477s）**，不再只是「fallback 後照跑」的良性症狀；且它只在 **KA 爆發窗**內發生（3h=1、24h=2）。建議三選一：① gateway 告警改看「superseded 且 run 未回覆」而不只看 `ce`；② 給 mrmime heartbeat 錯開整點（例 30 分槽 → :10/:40）＋ timeoutSeconds 600→900；③ 該 job payload 明確要求「superseded → 重試一次再放棄」。**改 job 需點頭。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【高】`heartbeat-flaaffy` everyMs 放大 1000 倍 → 該 heartbeat 從未執行過，下次 2027-02-03**。修法＝everyMs 改回 1,800,000 ＋ anchor 重新對齊。**改 job 需點頭。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】dreaming 的 event-loop 凍結會連帶殺死整個 heartbeat fleet（11-24 04:27–08:11：6 支 × 12 輪 600s 硬死）**，且被 ce=0/skipped 完全洗掉。三選一：① dreaming 錯開整點；② heartbeat timeoutSeconds 拉高 >1200s；③ dreaming 加 RSS 護欄。**改 job 需點頭。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【急】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）、本 job fallback 鏈實質冗餘＝0。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【急】KA anchor 拉開 ≥15 分鐘**＋讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 **24** 次疊窗（12.1s / 5ms）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【中】minimax-portal 額度池**（本窗 429=1、12:02→18:02 正好 6h；24h 19 筆為上輪量測值）→ 錯開整點 job 密度，或補一組真有憑證的第二廠商。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【中】self-heal 的 04 整點空窗**（dreaming 期間 Discord 無救援）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【中】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 本窗 canonical 0 筆。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中】17 支 skill 缺 description**（每日 ≈120 次 skip）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【中】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉 44 天重啟迴圈；需 root。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12. **【中】每日論文討論 07:00 槽連續 3 天撞 429**（11-21 / 11-22 / 11-24）→ 移槽或把 retry 間隔寫進 payload。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13. **【降級】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14. **【中】巡檢方法論**（本輪新增可複用工具）：`cron runs --id` 的 `ts` 是 epoch ms、**顯示務必用 `tsIso`**（容器 `strftime` 是 UTC，會整整錯 8 小時）；job id 必須用**完整 UUID**，短 id 會靜默回空（`tot=0`）→ 短 id 查詢結果看似「窗內 0 筆」，實則是查不到。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 下一輪（22:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. `heartbeat-mrmime` 是否再 error（尤其整點 ±5 分窗）；`Embedded agent failed before reply` 是否 24h 內從 2 升到 3+。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. 19:00 / 21:00 / 22:00 槽的 429 是否再現（12:02→18:02 已驗證 6h 節奏，若 21:02 或 22:02 再現則確立「整點密度 + 週期」雙證據）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. heartbeat fleet 是否維持 0 筆 600s 硬死（11-24 最後一筆 = 08:21；本輪新增 1 筆 477s 的 superseded 型，兩者型別不同要分開記）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. dreaming 11-25 04:25 是否仍完整活下來（連續第 3 次）；self-heal 04:00 空窗是否有補位。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. `heartbeat-flaaffy` 是否仍 0 entries（next 應仍是 2027-02-03，未經點頭不修）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## 2026-11-24 22:02 — Picturecat Keep-Alive 第 8 輪：🟡 lane PASS、Discord **連續 17h 零症狀**、gateway 連續 **41h15m** 未重啟、⭐⭐⭐ **heartbeat-mrmime 21:11 又硬死一次（600s timeout → 換手時被 superseded 補刀）＝「ce=0 洗掉整輪死亡」第 5 例**、⭐⭐ **新證據：429 的 `overloaded_error` 子型會吃掉 87.5s 的 600s 預算** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) Picturecat lane：PASS <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `sessions_send` → `agent:picturecat:main` → runId `4a37c03e-2548-40bb-b9ea-c84421b89374`、status=ok、回覆「pong — (a) no active task, (b) no errors/provider 429 in last 3h, (c) Discord inbound ok.」<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本 job（`02eb0989`）上一輪（**19:02**）**ok / dur=358,840ms（358.8s）/ ce=0** → 非降級輪（>30s 門檻），summary 完整。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - 今日七輪 dur 全量：01:02 **392,354ms** → 04:02 **390,890ms** → 07:02 **170,696ms** → 10:02 **138,687ms** → 13:02 **173,018ms** → 16:04 **145,332ms** → 19:02 **358,840ms**；**七輪全綠、全非降級**（11-23 22:02 那次 21.5s 零紀錄降級輪未再復現）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 姊妹 job（receipt 實測）：**Gengar KA 19:07 ok / dur=321,453ms**、**Celesteela KA 19:04 ok / dur=151,043ms**，兩者 ce=0 → **三支 KA 全綠**；**22:02 同槽亦全綠**（Gengar KA 22:08:27 ok/383,154ms、Celesteela KA 22:04:54 ok/155,883ms）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **KA anchor 疊窗第 25 次**（`state.nextRunAtMs` 實測）：gengar `1795528924181` → picturecat `1795528936307` → celesteela `1795528936313`＝**12,126ms / 6ms**。三支同槽同搶 minimax-portal 額度池。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ 工具可見性（非故障，沿用）：本輪 `automations` 視角仍不可用（`get` 回 `cron job not found`、`list` 回 0 筆；restricted automation-run session），cron 真相一律走 `openclaw cron list --all --json`（53 支全見）＋ `openclaw cron runs --id <完整 UUID>`（短 id 會回 `{"ok":false,"error":…}` 且**安靜地給 tot=0**，勿誤判成「窗內 0 筆」）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) ⭐⭐⭐ 本輪主事件：**heartbeat-mrmime 21:11 硬死**（600s timeout）＋ 換手時被 superseded 補刀 → 第 5 例「ce=0 洗掉整輪死亡」 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- receipt（`bcf270b8`）：**21:11:08 status=error / dur=600,003ms / `cron: job execution timed out`** → **21:12:59 status=error / dur=81,004ms / `heartbeat failed: agent-runner-failure`** → 21:31:12 ok/7,943ms → **22:01:10 ok/6,091ms** → `state.consecutiveErrors=0`、紅單清單**完全看不到**這兩筆死亡。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **⚠️ 這直接推翻 19:02 輪的結論**（「heartbeat fleet 維持 0 筆 600s 硬死，最後一筆仍是 08:21」）→ **11-24 的 600s 硬死在 21:11 再度發生**，距前一筆（08:21）僅 12h50m。**600s 定時炸彈仍在走時**，且這次是三支 KA 全綠、gateway 全綠、Discord 全綠的「完美窗」裡發生 → **不是 dreaming 那種事件迴圈凍結的連帶死，是 lane 自身的定時炸彈**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **完整因果鏈（journal 逐行，非推測）**： <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  1. **21:01:08** heartbeat-mrmime 起跑（600s 隱含上限）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  2. **21:01:33.784** `[provider-transport-fetch] status=429 elapsedMs=87,500 dispatcher=new` → rawError＝**`{"type":"error","error":{"type":"overloaded_error","message":"server is busy, please retry later"}}`** → `embedded run agent end isError=true` → `rate-limit same-model retry 1/3 delayMs=10000` → **21:01:46 status=200 elapsedMs=2,287**（13 秒自癒）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  3. 21:01:46–21:10:09 之間 mrmime lane 持續發出正常 `status=200`（多筆，elapsedMs 1–4s）＝ **run 仍在跑、只是太慢**：單是第一次被拒就燒掉 87.5s/600s 預算（**14.6%**），加上 agent 本身的工作量 → **21:11:08 觸頂，`cron: job execution timed out`**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  4. **21:06:16** `[cron:ca222989] Failed to remove unused run continuation: Cannot delete session while competing work is in flight for agent:mrmime:cron:ca222989` → **同一條 mrmime lane 上有別的 job 在跑**（系統維護 ca222989）→ runtime plugin 正在被重新生成。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  5. **21:11:08–21:12:59** 自動重試：連續 **3 組** `lane task error: lane=cron-nested / lane=session:agent:mrmime:main:heartbeat durationMs=3–22 error="prepared model runtime plugin generation was superseded for …/agents/mrmime/agent"` → `model-fallback/decision candidate_failed` ×3 → **21:12:59.512 `Embedded agent failed before reply: prepared model runtime plugin generation was superseded`** → 整輪死（81s）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  6. **21:12:56.188** `[cron:911eee45] Cannot delete session while competing work is in flight for agent:rowlet:cron:911eee45`（每日資安建議 21:00 槽）→ **21:00 槽的 job 還活著、壓在 21:12 換手點上**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **本輪把兩件待決事項用同一條鏈串起來了**：**①**「superseded 會直接殺掉整輪 job run」（16:09 首度實證）→ 本輪**第 2 次實證**（21:12:59）；**②**「heartbeat 的 600s timeout 是定時炸彈」→ 本輪**第 2 次實證**（21:11:08）；**而兩者是同一場事故的先後兩段**：先被 429 拖過 600s（第一段死法），換手時又被同 lane 的競態補刀（第二段死法）。**修任何一段都能避免這次雙死。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `Embedded agent failed before reply` = **3 筆**（19:02 輪為 2 → 本輪 +1）＝ 11-24 16:09、21:12、11-23 16:11。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **兩筆「差一點就炸」的近失**：同一窗內 `heartbeat-rowlet` 20:14:37 `skipped: no-route` 但 **dur=375,393ms**、`heartbeat-celesteela` 20:14:37 `skipped` 但 **dur=108,360ms**、`heartbeat-rowlet` 21:13:04 `ok` 但 **dur=281,588ms** → **同一支「skipped」其實跑了 6 分多鐘**，離 600s 只差一步。**`skipped` 不是「沒做事」，慢起來的 skipped 就是定時炸彈的引信。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) fleet：53 jobs / 46 enabled / 7 disabled — **ok 45 / skipped 5 / error 1 / none 1**（enabled 側），disabled 側另有 1 支 error(ce=2) <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- enabled 的非 ok：**8 支 heartbeat 中 5 支 `skipped`**（rowlet / celesteela / greninja / picturecat / roaringmoon，全 `no-route`，良性長態）；`c5352a84 skill-collection-review-roaringmoon` **error/ce=1**（11-19 DNS 舊因，next **11-26**）；**`6e93c179 heartbeat-flaaffy` status=None（從未跑）**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- disabled：`a94330a9 tmp-openai-probe` error/ce=2（11-19 舊因、legacy 可清）；其餘 6 支 ok。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **窗內（19:02–22:02）8 支 heartbeat receipt 逐支實測**：charizard 6 輪全 ok（11.2–15.7s）、gengar 7 輪全 ok（11–58s）、**mrmime 4 ok ＋ 2 error（見 §2）**、rowlet 1 ok ＋ 1 slow-ok ＋ 8 skipped、celesteela 全部 skipped（其中 1 輪 108s）、greninja/picturecat/roaringmoon 全 skipped（259–264ms）→ **窗內 1 筆 600s 硬死 ＋ 1 筆 superseded 型死**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `heartbeat-flaaffy`：`cron runs --id` **tot=0**、`state.lastRunStatus=None`、nextRunAt 仍 **2027-02-03**（≈71 天後）→ everyMs 1000× 錯誤仍未修（改 job 需點頭）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- self-heal `d4cd45bc`：17:13→21:43 共 **10 輪全 ok、dur 740–796ms**、全為「discord healthy (no startup-not-ready) - no action」→ **守門零開火**（11-23 那次開火腰斬 dreaming 的教訓持續有效）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming `36b493db`：窗內未跑；**11-24 04:25 → 04:55:18 ok / 1,816,088ms（30.3 分，連續第 2 次完整活下來）**，歷史 7 筆中 2 筆 error 皆為「interrupted by gateway restart」（11-20 / 11-23）；next **11-25 04:25**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 兩個整點槽的老問題（今日數據）：`40e09cd1 Jormungand` 03:01:55 error/115,867ms（429）→ **03:16:51 retry ok/865,320ms** → ce=0（第 5 次「retry 洗紅單」），近 5 天 03:00 槽：11-20 error / 11-21 error / 11-22 ok / 11-23 error / **11-24 error**；`58fe15dc 每日論文討論` 07:03:28 error/208,723ms（429）→ **07:12:06 retry ok/486,124ms**，近 5 天 07:00 槽：**4 天 4 次首輪 error**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) 429：3h 窗 **1 筆**（21:01:33），但**子型是新的**（`overloaded_error`），且這 1 筆就是殺死 mrmime 的那顆 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- canonical：`[provider-transport-fetch] [model-fetch] response provider=minimax-portal api=anthropic-messages model=MiniMax-M3 status=429 elapsedMs=87,500 dispatcher=new` → rawError `HTTP 429: {"type":"error","error":{"type":"overloaded_error","message":"server is busy, please retry later"}}`。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **新子型**：過去記錄的 429 兩種型別是「HTTP 429 rate_limit」與「Token Plan usage limit」；本輪首次出現 **`overloaded_error: server is busy`**（併發尖峰型）→ **判讀口徑必須再分一類**：它跟 quota 型不同，它帶的是「伺服器忙」而非「額度用完」，但**對 cron 一樣致命**（排隊 87.5s 就足以吃掉 600s 預算的 15%）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h canonical `status=429` = **16 筆**（逐時：11-23 23×2 / 11-24 00×1 / 03×1 / 05×2 / 06×1 / **07×3** / 08×2 / 09×1 / **12×1** / **18×1** / **21×1**）→ 12:02 → 18:02 → 21:01，**整點後 1–11 分鐘的指紋持續成立**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 24h `Token Plan usage limit` = **0**（真配額牆未復發）；3h 窗 `status=200` 最慢僅 21,820ms（無 429 之外的大排隊）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) Discord：**連續 17h 零症狀**（自今日 04:55:41 之後），8/8 running+connected <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`（22:03）：celesteela / charizard / flaaffy / gengar / mrmime / picturecat / roaringmoon / rowlet **全部 enabled, configured, running, connected**，transport 均 just now～1m（greninja disabled/stopped ＝預期）。真實收發：celesteela in:5m、charizard in/out:13h、gengar in/out:15h、mrmime in/out:50m、roaringmoon in/out:13h、rowlet in/out:15h。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- journal 3h（839 行）簽章：**READY wait timed out 0 / channel exited 0 / client initialized 0 / host timing gap 0 / event-loop starvation 0 / lane wait exceeded 0 / reconnect-exhausted 0 / startup-not-ready 0 / memory pressure 0 / overloaded_error 1 / Token Plan usage limit 0**；9 筆 `gateway websocket closed` ＋ 9 筆 `Gateway reconnect scheduled (resume=true)` ＝ 良性續連。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **乾淨段延伸**：24h 內最後一筆 READY-fail / channel-exit = **11-24 04:55:41（gengar）** → 至 22:02 **連續 17h06m 零症狀**（19:02 輪的 14h 再延長 3h）；24h READY timeout 38 / channel exited 13 全落在 04:25 dreaming 窗。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- DNS：本窗 `EAI_AGAIN` 6 筆 ＋ `ENETUNREACH` 6 筆，**逐行看全部落在 `[agent:nested] session=agent:gengar:main` 的回覆文字內**（19:05:43、22:04:19）→ **canonical 系統行 0 筆**（根因未除：enp43s0 無 DNS scope）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) 系統面：全綠（唯一噪音仍是 elle.service） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- Gateway（**user unit** 口徑）：MainPID **4137629**、`ps` etimes=**148,510s（41h15m 未重啟）**、ActiveEnterTimestamp=**11-23 04:48:17**、NRestarts=**0**、ActiveState=active、SubState=running、`/health` **200 in 1.2ms**（port 18789）、RSS 1.62GB、CPU 5.8%。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 主機：uptime **44d03:50**、load 0.75/0.57/0.52、RAM available **20.7GiB**、swap 0、`/` 61%（剩 178G）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `elle.service`（**system** unit）仍在重啟迴圈：**NRestarts=122,014**（19:02 輪 121,658 → **+356/3h**，連續三輪 +356/+357/+358 的穩定斜率）、ActiveState=activating、ActiveEnterTimestamp=22:03:26。與 openclaw 無關、需 root，歷輪不動。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 邊界（本輪刻意沒動） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **零改動**：未改任何 cron（排程/payload/model/fallback/timeout 全未動）、未動 self-heal 守門、未改 config/provider/model/channel、未碰憑證、未重啟 gateway、未停用 `elle.service`、未改 DNS/網路、未刪 job（`automations` 視角看不到 job 也沒據此刪除）、未動任何 heartbeat 的 everyMs（含 flaaffy 的 1000× 錯誤）、**未手動重跑 heartbeat-mrmime**（21:31 起已自癒，手動重跑無意義且佔額度）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 探測全唯讀：`sessions_send`（跨 lane ping 1 次，寫進 `agent:picturecat:main` 非 cron session）、`openclaw channels status`、`openclaw cron list --all --json`、`openclaw cron runs --id`（17 支）、`journalctl --user -u openclaw-gateway`（3h / 24h 簽章 + 逐行核對）、`systemctl --user show` / `systemctl show`、`ps`、`uptime/free/df`、`curl /health`。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 給 Linder 的待決事項（沿用 14 項 + 新增 2 項） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【新增・高】heartbeat-mrmime 是 fleet 最脆的一支，21:11 死法＝「429 拖過 600s → 換手又被同 lane 競態補刀」的雙死。** 最小改動優先序：① **把 heartbeat-mrmime 的槽錯開整點**（例：目前 :01/:31 → 改成 :11/:41，或直接與 :00 槽族群拉開）；② **timeoutSeconds 600 → 900**（這樣 87.5s 的 429 不會讓它觸頂）；③ **讓 mrmime heartbeat 不與 ca222989／911eee45 同時段**（同 lane 競爭是 superseded 的來源）。**改 job 需點頭。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【新增・中】429 記錄要新增第三型別 `overloaded_error`（server is busy）**，與 quota 型（Token Plan）分開計數；本輪證實它「13 秒自癒卻吃掉 600s 預算 15%」→ **429 自癒 ≠ 這輪 job 安全**，判斷健康要看「排隊 elapsedMs ÷ job 預算」而不是「最後 status」。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【高】`prepared model runtime plugin generation was superseded` 會直接殺掉整輪 job run**（11-24 **16:09 ＋ 21:12 兩次實證**）→ 修法三選一：① gateway 告警改看「superseded 且 run 未回覆」而不只看 `ce`；② 錯開同 lane 的 job 槽位；③ payload 要求「superseded → 重試一次再放棄」。**改 job 需點頭。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【高】heartbeat 的 600s timeout 是定時炸彈**（11-24 **08:21 ＋ 21:11 兩次實證**；且「skipped 但 dur=375s」的近失已出現 2 次）→ 拉高 timeoutSeconds 或在 600s 內主動結束。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. **【高】`heartbeat-flaaffy` everyMs 放大 1000 倍 → 從未執行過，下次 2027-02-03**。修法＝everyMs 改回 1,800,000 ＋ anchor 重新對齊。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. **【高】dreaming 的 event-loop 凍結會連帶殺死整個 heartbeat fleet（11-24 04:27–08:11：6 支 × 12 輪 600s 硬死）**。三選一：① dreaming 錯開整點；② heartbeat timeoutSeconds 拉高 >1200s；③ dreaming 加 RSS 護欄。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
7. **【急】openai 憑證缺失** → 三支 KA 的跨廠 fallback 名存實亡（`openai/*` 全 Auth=no）、本 job fallback 鏈實質冗餘＝0。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
8. **【急】KA anchor 拉開 ≥15 分鐘**＋讓 Gengar KA 與 Picturecat KA 分屬不同 agent lane → 本輪第 **25** 次疊窗（12.1s / 6ms）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
9. **【中】minimax-portal 額度池**（24h 16 筆 429；時戳幾乎全在整點後 1–11 分；**03:00 / 07:00 兩個槽近 5 天各撞 3–4 次**）→ 錯開整點 job 密度，或補一組真的有憑證的第二廠商。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
10. **【中】self-heal 的 04 整點空窗**（dreaming 期間 Discord 無救援）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
11. **【中】DNS 根因未除**（enp43s0 無 DNS scope，靠 Wi-Fi + tailscale0）→ 本窗 canonical 0 筆。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
12. **【中】17 支 skill 缺 description**（每日 ≈120 次 skip）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
13. **【中】KA payload 只有一句 `keep-alive test`、沒有必做清單** → 深度由 agent 自決。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
14. **【中】`elle.service` 停用**（`systemctl disable --now elle.service`）→ 消掉 44 天重啟迴圈；需 root。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
15. **【中】每日論文討論 07:00 槽近 5 天 4 次首輪 error**＋Jormungand 03:00 槽近 5 天 3 次首輪 error → 移槽或把 retry 間隔寫進 payload。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
16. **【降級】筆電端每 10 分鐘 3 次的 SSH automation** → 已證實不執行任何指令，降為「觀察」。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
17. **【中】巡檢方法論**：`cron runs --id` 的 `ts` 是 epoch ms、**顯示務必用 `tsIso`**；job id 必須用**完整 UUID**，短 id 會**安靜回 tot=0** → 看似「窗內 0 筆」其實是查不到（本次實測短 id `36b493db` 回 `Automation not found`）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 下一輪（11-25 01:02）請確認 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **heartbeat-mrmime 是否再 error**（21:31 / 22:01 已自癒，ce=0）→ 若 23:0x／00:0x 又死，代表 600s 炸彈已變成「每 2 小時一次」的週期，則待決事項 #1 必須升級為最高優先。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **23:00 / 00:00 / 01:00 槽的 429 是否再現**（21:01 那筆是 `overloaded_error` 新子型）→ 連續觀察 hourly 指紋是否成立。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **`heartbeat-rowlet` 那兩筆慢 `skipped`（375s / 281s）是否再現** → 若「skipped 卻跑 6 分鐘」變常態，就是 600s 炸彈的前哨。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **11-25 04:25 dreaming 是否仍完整活下來（連續第 3 次）**——但那要等 07:02 輪才驗得到；本輪只能確認排程未被動、self-heal 04 整點仍排除。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. `heartbeat-flaaffy` 是否仍 0 entries（next 應仍是 2027-02-03，未經點頭不修）。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
