
# Picturecat Keep-Alive 巡檢日誌（2026-11-17）

## 2026-11-17 04:02 — ⚠️ 雙軌結果：agent lane PASS / Discord 傳輸 DOWN（全域，8 隻 bot）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → 回 **pong**（runId b9f387b8，provider minimax-portal/MiniMax-M3，input 35k tokens，04:02:47 完成）。
- Discord account `picturecat`：enabled=true、groupPolicy=allowlist、guild 1481665580091048031 / channel 1481665581189959872（喵喵工作坊/一般）設定正常。
- 本 job 自身：上一輪 01:02 → **error**（HTTP 429 Token Plan usage limit reached (2056)、dur=339509ms、consecutiveErrors=4）；**本輪 04:02 model turn 正常** → 429 窗口已緩解，但紅單尚未清零（等這輪 success 回寫）。

### 2. 🔴 新發現：Discord gateway 全域斷線 1 小時以上（8 隻 bot 全掛，非 picturecat 專屬）
- **症狀**：今日 875 次 `discord: gateway READY wait timed out after 15000ms; reconnecting with backoff`，attempt 數已到 101–105；**今日 0 次成功 READY**。
- **時間線**：03:00 前 0 次 timeout（11-16 全日僅 25 次）→ 03:03 開始 ACK timeout / socket hang up / invalid-session / handshake timeout → 03:30 後只剩 READY 超時 storm（03:30=209、03:40=276、03:50=276、04:00=131 次/10min）。
- **元兇（高信心）**：`36b493db Memory Dreaming Promotion`（cron `0 3 * * *`）03:00 起跑、**跑了 31.5 分鐘**（dur=1887865ms），產物 mtime 對得上（memory/dreaming/light/2026-11-17.md 03:22、DREAMS.md 03:24）。同一時窗 gateway 記錄 **25 次 event-loop starvation**，`timerDelayMs` 從 6.5s 一路升到 **27.1s**（03:24:56）→ Node event loop 被塞住 → Discord WS 心跳／握手逾時 → 8 個 client 全部掉線。
- **為什麼掉線後沒回來**：03:04 health-monitor 對 client 做 `restarting (reason: disconnected)`（3 次），8 隻 bot 進入「WS 開得起、但 READY 等不到」的卡死迴圈；backoff attempt 持續累加 → 至今仍 100% 失敗。
- **排除網路因素**：主機 → Discord REST 正常（`discord.com/api/v10/gateway` 200 / 0.25s；`/users/@me` 401 = 無 token 正常）；**獨立 node `ws` client 直連 `wss://gateway.discord.gg` 0.5s 就 OPEN 並收到 Hello** → 對外連線路徑 OK，問題在 OpenClaw gateway 行程內部（client 狀態機卡死）。
- **無 401 / invalid token**：今日 46 筆 "401" 命中全是 provider auth re-warm 的雜訊，Discord 端沒有認證失敗。Discord REST channel resolve 在 03:30 之後也恢復正常（03:10–03:30 才 abort）→ **只有 WS/READY 掛著**。
- **後果**：所有 agent 的 **Discord 收訊（inbound）全死**（只能靠 API／CLI 呼叫，Discord 使用者傳訊不會被 agent 看到）。outbound REST 可能仍可用（今日 03:31 後沒實際外送紀錄，未驗證）。
- **與紅單的因果修正**：`heartbeat-rowlet`（03:09, dur 725403ms）、`heartbeat-charizard`（03:25, dur 459491ms）這兩支是 **timeout 型**（不是 429），時間點正落在 Discord 風暴區間 → 屬於 Discord 斷線的下游症狀，不是額度問題。
- **修復方式**：需要 **重啟 gateway** 才能重置 8 個 Discord client 的狀態機（重啟會中斷當下 cron，已知副作用「cron: job interrupted by gateway restart」會誤記 error）。本輪刻意**未自行重啟**（政策：不得用 shell 重啟 gateway；且重啟會 kill 掉本輪自己，報告會來不及交付）。→ 已升級給 Linder 決定。

### 3. Fleet 紅單（14/50，比 11-16 的 7–10 更差）
| job | id | errs | 最後一輪 | 類別 |
|---|---|---|---|---|
| OpenClaw 系統維護 | ca222989 | 5 | 11-17 03:09 | 429 Token Plan（All models failed 4）|
| heartbeat-rowlet | d82f78e3 | 5 | 11-17 03:09 | **timeout**（Discord 斷線下游）|
| heartbeat-charizard | ffc90b7d | 5 | 11-17 03:25 | **timeout**（Discord 斷線下游）|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | 5 | 11-16 11:07 | provider overloaded |
| **Picturecat Keep-Alive** | 02eb0989 | 4 | 11-17 01:02 | 429 Token Plan（2056）|
| push-llm-wiki | e2ffd70d | 4 | 11-16 05:11 | 429 |
| 健康回報 | 13ac4b5a | 4 | 11-17 02:12 | 429 |
| 每日論文討論 | 58fe15dc | 4 | 11-16 07:08 | 429 + cooldown |
| rowlet-ut-veteran-cpc-maintenance-noon | 08b7c00b | 4 | 11-16 12:08 | 429 |
| 每日資安建議 | 911eee45 | 4 | 11-16 21:09 | 429 |
| Jormungand daily all-agent health | 40e09cd1 | 4 | 11-17 03:29 | 429（All models failed 4）|
| PTCGP Meta Analysis | 09c7940b | 3 | 11-16 20:38 | auth profile unavailable（M2.7-highspeed）|
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | 2 | 11-16 08:10 | timeout (model-call-started) |
| 群體智能架構研究 | b37129c0 | 1 | 11-16 08:00 | gateway restart 誤記 |

- ✅ 轉綠：`d7b0355b` Jormungand mrmime A2A heartbeat（00:05 ok，5 連敗清零）、`b37129c0`/`45ccf4e9` 仍待下輪自癒。
- 8 個 heartbeat：6 支 skipped(no-route，良性長態)、rowlet/charizard 為 error（見上表）。
- 記憶體正常（available 21.4 GB / 31.8 GB）、load 0.83 → 不是資源不足。

### 4. 給 Linder 的待決事項（累積）
1. **【急】重啟 gateway** 恢復 8 隻 Discord bot 的 inbound（已斷 1h+）。建議同時檢查 `36b493db Memory Dreaming Promotion`：它 03:00 整點起跑、跑 31.5 分鐘、直接在 gateway 行程內做重活 → 把 dreaming 改成 **isolated 行程 / 錯開整點 / 降低 payload 權重**。這是「整點尖峰」理論的新實證。
2. **【急】MiniMax Token Plan 額度／跨廠商 provider**（429 帳號層，第 7 輪回報未決）。已 5/10 → 再各敗 5 次 `ca222989`、`d82f78e3`、`ffc90b7d`、`a72cb46b` 會被自動停用。
3. `push-llm-wiki` 4 連敗 → llm-wiki 變更仍推不上去，需人工 commit。
4. 本 job 的 fallback 鏈含 `minimax-portal/MiniMax-M2.7` + `minimax/MiniMax-M2.7` → 與 M3 共用同一份 Token Plan，**不構成冗餘**（既有已知問題，未動）。

