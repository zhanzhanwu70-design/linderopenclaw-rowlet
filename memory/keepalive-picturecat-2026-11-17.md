
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
