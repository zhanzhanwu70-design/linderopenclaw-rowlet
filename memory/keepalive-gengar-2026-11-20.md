# Gengar Keep-Alive 巡檢日誌（2026-11-20）

## 2026-11-20 19:02 — 巡檢 PASS（lane 雙向通）／本輪主因換成 **DNS 解析不穩**（實測 1.7% 失敗率、journal 3204 筆 EAI_AGAIN）／🔧 修好 selfheal 的 **fail-open guard**（04:35 腰斬 dreaming 的元凶）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1) rowlet lane：alive（minimax-portal/MiniMax-M3，本輪 19:02 正常產出，job `9d8b6001`）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 本輪 19:02 這次是「手動／scheduler 補跑」出來的：16:02 那次是被 16:17 的 gateway 重啟砍死（dur=873625ms、ce=2、lastDiagnostics=`getaddrinfo EAI_AGAIN api.minimax.io`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **今天 0 篇 keepalive 檔**（16:02、13:02、10:02… 全部陣亡）→ 本檔是 11-20 第一份巡檢紀錄。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 2) gengar lane：alive，雙向通<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- rowlet → 耿鬼：runId `f1c64a30-c7b0-4619-9bb6-a0ece11d6ba0`（19:08 回覆，立刻在跑 IPv6/DNS 診斷）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼自述與我的獨立核對 **完全一致**：03:36 / 03:50 / 04:36 / 04:58 = 我這支 `d4cd45bc` selfheal（03:35/03:50/04:35/04:50 四槽）；16:18 = 耿鬼 16:16:08 arm 的 one-shot（`openclaw-restart-once`, on-active=90s）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- rowlet → 耿鬼回覆（含兩條更正 + 我方 DNS 證據）：runId `94314262-9a57-4ee2-b4f5-e6eefd2aa60e`（19:2x）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 3) Discord runtime：8/8 enabled 帳號 connected；gateway 自 16:18 起 ~3h 穩定<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- `openclaw channels status`：celesteela / charizard / flaaffy / gengar / mrmime / picturecat / roaringmoon / rowlet 全部 `running, connected`；greninja disabled。**目前無 startup-not-ready**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- gateway：systemd `active`、ExecMainStart=16:18:14、NRestarts=0；16:21:10 ready；19:10–19:11 model-fetch 持續 200。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- event loop（19:05 讀數）：degraded=false、p99 delay 28.4ms、utilization 0.117 → **無飽和**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 4) ⭐ 本輪真正的主因：**DNS 解析不穩**（不是 429、不是 IPv6）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **實測**：120 次 getaddrinfo（api.minimax.io + gateway.discord.gg）→ **2 次失敗**（`Errno -2 Name or service not known`），整輪 30.6s → **~1.7% 失敗率**（平常 10 次 getent 全過）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **journal 證據**：今天 gateway journal 有 **3204 筆 EAI_AGAIN**。目標分布：gateway.discord.gg **2121**、api.minimax.io **672**、gateway-us-east1-{b,c,d}.discord.gg ~450、discord.com 10、api.openai.com 1。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 每小時分布（不是單一區間故障）：01h 802、13h 1130、07h 312、09h 269、02h 236、10h 101、00h 105、03h 86、08h 60、16h 38、17h 35、19h 4。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **放大器 = 時鐘步進**：systemd-resolved 今天 **63 次** `Clock change detected. Flushing caches`（08h 15 次、02h 11 次、09h 7 次…），→ resolved 快取反覆清空 → 查詢暴湧上游 → 隨機失敗。resolved 自身 **0 筆上游失敗紀錄**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **懷疑鏈**（待 Linder／root 修）：本機**唯一對外路徑是 WiFi**（`default via 192.168.1.1 dev wlp2s20f3`，enp43s0 只有 192.168.50.0/24 無 default route）→ 09:57 NetworkManager 換 DHCP lease → WiFi 抖動 → NTP 失步 → 步進 → resolved 快取清空 → DNS 隨機失敗 → 所有 agent job 死於 `LLM request failed: DNS lookup for the provider endpoint failed` + Discord 重連 133 次。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **IPv6 是假線索（已推翻）**：`getaddrinfo AF_INET6` → gateway.discord.gg / discord.com **完全沒有 AAAA**（Errno -5）；只有 api.minimax.io 有 AAAA（2600:1417:1b::cb45:8ae1）且 v6 curl=404 **通**。→ `curl -6 gateway.discord.gg=000` 只是「沒有 v6 位址可連」。**因此 `--dns-result-order=ipv4first` 對 startup-not-ready 沒有因果關係**，建議不要為了它多重啟一次（已同步給耿鬼）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 5) ⭐ 04:25 dreaming 被腰斬的元凶：selfheal 的 **fail-open guard**（本輪已修）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 症狀：`36b493db` Memory Dreaming Promotion 今天 lastStatus=**error**、ce=1、lastError=`cron: job interrupted by gateway restart`（04:25 起跑、04:35:37 被重啟砍斷、dur=675657ms）→ **今晚的 short-term promotion 沒完成**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 根因（讀碼確認）：舊 `scripts/discord-selfheal.sh` 的守衛是 `openclaw cron list --json | python ... j.get('status')=='running'`，**解析失敗時印 `False`**、且 `|| echo False` → **fail-open**。守衛要問的正是「已經不健康的 gateway」，那時 API 正好掛掉/逾時 → 守衛失效 → 在 dreaming 飛行中重啟 gateway。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 昨晚為防止黑屏而啟用的 `d4cd45bc`，今晚實際效果 = **自己動手把 dreaming 砍了**，而且 90 分鐘內重啟了 4 次（03:35→03:36、03:50、04:35→04:36、04:50→04:58）＝ restart storm。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **🔧 本輪修正**（已備份、可回退）：`scripts/discord-selfheal.sh`
  1. 守衛改 **fail-closed**：JSON 解析失敗 / 查不到 job → 一律視為「dreaming 在跑」→ 跳過重啟。
  2. 守衛同時看 `status=='running'` **或** `state.runningAtMs`（實測 3 支 running job 都有 runningAtMs，非 running 的沒有 → 可靠訊號）。
  3. **anti-storm**：寫 `memory/discord-selfheal-last-restart.ts`，30 分鐘內不重複 arm 重啟。
  4. 失敗語意改寫：查不到狀態時印「dreaming job still running (or state unknown) - postpone self-heal」而不是「running」。
  - 實測三條路徑：live 跑 → `discord healthy (no startup-not-ready) - no action`（exit 0）；餵壞 JSON → 守衛回 `True`；stamp 設成 5 分鐘前 → `self-heal skipped: ... avoiding restart storm`（測試用的 stamp 已刪除）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - **回退**：`cp scripts/discord-selfheal.sh.bak-2026-11-20-1920 scripts/discord-selfheal.sh`<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **要知道的副作用**：dreaming 期間 Discord 真的壞掉時，癒合會**延到 dreaming 結束**（現在有 `timeoutSeconds: 2400` → 最晚 05:05）而不是立刻重啟 → 黑屏上限從「近 2 小時」變成「≤45 分鐘」。這是我刻意選的方向（寧可晚癒合，不可腰斬 promotion）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 6) Fleet：53 jobs / 46 enabled / 7 disabled — enabled 視角 **ok 27 / error 11 / skipped 4 / running 3 / idle 1**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- vs 昨晚 22:02 基準（enabled error 3）→ **error 3 → 11**。新增的幾乎全部是 DNS 造成（03:07 Jormungand、03:56 skill-collection-review、07:00 每日論文討論、08:00/08:09 晨間情報+群體智能、09:04 clean-code、16:02 兩支 keep-alive、19:02 picturecat keep-alive）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 昨晚做的錯峰仍有效：`ae91b967` 05:30 ok、`a72cb46b` 06:10 ok、`08b7c00b` 06:40 ok（ce=0）、`d4cd45bc` selfheal ce=0（05:50 ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- dreaming 排程搬 04:25 **生效且沒被 reconcile 洗掉**（`36b493db` schedule=`25 4 * * *`、payload 仍保有 `timeoutSeconds:2400` + toolsAllow + fallbacks）→ 昨晚的設定動作只有「被 selfheal 腰斬」這一個副作用。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 7) 紅單（enabled）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【急】`bcf270b8` heartbeat-mrmime ce=8**（連續 8 次 `cron: job execution timed out`，dur=600006ms）→ **再 2 次自動停用**。根因仍是 mrmime 的 600s 上限（昨天補的 activeHours 沒有解決 timeout 本身）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【急】DNS 解析不穩**（見第 4 節）→ 所有 agent job 的共同紅字。需 root 級手段（加 resolver、緩DNS cache、或把對外路徑從 WiFi 移走）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. `13ac4b5a` 健康回報 ce=4（`⚠️ API rate limit reached`）→ 仍是單一 MiniMax Token Plan 的額度問題（與 DNS 兩回事）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. `45ccf4e9` ce=4 / `b37129c0` ce=5 / `89e2cfe7` ce=2 / `58fe15dc` ce=1 / `40e09cd1` ce=2 / `c5352a84` ce=1 → 全部 DNS 症狀。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. `36b493db` ce=1 → 被 selfheal 腰斬（已修 guard，明晚 04:25 應可跑完）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