### 邊界（本次刻意沒動）
- 不改 provider / model / modelPolicy / cron 排程（全域層，需 Linder）。
- 不用 shell 重啟 gateway（政策禁止；且會中斷本輪導致報告遺失）。
- 不為了讓紅單轉綠而手動 `run` 其他 job。
- llm-wiki 本輪不歸檔（健康檢查非研究資料）。

### 5. 補驗（針對「Discord inbound 是否真的全黑」的反駁查證）
系統專家（openclaw tool）提出反證：`agent:rowlet:main`、`agent:charizard:main` 在 03:03 後仍有近期活動，可能代表 inbound 未死。**獨立複驗後反駁不成立**：
- 逐一讀 `agent:rowlet:main` / `agent:charizard:main` 轉錄：03:19 之後的「活動」全部是 **heartbeat/cron 驅動的 agent turn**，且每一則都是 `The agent run failed before producing a reply.`（stopReason=error）→ 不是 Discord 使用者訊息。
- `agent:picturecat:main` 轉錄近幾輪只有 4 筆 rowlet 的 keep-alive ping（16:02 / 19:02 / 01:02 / 04:02）→ 沒有任何 Discord 使用者訊息。
- 補充事實：**01:02 那輪雖然 job 被記成 error（429 發生在本輪自己的 model turn），但 keep-alive 的實質目標有達成** —— 01:02:28 picturecat 就回過 `pong — idle, no active task, no errors`。也就是說 job 的紅字是「巡檢者自己被打死」，不是「Picturecat 沒回應」。這也代表 4 次連敗的紅單不代表 Picturecat 掉線。
- 結論維持：Discord **gateway 層**全黑（無 READY → 收不到 MESSAGE_CREATE），Picturecat **agent 層**存活（API/CLI 可達）。

## 2026-11-17 07:02 — ⚠️ 雙軌：agent lane PASS / Discord 傳輸仍 DOWN（已 4h05m，證實不會自癒）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → **pong**（runId abef4424，07:02 完成）。
- 本 job run 紀錄：04:07 **ok** → 01:07 error(429 rate_limit) → 22:03 error → 22:02 error → 紅單已在 04:07 清零；**本輪 07:02 = ok**，consecutiveErrors=0。
- 姊妹 job：`9d8b6001 Gengar Keep-Alive` 04:03 ok / 01:07 ok；`880b5c17 Celesteela Keep-Alive` 07:01 **ok** → 三支 keep-alive 全存活。

### 2. 🔴 Discord 傳輸：仍 DOWN，已 4 小時 05 分，**本輪證實不會自癒**
- 權威狀態（`openclaw channels status`）：8 個帳號**全部** `running, disconnected, error:startup-not-ready`（picturecat / mrmime / charizard / gengar / roaringmoon / celesteela / flaaffy；greninja disabled）。
  - ⚠️ 反證記錄：本輪 `openclaw` 系統專家回「accounts 8/8 connected」→ **不實**（只看 token 數量、沒看 READY）。以 `channels status` + journal 為準。
- 重連仍在燒：最近 5 分鐘 **133 次** `gateway READY wait timed out after 15000ms; reconnecting with backoff`，attempt 已到 **721–725**（04:02 時僅 101–105），約 1659 次/小時。
- ⭐ **本輪關鍵新事實**：最近 1 小時 **event-loop starvation = 0 筆**（dreaming 03:31 就跑完了），**Discord 依然全黑** → 排除「資源不足／尖峰仍在」假說，證實 **client 狀態機卡死、重連自癒無效 → 必須重啟 gateway**。
- 網路層再次實測正常：獨立 `ws` client 直連 `wss://gateway.discord.gg` → **0.5s OPEN + 收到 op10 Hello**；`discord.com/api/v10/gateway` 200。→ 問題 100% 在 gateway 行程內。
- gateway 本身健康：CPU 7.6%、RSS 1.68GB、load 0.66、`/health` 200 in 1ms。doctor 的「Channel status probe failed: gateway timeout after 6000ms」是 probe 在等 Discord，不是 gateway 慢。
- ❌ **「版本落差」是誤判（已自查推翻）**：systemd unit 的 Description 與 `OPENCLAW_SERVICE_VERSION=2026.7.1-2` 是**安裝 unit 時寫死的舊標籤**；ExecStart 實際跑的就是 CLI 同一份套件 `~/.nvm/versions/node/v24.22.1/lib/node_modules/openclaw/dist/index.js`（package.json = **2026.8.2**，mtime 10-28；ps 亦指向同一路徑）→ **跑的就是 8.2，沒有版本落差、沒有版本跳躍風險**。（本條初稿誤判為「gateway 落後一版」，已用 package.json + ps + systemctl show 三方證實推翻，避免後人重踩。）
- Discord plugin 本身也是新的：`@openclaw/discord@2026.8.2`，installed 2026-09-02，`openclaw plugins inspect discord` → **Status: loaded**、Shape hybrid-capability → **不是 plugin 版本不匹配**。唯一附帶警告是 capability consent（需 `openclaw plugins enable discord --accept-capabilities`），但 11-16 整天它都能正常收訊 → consent 不是當前阻塞點；**重啟後若 Discord 仍不 READY，consent 才是下一個嫌疑人**。
- inbound 停擺佐證（各帳號最後 inbound）：celesteela 4h ago、mrmime 5h ago、gengar 17h ago、rowlet 20h ago、charizard 22h ago → **11-16 整天 Discord 收訊正常，03:00 後全斷**。
- 因果不變但更嚴重：03:00 `36b493db Memory Dreaming Promotion` 起跑 → event loop 被塞住（timerDelay 最高 27.1s）→ 03:03 起 WS 全面掉線。4h 後仍無自癒 = dreaming 的副作用是**不可逆的 client 狀態損壞**，修法必須「重啟 + dreaming 改 isolated／錯開整點」雙管齊下。

### 3. Fleet 紅單（`openclaw cron list`，約 50 jobs）
| job | id | 狀態 | 最後失敗 | 類別 |
|---|---|---|---|---|
| 每日論文討論 | 58fe15dc | error (5x) | **11-17 07:01:34** | rate_limit（MiniMax 429 Token Plan）|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | error (5x) | 11-16 11:07 | provider overloaded |
| Rowlet: maintain ut-veteran | 08b7c00b | error (4x) | 11-16 | 429 |
| Jormungand daily all-agent health | 40e09cd1 | error (4x) | 11-17 03:29 | 429 |
| 每日資安建議 | 911eee45 | error (4x) | 11-16 21:09 | 429 |
| PTCGP Meta Analysis | 09c7940b | error (3x) | 11-16 20:38 | auth-profile-unavailable（+ delivery target unresolved）|
| 晨間情報 pipeline (Roaringmoon) | 45ccf4e9 | error (2x) | 11-16 08:10 | timeout |
| 群體智能架構研究 | b37129c0 | error | 11-16 08:00 | gateway restart 誤記 |

- ✅ 轉綠/維持綠：`ca222989` OpenClaw 系統維護（58m ok）、`13ac4b5a` 健康回報（2h ok）、`e2ffd70d` push-llm-wiki（2h ok）、`d82f78e3`/`ffc90b7d` heartbeat rowlet/charizard（恢復 ok）、`880b5c17` Celesteela Keep-Alive（07:01 ok）、`36b493db` dreaming（4h ok）。
- skipped 全為 heartbeat no-route（良性）：celesteela / greninja / picturecat / roaringmoon / gengar。
- `88810bfe BBC News Morning Discussion` 的 07:00 那輪 **07:06:22 ok**（同樣在尖峰時段，卻成功 → 再次支持「尖峰流量」而非「額度全面見底」的判讀）。

### 4. 429 的新判讀（修正前幾輪敘述）
- 今日 07:01:34 `58fe15dc` 失敗是 `rate_limit`（MiniMax 429 Token Plan），但**同一分鐘群的 02eb0989 keep-alive（07:02）正常跑完** → **不是帳號層額度全面見底，而是「整點尖峰流量」**：07:00 同時有 BBC News + 每日論文討論 + 2 支 keep-alive + heartbeat 群一起打 MiniMax，瞬間超 per-minute 限制；峰過就恢復（04:02 / 07:02 都跑得動）。
- 對策：**錯開 07:00 批次**（07:00 / 07:20 / 07:40）比「加值」更有效；跨廠商 fallback 仍需補（minimax 與 minimax-portal 共用同一 Token Plan → 目前不構成冗餘）。

### 5. 給 Linder 的待決事項（累積，第 5 輪）
1. **【最急】重啟 gateway 恢復 8 隻 bot 的 Discord inbound**（已黑 4h05m、721+ 次重連全敗、自癒無效；gateway 與 discord plugin 都是 2026.8.2 → 純 client 狀態機卡死，非版本問題）。路徑：`openclaw` 系統專家 或 `systemctl --user restart openclaw-gateway`。**重啟後立刻驗** `openclaw channels status`（8 帳號應為 connected）；若仍 disconnected 且日誌出現 capability consent 阻塞 → 補 `openclaw plugins enable discord --accept-capabilities` 後再重啟。
2. **【急】`36b493db Memory Dreaming Promotion` 改 isolated／錯開整點**（03:00 起跑、31.5 分鐘、直接在 gateway 行程內做重活 → 打死 Discord client 狀態機；現已證實不可自癒）。
3. **【急】錯開 07:00 尖峰**（每日論文討論 / BBC News / keep-alive 群）→ 緩解 429。`58fe15dc`、`a72cb46b` 已 5/10，再各敗 5 次會被自動停用。
4. `09c7940b PTCGP Meta Analysis` 的 delivery target `1338836482420510764` 未解析（與傳輸層無關，是 channel id 解析問題）。

### 邊界（本次刻意沒動）
- 未自行重啟 gateway（gateway 變更走 `openclaw` 系統專家、需人工核准；無人值守的巡檢 job 不該自行決定全域服務重啟 —— 即使已證實它是唯一解）。
- 未改 provider / model / modelPolicy / cron 排程 / plugin 啟用狀態 / channel 設定；未為了讓紅單轉綠而手動 `run` 其他 job。
- 探測全為唯讀（sessions_send、channels status、cron list/runs、journal、ps、獨立 ws 連線測試）。

## 2026-11-17 10:02 — ⚠️ 雙軌：agent lane PASS / Discord inbound 全瞎已 7h06m（outbound 正常 → 精確化前幾輪「全黑」敘述）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → **pong — no active task, no errors; idle and ready**（runId `b7190bab`，10:03 完成）。
- 本 job run 史：07:02 **ok** → 04:02 **ok** → 01:02 error(429) → **本輪 10:02 = ok（連 3 綠）**。
- 姊妹 job：`880b5c17` Celesteela Keep-Alive 09:0x **ok**；`9d8b6001` Gengar Keep-Alive 上一輪 3h 前。

### 2. 🔴 Discord：gateway WS inbound 死／REST outbound 活（本次**修正**前幾輪「全黑」的說法）
- 權威狀態（`openclaw channels status`）：8 個帳號仍**全部** `running, disconnected, error:startup-not-ready`（greninja disabled）。
- 斷線時間軸（journal 實測）：`02:56:45 websocket closed code=1005` → `03:11:16` 起第一次 `READY wait timed out (attempt 1)` → **至今 10:02 ≈ 7h06m**。
- 重連仍在燒：最近 1 小時 **1662 次** READY timeout（≈1660/小時，與 07:02 同量級）；attempt 已到 **1345–1350**（07:02 為 721–725，3 小時 +625 次）。
- ⭐ **本輪關鍵修正**：「Discord 傳輸 DOWN」精確說法是**一半死**：
  - **outbound REST 正常** —— mrmime 08:18 發 3 則（messageId `1572042899347210290` / `1572042935489536060` / `1572042971929510139`，狀態 `sent`）、roaringmoon 08:20、mrmime 08:30 & 08:41（`deliveryStatus: sent`）、`88810bfe` BBC News 07:06 `deliveryStatus: delivered`。
  - **inbound WS 全瞎** —— 8 隻 bot 收不到 Discord 使用者訊息（各帳號最後 inbound：rowlet 23h、charizard 25h、gengar 20h、roaringmoon 11h、mrmime 8h、celesteela 7h）。
  - 後果修正：cron announce **仍能投遞**（不要誤判「全艦無輸出」）；真正瞎掉的是「使用者在 Discord 對 bot 講話 → 無人回」。
- ⭐ **重啟提案仍未核准（第 3 輪）**：gateway 行程 `ps` 顯示 **STARTED Nov 16 08:17:48 / elapsed 1d01h45m** → **從未重啟過**；04:02 提出的重啟提案 `proposalId system-agent:d0e11349-…`（needsApproval=true）**擱置 3 輪約 7 小時**。
- 資源面再次排除：最近 1 小時 **event-loop starvation = 0 筆**；`/health` 200 in 1ms、load 0.88、RSS 1.79GB、free 20G → 純 client 狀態機卡死，無資源壓力。
- ⚠️ 重啟後的下一嫌疑人仍在：`openclaw plugins inspect discord` → Status: loaded、Version 2026.8.2，但仍有 **capability consent WARN**（需 `openclaw plugins enable discord --accept-capabilities`）。重啟後若仍 `startup-not-ready` → 先補 consent 再重啟。