6. `9d8b6001`（本 job）ce=2、`02eb0989` picturecat ce=2 → 16:02 死於 DNS + 被重啟砍。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 8) 本輪變更（全部可一鍵回退）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **只動了一個檔案**：`scripts/discord-selfheal.sh`（fail-closed guard + anti-storm）。備份 `scripts/discord-selfheal.sh.bak-2026-11-20-1920`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **沒有動任何 cron 設定、沒有重啟 gateway、沒有改 config**（避免與耿鬼 16:16 那次 one-shot 撞車、也避免在無人值守時段再製造一次中斷）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 9) 給 Linder 的待決事項<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
1. **【最高】DNS 根因（要 root）**：本機對外只有 WiFi；時鐘被步進 63 次 → resolved 快取反覆清空 → 解析隨機失敗（實測 1.7%）。可選手段：(i) 讓對外路徑走有線；(ii) 改用會平滑校正時鐘的 chrony（避免步進）；(iii) 換成本機快取型 resolver（dnsmasq/unbound）並保留上游；(iv) 至少把上游 DNS 從 1.1.1.1/8.8.8.8 擴到 3 個以上。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
2. **【高】`bcf270b8` heartbeat-mrmime ce=8** → 2 次後自動停用；需要把 mrmime heartbeat 的 600s 上限拉高或縮小它每次做的事。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
3. **【中】MiniMax Token Plan 額度**（`13ac4b5a` rate limit 的根因）；跨廠 fallback 仍是 0（`openai/*` 無憑證，我不碰）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
4. **【中】d4cd45bc selfheal 的定位**：修好守衛後它只剩「dreaming 結束後的保險」。若要保留，請確認「寧可晚癒合、不可腰斬 promotion」這個取捨；不想要就 `openclaw cron disable d4cd45bc-357d-42d4-9ba1-f7eb39e02f59`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
5. `elle.service` 仍 crash-loop（需 root，未動）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 下一輪：**22:02**（本 job，3h 一次）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 10) 本輪外部寫入<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 因 delivery.mode=none（最終回覆只進 run log），沿用前幾輪做法用 **rowlet 帳號**把巡檢摘要貼到 Discord channel `1482363974119854234`（內容不與 Picturecat 摘要重複，補 Gengar lane、DNS 根因、selfheal 修正與驗證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 11) 19:4x 追加（耿鬼回覆後交叉驗證）：DNS 是**兩因**模型＋ per-resolver 可靠度實測<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 耿鬼獨立跑出**同一組每小時 EAI_AGAIN 分布**（system journal：00h 105、01h 802、02h 236、03h 86、04h 13、07h 312、08h 60、09h 269、10h 101、13h 1130、14h 12、15h 1、16h 38、17h 35、19h 7），並**同樣數到 63 次** `Clock change detected. Flushing caches`（storm 期間 Cache Size 0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **耿鬼的關鍵修正（我接受並改寫本檔第 4 節）**：時鐘步進→快取清空**解釋不了最大那波**。12:50–14:10（就是黑掉 Discord 那段）**時鐘完全沒變**，卻每 10 分鐘 228/271/354/277 筆 EAI_AGAIN → **兩個獨立成因**：
  - (a) 時鐘步進 → resolved 快取清空（Cache Size 0）→ 查詢暴湧上游 → 對應 01h 802 / 09h 269 / 10h 101 這幾波。
  - (b) **上游 resolver 本身就抖** → 對應 13h 1130（零時鐘變動）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **per-resolver 可靠度（api.minimax.io，各 10 次查詢；我與耿鬼各測一次，互為對照）**：<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
  - `1.1.1.1` → 我 2/10 fail、耿鬼 6/10 fail ← **兩邊都最差，且它在 wlp2s20f3 的第一順位**
  - `8.8.8.8` → 我 0/10、耿鬼 0/10 ← **兩邊都最穩**
  - `2001:b000:168::1` → 我 0/10、耿鬼 2/10；`2001:b000:168::2` → 我 2/10、耿鬼 0/10；`9.9.9.9` → 我 1/10
  - `100.100.100.100`（Tailscale MagicDNS，僅 tail154ece.ts.net 域，**非預設路徑**）→ 耿鬼 10/10 fail（預期）
  - 現行 resolver 清單（wlp2s20f3）：`1.1.1.1 8.8.8.8 2001:b000:168::2 2001:b000:168::1`；stub `/run/systemd/resolve/stub-resolv.conf` → `nameserver 127.0.0.53` + `search tail154ece.ts.net`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **正式版因果鏈（要給 Linder 的版本）**：WiFi/DHCP flap → NTP 時鐘步進 → systemd-resolved 快取清空 → 查詢暴湧上游 → 上游 resolver 間歇失敗 → EAI_AGAIN → **同時**造成 (i) Discord WS handshake 永不完成（8 個帳號全 startup-not-ready）與 (ii) 每個 agent job 死在 `DNS lookup for the provider endpoint failed`。**再加上 (b) 上游 resolver 本身的抖動（13h 那波與時鐘無關）** → 不能只修時鐘。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **兩個具體動作（需 root／sudo，我沒動）**：(i) `sudo resolvectl dns wlp2s20f3 8.8.8.8 2001:b000:168::2`（先拿掉 1.1.1.1；要持久需寫進 NetworkManager 連線設定，否則重連失效）；(ii) 停掉時鐘步進（chrony / timesyncd 改成只 slew 不 step），讓 resolved 不再一天清 63 次快取。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **IPv6 線索正式結案（耿鬼接受）**：discord 網域根本沒有 AAAA → 不套 `--dns-result-order=ipv4first`（耿鬼已確認未套、我也不套）→ 不為此多冒一次重啟風險。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **耿鬼的邊界承諾**：不再動 gateway、不動我的 cron、不動 dreaming config；他那側 6/6 cron ok、Discord 8/8 connected、gateway pid 3469787 uptime ~2h50m。本輪我把上述兩因模型與 per-resolver 數據回覆給他（跑一次數據對照）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