### 3. 🆕 新失敗類別：「prepared model runtime plugin generation was superseded」
- 6 小時內 **122 次**，受影響：`/home/amr/.openclaw/agents/mrmime/agent`、`/home/amr/.openclaw/agents/picturecat/agent` 等多個 agent 目錄。
- 實例：`10:03:26 lane=nested:agent:picturecat:main durationMs=5 error="prepared model runtime plugin generation was superseded for .../picturecat/agent"`（同一秒 session lane 也報）→ 判讀為**併發重建 agent 目錄時的競態**，非致命（picturecat pong 仍回）。
- 為何重要：這是**第三種**失敗類別（既非 429 rate_limit、也非 timeout、也不同於 auth-profile-unavailable），本輪首次出現，先記錄待查。

### 4. Fleet 紅單（`openclaw cron list`，50 jobs）
| job | id | 狀態 | 最後失敗 |
|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | **error (6x)** | **11-17 10:00**（再 4 次自動停用）|
| 每日論文討論 | 58fe15dc | error (5x) | 11-17 07:01 |
| Rowlet: maintain ut-veteran | 08b7c00b | error (4x) | 11-16 12:08 |
| Jormungand daily all-agent health | 40e09cd1 | error (4x) | 11-17 03:29 |
| 每日資安建議 | 911eee45 | error (4x) | 11-16 21:09 |
| 晨間情報 pipeline | 45ccf4e9 | error (4x) | 11-17 08:00 |
| PTCGP Meta Analysis | 09c7940b | error (3x) | 11-16 20:38（delivery target 仍未解析）|
| 群體智能架構研究 | b37129c0 | error (2x) | 11-17 08:00 |
| Heartbeat (mrmime) / (rowlet) | bcf270b8 / d82f78e3 | error (5x) | 近期 |

- ✅ 綠燈：`ca222989` 系統維護、`13ac4b5a` 健康回報、`e2ffd70d` push-llm-wiki、`880b5c17` Celesteela KA、`88810bfe` BBC News、`36b493db` dreaming、`89e2cfe7` clean-code、`ae91b967` wiki 巡讀、`29c2d630` Gengar Cron Health Watch。
- skipped 全為 heartbeat no-route（良性）。
- 📌 副帶觀察：journal 持續刷 `Skipping invalid skill`（8 支 skill 缺 description / frontmatter BAD_INDENT，含 rosclaw 內建 skill）→ 這些 skill 實際**沒有被載入**，長期會讓對應能力靜默失效（非本輪阻塞項）。

### 5. 給 Linder 的待決事項（第 6 輪，數字化）
1. **【最急】核准 gateway 重啟** —— 提案 `system-agent:d0e11349-…` 已擱 3 輪 7h；Discord inbound 8/8 仍瞎。路徑：`openclaw dashboard` 批准該提案，或 `systemctl --user restart openclaw-gateway`。**重啟後 60 秒內驗** `openclaw channels status` 應 8/8 connected；若仍 `startup-not-ready` → `openclaw plugins enable discord --accept-capabilities` 後再重啟。
2. **【急】`36b493db` dreaming 改 isolated + 離開整點**（例 `17 3 * * *`）→ 否則明天 03:00 準時重演同一場斷線。
3. **【急】錯開 07:00 / 08:00 / 10:00 尖峰**（每日論文討論、每日 Agent 潮流研究、keep-alive 群、heartbeat 群同時打 MiniMax）→ 這是 429 的真正來源，比加值有效。
4. `a72cb46b` 已 **6/10**、heartbeat mrmime/rowlet 已 **5/10** → 再敗 4～5 次就會被自動停用。
5. 新增待查：`plugin generation was superseded`（6h 122 次，agent 目錄併發生成競態）。

### 邊界（本次刻意沒動）
- **未自行重啟 gateway**（政策：gateway 變更需人工核准；且重啟會 kill 掉本輪，使報告遺失 —— 邏輯上不可自證）。
- 未改 plugin 啟用狀態 / cron 排程 / provider / model / channel 設定；未為了讓紅單轉綠而手動 `run` 其他 job。
- 探測全為唯讀（sessions_send、channels status、cron list/runs、journal、ps、/health、curl）。

### 6. 本輪主動升級（唯一能到人的通道）
- 本 job delivery = `not requested` → 最終回覆不一定到人眼前；Discord **outbound 正常** → 已用 rowlet 帳號把「核准 gateway 重啟」告警貼到 Discord channel `1482363974119854234`，**messageId `1572070400416808994`，deliveryStatus sent**（同時再次實證：REST outbound 活 / WS inbound 死）。

## 2026-11-17 13:02 — ⚠️ 雙軌：agent lane PASS / Discord inbound 全瞎 10h05m / 新增「heartbeat 600s 逾時 → 自動停用倒數」

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → **pong — no active task, no errors, ready for work**（runId `95a45118`，13:02:19 完成）。
- 本 job run 史：10:06 **ok** → 07:07 ok → 04:07 ok → 01:07 error(429 rate_limit) → **本輪 13:02 ok（連 4 綠）**，consecutiveErrors=0。
- 姊妹 job 全綠：Gengar KA（13:0x ok，dur 793s）、Celesteela KA（13:0x ok，dur 108s）。

### 2. 🔴 Discord：inbound 全瞎已 10h05m（outbound 仍活）
- `openclaw channels status`：8 帳號（greninja disabled）**全部** `running, disconnected, error:startup-not-ready`。
- 重連仍在燒：最近 1 小時 **1664 次** READY timeout（連續 8 小時每小時 1653–1664，量級沒變）；attempt 已到 **1966–1971**（10:02 為 1345–1350，3 小時 +620）。
- 斷線起點：02:56:45 `websocket closed code=1005` → 03:11:16 首次 `READY wait timed out (attempt 1)` → 至今 13:02 ≈ **10h05m**；最後一次 `websocket closed` 是 07:55:49（code=1006）。
- 各帳號最後 inbound：celesteela 10h、mrmime 11h、roaringmoon 14h、gengar 23h、rowlet 26h、charizard 28h → **使用者對 bot 講話無人回**。
- outbound REST 仍活：mrmime 12:50（15m ago）、rowlet 10:02（3h ago）、charizard 09:02、gengar 07:0x。cron announce 仍投遞正常。
- 資源面持續排除：最近 1 小時 event-loop starvation **0 筆**；`/health` 200 in 0.87ms、load 0.89、mem available 20G。

### 3. 🔴 新發現（12:40 operator 熱改 config 造成的新症狀）：heartbeat 600s 逾時 → 自動停用倒數
- `journal` 12:40:13：`config hot reload applied (agents.entries.mrmime.heartbeat.isolatedSession, agents.entries.mrmime.heartbeat.lightContext)` → operator 在 12:40 動了 **mrmime** 的 agent 層 heartbeat（現在 `isolatedSession=true, lightContext=true, timeoutSeconds=1800`）。
- **但 cron job 層沒動**：`heartbeat-mrmime` / `heartbeat-rowlet` 的 `sessionTarget` 仍是 `main`、`payload={kind:heartbeat}`（agent 層 `isolatedSession` 管不到 cron job）。
- 症狀：兩支 heartbeat 每 30 分鐘**精準卡 600004ms**（= cron 預設 timeout 上限）→ `cause=timeout, error="cron: job execution timed out"`；**charizard 同一模板卻只要 7–17s 就 ok**（差異在 charizard 的 heartbeat 設定有 `target:"none"`，且其 main lane 空閒）。
- 連敗數：`heartbeat-rowlet` consecutiveErrors **8**、`heartbeat-mrmime` **8**（10:02 時為 5）。rowlet 下一輪 13:18、13:48 → **再 2 次就 10/10 自動停用**（mrmime 改了 timeoutSeconds=1800 後計數可能暫停，需下輪觀察）。
- ⭐ 佐證（agent:rowlet:main 12:47 自己的 heartbeat 報告）：rowlet main lane 在 12:47 仍是 `status=running` 被佔著 → 心跳進得去卻跑不動，agent 層 isolatedSession 解決不了 cron 的 sessionTarget=main 問題。

### 4. 🧪 本輪實測推翻兩個假說（省得後人重踩）
- ❌ **「9 個 Discord 帳號共用同一 token」→ 推翻**。對 `~/.openclaw/openclaw.json` 9 個帳號算 token SHA-256 前綴：9 組**全不相同**（8e1b6b317b / 23e2412461 / 5d20fd711f / 3aecbb6f73 / f9951a3c39 / d0402322d6 / e45a604cd3 / 7e77d13280 / 5e2a423cab）→ 不是重複 token 互踢。
- ❌ **「gateway 每小時自動重啟、attempt counter 因此從未重置」→ 推翻**。`ps` 顯示**唯一** gateway 行程 pid 2235362，`STARTED Nov 16 08:17:48`、elapsed **1d04h45m** → **從未重啟過**，且 attempt counter 也從未歸零（1968）。mrmime 12:31 的推理裡「gateway 每小時自動重啟」與 ps 事實不符。
- ⚠️ `plugin generation was superseded` 已從 122 次/6h 降到 **2 次/1h**（併發重建 agent 目錄的競態，非致命）。

### 5. Fleet 紅單（45 jobs）
| job | id | 狀態 | 最後失敗 |
|---|---|---|---|
| heartbeat-rowlet | d82f78e3 | **error (8x)** | 11-17 12:48（600004ms timeout）|
| heartbeat-mrmime | bcf270b8 | **error (8x)** | 11-17 12:41（600004ms timeout）|
| 每日 Agent × 軟體開發潮流研究 | a72cb46b | error (6x) | 11-17 10:02（rate_limit）|
| 每日論文討論 | 58fe15dc | error (5x) | 11-17 07:01 |
| 每日資安建議 | 911eee45 | error (4x) | 11-16 21:09 |
| Jormungand daily all-agent health | 40e09cd1 | error (4x) | 11-17 03:29 |
| 晨間情報 pipeline | 45ccf4e9 | error (4x) | 11-17 08:00 |
| PTCGP Meta Analysis | 09c7940b | error (3x) | 11-16 20:38（delivery target 未解析）|

- ✅ 綠燈：3 支 keep-alive、`ca222989` 系統維護、`13ac4b5a` 健康回報、`e2ffd70d` push-llm-wiki、`36b493db` dreaming、`ffc90b7d` heartbeat-charizard、`537bd0dd` 轉錄監控。
- **429 已退潮**：最近 1 小時 0 次 429（12:01–12:02 有 2 次 429，12:04 起恢復 200）。→ Token Plan 尖峰理論成立，這一輪不再是額度問題。

### 6. 給 Linder 的待決事項（第 7 輪，已數字化到「多久會壞」）
1. **【最急，13:48 截止】`heartbeat-rowlet` 只剩 2 次容錯**：把 cron job 層改成獨立 session（`sessionTarget: isolated`），或照 mrmime 那樣把 `agents.entries.rowlet.heartbeat` 加 `isolatedSession/lightContext` **且** 確認 job 層的 `sessionTarget` 不再是 `main`；最省事是照 charizard 加 `target:"none"`（它 7–17s 就跑完）。
2. **【最急，第 4 輪約 9h 未核准】重啟 gateway 恢復 Discord inbound**（8/8 disconnected、1664 次/小時重連全敗、自癒無效；ps 證實未重啟）。重啟後 60 秒內驗 `openclaw channels status` 應 8/8 connected；仍 `startup-not-ready` → 先 `openclaw plugins enable discord --accept-capabilities`。
3. **【急】`36b493db` dreaming 改 isolated + 離開整點**（`17 3 * * *`）→ 否則明天 03:00 重演同一場斷線。
4. **【急】錯開 07:00 / 08:00 / 10:00 / 13:00 尖峰**（keep-alive 群 + heartbeat 群 + 論文/潮流研究同時打 MiniMax）→ 429 的真正來源。
5. 429 已退潮 → 額度加值需求下降；重點轉向「尖峰錯開」與「跨廠商 fallback」（minimax 與 minimax-portal 共用同一 Token Plan，不構成冗餘）。

### 邊界（本次刻意沒動）
- 未自行重啟 gateway、未改 config / cron 排程 / provider / model / channel 設定；未為了讓紅單轉綠而手動 `run` 其他 job。
- 探測全為唯讀（sessions_send、channels status、cron list/runs、journal、ps、/health、config get、token hash 比對）。

### 7. 本輪升級（唯一能到人的通道，delivery=not requested → 最終回覆只進 run log）
- 已用 rowlet 帳號貼到 Discord channel `1482363974119854234`，**messageId `1572115759717416983`**，deliveryStatus `sent`（同時再次實證 REST outbound 活 / WS inbound 死）。
- 貼文內容：① `heartbeat-rowlet` 8/10、約 13:48 自動停用倒數 + 三個止血選項（job 層 `sessionTarget: isolated` / 照 charizard 加 `target:"none"`）；② gateway 重啟第 4 輪未核准、10h05m inbound 全瞎 + 重啟後驗證步驟；③ 429 已退潮；④ 兩個被推翻的假說（token 唯一、gateway 未重啟）。
- 待下輪驗證：`heartbeat-mrmime` 改了 timeoutSeconds=1800 後 13:41 那輪是否還會 600s 逾時（若會，連敗數繼續累積 → 14:11 自動停用）。

## 2026-11-17 16:02 — ✅ 轉折：gateway 已重啟、Discord inbound 復活；Picturecat PASS；備份 job 被 529 打死（已手動補跑）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → **"No active task, no errors — ready for work."**（runId `c605c379`，16:02:38 完成）。
- 本 job（02eb0989）run 史：13:02 ok → 10:06 ok → 07:07 ok → 04:07 ok → 01:07 error(429) → **本輪 16:02 running**，consecutiveErrors=0。
- 姊妹 job 同步全綠：Gengar KA（16:02 ok，dur 15.3s）、Celesteela KA（16:02 ok，dur 11.9s）。

### 2. ⭐⭐ 大新聞：gateway 已於 **13:19:02 重啟**，Discord 全線復活（前 7 輪的頭號問題已解）
- journal 13:19:02 `[gateway] received SIGTERM; restarting` → 13:19:32 systemd `stop-sigterm` timeout → kill → pid 2548417 啟動 → 13:19:54 http listening → 8 個 Discord client 依序 delayed startup（10s–70s 錯開）→ 13:21 各 `client initialized` / `channels resolved`。
- 前一輪報告的 **gateway restart approval 最終被核准並執行**（approval id `system-agent:e33efcf4-…`；前一輪 13:17 還顯示 EXPIRED，隨後重新開立並通過）。
- ✅ `openclaw channels status`：**8 帳號全部 `running, connected`**（greninja disabled）——對比前 7 輪的 `running, disconnected, error:startup-not-ready`。
- ✅ **READY wait timeout = 0**（13:19 重啟後至今 0 筆），重連 storm 消失。
- ✅ **inbound 復活的直接證據**：`channels status` 顯示 gengar `in:5m ago`、mrmime `in:4m ago`、celesteela `in:1m ago`（在:in/out 都在跳）；重啟後 Discord 使用者訊息有被收到並處理。
- ⚠️ 仍有間歇性 `websocket closed code=1005`（14:11 / 14:18 / 15:23 / 16:07 各一次，reconnect-opcode resume=true 後**成功重連**，不再卡死）→ 症狀從「10 小時全黑」降級為「偶發掉線、可自癒」，已非阻塞項。
- 📌 長期風險仍在：**03:00 `36b493db Memory Dreaming Promotion`** 明天準時再跑 → 需確認是否還會打死 client 狀態機（本輪已改 isolated，仍建議改離開整點）。

### 3. 🔴 新瓶頸：MiniMax 供應端 **529 overloaded**（不再是 429 Token Plan），並打死了「每日 OpenClaw 備份」
- 16:00–16:04 短短幾分鐘：**40 次 HTTP 529 `overloaded_error` (2064)** + 1 次 HTTP 429（`server is busy`）。16:04:30 之後回落到 0 次，09:xx 有 `status=200` 成功回應 → **供應端容量尖峰，非本機問題**。
- 受災 job：`af94aa92 每日 OpenClaw 備份`（cron 5 0 8 * * * UTC）→ **連 3 次 error**，last summary：`All models failed (3): minimax/MiniMax-M3: 529 | minimax-portal/MiniMax-M2.7: 529 | minimax/MiniMax-M2.7: 529`。**注意：整條 fallback 鏈三個型號都指向 MiniMax（minimax / minimax-portal 共用同一 Token Plan），所以 fallback 完全沒有冗餘 → 供應端一忙就全滅。**
- ✅ **已手動補跑備份**（在本輪內直接跑 `/home/amr/.openclaw/workspace-mrmime/scripts/backup-openclaw.sh`，未經 model、不受 529 影響）：**成功**，UTC 08:06:59–08:08:38。結果：
  - workspace-mrmime → `7ab4a8f45` pushed main → origin/main
  - workspace-rowlet → `120df8cf` pushed master → origin/backup/master（13 files，含 3 份 keepalive 日誌）
  - workspace-picturecat → `60eed93` pushed master → origin/master
  - workspace-roaringmoon → `35e0d2b` pushed master → origin/backup/master
  - workspace-greninja → `60a2f36` pushed master → origin/master
  - nested snapshot → `74ec57d` → charizard-nested-snapshots（9 repos captured）
  - **無 push 失敗、無 rebase 衝突**（今天第一次全綠的備份）。
- 💡 **教訓**：備份 job 的核心動作是 shell script，卻綁在 model turn 上 → **模型一忙，資料就沒備份**。備份腳本應該直接由 cron 觸發（不經 agent），或至少讓 agent 失敗時仍執行腳本。

### 4. Fleet 紅單（45 jobs，本輪 7 支紅）
| job | ce | 最後失敗 | 類別 |
|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | 6 | 11-17 10:02 | rate_limit |
| 每日論文討論 | 5 | 11-17 07:01 | rate_limit |
| 每日資安建議 | 4 | 11-16 21:09 | rate_limit |
| Jormungand daily all-agent health | 4 | 11-17 03:29 | rate_limit |
| 晨間情報 pipeline (Roaringmoon) | 4 | 11-17 08:00 | timeout |
| 每日 OpenClaw 備份 | 3 | 11-17 16:02 | **529 overloaded** |
| PTCGP Meta Analysis | 3 | 11-16 20:38 | delivery target 未解析 |

- ✅ 綠燈：3 支 keep-alive、系統維護、健康回報、push-llm-wiki、dreaming、heartbeat-charizard、轉錄監控、Gengar Cron Health Watchdog。
- `heartbeat-rowlet` / `heartbeat-mrmime` **已自癒**：mrmime 最近 3 輪全 ok（dur 4.6–9.8s）；rowlet 3 輪 `skipped (no-route)` 屬良性長態（不再有 600s timeout → 前一輪的「自動停用倒數」威脅解除）。

### 5. 給 Linder 的待決事項（第 8 輪，重點已轉移）
1. **【已解決】** gateway 重啟 → Discord inbound 復活；**不需要再做第 5 次重啟提案**。
2. **【新・急】補跨廠商 fallback**：`agents.entries.*.model.fallbacks` 全部只列 MiniMax 系（`minimax/*` 與 `minimax-portal/*` 共用同一 Token Plan → 零冗餘）。config 已有 `openai` provider（`gpt-5.5` / `gpt-5.4-mini`，auth=oauth）可作 fallback，但 **auth 狀態未驗證**（`openclaw models list` 顯示 Local= Auth=no）→ 需先確認 openai provider 的憑證可用，再把 `openai/gpt-5.4-mini` 加進 mrmime 等關鍵 agent 的 fallback 鏈。
3. **【新・急】備份不該綁 model**：把 `backup-openclaw.sh` 從 agentTurn payload 改成純 cron/script payload（`kind:"script"` 或直接 crontab），避免 529/429 讓備份整天不跑。
4. **【急】`36b493db` dreaming 離開整點**（`17 3 * * *`）→ 明天 03:00 是否重演斷線仍未驗證，本輪重啟只是治標。
5. 錯開 07:00 / 08:00 / 10:00 尖峰（429 歷史來源）＋ 本輪新增 **16:00 尖峰 529** → 建議整體排程散開。
6. `09c7940b PTCGP Meta Analysis` 的 delivery target `1338836482420510764` 仍未解析。

### 邊界（本次刻意沒動）
- 未自行重啟 gateway（重啟是 operator 核准後由外部執行）；未改 provider / model / fallbacks / cron 排程 / channel 設定；未為了讓紅單轉綠而手動 `run` 其他 job。
- 例外：**手動跑 backup-openclaw.sh**（唯讀 git 提交與 push，屬 job 自身的既定工作、不改 config、不觸碰模型層），用來補回被 529 打掉的當日備份。
- 探測全為唯讀（sessions_send、channels status、cron list/runs、journal、ps、config get）。

## 2026-11-17 19:02 — ✅ 全綠收尾：Picturecat PASS、Discord 8/8 連線、備份已脫離模型束縛

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 0. ⚠️ 本輪先修掉一個「假全綠」的觀測錯誤（重要教訓）
- 我第一次掃 log 用 `journalctl -u openclaw-gateway --since "16:00"`，得到 **0 筆** → 一度誤判「16:00 後零錯誤」。
- 真相：gateway 是 **user unit**，正確寫法是 `journalctl --user -u openclaw-gateway`。錯誤寫法回 `-- No entries --`（stderr 被我 `2>/dev/null` 吃掉 → **假的 0**）。
- ⇒ **往後所有 round 的錯誤掃描一律用 `--user`**，且先跑 `wc -l` 確認 journal 有資料再看統計。

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → **"pong — idle, no errors since 16:00."**（runId `5e970f4b`，19:02）。
- Discord `picturecat`（@luna）：enabled / running / connected / transport:just now。
- 本 job（02eb0989）：上一輪 16:02 ok、dur=475s、consecutiveErrors=0；本輪 running。
- 姊妹 job 同時段全綠：Gengar KA 16:02 ok（dur 15.3s）、Celesteela KA 19:02 ok。

### 2. Gateway / Discord：穩定
- gateway pid **2548417 自 13:19:32 起活到現在（5h43m，無重啟）**；`NRestarts=0`。
- `openclaw channels status`：**8 帳號全部 running + connected + transport:just now**（greninja disabled）。
- inbound 有跳動：celesteela in:2m、gengar in:58m、mrmime in:57m、rowlet in:3h。
- ⚠️ 仍有間歇 `websocket closed code=1005`（18:18 / 18:19 / 18:21 / 18:31 / 18:53 各一次）→ **全部自癒重連**，未累積 READY timeout（13:19 重啟後 READY timeout = 0）。症狀維持「偶發掉線、非阻塞」。

### 3. Provider 壓力：16:00–16:10 一波，之後退潮
- 真正錯誤分佈（`--user` 掃到的）：16:00–16:10 共 **70+ 筆** 429/529（備份 job 16:09 被 529 打死那次）→ 16:10 後只剩 **1 筆**：18:02:08 `minimax-portal` HTTP 429（elapsed 97.9s）。
- 該筆打死的是 `d7b0355b Jormungand mrmime Codex A2A heartbeat`（agent=mrmime, sched `0 */6 * * *` Asia/Taipei）→ **但 fallback 鏈救回來了**：最終 lastRunStatus=ok、dur=155s、ce=0。
- ⇒ **同廠 fallback（minimax-portal → minimax）有效**；但 `agents.defaults.fallbacks = ["minimax/MiniMax-M3"]` 仍是同一家 Token Plan → **零跨廠冗餘**。

### 4. ✅ 上一輪待辦 #3 已解：每日 OpenClaw 備份已脫離模型層
- `af94aa92` payload 已改成 **`kind:"command"`**：`sh -lc "bash /home/amr/.openclaw/workspace-mrmime/scripts/backup-openclaw.sh"`（updated 17:09，timeout 1800s）→ **不再經過 model，429/529 打不到它**。
- 16:06–16:08 手動補跑結果仍在 repos 裡：rowlet `120df8cf` / mrmime `7ab4a8f45` / picturecat `60eed93` / roaringmoon `35e0d2b`（dirty 檔案為 16:08 之後新產生的 memory log，正常）。
- 下一輪自動執行：**明天 16:05（08:05 UTC）**，這次是 script payload → 預期必定成功，**待明天那輪驗證**。

### 5. Fleet 紅單（45 jobs，本輪 7 支紅，與上輪持平；**16:00 後無新增紅單**）
| job | ce | 最後失敗 | 類別 |
|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | 6 | 11-17 10:02 | rate limit |
| 每日論文討論 | 5 | 11-17 07:02 | rate limit |
| 每日資安建議 | 4 | 11-16 21:09 | rate limit |
| Jormungand daily all-agent health | 4 | 11-17 03:29 | 429 |
| 每日 OpenClaw 備份 | 4 | 11-17 16:09 | 529（**payload 已修，待明天驗證**）|
| 晨間情報 pipeline (Roaringmoon) | 4 | 11-17 08:15 | timeout |
| PTCGP Meta Analysis | 3 | 11-16 22:23 | auth profile unavailable |

- 綠燈：3 支 keep-alive、系統維護、健康回報、push-llm-wiki、dreaming、heartbeat-charizard/mrmime、轉錄監控、Codex health check、Gengar Watchdog、A2A heartbeat。
- `heartbeat-*` 的 `skipped: no-route` 仍是良性長態（rowlet/picturecat/roaringmoon/gengar/greninja/celesteela），非失敗。

### 6. 給 Linder 的待決事項（第 9 輪，重點已收斂到 2 條）
1. **【最急・約 8 小時後】`36b493db Memory Dreaming Promotion` 仍在 `0 3 * * *`（03:00 整點）**。機制已釐清：它是 **isolated agentTurn、lightContext、實跑 31.5 分鐘**（dur=1887865ms）→ 與 8 隻 Discord bot **同一個 gateway process / 同一個 event loop** → 重活時 event-loop starvation → 今日 03:03–03:30 全域斷線、Discord inbound 全瞎 10 小時。建議二選一：① 移到冷門時段並設 `timeoutSeconds` 上限；② 改 script payload / 限縮 tools（目前 `toolsAllow:["*"]`）。
2. **【急】跨廠 fallback 仍無法啟用**：`openai/*` provider 已設定但 `openclaw models list` 顯示 **Auth = no**（gpt-5.5 / gpt-5.4-mini / gpt-5.4 / gpt-5.3-codex 全部）→ 需 Linder 端完成憑證流程後，才能把 `openai/gpt-5.4-mini` 加進 `agents.defaults.fallbacks`。這是唯一能真正消除「MiniMax 一忙全滅」的動作，**我做不了（不碰憑證）**。
3. `09c7940b PTCGP Meta Analysis`：auth profile 仍 unavailable + delivery target `1338836482420510764` 未解析（ce=3，兩天未恢復）。
4. 尖峰仍存在（07:00 / 08:00 / 10:00 / 16:00），本輪 16:00 波單獨造成 70+ 筆 429/529；建議持續錯開整點排程。
5. `heartbeat-*` 的 `skipped: no-route` 是預期長態，**建議不要算入紅單**（否則每天都有假紅）。

### 邊界（本次刻意沒動）
- 未自行重啟 gateway（重啟屬 operator 核准範圍）；未改 config / cron 排程 / provider / model / fallback / channel；未手動 `run` 任何其他 job。
- 探測全為唯讀：sessions_send、channels status、cron list、journal（`--user`）、ps、models list、config get、git log。

## 2026-11-17 22:02 — ✅ 全綠：Picturecat PASS / Discord 8/8 連線 / gateway 連續活 8h43m / fleet 紅單 6 支（+1 新增 429）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

### 1. Picturecat 本身：PASS
- `sessions_send` → `agent:picturecat:main` → **"pong — no active task, no errors since 19:02; Discord delivery context is active/connected."**（runId `dc1cfd9a`，22:02）。
- Discord `picturecat`（@luna）：enabled / running / connected / transport:just now。
- 本 job（02eb0989）：status=running、ce=0；上一輪 19:02:07 **ok**（dur=121s）。
- payload 複查：`kind=agentTurn`、model `minimax-portal/MiniMax-M3`、fallbacks `["minimax/MiniMax-M3","minimax-portal/MiniMax-M2.7","minimax/MiniMax-M3"]` → **三個備援全是 MiniMax 同廠同 Token Plan → 跨廠冗餘仍是 0**。

### 2. Gateway / Discord：健康
- pid **2548417 自 13:19:32 活到 22:02（8h43m，無重啟）**，`NRestarts=0`，`ActiveState=active/running`。
- `openclaw channels status`：**8 帳號全部 running + connected**（greninja disabled = 預期）；inbound 有跳動（picturecat/celesteela/charizard/flaaffy/roaringmoon in:just now；gengar in:2h、mrmime in:57m、rowlet in:6h）→ **今日 10 小時的 inbound 全瞎已癒合**。
- `READY timeout` 自 13:19 重啟後累計 **0**。
- ⚠️ 唯一症狀：`websocket closed` 自 19:00 起 **29 條 log（含重複行，實際 ~15 次）**，code 1006/1005 → 全部自癒重連。比 18:00–19:00 視窗（5 次）略密（≈每 12 分鐘 1 次），屬「偶發掉線、非阻塞」，但**頻率在爬升，值得盯**。

### 3. Provider 壓力：19:00 後只有 1 筆真錯誤
- `21:01:48 provider=minimax-portal status=429 elapsedMs=81806` → 打死 `每日資安建議`（runId `0d1066db`）→ **ce 4→5**（新紅單）。
- **529 = 0**（先前 grep 到的 2 筆「529」是毫秒時間戳 `20:10:17.529`／`20:11:07.529`，非錯誤碼 —— 已排除）。
- 其餘 19:00→22:02 全 provider 呼叫皆 200。

### 4. 📌 已確認為「良性簽章」的一條錯誤（勿再誤判成紅單）
- `lane task error: lane=nested:agent:picturecat:main error="prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/picturecat/agent"`（durMs 5–9）。
- 出現時機**精準對齊本 job 的 keep-alive ping**：16:02:38 / 19:02:23 / 22:02:27 → **3 輪 3 次**，且每次 pong 都正常回來。
- 結論：這是 picturecat agent runtime plugin generation 的競態副作用，**非故障、非掉線**；往後巡檢直接歸類為良性，不再升級通報。

### 5. Fleet 紅單（45 jobs：ok 32 / skipped 6 / error 6 / never 1）
| job | ce | 最後失敗 | 類別 | 下次 |
|---|---|---|---|---|
| 每日 Agent × 軟體開發潮流研究 | 6 | 11-17 10:00 | rate limit | 11-18 10:00 |
| 每日論文討論 | 5 | 11-17 07:00 | rate limit | 11-18 07:00 |
| 每日資安建議 | 5 | **11-17 21:00（本輪新增）** | 429 Token Plan | 11-18 21:00 |
| Jormungand daily all-agent health | 4 | 11-17 03:29 | 429 | 11-18 03:00 |
| 晨間情報 pipeline (Roaringmoon) | 4 | 11-17 08:15 | timeout（dur=936s） | 11-18 08:00 |
| 每日 OpenClaw 備份 | 4 | 11-17 16:09 | 529（**payload 已修，待驗證**） | 11-18 16:00 |

- ✅ **PTCGP Meta Analysis 已脫紅單**（上輪 ce=3 → 本輪不在 error 列表）。
- `never run`：`Heartbeat (flaaffy)`（1 支，良性）。
- `skipped: no-route` 6 支（rowlet/picturecat/roaringmoon/gengar/greninja/celesteela）＝良性長態，**不計紅單**。
- 綠燈：3 支 keep-alive、系統維護、Gengar Cron Health、Rowlet 轉錄監控、heartbeat-charizard 等。

### 6. ✅ 上一輪待辦 #3 已驗證（部分）：每日 OpenClaw 備份已脫離模型層
- `af94aa92` payload 確認為 **`kind:"command"`**：`sh -lc "bash /home/amr/.openclaw/workspace-mrmime/scripts/backup-openclaw.sh"`（timeout 1800s）→ **不再經過 model，429/529 打不到它**。
- ce=4 是 16:09 那次 529 的殘留值；**下一輪自動執行 11-18 16:00:05（script payload）→ 預期必定成功，待明天驗證**。

### 7. 給 Linder 的待決事項（第 10 輪，重點已收斂到 2 條 + 1 觀察）
1. **【最急・約 5 小時後】`36b493db Memory Dreaming Promotion` 仍在 `0 3 * * *`（03:00 整點）**。複查 payload：**agentTurn + `toolsAllow:["*"]` + 無 `timeoutSeconds` + lightContext**，上次實跑 **dur=1888s（31.5 分鐘）** → 與 8 隻 Discord bot **同一個 gateway process / event loop** → 重活時 event-loop starvation，今日 03:03–03:30 全域斷線、inbound 全瞎 10 小時的元兇。**今晚 03:00 會再發生一次**（next=2026-11-18 03:00:00）。建議二選一：① 移到冷門時段（例如 04:30 或 23:30）並設 `timeoutSeconds`；② 改成 script payload 或限縮 `toolsAllow`。
2. **【急】跨廠 fallback 仍無法啟用**：`openai/*` provider 已設定但 `openclaw models list` 顯示 **Auth = no** → 需 Linder 端完成憑證流程，才能把 `openai/gpt-5.4-mini` 加進 `agents.defaults.fallbacks`。這是唯一能真正消除「MiniMax 一忙全滅」的動作，**我做不了（不碰憑證）**。
3. **【觀察】websocket close 頻率爬升**（19:00–22:02 約 15 次，code 1005/1006）：目前全自癒、READY timeout 仍 0。若下一輪出現 READY timeout 累積，就不是自癒範圍，需要 operator 核准後重啟 gateway。
4. 尖峰仍存在（07:00 / 08:00 / 10:00 / 16:00 / 21:00），本輪 21:00 波單獨造成 1 筆 429 打死「每日資安建議」；建議持續錯開整點排程。
5. `heartbeat-*` 的 `skipped: no-route` 與 `Heartbeat (flaaffy)` never run 皆為預期長態，**建議不要算入紅單**。

### 邊界（本次刻意沒動）
- 未自行重啟 gateway（重啟屬 operator 核准範圍）；未改 config / cron 排程 / provider / model / fallback / channel；未手動 `run` 任何其他 job。
- 探測全為唯讀：sessions_send、channels status、cron list(--json)、journal（`--user`）、systemctl --user show、ps。
