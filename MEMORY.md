# MEMORY.md - Rowlet Long-Term Memory

> Curated from daily logs. This is the distilled version — not raw events.

## Identity & Role
- I'm **木木鴞**, a Specialist agent on the Linder OpenClaw team
- My channel: 1482363974119854234
- I report to **roaringmoon** (CEO), channel: 1482561255955763293

## Team Members
| Agent | Role | Channel |
|-------|------|---------|
| roaringmoon | CEO / orchestrator | 1482561255955763293 |
| charizard | Tool Display specialist | 1482097593784733839 |
| gengar | Banini 反指標追蹤器 | 1484513576482902158 |
| mrmime | Container recovery | 1482069603512221927 |
| celesteela | TBD | 1482607890098421842 |
| picturecat | TBD | 1481665581189959872 |
| greninja | TBD | 1382962403720827011 |
| flaaffy | TBD | 1494534371292614729 |

## OpenClaw Architecture (Key Decisions)

### Communication Stack
1. **Heartbeat** — primary mechanism (current: 5min interval via Gateway Scheduler, setInterval/setTimeout)
2. **Task Queue** — `~/.openclaw/task-queue/task_queue.json` with file locking
3. **sessions_send** — cross-agent messaging (best-effort, not guaranteed)
4. **Cron** — exact-time scheduling for daily routines

### Shared Memory (Three Layers)
- `~/.openclaw/shared-memory/memory/episodic/YYYY-MM.jsonl` — append-only event log
- `~/.openclaw/shared-memory/memory/semantic/facts.json` — confirmed facts (all agents write)
- `~/.openclaw/shared-memory/memory/approved/` — pending CEO review

### Protocol: No forced mandates via sessions_send — it can't enforce
- Pure OpenClaw route: Task Queue + Heartbeat polling
- CEO assigns tasks, agents mark completed/running

## Key Projects

### TopoClaw (arXiv:2605.15556)
- Human-Centric + Topology-Aware Agent OS
- Physical topology (device capability clusters)
- Social topology (org roles, delegation)
- Cross-Device Action Placement (intent/execution decoupling)
- Digital Twin identity for human accountability
- **Highly aligned with OpenClaw architecture** — investigate if there's direct relation

### LLM-ACTR / Cognitive LLMs
- Wu et al. (arXiv:2408.09176)
- ACT-R cognitive traces as priors for LLMs
- Macro traces more transferable than full ragged traces
- Planner/verifier/repair trace injection relevant for code-agents

### Bumblebee (perplexityai/bumblebee)
- Supply chain security tool
- Source saved to `raw/code/bumblebee/`
- Wiki: `wiki/concepts/bumblebee.md`

### Hermes Agent
- Tool/Thinking realtime display research completed
- Implementation plan delivered to Charizard (task_20260526_001)
- Charizard implemented Tool Realtime Display MVP (task_20260526_002)

### Container Recovery (mrmime)
- Bundle at `~/.openclaw/restore/`
- Contains: restore.sh, inventory.md, setup-guide.md, app overrides, source patch, config/cron backups

## Papers Saved
- `raw/references/papers/ai/2024-wu-cognitive-llms.pdf`
- TopoClaw arXiv:2605.15556 (✅ downloaded 2026-06-27)
- MetaCogAgent (pending download)

## Daily Routine
- **7:00 AM UTC** — Daily paper discussion (Context Processing / Agent Memory)
  - Topics: Context Window Management, Long-term Memory, Compression/Summarization, RAG for Agents, Conversation History
  - Delivery: announce → rowlet Discord (1482363974119854234)

## Lessons Learned
- sessions_send is fire-and-forget, not a reliable mandate mechanism
- Heartbeat interval controlled by `heartbeat.every` in openclaw.json
- File locking (`flock`) required for safe Task Queue reads
- `needs_ceo_review` flag signals CEO to audit completed tasks
- **Heartbeat cron jobs are config-declared** (`declarationKey=heartbeat:<agent>`): `openclaw cron edit` is NOT the lever (CLI rejects `--cron`/`--timeout-seconds`/`--light-context` for heartbeat-kind jobs, and edits get reconciled away). The only working lever is `agents.entries.<agent>.heartbeat` (use `openclaw config set agents.entries.<agent>.heartbeat '<json>'`): add `isolatedSession` + `lightContext` to keep turns small/fast, and `activeHours` to skip known storm windows. Heartbeat turns also hit a hard **600s** cap regardless of `timeoutSeconds` in config. (verified 2026-11-19) <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Gateway event-loop starvation is not always fatal**: the 03:00 dreaming job starving the loop for ~32 min produced identical signatures on 11-17/11-18 (clients stuck in `startup-not-ready`, needed restart) and 11-19 (max timer delay only 18.7s vs 101.9s → clients self-recovered, no restart). Treat restart as the fallback for failed self-healing, not the default. (verified 2026-11-19) <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **A real provider 429 costs ~3 minutes of wall-clock, not seconds**: MiniMax rate-limit responses come back after `elapsedMs` ≈ 143,000–175,000 (measured 2026-11-22: 174461 / 142534 / 143243). The fallback chain cannot advance during that window, so a 429 inflates job duration by minutes and can push a job into its cron timeout. Leave ≥3 min of `timeoutSeconds` headroom and schedule the retry in the *next* slot, not the same one. Verify with `journalctl --user -u openclaw-gateway | grep 'status=429'` — that greps the provider-transport line, not job receipt text. <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **Check anchor stagger with `state.nextRunAtMs`, not with anchorMs**: two `every` jobs can carry anchorMs 40ms apart and still land inside the same millisecond window. On 2026-11-22 the three Keep-Alive jobs fired at 01:02:04 / 01:02:04 / 01:02:06 (2ms spread) and a real 429 landed in that window. Read `state.nextRunAtMs` from `openclaw automations list --all --json` to see the *actual* next fire time, then spread sibling jobs ≥3 min apart. <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「status=error」不等於「巡檢失敗」：先看 `cron runs --id` 的 diagnostics 再下結論（2026-11-23 13:02 實測）**。新的失敗型別是 **transcript-ownership（session-rebound）**：`Transcript session <uuid> is owned by agent:rowlet:cron:<jobId>, not agent:rowlet:cron:<jobId>:run:<uuid>; resolve the transcript target again before retrying.` → job 收尾記 error、ce=1，但**工作其實由 retry 接手完成**（本輪 13:02 attempt-1 error 158.6s → attempt-2 完整巡檢）。同一故障會同時打中兩處（本 job 的 attempt + 對方 lane 回送本 session 的 announce），並在 agent 端表現成 `missing tool result in session history; inserted synthetic error result`。判讀順序：① `openclaw cron runs --id <uuid>` 看 `diagnostics.entries[].message` ② 分辨 transcript 問題 vs provider 429 vs agent-runner-failure ③ 再看 dur 判斷是否降級跑。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **任何會 restart gateway 的 script 都必須先過 dreaming 守門（2026-11-23 13:15 實測）**：dreaming（`36b493db`）被砍的根因從來不是 dreaming 自己，而是**有人在它飛的時候重啟了 gateway**。本機共有 **3 條會 restart 的路徑**：`scripts/discord-selfheal.sh`（cron `d4cd45bc` 呼叫）、`scripts/gw-node-guard.sh`（手動，L42 主 restart + L50 rollback restart）、`scripts/apply-dreaming-schedule.sh`（手動，L32）→ **後兩支原本完全無守門**（07:02 輪只修了第一支）。✅ 已把同一支 `scripts/dreaming-running-check.py`（api / db / clock 三家族、fail closed、任何不確定都算 running）補進後兩支，且放在**任何檔案變更之前**；`DREAMING_CHECK` 做成可覆寫只為單元測試（stub checker 測 4 案：running→postpone、idle→照跑、checker 壞掉→postpone、checker 不存在→postpone）。**邊界**：gw-node-guard 的 rollback 路徑（健康檢查失敗才走）刻意**不**加守門 —— 閘道健康優先於 dreaming。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **量測 DNS 失敗要用 `getaddrinfo EAI_AGAIN`，不要用 `grep -c EAI_AGAIN`（2026-11-23 13:02 踩坑）**：後者會把 agent 自述裡的「EAI_AGAIN = 0」也算進去（本輪假陽性 10 筆，實際真實 DNS 失敗 0 筆）——這是既有那條「journal 簽章計數必須排除 `[agent:nested]` 行」教訓的具體實例。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Design Principle: Attention is the Scarce Resource (Linder 2026-06-18)
**Linder 一句話定調：「專注力是稀缺資源」** — 整個 Rowlet / OpenClaw / llm-wiki 的設計基準應該是 attention，不是 token / memory / compute。

### 具體意涵
- **CodeGraph 講 ↓57% token** = ↓57% attention budget（同一件事）
- **Harness Engineering 的「減法藝術」** = 少要求 agent 注意
- **Sutton Enactive AI 的「意向弧」** = agent 主動選擇把什麼帶入 working attention
- **Graphify-only workflow** = 不預載 wiki，因為預載 = 偷走 attention
- **HEARTBEAT-driven** = 每次 beat 重新定向，避免 attention drift

### 對 Rowlet 自身行為的約束
- 寫 wiki 條目 → 偏結構化查詢，**不偏自動摘要**（摘要丟中段關鍵假設）
- 回 Linder 訊息 → 短句優先，要擴充再問
- 設計任何 agent workflow → 問「這步要 agent 注意什麼？」比「這步耗多少 token？」重要
- 自己寫的 prompt / CLAUDE.md / SOUL.md → 100 行版本勝過 1000 行版本
- 「Less Is More」**不是風格選擇，是架構必要條件**

### 與既有 memory 的關係
- 與 `Risk and Consequence Principle`（永久安全邊界）互補：那條管「不該做什麼」，這條管「該少注意什麼」
- 與「YouTube Video Ingestion Pipeline」互補：完整入庫 ≠ 全部塞 context，而是分層儲存 + 按需查詢

## Design Principle: Training-Set Quality Generalizes (Linder 2026-06-19)
**Linder 一句話：「訓練集的好壞可以泛化」** — 來源 [https://alignment.openai.com/beneficial-rl/](https://alignment.openai.com/beneficial-rl/)

### 核心理念
- 一個 agent 的「訓練集」= 它運行時能讀到的一切：MEMORY.md / SOUL.md / AGENTS.md / 對話歷史 / daily memory / wiki / heartbeat state
- 這些素材的「品質」會泛化到 agent 在新任務上的表現
- Garbage in, garbage out — 在 runtime 也一樣成立

### 與「Attention is the Scarce Resource」的關係
- 「Attention is scarce」是**下游的觀察**：agent attention 不夠，導致輸出爛
- 「Training-set quality generalizes」是**上游的因**：因為 training 素材品質差，所以泛化出去才需要更多 attention 補救
- **實務意涵**：把 quality 控在 source，比後續的 attention 修復更有效

### 對 Rowlet 自身行為的約束
- 寫進 MEMORY.md 的東西要「值得泛化」— 結論 / 原則 / 結構，而非流水帳
- daily memory 是 raw，允許雜亂；但 daily → MEMORY 的提煉過程要狠
- wiki 條目寫完要能泛化（可重複 query 套用），不是一次性筆記
- 拒絕把「未消化的 context」當訓練素材保存（預載 wiki = 自動被當 training data）
- 每個 heartbeat 要驗證：這個 beat 學到的東西，配不配進 MEMORY.md？

### 與 RL/RLHF 的對應
- 對齊研究的核心問題：reward function / training signal 怎麼設計 → 決定 model 行為
- Rowlet 的對應問題：「什麼值得寫進 MEMORY」=「什麼是 reward signal」— 寫錯一次，會在未來 N 個任務上泛化放大
- OpenClaw 的 Risk and Consequence Principle 就是 runtime 版的「negative reward shaping」



## LLM Wiki Nickname: 大書庫
- Official name: llm-wiki
- Nickname: 大書庫（The Big Library）
- Location: `/home/amr/llm-wiki/`
- 存放所有知識、依賴圖、原始資料

## Wiki Discovery (graphify-first, no preload)
- **Primary** — graph layer: `/home/amr/llm-wiki/graphify-out/`
  - `GRAPH_REPORT.md` (clustered communities) is the first thing to read
  - `graph.json` for BFS / adjacency lookups
- **Secondary** — wiki pages (read only when graph points there): `/home/amr/llm-wiki/wiki/`
- **Last resort** — raw sources: `/home/amr/llm-wiki/raw/{code,sources,video,documents,images}/`
- **Query**: `/graphify query "<question>"` (or `cd /home/amr/llm-wiki && graphify query "<question>" --budget 800`)
- ⚠️ Do NOT scan `wiki/**/*.md` or `raw/**` at session start. Trust the precomputed graph.

## llm-wiki Graphify Linker (維護規則)
- **工具**：`/home/amr/llm-wiki/tools/add-wiki-pages-to-graphify.py`（repo 內確定性 linker；cron 指示的 `npx graphifyy link` **不存在**，那是 skill 安裝器）
- **用法**：改完 `wiki/` 後直接跑 `cd /home/amr/llm-wiki && python3 tools/add-wiki-pages-to-graphify.py` → 會重建全部 wiki page nodes + `[[wikilink]]` 邊
- **★ 坑（2026-11-21 踩到）**：linker 的 `LINK_PATTERN` 別名部分 `(?:\|[^\]]*)?` **不能跨過 `]`** → 條目別名裡若寫 `arXiv:2611.25123v1 [cs.CL, cs.AI]`，整條 `[[...]]` 會**靜默解析失敗**，該頁在 map 的入邊會消失（看起來像 link 沒生效）
  - **修法**：別名避免方括號 → 寫 `cs.CL/cs.AI`
  - **驗收**：每次新增 source 後查新節點的 incoming edge 數，**incoming = 0 就是 orphan**，必須從 concept／map 頁補 `[[sources/…]]` 入邊再重跑
- **GRAPH_REPORT.md** 需 `networkx`（本機未裝）→ 改完圖不會自動重生成，report header 會是舊快照
- **備份慣例**：跑之前 `cp graphify-out/graph.json /tmp/graph.json.pre-<slug>-<date>`

## Self-Reproduction Skill
- Created: 2026-06-16
- Location: `~/.openclaw/skills/rowlet-self-reproduction/`
- Contains: SKILL.md (initialization flow) + MEMORY_SNAPSHOT.md (complete memory)
- Purpose: Bootstrap new Rowlet sessions, recover from failures, clone Rowlet identity

## YouTube Video Ingestion Pipeline (Linder standing rule, 2026-06-17)
**Linder 說：「接到影片都要這樣處理」** — 任何時候接到 YouTube 連結，預設走完整入庫流程，不要只回應摘要。

### 標準流程
1. **下載音訊** — `yt-dlp -f 251` (webm, opus) → wav。sandbox 沒 pip，用 `curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp` 裝到 `~/.openclaw/local/bin/yt-dlp`
2. **抓 metadata** — 加 `--write-info-json --write-description` 拿 title/channel/uploader/upload_date/duration/view_count/like_count
3. **本機轉錄** — `~/.openclaw/local/bin/whispercpp-transcribe <wav>` (ggml-small.bin, zh, CPU-only, no flash-attn)。**不要**用 OpenAI Whisper API
4. **重組 raw 資料夾** — 沿用 convention：`raw/video/YYYY-MM-DD-<videoId>/` 含 `transcript.txt` / `metadata.md` / `metadata.json` / `description.txt` / `audio.wav`
5. **寫 wiki 條目** — `wiki/sources/<slug>.md` (source page, 帶 frontmatter)
6. **順手補 concept page** — 影片提到的新術語 / 專案 / 工具，沒 wiki 頁就建
7. **append log** — `wiki/log.md` 補一條 entry
8. **更新 daily memory** — `memory/YYYY-MM-DD.md` 補一筆

### 對應技能
- `youtube-whisper-transcript` — 下載+轉錄 SOP
- `llm-wiki-maintainer` — 寫入 wiki 的規則
- `youtube-deck-analyzer` / `video-frame-analyzer` — 需要抽 frame 細看時才用

### 注意事項
- `wiki/index.md` 之前被刪了（2026-06-14 raw-layer migration），不要浪費時間找，直接 append log
- yt-dlp 在 sandbox 沒 JS runtime 會跳 warning，但 android vr API 仍能成功 extract，可忽略
- 80MB wav 是 wav 格式的代價，保留供重轉/重分析，不要刪
- 影片類型不限（AI 工程 / 哲學 / 演講 / 教學）— 統一流程，差異只在 concept page 的術語抽取

## Agent Builder Researcher Skill（2026-06-23）
- 新增 skill：`~/.openclaw/skills/agent-builder-researcher/SKILL.md`
- 研究「製作agent的agent」— agent-builder, agent-factory, meta-agent, agent-forge 等
- 整合進既有的「每日 Agent × 軟體開發潮流研究」cron（ID: a72cb46b）
- 輸出：`wiki/sources/agent-builder-daily-YYYY-MM-DD.md`
- 搜尋關鍵字：agent-builder, agent-factory, agent-forge, meta-agent, auto-agent, agent-generator

## Standing Rules (Linder 2026-06-25)
- **Cron Job Data Archive Rule**: 所有 cron job 找到的資料都必須歸檔到 llm-wiki（`wiki/sources/` 或相關 concept 頁），不得停留在 session context 就消失
- **逐字稿檢查 Rule**: 每次 agent run（session 啟動/heartbeat）檢查 `/home/amr/llm-wiki/raw/video/*/metadata.json`，若 `transcription_status: "in_progress"` 但 PID 不存在了，自動完成後續入庫（寫 wiki、存 MEMORY）

## Sakana Fugu / TRINITY / Conductor 研究（2026-06-25）

### Sakana AI 公司背景（2026-06-28 新增）
- **創辦人**：David Ha（Google Brain → Stability AI）+ Llion Jones（Transformer 論文八位作者之一）
- **為何在日本**：資源受限 + 可自由使用中美模型不受出口管制
- **哲學**：不做更大模型，用集體智慧組合模型能力

### Sakana Fugu 兩種模型
| 模型 | 定位 | 運作方式 |
|------|------|---------|
| Fugu | 簡單任務 | 從池子裡挑一個模型 |
| Fugu Ultra | 複雜任務 | Opus 4.8 + GPT 5.5 + Gemini 3.1 Pro 三模型協作 |

### Conductor 工作流程包含三件事（2026-06-28 新增）
1. **Subtask 任務清單** — 把請求拆成小的子任務
2. **Worker 分配** — 每個子任務交給哪個模型
3. **Context Access** — 每個子任務模型可以看到前面哪些步驟的答案

### 三篇論文
| 論文 | arXiv | 會議 |
|------|-------|------|
| Sakana Fugu Technical Report | 2606.21228 | arXiv only（無 peer review）|
| TRINITY | 2512.04695 | ICLR 2026 |
| Conductor | 2512.04388 | ICLR 2026 |

### 核心架構差異
| 產品/論文 | 協調方式 | 輸出 |
|---|---|---|
| Fugu（快速版）| Selection Head（向量路由）| Logit 矩陣，不經自然語言 |
| Fugu-Ultra/Conductor | 自然語言 workflow | 文字描述的協作步驟 |
| TRINITY | CMA-ES 訓練的 coordinator | 0.6B coordinator + ~10K Selection Head |

### 三種角色（TRINITY 提出）
- Thinker（規劃）、Worker（執行）、Verifier（驗證）
- 動態分配，不固定三個模型

### Conductor 遞迴拓撲
- Conductor 可以叫自己當 Worker，產生遞迴規劃
- 動態測試時擴展：越難的任務迭代越多

### 論文弱点（Linder 指出）
1. **沒有對齊 Worker LLM 版本**：聲稱打敗 prior multi-agent baselines，但沒有控制「Worker 模型版本」變數
2. **缺少 ablation study**：沒有實驗证明是「協調策略」在起作用，而非「模型進步」的紅利
3. **對比的 baseline（2023-2025）**：用 2026 年的頂級 Worker 模型，比 2023-2025 年較弱系統的分數
4. **Fugu Technical Report 是 arXiv only**：非正式發表，claims 未經 peer review

### 真正的創新點
- **Selection Head = 向量路由**（Fugu 的核心）— 不經自然語言解碼，低延遲
- **Conductor 的遞迴拓撲** — 新測試時擴展軸
- **CMA-ES 訓練**（TRINITY）— 在高維度/預算限制下優於 RL

### 與 OpenClaw 的關聯
- OpenClaw 是發號施令型協調者（直接 tool call）
- Conductor/Fugu 是寫劇本型協調者（輸出描述讓別人執行）
- 真正的 Agent = LLM + 框架 + **行動**（非只有輸出描述）

## Standing Rules（每次 Agent Run 必做）
- **檢查待處理逐字稿**：每次 session 啟動/heartbeat 檢查 `/home/amr/llm-wiki/raw/video/*/metadata.json`，若 `transcription_status: "in_progress"` 但 PID 不存在了（轉錄完成），自動完成後續入庫流程（寫 wiki、存 MEMORY）

## Pending / Follow-ups
- Download TopoClaw + MetaCogAgent papers to wiki
- Update HEARTBEAT.md for other agents (charizard, gengar, etc.) with Shared Memory integration
- Investigate TopoClaw / OpenClaw naming similarity
- Episodic memory gap: only `2026-05.jsonl` exists; Jun-Jul 2026 events not archived
- ELLE_WS repos/ code 待到位，Phase 3 graphify extraction 為 blocker

## ELLE_WS Wiki Project（2026-06-23）
- **Task**: task_20260623_elle_04_wiki_draft（✅ 已結案，CEO 審核通過）
- **Location**: `/home/amr/.openclaw/workspace/elle_ws/`（Ouroboros Trivium v2.4 格式）
- **產出**：
  - `raw/` — 2 evidence files（mrmime 規劃 + charizard 研究）
  - `wiki/entities/` — 5 repos 各一頁（bringup/functions/hardware/simulations/tools）
  - `wiki/concepts/` — 5 概念頁（architecture-overview / amr-plugin-consolidation / launch-architecture-refactor / adr-mechanism / package-granularity）
  - `wiki/patterns/` — 2 問題頁（nav2-plugin-drift / package-xml-todo）
  - `wiki/index.md` + `wiki/SCHEMA.md`
- **Blocker**: 待 actual code 填入 repos/ 後執行 Phase 3（graphify extraction）
- **charizard 研究發現整合**：P1 Nav2 plugin 重複設計 / P2 hardware/ 粒度錯誤 / P3 package.xml TODO / P9 缺少 ADR 機制

## Sensor Fusion Daily Research (task_20260609_001, ongoing)
- CEO assigned daily research task covering IMU/Camera/LiDAR fusion topics
- Location: `~/.openclaw/shared-memory/sensor-fusion/daily/YYYY-MM-DD.md`
- Topics covered so far:
  - 6/9: Initial study
  - 6/16: Unknown (by other session)
  - 6/17-6/18: (by other sessions)
  - 6/21: LiDAR + Camera Fusion — Early/Late/Middle Fusion, PointPainting/PointAugmenting/DeepFusion, ROS2 calibration
  - 6/22 AM: IMU + Camera Fusion (VIO/VI-SLAM) — MSCKF vs VINS-Mono, Bongarella IMU Preintegration, Kalibr, Allan Variance
  - 6/22 PM: ROS2 Fusion Packages — message_filters/ApproximateTimePolicy, sensor_filters, robot_localization EKF, rtabmap_ros
  - 6/22 PM: EKF/UKF Math — state space model, Kalman gain intuition, Sigma Points (UKF), Q/R tuning, Allan Variance
  - 6/23: Time Sync — PTP/gPTP (±100ns), PPS (±50ns), Hardware Trigger, Software sync limits (50-200ms latency), ROS2 clock settings
  - 6/23b: Factor Graph SLAM — iSAM/GTSAM vs EKF/UKF、增量優化、Factor Graph 在 SLAM 中的優勢
  - 6/23c: 人形機器人傳感器融合 — Boston Dynamics Atlas（液壓/ZMP）、Tesla Optimus（Vision-First）、姿態控制與接觸檢測
  - 6/23d: Edge AI for Robotics — Jetson AGX Orin、Edge TPU、Isaac ROS、邊緣端調度優先級
  - 6/23e: Sensor Fusion Safety — CRC-32 校驗、序列號連續性、IMU Range Check、Innovation 卡方檢驗、降級策略 L0→L4、ISO 26262 ASIL 等級
  - 6/23f: Multi-Robot Collaborative SLAM — 中央式 vs 分散式架構、DBoW2/ICP/submap 地圖融合、OctoMap 頻寬優化、DARPA SubT 案例
  - 6/23e（another agent）: Bio-inspired Sensor Fusion — 奧運報告（另一 agent 整理上報）
  - 6/24: GNSS/RTK + Sensor Fusion — RTK/PPP-RTK/PPP 比較、Loose/Tight/Ultra-Tight 耦合、城市 NLOS 解決方案、ROS2 EKF 設定
- Next: 繼續每日 topic 或等 CEO 指定新方向

## OpenClaw Memory Architecture — 3-Tier Pattern (Zac Frulloni, 2026-06-20)
**來源**：`[[wiki/sources/openclaw-memory-plugins-tier-list-youtube]]` — 直接命中 Rowlet 自身架構

### 三層架構
1. **Tier 1 (Human layer)**: Obsidian markdown — 人可讀、可編輯的 agent 思考日誌
2. **Tier 2 (Search layer)**: QMD — Hybrid BM25 + Ollama embedding + MMR + temporal decay
3. **Tier 3 (Structured layer)**: SQLite — 零 hallucination 事實查詢

加 **Dream Cycle** — 凌晨 nightly consolidate daily logs / compress memory / reindex QMD。

### Rowlet 架構 gap (重要)
| 層 | Rowlet 現狀 | 缺口 |
|----|-----------|------|
| Tier 1 | ✅ MEMORY.md + wiki/ + memory/YYYY-MM-DD.md | 無 |
| Tier 2 | ⚠️ 只有 Graphify (graph-based) | **缺 BM25+vector hybrid search** |
| Tier 3 | ⚠️ 有 SQLite (CodeGraph DB) 但未整合 | **需結構化 query 介面** |
| Dream Cycle | ❌ | **需加 nightly cron job** |
| Temporal decay | ❌ daily memory 同等權重 | **需半衰期排序** |
| MMR dedup | ❌ graphify query 不去重 | **需結果多樣化** |

### 關鍵詞 (for future query)
- **Token Bloat Trap** — 純 markdown 全文載入的致命成本
- **Core rules survive compaction** — SOUL.md / AGENTS.md 即使 compact 仍在（這就是為什麼 Rule Layer 設計成 markdown 而非 prompt）
- **MMR** — Maximal Marginal Relevance，多樣化檢索
- **Hybrid Search** — BM25 (精確) + Vector (語意) 組合
- **6 個方案 tier list**：C(原生 markdown) / B(MemZero) / A(LanceDB / KG / SQLite) / S(QMD)

## NemoClaw 水位線監控設計決策（2026-07-02）
- **水位線監控嚴禁放在 Worker 行程內部** — Worker 可被 evict，狀態會丟失
- 正確位置：NemoClaw 沙盒層（具備 process 監控能力）
- 好處：隔離重啟、狀態不丟、不被 Worker panic 影響
- 等待設備到位後通知 Charizard 實作時注意此點

## 2026-08-11 Open-Source Agent Stack Trilogy

- **OpenClaw 已被 Meta Muse Glimmer 30B model card 寫入「Scaffold Compatibility」section**（與 Hermes Agent 並列）—— 從內部架構升級為 vendor 級識別的 scaffold
- 開源三軸同週落地：Model (Meta Muse Glimmer 30B) + Edge (Cactus Needle 2 14MB) + Graph-governance (semantica-agi) + Skill standard (addyosmani) + RLM self-improving (PrimeAgent)
- Skill standard 進入搶位時間（24h 內應起草 skill-archive-v1）
- graphify KM-only → governance-grade 是真實 gap（看 semantica +970/day）
- 三層 fallback chain：Needle 2 (45M local) → Muse Glimmer (30B local) → Cloud frontier

## CompactionRL 入庫 (2026-06-20)
- roaringmoon 交辨：arXiv:2607.05378, Li et al., KDD 2026
- PDF + metadata → `raw/references/papers/ai/2607-compactionrl/`
- Wiki source → `wiki/sources/compactionrl-2026-li.md`（含 reading notes）
- Graph: 27 nodes, 26 edges 已 merge（9448 nodes 總計）
- **Core insight**: summarization = learnable RL action, token-level PPO advantage（比 GRPO 更精細）
- **對 OpenClaw 的意義**: heartbeat = RL step，token-level advantage 可追蹤哪些 action 真正減少下次觸發的 context length
- **graphify query**: 51 nodes found，Community 0(core mechanism)/1(optimization)/2(related systems)
- Graph 有 node count bug（cluster-only 報 8648 vs 9448），暫不處理

## 蒸餾層的權威性陷阱（2026-10-31 新增）

來源：arXiv:2610.26836 *Same Simulation, Different Evidence*（UC Riverside + UC Irvine）。

- **Evidence substitution**：當 harness 把長輸出搬出 context 讓 agent 檢索取用時，agent 會**改用自己寫的輸出**取代工具的權威輸出，精度更高但需要四捨五入，常被**截斷** → 答錯。實測 GPT-5.2 有 **60.3%**、GPT-5.1 **53.0%** 的 trajectory 沒讀到權威 report。
- **對應到我的系統**：`MEMORY.md` / daily note 這些**蒸餾層**就是那個「沒被指名的權威來源」。agent 若讀蒸餾筆記而非 raw row，**蒸餾層會自我強化成事實來源**。
  → **規則**：harness 指令層必須明確寫出「**權威來源是 raw row，不是蒸餾筆記**」，並在蒸餾筆記保留指回 raw 的 pointer。
  （機制化版本 = [[eywa-provenance-grounded-long-term-memory|Eywa]] 的 Tier-0 immutable evidence + signal-anchored promotion。）
- **教方法不如指名來源**：只教「要四捨五入」完全無效（沒換 source，只換做法）；指名「哪一份輸出是權威」才有效（+6.3~+7.9 pp）。
- **淨值 ≈ 0 不等於無害**：GPT-5.4 的 build +4.1 pp 抵銷了 closure −7.2 pp → 評估 context 管理**必須分階段報告**（build / exposure / closure），不能只看 final accuracy。
- **Hybrid 是 safe default**：塞得下就內聯（不需知道工具語意、不需額外指令、還更省 token）；**檢索應是容量不足時的 fallback，不是預設路徑**。
- **可攜 protocol**：配對重播——checkpoint 取在「執行結果進模型之前」，兩臂共用檔案/prompt/history/預算，唯一差異是交付方式 → 可驗證任何「要不要把這個輸出放進 context」的決策。

## Promoted From Short-Term Memory (2026-11-18)

<!-- openclaw-memory-promotion:memory:memory/2026-11-16.md:33:41 -->
- ## Gengar Keep-Alive 巡檢（cron 9d8b6001，11:38 台北）— 同一支 Picturecat 那節的姊妹篇 [score=0.852 signals=3 recalls=3 avg=1.000 source=memory/2026-11-16.md:33-34] <!-- trigger: gpt, openai, keep-alive --> <!-- importance: 9 --> <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
<!-- openclaw-memory-promotion:memory:memory/2026-11-16.md:1:16 -->
- # 2026-11-16（週一） ## Picturecat Keep-Alive 巡檢（cron 02eb0989，11:38 台北） [score=0.847 signals=3 recalls=3 avg=1.000 source=memory/2026-11-16.md:1-4] <!-- trigger: gateway, keep-alive, v2026.8.2 --> <!-- importance: 8 --> <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
<!-- openclaw-memory-promotion:memory:memory/2026-11-16.md:22:37 -->
- ### 為什麼不改成「把 openai-codex 加進 allow」 - mrmime 2026-11-15 實測：`openai-codex/gpt-5.5` 打到 `https://api.openai.com/v1/responses` 且用 sentinel key `openai-oauth` → **HTTP 401 invalid_api_key**；自建 `chatgpt-codex` provider 也接不上。放行也不會成功，改用 minimax 才是有效解。 - 但「要不要把 codex 這條路真的修通」是全域 policy / provider 層級的決定 → 留給 Linder，不在 unattended run 裡自行放寬 modelPolicy。 ### 給 Linder 的待決事項 1. MiniMax Token Plan 額度今日 07:00 前後見底（429），若要穩定跑 07:00 晨間批次，需確認額度或加 fallback provider。 2. `openai-codex` provider 端點錯誤（401）是否要修 provider 設定。 3.... [score=0.847 signals=3 recalls=3 avg=1.000 source=memory/2026-11-16.md:22-37] <!-- trigger: gpt, openai, openai-codex --> <!-- importance: 8 --> <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 03:00 槽雙重負載（2026-11-18 13:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **03:00 台北有兩支 30 分鐘級 agentTurn job 同時起跑**：`36b493db` Memory Dreaming Promotion（`0 3 * * *` tz=None=gateway local、`timeoutSeconds=None`、`toolsAllow=["*"]`、declarationKey `memory-core:memory-dreaming-promotion`）＋ `40e09cd1` Jormungand daily all-agent health（`0 3 * * *` tz=Asia/Taipei）。今日 03:00 實測：dreaming 跑 30.1 分鐘（ok），Jormungand 30.1 分鐘 timeout（ce=5），期間 03:02:50 八個 Discord client 同批 close → inbound 瞎約 59 分鐘（04:44 重啟後恢復）。
  → **只搬走 dreaming 只減半負載**；兩支都要錯開。且 dreaming 屬 plugin-declared job，CLI 改可能被 declaration reconciliation 還原 → 治本在 memory-core plugin。
- **Discord runtime 的判準是 `channels status` + journal，不是 agent 自述**：agent 會回「Discord inbound working: yes」但那只代表 delivery context 物件存在，不代表 WS READY。判讀用 `READY wait timed out` 筆數（2026-11-18：重啟前 2023 筆、重啟後 0 筆）。
- **「prepared model runtime plugin generation was superseded」會在多支 agentTurn job 同分鐘起跑時出現**（durationMs=6 瞬間死），已從 gengar/picturecat/mrmime 蔓延到 **rowlet lane**（2026-11-18 13:00 起 rowlet nested+session 各 2 筆）。
- 本 job（cron `02eb0989`）fallback 鏈 4 個候選**全屬同一 MiniMax Token Plan** → 跨廠冗餘恆為 0；429 時四個一起死，紅單佔 fleet 紅單的 18/20。
- ⭐⭐ **MiniMax Token Plan 配額枯竭＝每日準時發生的 4 小時窗口（2026-11-19 13:02 四天實測）**：真簽章是 `Token Plan usage limit reached`（MiniMax code 2056），**不是只有 `status=429`**——前幾輪只數 429 次數，把它誤讀成「每小時 1–2 筆的滲漏」，其實是 100–230 筆/小時的尖峰。逐時實測：11-16 05–07/12–13/16–17/20–22、11-17 01–03、11-18 09–12（另 07、16–17）、11-19 **09–12**；11-19 窗口內 463 筆 Token Plan 429 + 36 筆 `All models failed`，**13:00 歸零後 KA 三支全部恢復**。影響面＝**cron lane 全滅、使用者面無恙**（窗口內 463 筆全無 session 屬性、唯一 `agent:*:main` 筆是 probe；ingress 近 3h 150 筆全 completed）。→ **每天 09:00–13:00 內排的 job 結構性撞限**：`a72cb46b`（`0 10 * * *`）ce 已 8，再 2 次自動停用，且它每天都落在窗內。修法＝(a) 把窗內 job 移到 14:00 後 (b) 補非 MiniMax provider 的 fallback（現在 4 個 fallback 全 MiniMax，跨廠冗餘 0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「每日 09:00–13:00 單窗」模型不完整：一天可能有兩個尖峰（2026-11-19 19:02 實測）**。逐時 Token Plan 429：11-19 **09–12（102/172/88/101＝463 筆）→ 13–15 乾淨（0 筆）→ 16–17（193/111＝304 筆）→ 18:00 歸零、19:02 恢復正常**。歷史對照 11-16（16–17、20–22）、11-18（16–17）→ **午後/晚間峰會反覆出現**。→ 排避時段不能只避開 09:00–13:00。⚠️ **11-21 實測修正：19:00 之後並不保證安全**（18:00 槽 2 筆、21:00 槽 2 筆真 429，`overloaded_error` "server is busy"，回應延遲 73–165 秒＝上游排隊後才拒收；21:00 那兩筆落在 cron `911eee45` 每日資安建議、靠 same-model retry 2/3 救回）→ **排避要覆蓋整天尖峰（09–13 + 16–18 + 20–22），並靠同模型重試 + 跨廠 fallback 兜底**。另註：11-21 全天 `Token Plan usage limit reached` = 0 筆，晚間中的是**通用 rate-limit**（非配額上限），兩者要分開判讀。午後窗的受害者（全部 rate_limit）：`02eb0989` Picturecat KA 16:06–16:13 ce=4、`880b5c17` Celesteela KA 16:07 ce=2、`13ac4b5a` 健康回報 17:12 ce=4。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 溯源與「是不是人在講話」的判讀（2026-11-21 22:02 實測）**：journal 的 `[discord] embedded run agent end` 只代表**該 run 的投遞通道是 Discord**，不代表有人在 Discord 講話（11-21 21:01/21:03 的兩筆 429 最後綁回 cron `911eee45` 每日資安建議，靠 same-model retry 2/3 救回）。→ **溯源錨點＝下一行的 `[cron:<uuid>] … :run:<runId>`**，用它把 runId 對回 job；「誰受影響」不能只看 channel 標籤。另註：`openclaw cron list --all --json` 的時間欄位在 **`state.lastRunAtMs`**（`state.lastRunAt`/`nextRunAt`/`lastErrorReason` 常為 null），紅單掃描＝`state.lastRunStatus` + `state.consecutiveErrors` + `state.lastDurationMs`，且**必須含 disabled jobs**（舊痕跡會混進紅單）；本機 `sqlite3` CLI 不存在，`channel_ingress_events` 只能靠 `openclaw channels status` 的 in/out 新鮮度替代。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **state DB 唯讀查詢被 exec guard 擋（2026-11-19 19:02）**：`sqlite3` 對 `~/.openclaw/state/openclaw.sqlite` 與**任何副本**（複製到 `/tmp`、`~/ka-check/` 都試過）一律被拒：`external sqlite3 cannot open databases under the active OpenClaw state directory…` → guard 認內容／身分而非路徑。影響＝巡檢無法查 `channel_ingress_events`（inbound 真流量）與 `cron_run_receipts`；替代證據用 Discord 層（`openclaw channels status` 的 in:/out: 新鮮度 + journal 的 websocket/READY 簽章組）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`openclaw cron runs` 的 `ts` 是「結束時間」不是開始時間**（2026-11-19 19:02 實測）：`40e09cd1` 11-18 19:34 UTC + dur 2,065,675ms → 實際 03:00 TPE 起跑；算起跑時間要減掉 duration，否則會誤判「這支 job 不在它的 cron 槽內跑」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **03:00 槽現在有兩個彼此獨立的失敗原因**（2026-11-19 13:02）：除了 dreaming 的 event-loop 阻塞，03:00 在配額史上也被打到過（11-16T03 55 筆、11-17 01–03 共 279 筆 Token Plan 429）→ 同一槽可能整段被配額卡死。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **`openclaw cron runs --id` 只接受完整 UUID**（短 id 會回 `Automation not found`）；而且 **`entries[].cause`（rate_limit / timeout / agent-runner-failure）才是紅單根因**，`state.lastRunStatus` 只有 ok/error。`cron_run_receipts` 表可唯讀驗證某輪是否真跑完（status=running/ok/failed）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **量測 event-loop starvation 的假陽性陷阱（2026-11-19 01:02 實踩）**：`grep -c "starvation"` / `grep -c "event[- ]loop"` 會命中**上一輪 agent 報告的內文**（[agent:nested] session 行裡的報告句），把假陽性當成 runtime 事件。✅ 正確 runtime 簽章＝`[fetch-timeout] … timer delayed Nms, likely event-loop starvation`。用正確簽章重算：2026-11-19 01:02 近 3h = 0、近 24h = 26（全部在 11-18 03:00–03:30 dreaming 區間）、max timer delayed = 101,948ms。
- ⭐ **「必須重啟 gateway」是過度結論（2026-11-19 04:02 實測修正）**：11-19 03:00 dreaming 第 3 晚重演（dur=1,922,307ms=32 分鐘、starvation 16 筆、max timer delayed **18,749ms**、READY timeout 33 筆、websocket closed 69 行），但 **`startup-not-ready` = 0 筆** → 03:31–03:32 client 自行 `client initialized` / `channels resolved`，gateway 全程未重啟（pid 2724303、23h18m、NRestarts=0），8/8 帳號 04:02 全 connected，ingress 近 400 筆全 completed。→ **重啟應降級為「自癒失敗時的後備手段」**；starvation 輕（18.7s vs 11-18 的 101.9s）時可自癒。但**根因（dreaming 在 gateway 自己的 event loop 內跑 32 分鐘）不變**，症狀輕重隨機。
- ⭐⭐ **內建 health watchdog 有「host thaw → channel restart」機制，2026-11-19 04:19:53 實證它真的會動**（修正 04:02 輪「完全自癒」的說法）：watchdog 每 30 秒噴一次 `[health] host thaw channel restart deferred: gateway still has active work`（04:13–04:19 共 13 筆，被 dreaming 那 32 分鐘的工作擋住）→ **04:19:53 一次做完**：8 個 Discord 帳號依序 `delaying provider startup 10s/20s/…/70s to reduce Discord startup rate limits` → 每 10 秒一個 `client initialized` + `channels resolved` → **04:21:04 全部 8/8 connected**，而 **gateway 全程未重啟**（pid 2724303、26h20m、NRestarts=0）。→ 對 `d4cd45bc` 的啟用決策有直接影響：**內建機制能重啟 channel 層（比整個 gateway 重啟輕），建議 d4cd45bc 降為「watchdog 還在等／等到天亮」時的後備**。判讀 Discord 斷線要看「host thaw / client initialized / channels resolved / READY timeout / channel exited」**整組簽章**，只看 `channels status` 會誤判沒事。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「host timing gap detected: process was frozen ~Nms」＝ gateway 自己的 admission suspend，不是 OS 層 freeze（2026-11-22 07:02 釐清，dreaming 04:25 槽的第 3 代根因）**：判讀時先看同一時點有沒有 **`[admission] closed: suspend phase` / `reopened: suspend phase`** —— 有的話就是 dreaming 的 admission 暫停被 watchdog 記成「frozen」（本輪 6 次：04:27:55 158s／04:34:11 280s／04:39:58 207s／04:45:59 265s／04:49:48 131s／04:53:57 150s）。**排除法**：無 systemd suspend/resume、無 PM: suspend、真實 DNS（EAI_AGAIN/getaddrinfo）失敗 = 0。→ **殺死 Discord 的不是 starvation 幅度，而是 suspend 期間 Discord client 的 30s READY 握手期限先到期**（`gateway opened but did not reach READY within 30000ms` → `channel exited` 14 筆 → auto-restart 1/10 → `delaying provider startup 10–70s` 21 筆避開 Discord startup rate limit → 04:57 全數恢復，gateway 本身未重啟）。**可重現性**：近 7 天每天固定 6 次（11-15:7／11-16:6／11-17:6／11-18:6／11-19:6／11-20:2／11-21:6／11-22:6），全部落在 dreaming 04:25 槽 → **結構性每日事件，非偶發**。判讀「Discord 是否失明」時請把這種**可自癒的 04:25–04:57 重連風暴**與真正的 outage（11-21 那次 DNS 全滅、READY 全滅 0 次成功）分開看：**前者有 `client initialized`/`channels resolved` 收尾且 8/8 connected，後者沒有**。修法（待 Linder 決定，不在 unattended 輪次自行變更）：(a) 把 Discord READY 握手上限拉高到 ≥300s，或 (b) 讓 dreaming 的 admission suspend 不中斷既有連線的 READY deadline。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`[agents/harness] Codex agent harness failed; not falling back to embedded OpenClaw backend`**（2026-11-19 03h=2、04h=2）：`lane task error: lane=main|cron-nested durationMs=24–52 "Codex agent harness cannot enforce this conversation's tool policy. Use the embedded runtime or ask in the main conversation."` → 瞬間失敗、良性，但代表 **Codex 這條路徑仍不可用**（呼應 11-16 的 openai-codex 401）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **8 支 heartbeat 的 600s timeout 是 03:00 斷線的下游症狀，不是 provider 問題**（2026-11-19 04:02 實測）：`dur=600004ms`（cron 預設上限）+ `lastErrorReason=timeout` + job 層 `sessionTarget=main` → Discord 掛掉時 main lane 等不到回應就整整卡 600 秒，8 支（mrmime/rowlet/celesteela/charizard/greninja/picturecat/roaringmoon/gengar）同時轉紅。修法＝job 層改 `sessionTarget=isolated` 或照 charizard 加 `target:"none"`。
- **restricted automation-run session 中 `automations list/get` 對本 job 回 not found／空清單**（已知工具限制，非故障）→ 巡檢一律用 `openclaw cron list --all --json` 與 `openclaw cron runs --id <id>` 唯讀彙總；其 `state.lastDurationMs` / `state.lastRunAtMs` 才是權威欄位（頂層同名欄位可能為 null）。
- **`channel_ingress_events` 是驗 inbound 的權威來源**：DB = `~/.openclaw/state/openclaw.sqlite`，唯讀查詢須連 `-wal`/`-shm` 一起複製再查；**沒有 `created_at` 欄，用 `received_at`（epoch ms）**；journal 的 `message processed` 只會出現 `channel=cron`，Discord 使用者訊息不在那裡（別誤判成 inbound 全黑）。
- **自愈機制已備妥但仍需人點頭**：`d4cd45bc discord-selfheal-after-dreaming`（sched `35,50 3,4 * * *` tz=Asia/Taipei、payload kind=command、60s）守門良好——只在 `channels status` 出現 `startup-not-ready` **且** dreaming job 未 running 時才 `systemd-run --user --on-active=10s systemctl --user restart openclaw-gateway`；由 rowlet 於 2026-11-18 04:2x 主動停用等 Linder 核准，`openclaw cron enable d4cd45bc-357d-42d4-9ba1-f7eb39e02f59` 即可啟用（第一個生效時點＝ dreaming 結束後的 03:35）。
- ⭐⭐ **Node 版本是「systemd 單元釘死」的，不是跟 shell PATH 走**（2026-11-19 21:00 實測）：`~/.config/systemd/user/openclaw-gateway.service` 與 `jormungandr-openclaw-bridge.service` 的 `ExecStart` 直接寫死 `/home/amr/.nvm/versions/node/v24.22.1/bin/node` → 即使 shell 已是 v24.22.3，**兩個長駐服務仍跑舊版**（2026-11-11 的 Node 安全版含 11 筆 http2/tls High CVE 全數未生效）。✅ 修法＝改單元的 `ExecStart` **node 路徑**即可、**不要**搬 openclaw 套件安裝位置（仍在 v24.22.1/lib/node_modules）→ 單元改完 `systemctl --user daemon-reload` 即生效，下次重啟自動套用。⚠️ **bridge 可安全立即重啟**（401 驗證可復驗）；**gateway 不要隨手重啟**（MEMORY 既載：重啟會讓 8 個 Discord client 依序 10–70s 重建連線、衝 cron lane）→ 與升級/低峰窗口一起做。✅ **【2026-11-23 01:02 複驗：此條已過期】兩個單元 mtime＝2026-11-19 21:13:09，當晚即改為 `node v24.22.3`（gateway 與 bridge 皆是，套件仍在 v24.22.1/lib/node_modules）→ gateway 自 11-21 02:11 重啟後**實際跑新版**（`ps` 實測二進位 = v24.22.3）→ 11 月 CVE 修補已生效，舊版風險敘述不再適用。**「gateway 不要隨手重啟」的前提仍然有效**（Discord 重建風暴未變）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`openclaw security audit --deep` 的 5 個 critical 全是 `skills.code_safety` 樣式誤判（2026-11-19 逐一讀原行驗偽）**：`hung-yi-lee:651`=研究主題清單含「system prompt」字樣、`openclaw-docs:279`=官方 `curl … install.sh | bash` 安裝文件、`openclaw-security-scanner:48`=prompt-injection 防護功能說明、`ptcgp:212`=合法 `execSync` 範例、`skill-guard:34`=風險偵測規則表。→ **判定技巧：`skills.code_safety` 的 critical 一律先讀該行原文再下結論**，不要照著 remediation 把 skill 刪掉；真正要處理的是 warn 層（`tools.exec.mode=full`、`applyPatch.workspaceOnly=false`、`tools.elevated`、`channels.discord.allowlisted_groups.broad_members`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **本機 npm audit 要對「installed 樹」與「目標版樹」各跑一次才有意義**（2026-11-19）：installed openclaw 2026.8.2 = **zod 4.4.3 < 4.6.6（High，oversized constrained collections 記憶體耗盡）+ undici 8.10.0（8 筆 High，含 TLS 憑證驗證繞過 GHSA-2m5v-pch6-74hx、跨使用者資訊洩漏 GHSA-4w7w-5xrc-9h26）**；`npm i --package-lock-only` 目標版 2026.11.5 樹 = **zod 告警消失**（只剩 npm 自帶的 undici ≤6.29.0，非執行期路徑）→ 這就是「升級可解」的證據。⚠️ 全域套件目錄**沒有 lockfile**，`npm audit` 會直接 ENOLOCK，必須在 /tmp 建暫存目錄用 `npm i --package-lock-only --ignore-scripts` 生 lock 再 audit。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **每日資安 cron 的做法已定型**：KEV 用 `curl https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json` 直接解析（catalogVersion + dateAdded ≥ 最近 7 天 + dueDate），比讀新聞快且準；`web_fetch` 的 thehackernews.com 會 403、CISA alert 頁 HTML 是導覽雜訊 → 改用 JSON feed。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **升級管道兩條**：① `openclaw` 系統專家（提案需人工核准；限制：它讀不到 cron job 定義與提案佇列，且 gateway 一次只能 stage 一個操作——有殘留提案佔槽時所有新提案會被 `proposal-conflict` 擋下）；② Discord REST outbound（WS inbound 死時仍可用）→ 一律貼 channel `1482363974119854234`，rowlet 帳號。
- ⭐⭐ **selfheal 守門只認 `startup-not-ready`、認不出 `disconnected`（2026-11-21 07:04 實測反證）**：`scripts/discord-selfheal.sh` L48 的判斷是 `channels status | grep -q "startup-not-ready"`。11-21 04:35–04:59 那波 Discord 不穩（health-monitor 因 `disconnected` 重啟 5 個 channel、READY timeout ~44 筆、1 筆 reconnect-exhausted）**全程 gateway journal 的 `startup-not-ready` = 0 筆** → 04:43 那輪 selfheal 回「discord healthy - no action」＝**啞火**。該波是靠 **gateway 內建 health-monitor（channel 層重啟）+ reconnect backoff** 在 19 分鐘內自癒（04:58 `delaying provider startup 40s–70s` → 04:59 client initialized），**不是** selfheal 救的。→ 判讀「Discord 是否真的失明」要看整組簽章（health-monitor restarting / READY timeout / reconnect-exhausted / client initialized），**只看 `channels status` 會誤判沒事**；同理 selfheal 的觸發條件目前只覆蓋「卡死在 startup-not-ready」一種症狀。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 尖峰時段表要加「清晨 05–07 點」（2026-11-21 07:04 實測）**：既載尖峰窗為 09:00–13:00（主）＋午後/晚間（16–17、20–22），11-21 實測在 **05:01、05:04、05:32、06:02、07:01、07:03、07:04** 也出現 `provider=minimax-portal api=anthropic-messages status=429`（8h 共 9 筆），成因＝**07:00 槽 4 支 job 同時起跑**（BBC News / 每日論文 / heartbeat-mrmime / 三支 KA 交錯）的併發尖峰，**不是** `Token Plan usage limit reached`（近 8h = 0 筆，連續第 3 輪零配額窗）→ 排避時段建議再加「05–07 點輕載」，且**併發槽比配額窗更可能是當日紅單主因**。同模型 retry 機制正常接管（`rate-limit same-model retry 1/3` delayMs=10000 → 2/3 delayMs=20000）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **429 尖峰的正確模型是「整點槽併發數」，不是「時段」（2026-11-21 10:02 實測，取代既有時段表）**：近 4h 429 = 6 筆、**全是 `overloaded_error`（server busy）、`Token Plan usage limit reached` = 0 筆（連續第 4 輪零配額窗）** → 分布 **07h×3（07:01/07:03/07:04）、08h×2（08:01/08:03）、09h×1（09:02）**，幾乎都落在各 job 的**整點起跑時刻**（07:00 論文+BBC+三支 KA、08:00 晨間情報+群體智能、09:00 clean-code）。→ 排避的正確做法是**錯開同分鐘的起跑數**（例：`58fe15dc` 移出 `0 7 * * *`、08:00 兩支拆成 08:00/08:45），而不是只搬離「09–13 配額窗」——那時段根本不是配額窗，是併發窗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **journalctl 的 `--since` 必須用相對格式，否則會假「全乾淨」（2026-11-21 10:02 踩坑）**：把 `--since '4 hours ago'` 放進 shell 變數再展開時，**內層引號會被吃掉** → journalctl 報 `Failed to parse timestamp: '4`、輸出 0 行 → 所有簽章計數（429 / READY timeout / EAI_AGAIN…）全部變 0，看起來像「四小時零症狀」其實是**沒查到資料**。✅ 正確寫法：`journalctl --user -u openclaw-gateway --since=-4h --no-pager`（相對式），或直接用 `journalctl ... --since=-4h` 不套變數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **journal 逐時統計要除以 2（2026-11-21 10:02 實測）**：journal 每行含兩個時間戳（`十一月 21 07:04:01` 前綴 + ISO `2026-11-21T07:04:01.298+08:00`）→ `grep -oE "[0-9]{2}:[0-9]{2}:[0-9]{2}" | cut -c1-2 | uniq -c` 會數到 **2 倍**（6 筆實際 → 顯示 6/4/2）→ 判讀時要除以 2 才對。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 對 auth profile 的完整鏈路已實測（2026-11-21 13:02，取代「429 = 直接失敗」的簡化模型）**：`provider-transport-fetch status=429` → `[agent/embedded] embedded run agent end isError=true` → **`auth profile failure state updated: profile=sha256:<hash> provider=minimax-portal reason=rate_limit window=cooldown reused=false`** → 數秒後 **`[gateway] provider auth state re-warmed (auth-profile-failure) in 3400ms`**。cooldown 期間**該 auth profile 那一格會從 fallback 鏈上消失**（＝11-17 記錄的「auth-profile-unavailable」，fallback 鏈退化成一格）；若 re-warm 成功則 fallback 鏈自動復原、紅單可避免。實測 10:31 這次 re-warm 成功、**零紅單**；12:02 那次則被 `rate-limit same-model retry 1/3 delayMs=10000` 吃掉。判讀 fallback 是否真的退化，要看 `model-fallback/decision` 的 `next=` 候選鏈 + `openclaw models list` 的 Auth 欄（cooldown 當下 Auth 會顯示 no）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **journal 簽章計數必須排除 `[agent:nested]` 行（2026-11-21 13:02 踩坑）**：agent 的自述輸出（`session=agent:x:main ... channel=webchat`）會把「startup-not-ready」「EAI_AGAIN」「429」「overloaded」等字樣原樣寫進 journal → 直接 `grep -c` 會得到假陽性（本輪 startup-not-ready/EAI_AGAIN 各 1 筆，實際都是 gengar 報告內文，runtime 真值為 0）。✅ 正確做法：`grep -v "agent:nested"` 後再計數，或改用 runtime 專屬簽章（`[fetch-timeout] … timer delayed`、`[provider-transport-fetch] … status=429`、`[discord] client initialized` / `channels resolved`）。另：`Failed to remove unused run continuation: Cannot delete session while competing work is in flight … retry after the run completes` 是**每支 cron job 收尾的良性清理噪音**，不代表失敗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **紅單掃描必須分 enabled / disabled 兩層（2026-11-21 16:02 實踩）**：`openclaw cron list --all --json` 撈全部 job 後要依 `enabled` 分組 —— **只有 enabled 且 `state.consecutiveErrors>0` 才是「現行紅單」**；disabled 的 ce 只是歷史痕跡。本輪在 disabled 群裡抓到 `a94330a9 tmp-openai-probe`（ce=2、11-19 紅、lastError=`Codex agent harness cannot enforce this conversation's tool policy…`、nextRun=None）——前幾輪只數 enabled 就完全沒看到它。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`skipped` 數量不是健康指標（2026-11-21 16:02 實測）**：`no-route` heartbeat 每輪都會翻成 skipped，數量隨各支落點浮動（本輪 8→5）→ 一律看 `consecutiveErrors` 判斷紅單，不要用 skipped 計數做趨勢。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **journal 的 429 grep 命中數會 ×2，且偶有假陽性（2026-11-21 16:02 實測）**：每次真 429 會產生 `provider-transport-fetch … status=429` ＋ `[agent/embedded] … isError=true` **兩行**；6h 窗命中 5 行＝**2 次真 429**（10:31:36、12:02:32）＋1 行假陽性（`ended with stopReason=stop…` 內含字串）。判讀時要逐行看 `[provider-transport-fetch]` 前綴才算真事件。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **Discord 乾淨段起點的取法（2026-11-21 16:02 實測）**：`journalctl --user -u openclaw-gateway --since=-24h --no-pager | grep -v 'agent:nested' | grep -E "READY wait timed out|disconnected" | tail -1` → 最後一筆事故時間戳（本輪＝04:56:12 → 16:03 連續 ≈11h07m 零症狀，自癒以來最長乾淨段）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **plugin runtime 競態會把 fallback 鏈一起掃掉（2026-11-21 22:02 實測，連五輪重現）**：簽章＝`prepared model runtime plugin generation was superseded for <agent dir>`，會同時出現在 `[diagnostic] lane task error` 與 **`[model-fallback/decision] … reason=unknown detail=<同一句>`** → 3 格 fallback 鏈被逐一判成 `candidate_failed`，**多燒 2 個 hop** 才由第三個候選接住（11-21 22:02 gengar lane：M3-portal → M3-key → M2.7-portal 才成功）。⚠️ 判讀陷阱：這**不是 provider 掛掉**，是 plugin generation 被取代；且**破的是 announce 路徑**（`sessions_send announce flow failed`）——**回覆一律會落地**：inline 先拿到全文，announce 之後仍會**晚到**（11-21 19:03、22:04 兩輪實證：journal 報 announce flow failed，但該則 inter-session announce 照樣送達本 session）→ 別誤判成對方失聯、也別重複發送。⚠️ 附帶教訓：**對端自報的「近 60 分鐘 429」可能是上一輪的舊數字**（gengar 22:03 報「18:04:43」明顯非 60 分鐘內）→ 429 一律以 journal `[provider-transport-fetch] … status=429` 的時間戳為準。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **三支 Keep-Alive 的 anchor 錯峰要自己驗，不要相信「已經錯開了」（2026-11-21 22:02 實測）**：`openclaw automations list --all --json` 的 `state.nextRunAtMs` 才是權威（`schedule.anchorMs` 只差毫秒看不出來）。本輪實測 Celesteela 已錯開到 22:02:06，但 **Gengar 22:02:04.129 vs Picturecat 22:02:04.143 → 只差 14ms**＝實質同時，競態（`prepared model runtime … superseded`）正是落在這個重疊窗。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`cron_run_receipts.job_id` 與 `cron_jobs.job_id` 都是完整 UUID，短 id 不能用 `=` 比對（2026-11-21 22:02 踩坑）**：用 `where job_id='9d8b6001'` 或 `='9d8b6001-…'` 都查不到（要回傳 no receipts），必須先用 `cron_jobs` 的 `name`→`job_id` 對照再帶完整 UUID 進 IN 子句。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **紅單根因要靠 `cron_run_receipts.error_text` 分類，第四型出現了（2026-11-22 16:02 實測）**：`state.lastRunStatus` 只有 ok／error，真正的原因字串在 receipts 的 `error_text`。已辨識到的型別：① 限流＝`rate_limit`／`Token Plan usage limit reached`；② 逾時＝timeout；③ 網路＝`LLM request failed: network connection error` / `DNS lookup for the provider endpoint failed`；④ **【新】CDN/gateway 擋下＝`The provider returned an HTML error page instead of an API response. This usually means a CDN or gateway (e.g. Cloudflare) blocked the request.`** —— 第 ④ 型不會寫在任何 journal 簽章裡（不是 429、不是 timeout），**只靠 grep journal 一定漏掉**，必須查 receipts。實例：`45ccf4e9` 晨間情報 11-22 08:00 937s 後以此失敗（11-21 同槽 ok）。查法：先由 `cron_jobs.name` 對出完整 `job_id`，再用 `started_at_ms >= <epoch ms>` 篩 `cron_run_receipts` 的 status／error_text。
- ⭐ **KA anchor 疊窗的第 7 次實測（2026-11-22 16:02）**：Picturecat anchorMs 1780452122531／Gengar …570（+39ms）／Celesteela …603（+33ms）→ 實跑 16:02:06／16:02:06／16:02:08，**兩支同秒**。本輪該窗內 0 紅單（未撞 429）→ 疊窗是「潛在風險」而非「必然爆」；別把未爆當成已解決，仍建議拉開 ≥3 分。另外 `plugin generation was superseded` 本輪 3h 內 **10 筆**（picturecat KA 16:02:23 nested+session durationMs 4–6、gengar lane 16:04:09 連帶 `model-fallback/decision candidate_failed`），**回覆照常落地**（探測全文已回）→ 連續六輪證實它是良性競態，判讀時不必當紅單。

## Gengar Keep-Alive 巡檢 — superseded 競態釀成硬失敗 + 計數分層（2026-11-22 19:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`plugin generation was superseded` 不是永遠良性（推翻前六輪判讀）**：2026-11-22 16:01:09 `bcf270b8` heartbeat-mrmime 直接紅單 `heartbeat failed: agent-runner-failure`（dur 366s），journal 真因在 16:07:15 `Embedded agent failed before reply: prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/mrmime/agent`（lane=cron-nested / session:agent:mrmime:main:heartbeat，durationMs 3–4ms 就炸）。同一競態在 picturecat／gengar lane 上只是噪音 → **看到 agent-runner-failure 先 grep journal 的 `Embedded agent failed before reply`**，不要直接歸因限額。18:01／19:01 兩輪自癒（228s／5s ok）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **真 429 ≠ job 失敗，OpenClaw 有同模型重試**：18:02:25 provider=minimax-portal status=429 elapsedMs=112184 → 隨即 `rate-limit same-model retry 1/3 … delayMs=10000` → 對應 job `d7b0355b` 最終 ok(259s)。且限流壓力在降：真 429 由 01:02 窗的 4 筆 → 19:02 窗 1 筆，EAI_AGAIN 0、Token Plan 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **skill skip 噪音要分層計數，且關鍵字別猜**：event 形式是 `[skills] Skipping invalid skill: file=… error=description is required`（**不是** `skill error`）。用錯關鍵字會數成 0 → 誤判「已修好」。3h 內 raw **204 行**、unique **17 檔**（12 缺 description ＋ 5 BAD_INDENT），與前輪同一組（第 7 輪未修）→ 引用時務必標明是 raw 行數還是 unique 檔數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **sessions_send 收到亂碼 ≠ lane 失聯**：19:02 第一次探測 gengar 回 `]<]minimax[>[<invoke name="process">]…`（模型把 tool-call 標記當純文字吐出，先發兩個 `process poll` 卻無 tool result，`stopReason=stop`）。正確處置＝**補第二次精簡 token 探測**（`LANE_OK_GENGAR_1902 = 6` 乾淨回覆）→ 不要重發長訊息、不要誤報故障。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 8 次**：19:02:06 Picturecat／19:02:06 Gengar／19:02:08 Celesteela → 寬度 2ms。三支 KA 本身全 ok、ce=0，但 superseded 競態噪音 29 筆/3h（>前輪 10）。拉開 ≥3 分鐘仍未執行（等 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — skill skip 根因定位 + Discord reconnect 指標修正（2026-11-22 19:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **17 支 SKILL.md 每天被跳過 197 次＝17 支 skill 功能上「不存在」**（`[skills] Skipping invalid skill`，24h 3,349 行、每檔各 197 次＝每日 197 輪 skill 載入）：**13 支 `description is required`**（frontmatter 整段不存在，如 `card-lookup`、`network-security-defense`、`prompt-injection-defense`、`ptcgp-card-*`＋rosclaw 4 支）＋ **4 支 `invalid frontmatter: BAD_INDENT`**（多行 block scalar 破壞 YAML：`excel-image-pipeline`、`human-behavior-simulation`、`image-attendant`、`ocr-confidence-mark`）。→ **驗證方式＝看它們不在 `<available_skills>` 清單裡**（不是看 log 有沒有報錯）。修法＝補單行 `description` frontmatter / 折成單行 block scalar。**未經 Linder 點頭不寫**：數支屬其他 agent lane、rosclaw 4 支屬第三方 plugin（更新會覆寫）。完整清單與抽驗見 `memory/keepalive-picturecat-2026-11-22.md` §7。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **Discord reconnect 一定要數兩種簽章，否則低估 10 倍**：只數 `did not reach READY` / `channel exited` 會得到 0.17/h（16:02 輪的錯值），真實 `Gateway reconnect scheduled` + `websocket closed code=1005` ≈ **2.6/h**（安靜時段基線 2.6–3/h；dreaming 04:25 窗 ≈17/h）。resume=true 的重連＝健康；READY 失敗 + channel exited 才是失明。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 尖峰可逐窗量化退潮**：今日 3h 窗 429 次數 **3→6→4→2→1→0→1**（15:00–18:00 零錯誤），每次都被 **same-model retry 1/3** 救回且**所屬 job 收尾仍 ok** → 判 job 紅燈要看 job 狀態，provider 429 次數只是背景噪音；真實配額（`Token Plan usage limit` + `2056`）今日仍為 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — Node 釘死條目已作廢 + 01:02 槽觀測（2026-11-23 01:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「Node 版本被 systemd 釘死在 v24.22.1」已證實過期（2026-11-23 01:02 實測，修正 11-19 21:00 那條）**：兩個單元 mtime = **2026-11-19 21:13:09**（比原觀測晚 13 分鐘 → 當晚就修好，MEMORY 沒回寫）→ ExecStart 現為 `node v24.22.3`（gateway + bridge），`ps -o cmd -p <MainPID>` 實測進程二進位 = **v24.22.3** → 11 月 CVE 修補已實際生效。**教訓：MEMORY 裡「已載待辦」要複驗是否已被修，別照抄舊結論。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 逐時退潮（24h 統一口徑 `model-fetch.*status=429`）：11-22 03/05×4/06/07×2/08/09×2/12/18/21/23 各 1 + 11-23 00 一筆 = 24h 共 16 次，全部 same-model retry 1/3 救回，硬失敗 0；真實 `Token Plan usage limit` 仍 0 筆**。本窗 2 次：23:02:42 → job `5b7c1082 每日模型排行前十`（ok / dur 496,600ms）、00:02:34 → job `d7b0355b mrmime Codex A2A heartbeat`（retry 1/3 → 00:02:46 status=200；ok / dur 190,605ms）。**溯源速查**：`sessionKey=agent:<lane>:cron:<jobid8>` 直接對出 job id；`[agent/embedded]` 行則靠鄰近 `[cron:<uuid>]` 行補。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **Discord 乾淨段續長**：最後一筆 READY-fail/channel-exit = **11-22 04:55:37** → 11-23 01:02 **連續 ≈20h07m 零症狀**（3h 窗 reconnect 8、websocket closed 8、READY-fail 0、channel-exited 0；24h reconnect 117≈4.9/h、websocket closed 142≈5.9/h、READY-fail 27、channel-exited 14、host-timing-gap 6 —— 後三者全落在 dreaming 04:25 窗）。**reconnect 兩簽章一起數**（單數 READY-fail 會低估 10 倍）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 8 輪未修**：3h 窗 408 筆、24h 3,281 筆、唯一檔 17 支、每檔每 3h 各 24 次（≈192 次/日）。**仍未授權，不動。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 10 次**：本輪 picturecat 01:02:06.137 ↔ gengar 01:02:08.151 ↔ celesteela 01:02:08.156（gengar↔celesteela **差 5ms**）→ superseded 競態噪音 2 筆/3h，回覆照常落地（良性）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- **紅單仍是兩支、均待自癒**：`45ccf4e9 晨間情報 pipeline` ce=1（next 11-23 08:00，根因＝CDN 回 HTML 錯誤頁）、`c5352a84 skill-collection-review-roaringmoon` ce=1（next 11-27 03:56，11-20 DNS 餘波）。`a94330a9 tmp-openai-probe` 為 enabled=false 殘留，不算活紅單。gateway 連續第 4 天 NRestarts=0（1d22h50m）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — 降級跑可量化 + 429/529 判讀（2026-11-23 01:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「KA 巡檢會降級成三行字」已可量化：receipt dur < 30s ≈ 降級輪**（2026-11-23 01:02 實測，量化 Gengar KA 11-22 全天）：11-22 的 8 輪 dur = 301s / 103s / **18s** / **8s** / **15s** / 307s / 165s / **10s** → 其中 4 輪屬降級跑，後果分三種：**零紀錄**（07:02、10:02、22:02）、**只留 3 行**（13:02）、**寫進別的 agent 的檔**（04:02 落進 `keepalive-picturecat-2026-11-22.md`）。**根因＝payload 只有一句 `keep-alive test`、沒有 checklist**，每輪深度由 agent 自決。→ **查漏做不必翻 transcript**：`cron_run_receipts` 取 dur 明細，對照當日 keepalive 檔的 `^## ` 段落數，差額＝漏做輪數。**修法＝把必做五步與檔名寫進 job payload（屬改 job，需 Linder 點頭）。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **journal 裡的 `overloaded` / `overloaded_error` 是 429 錯誤封裝內文的 error type，不是獨立 529**（2026-11-23 01:02 實測：3h 窗 `model-fetch.*status=429` = 2，但 `grep -i overloaded` = 3 筆、`status=529` = 0）。→ **一律用 `model-fetch.*status=429` 單一口徑**，別把 `overloaded` 當成另一類故障重複計數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 回應延遲量測續作**：本窗 elapsedMs = **158,105 / 122,549**（與 11-22 01:02 量到的 142,534–174,461 同區間）→ **MiniMax 限流固定要 ~2–2.6 分鐘才回**，期間 fallback 鏈完全不能推進；每次真 429 都白燒近 3 分鐘 job wall-clock。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **去程＋回程同窗落地＝最乾淨的一次閉環**（2026-11-23 01:02）：`sessions_send` 去程讀回乾淨回覆（含 `LANE_OK_GENGAR_0102 = 6` token），同時 gengar 另以 `sessions_send` 回送到本 cron session 且 pendingInputs state=**queued** → 回程腿不再停在 announce/pending。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **三支 KA anchor 疊窗第 11 次**（2026-11-23 01:02：picturecat 01:02:06.137 ↔ gengar 01:02:08.151 ↔ celesteela 01:02:08.156，gengar↔celesteela 差 **5ms**；anchorMs 只差 39ms/33ms）→ `plugin generation was superseded` 競態噪音 2 筆/3h，回覆照常落地（良性）。修法（拉開 ≥3 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 429 救回可能無 log + 簽章 grep 污染（2026-11-23 04:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「429 有沒有硬失敗」不能看 journal 有沒有 retry log，要看 job 的 `lastStatus` / `consecutiveErrors`**（2026-11-23 04:02 實測）：03:01:37 的 429（`40e09cd1 Jormungand daily all-agent health`）讓 embedded run 以 `isError=true` 收尾，但**全程沒有 `rate-limit same-model retry 1/3` 那一行**——runner 直接在 2.5 秒後發新 fetch（03:01:39 start → 03:01:42 status=200, dispatcher=new），job 最終 **ok / ce=0 / dur 655,053ms**。只 grep retry 關鍵字會低估救回次數、誤判成紅單。journal 只用來定位「哪支 job、哪個時間點、elapsed 多長」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **簽章 grep 一定要 anchor 在 log 行首前綴**（`[discord]` / `[provider-transport-fetch]` / `[skills]`），否則會被 **agent 自己的回報文字**污染：`startup-not-ready`（gengar 寫「0 `startup-not-ready`」→ 誤判 1，實為 0）、`EAI_AGAIN`/`getaddrinfo`（agent 敘述 DNS 風暴 → 誤判 7，實為 0）、`Token Plan usage limit`（同樣誤判 1，實為 0）三個本輪全踩。⚠️ **【2026-11-23 13:02 修正：anchor 不能用 `^` 行首】** 本機 journal 每行開頭其實是 `十一月 23 12:02:01 amr-Nitro-AN515-58 node[4137629]: 2026-11-23T12:02:01.177+08:00 [discord] …` → **`[discord]` 不在行首**，`grep -cE "^\[discord\].*did not reach READY"` 恆為 0（實測 24h 真值 12），`^\[discord\].*Gateway reconnect scheduled` 也恆為 0（實測 106）→ **這個方向的錯會把「有事故」判成「零症狀」**。✅ 正確＝子字串比對（`grep -c "did not reach READY"`）或 anchor 在 `node\[[0-9]+\]: 2026-11-2[0-9]T` 之後；**排除 `[agent:nested]` 這條仍然要保留**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **Discord `reconnect-opcode, resume=true` 屬心跳式重連、非掉線**（2026-11-23 04:02 實測：3h 窗 11 次全屬此型、READY 失敗 0、channel exited 0）；判定掉線要看 `READY wait timed out after 15000ms` 與 `channel exited`。`READY within 30000ms` 是**成功**握手，別跟失敗簽章混算。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 11 次**（2026-11-23 04:02：picturecat 04:02:06.154 ↔ gengar 04:02:08.171 ↔ celesteela 04:02:08.176，gengar↔celesteela 差 **5ms**，與上一輪同一組）；三支上輪 dur 全 >30s（88s/277s/118s）＝皆非降級輪。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 9 輪仍未修**（2026-11-23 04:02：3h 窗 442 筆、24h 3,298 筆、唯一 17 檔、每檔每 3h 26 次 ≈208 次/日）→ **仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — dreaming 風暴基準表 + 429 elapsed 破 2 分鐘（2026-11-23 04:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **Dreaming 風暴可量化成基準表，下次不用重推**（2026-11-23 04:02，48h 交叉驗證）：`READY wait timed out after 15000ms` 48h 共 **66 筆**、`[health] host timing gap detect` 48h 共 **12 筆（＝每日 6 筆）** → **全部落在 dreaming 排程窗 `25 4 * * *` 之後的 04:27–04:55**（11-21：04:27/04:34/04:40/04:46/04:50/04:54；11-22：04:27/04:34/04:39/04:45/04:49/04:53）。dreaming 上一輪 dur = **1,852,428ms ≈ 30.9 分** → 風暴窗 ≈ **04:25–04:56**。→ **在 04:02 槽（風暴前）量到的必然是 0，別誤判成「已修復」**；要驗證得等 07:02 槽比對基準表。selfheal `d4cd45bc` = cron `13,43 * * * *`，04:43 槽雖落在窗內但 fail-closed 會順延到 **05:13 / 05:43**。<br/>⚠️ 對照時注意 `host timing gap detect` 只在 `[health]` 前綴行出現；naive grep「timing gap|clock change」會把 agent 回覆文字也算進去（24h 誤判 8，實為 6）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 的 provider 回應延遲首次跌破 2 分鐘**：2026-11-23 04:02 窗量到 `elapsedMs=93,090`（前幾輪 142,534–174,461 / 122,549 / 158,105）→ **MiniMax 限流恢復在變快**。仍需留意：一旦真 429，每次至少白燒 1.5–2.6 分鐘 job wall-clock，且 fallback 鏈完全不能推進。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **同一支 job 在 3h 窗內可能同時存在 error receipt 與 ok receipt → receipt 數 ≠ 紅單數**（2026-11-23 04:02 實測）：`40e09cd1 Jormungand daily all-agent health`（cron `0 3 * * *`）03:00:01 起跑、receipt 記 **error / dur=96.1s / error_text「⚠️ API rate limit reached. Please try again later.」**，但 03:02:07 又起跑一次收 **ok**，job state = `lastStatus=ok / consecutiveErrors=0`。→ **統計紅單務必以 job state 的 lastStatus/ce 為準；receipt 的 error 欄位只是「那一次嘗試」的快照。**<br/>延伸口徑：3h 窗 receipt 的 error 計數（1）與 24h `model-fetch.*status=429` 計數（16）也**不可互相推導**——前者是 job 級落盤結果、後者是 provider 層事件數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **Discord slash command 已溢出平台上限（全新問題、非 dreaming 相關）**：`112 commands exceed the 100-command Discord limit` 24h **24 筆**、末筆 11-22 10:27:10，**全天散落**（與 dreaming 時段無關）→ 部分指令實際註冊不出去。修法＝精簡 command 註冊數（尚未授權，不動）。<br/>相鄰簽章：`channel resolve failed` 24h = 8 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 12 次**（2026-11-23 04:02：picturecat 04:02:06.169 ↔ gengar 04:02:08.188 ↔ celesteela 04:02:08.193，gengar↔celesteela 差 **5ms**、三輪同一組數字）→ `superseded`/`lane task error` 競態噪音 3h 4 筆（每輪 2 筆、良性）。修法（拉開 ≥3 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 10 輪仍未修**（2026-11-23 04:02：3h 窗 raw 442 行＝338 `description is required` ＋ 104 `BAD_INDENT`、唯一 17 檔、≈192 次/日）→ **仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **降級跑不是必然**：本 job 11-22 有 4 輪 dur <30s（9.8 / 15.2 / 7.8 / 17.6s），但 **11-23 01:02（277.5s）與 04:02 兩輪皆完整走完** → 「payload 沒 checklist 導致深度自決」是**風險**不是**定律**。→ checklist 補進 payload 這件事的優先度可下修（從「中」降到「低」），但根治方案仍成立。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **SSH 事件在 system journal，不在 user journal**（2026-11-23 22:02 實測，差點誤判）：`journalctl --user -u ssh --since "1 hour ago" | grep -c "Accepted publickey"` → **0 筆（假陰性）**；正確作法＝`journalctl --since "1 hour ago" | grep "Accepted publickey"`（**不加 `--user`**）才拿到真值（3h 56 筆／1h 18 筆）。→ sshd 是 system unit，`--user` 只看得到自己的 user unit log；**凡「查某個 system 服務的事件」都要先確認該服務是 system 還是 user unit**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「dur<30s ≈ 降級跑」這條規則要跨 lane 套用**（2026-11-23 22:02 實測）：本輪從 `openclaw cron runs --id <Picturecat uuid>` 直接讀到 **`02eb0989` Picturecat KA 22:02 輪 dur=21,550ms → 疑似降級跑**（自己這支 22:02 是完整巡檢）。→ 只量自己那支會漏掉 fleet 面；**每輪巡檢順手把三支 KA 的 receipt dur 一起列出**（本輪 Celesteela 的 22:02 receipt 到收尾時還沒寫出）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **429 的「續 0」敘事一律會破，別再寫**（2026-11-23 22:02 實測）：近 5 輪的 429 敘事每輪都宣稱「自 X 起 3h 零 429」→ 下一輪就被打破（12:02→18:02→21:01，間隔約 3h）。→ **事件數只當波動，唯一穩定軸是 elapsed**（130.0s → 106.2s，且 dispatcher 由 `reused` 轉 `new`）。→ 寫報告時用「零星復發」取代「恢復」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **疊窗危害的邊界條件被量到**（2026-11-23 22:02 實測）：三支 KA anchor 疊窗第 17 次（22:02:02／22:02:10／22:02:12），但本窗 **stalled session = 0、lane wait = 0（3h 窗首次歸零）**；相對地 16:0x 那種「KA 窗 + 其他高 dur job 同時長跑」的窗才會出 lane wait（351.9s）與 stalled session。→ **疊窗不是必要條件，是放大器**：真正要注意的是「疊窗 + 同時段其他長 job」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **回程腿的 queued→injected 延遲可達 2–4 分鐘，「pendingInputs 為空」不等於「回程腿沒跑」**（2026-11-23 04:02 實測）：gengar 回送本 cron session 的訊息 **queued 04:03:11.298 → 實際注入 04:05:33.383（142.1s）**，內容與去程回覆**逐字一致**。本輪在 04:05:2x 查詢 pendingInputs 時仍是空 array、當下誤判成「回程腿未閉環」→ **必須在本輪收尾前再查一次**（或跨輪追蹤），否則會把完整的閉環輪誤記成單向腿、甚至誤判成降級。→ **診斷順序：先查 job receipt 的 dur（本輪 >30s 即非降級），再查 pendingInputs；兩者衝突時以 dur + 實際注入紀錄為準。**<br/>對照：gengar 僅在 01:02 輪明確回送並於同窗注入（queued→injected 同窗），04:02 輪延遲 2m22s → **「回程腿閉環與否」每輪品質不同，勿混為一談**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — selfheal 守門 fail-open 腰斬 dreaming（2026-11-23 07:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **本輪抓到真實故障並已修復：selfheal 的「dreaming 是否在跑」守門 fail-open，開火把 dreaming 腰斬了**（11-23 04:25–04:48）：04:43 的 selfheal 槽因 gateway 凍結延遲到 **04:46:17** 起跑 → 守門回報「dreaming idle」→ 排 gateway restart → 04:47:46 `Stopping OpenClaw Gateway` → **04:48:17 `State 'stop-sigterm' timed out. Killing.` → SIGKILL MainThread + 8 個 V8Worker** → dreaming job `36b493db` receipt = **error `cron: job interrupted by gateway restart`**（dur 1,406,869ms＝23.4 分，平日約 30.9 分）→ **ce=1**，且 **55 個 dreaming subagent run 被 `Subagent orphan run pruned source=restore` 砍掉**。→ **這是自癒機制造成的自我傷害，不是 dreaming 本身故障**；紅單由 2 支變 3 支。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **守門 fail-open 的根因＝CLI 錯誤封套是「合法 JSON ＋ exit 0」**：`openwall cron list` 在 RPC 失敗時把 **`{"ok":false,"error":{...}}` 印到 stdout 且 exit code=0** → 舊守門 `json.load()` 解析成功 → `.get("jobs",[])` 回 `[]` → 迴圈找不到 dreaming → 印 **`False`（＝dreaming idle）** → 開火。11-20 那版只對「JSON 解析失敗」fail-closed，**漏了「合法 JSON 但形狀不對」這一類**。已用 8 個 fixture 重現並驗證修法。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **已修（rowlet 自有 script，backup 留存）**：`scripts/discord-selfheal.sh`（+ `.bak-2026-11-23-0702`）→ ①任何不確定（`ok:false` 封套 / 非 list / **清單裡找不到 dreaming**）一律回 `True`＝視為在跑；②讀取改 `--all`（不含 `--all` 只有 46 支 enabled，含 dreaming 在內共 53 支）；③加 `queuedAtMs` 判斷；④**新增完全不依賴 cron API 的時鐘窗守門**：`DREAMING_WINDOW_START=04:15` / `END=05:10`（dreaming 排程 `25 4 * * *` ＋ timeout 2400s → in-flight 約 04:25–05:05；END 刻意設在 05:13 合法治療槽之前）。驗證：`bash -n` 通過、8 個 fixture 全過、對 live CLI 實跑得 `False`（dreaming 現況確實 idle）、整支 script 實跑輸出 `discord healthy - no action` 且 **stamp 檔未被改動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **任何「以 cron API 為前提」的自動化，都必須有一道不依賴 API 的第二道守門**：本輪 journal 顯示 **`[ws] ⇄ res ✓ cron.list 32103ms`**（gateway 凍結時 cron.list 慢到 32 秒）→ **事件迴圈飽和正是這種自動化最需要正確判斷的時刻，而那正是 API 最不可信的時刻**（會慢、會回錯誤封套、會回過期狀態）。「查詢失敗→保守」不足以cover「查詢成功但內容錯」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **`NRestarts=0` ≠ gateway 沒重開過**：unit 被 `systemctl restart` **主動**重啟時 systemd 不計入 NRestarts（11-23 04:48 那次就是 NRestarts=0 但 MainPID 3573532→4137629、ActiveEnterTimestamp=2026-11-23 04:48:17）。→ **判斷 gateway 有沒有被重啟，要看 `systemctl --user show openclaw-gateway` 的 ActiveEnterTimestamp ＋ MainPID 變化**，不能只看 NRestarts。（前幾輪用 NRestarts=0 推論「連續第 N 天未重開」在此不成立。）<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **故障歸因要對齊「fetch 起始時間」**：429 的 log 時間是**回應**時間，`elapsedMs` 高達 101k–162k ms → 起始點在 1.7–2.7 分鐘前；用回應時間去對 `[cron:<uuid>]` 標記會錯位到**前一支** job（本輪 07:01/07:02 兩次 429 若用回應時間對齊會被記到 06:40 的 `08b7c00b`，實際起始是 07:00:00/07:00:20）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **dreaming 風暴的「可自癒」假設再次被推翻（11 天來首次需靠 gateway 重啟）**：11-23 04:25 槽 **4 次** `host timing gap detected`（frozen 146s/266s/231s/**279s**）、**25** 筆 READY wait timed out、**6** 筆 channel exited、55 個 subagent 被 prune；期間 `host thaw channel restart deferred: gateway still has active work` **12 筆** → **內建 health-monitor 只會重啟 channel、不會重啟 gateway，撐不過 30s READY 逾時**。今日 Discord 之所以回來，是因為 selfheal 恰好開火重啟了 gateway（副作用）——**這不能算自癒成功**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **bash 的時間字串比較要用 `[[ > ]]` / `[[ < ]]`**：`[ "$t" \> "$S" ]` 會被 shell 當成重導向 → 邊界失效（本輪 `04:15` 沒被判定在窗內）。修完後邊界實測：04:14 窗外 / 04:16–05:09 窗內 / 05:10 窗外 / **05:13 窗外（不擋合法治療槽）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 13 次**（11-23 07:02：picturecat 07:02:06.169 ↔ gengar 07:02:08.188 ↔ celesteela 07:02:08.193，gengar↔celesteela 差 **5ms**，與前兩輪同一組數字）→ superseded 競態噪音 3h 12 筆（良性，回覆照常落地）。修法（拉開 ≥3 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 11 輪仍未修**（11-23 07:02：3h 窗 **1,020 筆**、24h **3,026 筆**、唯一 17 檔、每檔每 3h 各 **60 次** ≈480 次/日/檔）→ **仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **429 尖峰維持每小時 0–2 次、硬失敗仍 0**（11-23 07:02 3h 窗 **5 次**：05:01/05:32/06:03/07:01/07:02，elapsed 101k–162k ms，全被 `rate-limit same-model retry 1/3` 救回；24h 合計 14 次；Token Plan usage limit 仍 0；EAI_AGAIN 仍 0；跨廠 fallback 仍 0）。**但注意 07:01/07:02 兩次正好打在 07:02 三支 KA 起跑點** → 與「整點槽併發數」模型一致。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — selfheal 守門 fail-open 實作修法（2026-11-23 07:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「dreaming 還在跑」的判斷不能只靠 cron API**（2026-11-23 07:02 實測， dreaming 被截斷第 3 次）：`36b493db` 是 **managed plugin job（agentId=None）** → 它在跑時 `openclaw cron list --all --json` **只發布 last-run status（"ok"/"error"）、從不發 `runningAtMs`/`queuedAtMs`**（實測 state keys：`lastRunStatus, nextRunAtMs, scheduleActivatedAtMs, …`，無 runningAtMs）→ **API 全健康也看不到它在跑**。加上 `openclaw cron list` 在 RPC 失敗時會在 stdout 印 `{"ok":false,"error":{…}}` **且 exit 0**（舊守門 `json.load()` 解析成功 → `.get("jobs",[])`＝`[]` → 找不到 job → 印「idle」→ 在 dreaming 跑到一半時排重啟 → 04:48 砍掉 dreaming ＋ 8 支 heartbeat）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **可用的三家族獨立證據（守門要 fail-closed 就得湊三個互不依賴的來源）**（2026-11-23 實作於 `scripts/dreaming-running-check.py`）：**`api`**（cron list 的 status/runningAtMs + 由 `lastRunAtMs + timeoutSeconds` 推出的 job 自己的 run window）｜**`db`**（`cron_run_receipts` 中 `finished_at_ms IS NULL` 的列＝在飛；runner 在 run 開始就建列、結束才填 → **獨立於 cron API，且正是 plugin job 缺 runningAtMs 時唯一可靠的「在跑」證據**）｜**`clock`**（排程本身 `25 4 * * *` + timeoutSeconds 2400 → 只可能在 04:25–05:05，**既不需 API 也不需 DB**，恰是 API/DB 同時退化時唯一還活著的訊號）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **fail-closed 的正確票數規則：不能把「無法作答」當成一票**（2026-11-23 07:02 修正）：**任一家族說 running 就 postpone**；要判 **idle 需兩個獨立家族同意**；**無法作答不算票**、票數 <2 → 一律 fail closed 印 running。（第一版把 unknown 從分母剔除、只剩 1 個 idle 票也放行 → 正是重演舊 bug，已修。）**另外 cron-list 與 window 共用同一份 payload → 屬同一家族，不能算兩票。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「壞掉的資料」與「沒資料」要分開處理**（2026-11-23 實作）：receipt 列若 `finished_at_ms IS NULL` 但 `started_at_ms` 已超過 `timeout + grace + slack`（3300s）→ 是 crash 遺留的**陳舊列**、不是活 run → 忽略（否則一列壞資料會讓守門永久死鎖、永不重啟）；反之**查不到 DB／查詢失敗 → unknown，不是 idle**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **改 gateway 守門類腳本時，必須用 stub 驗證「會重啟」那條路徑**（2026-11-23 07:02 實作）：把 `openclaw channels status`（假造 `startup-not-ready`）與 `systemd-run`（只寫 log、絕不真重啟）都換成 stub，再用 fake DB 驅動 in-flight/finished 兩種狀態 → FLOW A（Discord 壞＋dreaming 在飛）必須 postpone 且 armed.log 空、FLOW B（dreaming 已結束）才 arm。**實測時真實 gateway 的 MainPID/NRestarts/ExecMainStartTimestamp 三項前後一致才算過關。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **dreaming 風暴基準表（04:20–06:00 窗，READY-fail / host-timing-gap）**：11-21 = 39/6（dreaming ok 32.0 分）｜11-22 = 27/6（ok 30.9 分）｜**11-23 = 25/4（interrupted 23.4 分，被 04:48 重啟砍）**。症狀量級變輕，但**被砍這件事本身就是重啟造成的**，且是本週第 3 次（11-19、11-20、11-23）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 13 次**（2026-11-23 07:02：picturecat 07:02:07.356 ↔ gengar 07:02:09.376 ↔ celesteela 07:02:09.382，gengar↔celesteela 差 **6ms**）→ 修法（拉開 ≥3 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 11 輪未修**（2026-11-23 07:02：3h 窗 833 行、每檔 49 次 × 17 檔 ≈278 次/日）→ **仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **429 elapsed 回到 100–161 秒**（2026-11-23 07:02：117,462 / 117,484 / 161,544 / 105,367 / 101,440 / 117,054）→ 上一輪量到的 93,090ms「跌破 2 分鐘」是**單點不是趨勢**，不要寫成改善。24h 15 筆、529 = 0、真實 Token Plan limit = 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **本 lane 併發寫檔要小心**（2026-11-23 07:02 實測）：Picturecat KA 與本 job 都跑在 rowlet lane，07:21 發現 `scripts/discord-selfheal.sh` 被**另一支 keep-alive job 改過**（mtime 07:21:41、我 07:0x 讀到的是舊版）→ **動手前先 diff 現況、保留對方的修正再合併**，別整份覆蓋。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — fleet 狀態會藏起整輪死亡（2026-11-23 10:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **`state.consecutiveErrors` 會把「上一輪整輪死亡」洗成全綠（2026-11-23 10:02 實測）**：Gengar KA `9d8b6001` 於 **07:29:13 硬死**（dur 1,624,295ms、err=`⚠️ API rate limit reached`）＋ **07:29:53 再死**（err=`Explicit auth order for openai has no usable profiles`），但 10:02 輪成功後 `state.consecutiveErrors` 歸 0 → **`openclaw cron list --all --json` 的紅單掃描完全看不到這次整輪死亡**（只會看到 fleet error 計數少了一支）。→ **巡檢必補 `openclaw cron runs --id <完整uuid>` 看最近數筆 status**（`ts`＝結束時間、`runAtMs`＝開始時間；只接受完整 uuid）。這是既有「紅單掃描＝`state.lastRunStatus` + `consecutiveErrors`」方法論的**已知缺口**，別再把 ce=0 當成「這段時間沒出事」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **跨廠 fallback 是「有設定、沒憑證」＝零冗餘，且是硬失敗（2026-11-23 10:02 實測）**：07:29 配額牆後的 fallback 嘗試直接被擋：`Explicit auth order for openai has no usable profiles`（`[diagnostic] lane task error`）。24h `candidate_succeeded` 共 4 筆，candidate 全是 **`minimax-portal/MiniMax-M2.7`（同廠換型號）**，`minimax/*` 候選 **0 次成功** → **判「有沒有跨廠冗餘」要看 `[model-fallback/decision] … candidate=` 的 provider 名，不是看 fallback 鏈長度**；鏈裡有非 minimax-portal 候選也不等於能用（要有可用 auth profile）。同廠雙型號 `minimax-portal/MiniMax-M2.7` 是現況**唯一實測可用**的救回路徑。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **MiniMax Token Plan 配額牆 07:29–07:59 實測（31 分鐘）並首次直接打死一整輪 KA**：真簽章 `Token Plan usage limit reached: Upgrade your Token Plan…`（`rawError HTTP 429`）24h 共 **58 筆全部落在 07:29:00–07:59:50**，同窗 canonical `model-fetch.*status=429` 26 筆（**單 07:29 一分鐘 13 筆**）→ 這是**帳號層 plan 上限**，與 burst 429／`overloaded_error` 是不同型態，別混算。→ 既有尖峰時段表（09–13 / 16–18 / 20–22 / 05–07）要**補上 07:00–08:00**，且 08:00 槽 `45ccf4e9` 已自癒（ok、ce=0）→ 牆會自己退。計數要用 `Token Plan usage limit reached: Upgra` 這個唯一指紋（泛用 "Token Plan" 會被 agent 自述污染）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 14 次**（11-23 10:02：gengar 10:02:02 → picturecat 10:02:07 → celesteela 10:02:09，間距 **5s / 2s**）→ 本輪**未**出現 5ms 級碰撞，superseded 噪音未釀紅單；修法（拉開 ≥3 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **Discord 乾淨段 ≈5h15m（自 04:47:09 起）**、gateway 連續 **5h14m 未重啟**（MainPID 4137629、ActiveEnterTimestamp 2026-11-23 04:48:17、NRestarts=0）、selfheal 守門（含 04:15–05:10 時鐘窗）09:13 / 09:43 兩槽 ok 且**未誤開火** → 07:02 輪的守門修法持續有效。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — journal anchor 反向誤判 + 降級跑第 12 例（2026-11-23 13:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **簽章 grep 的 `^` 行首 anchor 會把「有事故」判成「零症狀」——方向比「假陽性」更危險**（2026-11-23 13:02 實測）：本機 journal 行首是 `十一月 23 12:02:01 amr-Nitro-AN515-58 node[4137629]: 2026-11-23T12:02:01.177+08:00 [discord] …`，**`[discord]` 不在行首** → `grep -cE "^\[discord\].*did not reach READY"` 在 3h/24h 窗都回 **0**，而同檔子字串 `grep -c "did not reach READY"` 的 24h 真值是 **12**；`^\[discord\].*Gateway reconnect scheduled` 回 0 vs 真值 **106**；`^\[discord\].*channel exited` 回 0 vs 真值 **6**。→ **量測結論要寫成「子字串計數 vs `^` anchor 計數」的對照**，兩者不一致時以子字串為準；排障時務必先 `grep -m2 "<簽章>"` 看一眼原始行再決定 anchor 位置。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「降級跑 ⇒ 無巡檢紀錄」第 12 例，規則可直接用於查漏**（2026-11-23 13:02 實測）：Gengar KA `9d8b6001` 今日 5 輪 receipt dur = 277,451 / 205,068 / **1,624,295(error)** / **8,826(error)** / **12,842** ms → `memory/keepalive-gengar-2026-11-23.md` 最後一節仍是 **07:02 那一輪**，**10:02 那輪（dur 12,842ms < 30s）沒寫任何內容** → **今日只有 3/5 輪留下巡檢紀錄**。查漏動作＝取 receipt dur 明細 → 標出 <30s 的輪 → 對照當日 keepalive 檔的 `^## ` 段落數，差額＝漏做輪數。**不需翻 transcript**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「誰下的 systemctl restart 指令」有直接證據**（2026-11-23 13:02 實測）：`journalctl --user --since="2026-11-23 04:40:00" --until="2026-11-23 05:00:00" | grep "Started /usr/bin/systemctl --user restart openclaw-gateway"` → 印出 **04:46:50 與 04:47:46 兩筆** → 證實 04:48 那次 gateway 重啟是**有人下指令**（非 systemd 自動重啟，故 `NRestarts=0`）而且**下了兩次**（第二次在 SIGTERM 逾時後 56 秒 → 04:48:17 SIGKILL MainThread + 8 個 V8Worker）→ 這條命令是**歸因 selfheal 開火**（而不是猜）的關鍵證據。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **MiniMax 配額牆連續第 2 天在 07:29–07:59 出現**（2026-11-23 13:02 實測）：唯一指紋 `Token Plan usage limit reached: Upgra` 24h **58 筆全部落在 07h**，同窗 canonical `model-fetch.*status=429` **26 筆**（單 07:29 一分鐘 13 筆）→ **這條牆已是連續第 2 天在 07h**、且 11-23 那次直接打死一整輪 Gengar KA（07:29:13 dur 1,624,295ms + 07:29:53 `Explicit auth order for openai has no usable profiles`）。既有尖峰時段表要**把 07:00–08:00 當成固定高風險窗**；救回路徑仍只有 `minimax-portal/MiniMax-M2.7`（同廠換型號）——`minimax/*` 與 openai 候選 0 次成功＝**無憑證＝零冗餘**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 15 次**（2026-11-23 13:02：gengar 13:02:02 → picturecat 13:02:08 → celesteela 13:02:10，間距 **6s / 2s**，非 5ms 級）→ superseded 競態噪音 3h 2 筆 / 24h 162 筆（回覆照常落地，良性）；修法（拉開 ≥3 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 12 輪仍未修**（2026-11-23 13:02：3h 窗 **374 行**、24h **2,941 行**、唯一 **17 檔**）→ **仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **8h14m 長乾淨段 + 守門未誤開火**（2026-11-23 13:02）：gateway MainPID 4137629、ActiveEnterTimestamp 2026-11-23 04:48:17（**04:48 selfheal 事故後連續 8h14m 未重啟**）、`NRestarts=0`；Discord 最後一筆 READY-fail = **04:47:09** → 至 13:02 **連續 ≈8h15m 零症狀**（3h 窗 READY-fail 0 / channel exited 0 / client initialized 0 / host timing gap 0，reconnect 12 + websocket closed 12 ≈4/h 屬心跳式）；selfheal `d4cd45bc` 10:13→12:43 共 6 槽全 ok（dur 743–828ms）→ **07:02 輪修的 fail-closed 守門 + 04:15–05:10 時鐘窗持續有效**。活紅單維持 **2 支**（`36b493db` dreaming ce=1 待 11-24 04:25 自癒、`c5352a84` ce=1 待 11-27）；`45ccf4e9` 晨間情報 11-23 08:00 ok / dur=1,081,044ms **連續兩輪自癒確認**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 第二次 arm 來自互動式 session（2026-11-23 13:02 收尾補充）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **「兩次 systemctl restart」的第二發來自互動式 session，不是 cron、也不是三支已知 script**（2026-11-23 13:02 實測＋gengar lane 交叉回報）：journal `Started /usr/bin/systemctl --user restart openclaw-gateway.` 共 **兩筆：04:46:50（selfheal cron，第一發）與 04:47:46（第二發）**；gengar 查到 **04:47:35 有 `Started Session 7267 of User amr`** → 11 秒後第二次重啟 → **第二發是從互動式終端直接下指令，繞過了 selfheal 的 30 分鐘 anti-storm 閘**。逐一排除：`discord-selfheal.sh`（stamp `memory/discord-selfheal-last-restart.ts` mtime = **04:46** ＝第一發）｜`gw-node-guard.sh`（`logs/gw-upgrade-guard.log` 為空檔無 mtime → 未跑）｜`apply-dreaming-schedule.sh`（`memory/dreaming-schedule-check.log` 末筆 **2026-11-19T22:33:38** → 未跑）。→ **「誰下的」仍待確認**：若是 Linder 本人則無需動作；**若不是人下的，代表還有第四個未盤點到的 arm 來源**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **anti-storm / dreaming 守門若只做在「某支 script 裡」，任何直接 `systemctl restart` 的路徑都會繞過它**（2026-11-23 13:02 實測）→ 保護要放在**重啟的共同入口**（把 restart 收斂到單一 wrapper，wrapper 內做 dreaming in-flight 檢查），而不是每個呼叫端各自判斷。**這是 07:02 輪修的 selfheal 守門的下一個缺口**，也解釋了為什麼「守門修好」仍可能被繞過。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「降級跑 ⇒ 當下無紀錄」≠「永遠無紀錄」**（2026-11-23 13:02 實測）：Gengar KA 10:02 輪 dur=12,842ms（<30s）當下沒寫任何內容 → **13:02 輪由 gengar 手動回填**（`memory/keepalive-gengar-2026-11-23.md` 新增 `Gengar lane 自報（gengar 10:02 台北）` 與 `（gengar 13:02 台北）` 兩節）→ 查漏要分兩種口徑：**當下無紀錄**（降級跑）vs **永遠無紀錄**（真漏做）；回填機制存在時「檔案節數」會低估漏做輪數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 對方 lane 自報的數字必須用同一口徑複算（2026-11-23 13:05 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **跨 lane 的自報數字會被「自己的自述」污染，且會數成 ×2**（2026-11-23 13:05 實測，gengar lane 回覆逐條對帳）：gengar 自報「3h 內 **2 × 429/overloaded** ＋ **1 EAI_AGAIN**」→ 實測 canonical `model-fetch.*status=429`（3h）= **1**（12:02:01.177），另一筆 12:02:01.191 是**同一個 429 的 `[agent/embedded] … error=…overloaded…` error envelope**（既有「429 grep 命中 ×2」陷阱）；「1 EAI_AGAIN」則是 **6h 窗 5 筆全部落在 `[agent:nested]`**（gengar 自己的回報文字）→ runtime 真值 **0**。→ **判讀他 lane 自報，一律用自己的 canonical 口徑複算＋排除 `[agent:nested]`**（跨 lane 版的「簽章被 agent 自述污染」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「我沒寫過 / 檔案 mtime = X」這種狀態句，若同一輪內被自己改動就會變過期事實**（2026-11-23 13:05 實測）：gengar 回答「10:02 沒寫紀錄、該檔 mtime = 07:27:49、我從不寫進你的 workspace」→ 實測 **mtime = 2026-11-23 13:07:16、33,350B**，檔內已有 `## Gengar lane 自報（gengar 10:02 台北）` 與 `（gengar 13:02 台北）` 兩節，而 gengar 13:08:31 的自補訊息自己也說「Fixed: I appended …」→ **是自報與自己的寫入競爭（競態），write path 其實是通的**。→ **衝突時以寫入後的 `stat` 為準，並把差異回報對方**（本輪已用 `sessions_send` 更正）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **「第二個 arm 是誰」已結案＝人類的 publickey SSH session**（2026-11-23 13:11 實測，rowlet 用**系統 journal** 獨立複驗）：`sshd[4137564]: Accepted publickey for amr from 192.168.50.2 port 49765 ssh2` → `pam_unix(sshd:session): session opened for user amr` **04:47:35** → `session closed` **04:47:51**（16 秒），而第二次 `Started /usr/bin/systemctl --user restart openclaw-gateway.` 在 **04:47:46** ＝**登入後 11 秒**；journal 的 `Started Session 7267 of User amr` 04:47:35 即此 session。→ **不是第四個未知 arm 來源，是人為介入**（推測在處理當時的 Discord 斷線風暴）→ anti-storm 被繞過是因為那條路徑本來就不走 selfheal script。**教訓不變：護欄必須放在「重啟的共同入口」，否則人手動 restart 一樣能砍掉 dreaming。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **找「誰在動這台機器」要查系統 journal，不能只查 `--user`**：`journalctl --user` 只看得到 user unit，**sshd 的登入軌跡在系統 journal**（`journalctl --since ... --until ... | grep -E "session opened for user|sshd"`）→ 才能把一條 `systemctl --user restart` 對到具體的 SSH session 與來源 IP。附帶量測：11-23 全天 `session opened for user amr` = **255 次**，且每 **10 分鐘**整點一次（04:07/04:17/04:27/04:37/04:47/04:57）→ 有一支每 10 分鐘的外部監控在登入本機（身分未追）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — transcript-ownership 新故障型別 + dreaming 守門補到 3 條 arm 路徑（2026-11-23 16:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **新故障型別 #4：transcript-ownership —— 模型呼叫全 200，job 卻判 error**（2026-11-23 16:02 實測）：Gengar KA `9d8b6001` 13:02 輪 receipt = **status=error / dur=158,634ms / `⚠️ minimax-portal/MiniMax-M3 request failed.`** → 真正根因在 journal 13:04:41：`[agent/embedded] failed to persist prompt error entry: **SessionTranscriptWriterClaimReboundError: session writer claim changed before transcript persistence**` ＋ `embedded run failover decision: decision=surface_error reason=none rawError=session writer claim changed…` ＋ `[diagnostic] lane task error: lane=nested:agent:rowlet:cron:9d8b6001…durationMs=478`。**同時窗 `model-fetch` 全 `status=200`、canonical 429 = 0 → 不是供應商問題，是「transcript 寫入權」被搶**。→ **診斷式**：`openclaw cron runs --id` 的 `error` 欄只是摘要，真因要 grep journal 的 `lane task error` / `failover decision` 的 `rawError=`；**看到 `MiniMax-M3 request failed.` 別直接歸因限額**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「receipt=error」≠「無巡檢紀錄」——與「降級跑 ⇒ 無紀錄」互為鏡像**（2026-11-23 16:02 實測）：gengar lane 在 `memory/keepalive-gengar-2026-11-23.md` 已寫出 `## 2026-11-23 13:02 — PASS …／🔴 新故障型別：transcript-ownership（13:02 attempt-1 硬失敗，本 session 為 retry 接手）`（mtime 13:14），但 job receipt 仍是 error → **查漏要分三種口徑**：dur<30s 的降級輪（當下無紀錄）／硬失敗輪（可能有替代紀錄）／真正漏做。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **dreaming 守門已補到 3 條重啟 arm 路徑（11-23 13:12–13:15，gengar lane 實作）＝上輪「守門要放在重啟共同入口」建議已落地**：`scripts/gw-node-guard.sh`（mtime 13:12、3,462B）與 `scripts/apply-dreaming-schedule.sh`（mtime 13:12、3,420B）都新增 dreaming guard（註解 `--- dreaming guard (added 2026-11-23 13:15) ---`），與 `scripts/discord-selfheal.sh`（6,607B、07:26）**共用同一檢查器** `scripts/dreaming-running-check.py`（9,589B、07:27、syntax OK）→ 先證明 dreaming IDLE 才允許動 gateway。實測 `--prefix 36b493db` → receipts/cron-list/window/clock/family-api **全部 idle**；三支 `bash -n` 全 OK；`memory/discord-selfheal-last-restart.ts` mtime 停在 **04:46** → 04:48 之後零重啟。**已知 arm 路徑的缺口已封；剩餘未封的是「人手動 systemctl restart」**（04:47 那次已證實是人）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **journal grep 必須加 `-a`，否則會數到 agent 自述裡的假 429**（2026-11-23 16:02 實測）：無 `-a` 的 `grep -c "status=429"` 在 13:02→16:02 窗回 **1**，但 `grep -a` 逐行列出後那唯一一筆其實是 `[agent:nested] session=agent:gengar:main …` 內文裡的「429」字樣 → **真值 = 0**（本窗 canonical 429 為零）。加上既有的「排除 `[agent:nested]`」，429 口徑現在是 **`grep -a` + 排除 agent:nested + `model-fetch.*status=429` 三條件**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **活紅單由 2 支升回 3 支**（2026-11-23 16:02 實測）：新增 `9d8b6001 Gengar Keep-Alive` ce=1（13:02 transcript-ownership，next 16:02 自癒）、`36b493db` dreaming ce=1（next **11-24 04:25**＝決定性驗證輪）、`c5352a84` ce=1（next 11-27）；`a94330a9` 仍為 enabled=false 殘留。`45ccf4e9 晨間情報` 連續第 3 輪自癒確認（08:00 ok / dur 1,081,044ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **配額牆連續第 2 天在 07h（07:29–07:59）**：24h `Token Plan usage limit reached: Upgra` = **58 筆全部落 07h**、canonical 429 同窗 **26 筆**（單 07:29 一分鐘 13 筆）；本 3h 窗（13:02→16:02）canonical 429 = **0**、真實 DNS = 0；24h canonical 429 合計 40 筆（逐時 00×1｜03×1｜05×2｜06×1｜**07×26**｜08×3｜09×1｜12×1｜18×1｜21×1｜23×1）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 16 次**（2026-11-23 16:02：gengar 16:02:02 → picturecat 16:02:08 → celesteela 16:02:10，間距 **6s / 2s**，非 5ms 級）；修法（拉開 ≥3 分鐘）仍待 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 13 輪仍未修**（2026-11-23 16:02：3h 窗 **425 行**、24h **3,298 行**、唯一 **17 檔**）→ **仍未授權，不動**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **11h14m 長乾淨段 + 守門未誤開火**（2026-11-23 16:02）：gateway MainPID 4137629、ActiveEnterTimestamp 2026-11-23 04:48:17（**04:48 事故後連續 11h14m 未重啟**）、`NRestarts=0`、node v24.22.3、`/health` 200 in 86ms；Discord 最後一筆 READY-fail = **04:47:09** → 至 16:02 **連續 ≈11h15m 零症狀**（3h 窗 READY-fail 0／channel exited 0／client initialized 0／host timing gap 0，reconnect 8 / websocket closed 8 ≈2.7/h）；selfheal `d4cd45bc` 13:13 / 13:43 皆 ok（dur 748ms）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **上輪交辦⑨ 的假設要修正**：`09c7940b PTCGP Meta Analysis` 不是 14:00 槽，而是**每日 20:05**（11-22 20:05 ok / dur 544,739ms、next 11-23 20:05）；`13ac4b5a 健康回報` 14:05:22 ok / dur 59,437ms → 兩者皆無 429。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **job receipt 的錯誤字串會誤導歸因：要看 journal 的 `rawError`**（2026-11-23 16:02–16:06 收尾對帳）：Gengar KA 13:02 receipt 的 err 寫的是 `⚠️ minimax-portal/MiniMax-M3 request failed.` → gengar lane 據此判「provider 失敗」；但 journal `embedded run failover decision: decision=surface_error reason=none from=minimax-portal/MiniMax-M3 rawError=session writer claim changed before transcript persistence` ＋ `lane task error: lane=nested:agent:rowlet:cron:9d8b6001…durationMs=478` 明確指出失敗在 **transcript 寫入階段**，且同窗 `model-fetch` 連續 8+ 筆全 `status=200`、canonical 429 = 0 → **provider 側無失敗證據**。→ **`MiniMax-M3 request failed.` 只是 runner 對 `surface_error` 的泛用文字，不可直接當根因**。附帶通則：**引用跨 lane 的 429 數字要連 3h 窗起點一起報**（gengar 窗內 1 筆 12:02:01.177 vs 我的 13:02→16:02 窗 = 0，同一事件、不同 anchor）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 交付進「正在跑的 cron session」會打死整輪 job（2026-11-23 16:07 現場重現）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **Protocol 規則（新）：不要把訊息交付進「正在執行中」的 cron run session**（2026-11-23 16:07 現場重現）：nested lane（gengar）的回覆在父 cron run 還在跑時被 `sessions_send` 投遞回父 cron session → **competing work in flight** → run-scoped lane 排隊超時（13:02 那輪 `waitedMs=43542`、本輪我自己的 job `waitedMs=31127`、gengar main lane `waitedMs=175731`）→ transcript ownership 不符（`Transcript session 2c986549… is owned by agent:rowlet:cron:9d8b6001, not …:run:2c986549…` → `SessionTranscriptWriterClaimReboundError`）→ `surface_error` → **整輪 job 判 error，且錯誤訊息被寫成 `⚠️ minimax-portal/MiniMax-M3 request failed.`（誤導成 provider 故障）**。本輪現場重現：`16:03:58` celesteela、`16:06:41` mrmime、`16:07:10` **我自己的 `02eb0989`（run bed0fda9）** 同簽章（我這輪最終仍 ok / 300,250ms，gengar 13:02 那輪則被打死）。**正確通道＝寫檔（`memory/keepalive-*.md`、`MEMORY.md`）或 `agent:<lane>:main`；要送 cron session 也得等該輪跑完。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **13:02 Gengar KA 紅單的完整因果鏈（provider 完全清白）**（2026-11-23 16:07 逐行複驗）：13:02:03–13:05:10 的 `[model-fetch] response` **62 筆全 `status=200`、零非 200** → **不是限額、不是 provider**；真正鏈條＝13:03:47 `Worker turn session key does not match its placement`（觸發：交付進基礎 cron session）→ 13:04:40.967 transcript ownership 不符 → 13:04:40.992 `lane wait exceeded waitedMs=43542 activeAhead=1` → 13:04:41.234 `Cannot delete session while competing work is in flight` → 13:04:41 lane task error（nested 478ms／session 482ms）→ receipt error（dur 158,634ms）。**gengar lane 的歸因（「provider 請求失敗」）不成立；它自述的「delivery fault」其實就是觸發器本身** —— 兩邊各對一半，合成版如上。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **診斷順序修正：cron receipt 紅單 → journal `lane task error` / `lane wait exceeded` / `competing work` → `model-fetch` 狀態碼 → 最後才懷疑供應商**（2026-11-23 16:07 實測）：receipt 的 `error` 字串是 runner 的泛用 surface_error 文字（`MiniMax-M3 request failed.`），**不能當根因**；`Cannot delete session while competing work is in flight` 是 fleet 級常態雜訊（24h ≥10 筆，橫跨 `02eb0989`／`ca222989`／`880b5c17`／`13ac4b5a`／`d7b0355b`／`e2b00e12`／`9d8b6001`），**只有疊上 lane wait 超時才致命**（11-22 16:07 同一支 gengar job 曾 `waitedMs=218581`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **同輪內發現對方歸因有誤時，先遵守新規則：不要為了「更正對方」再投遞一次訊息**（2026-11-23 16:07 實測）：gengar 16:02 輪仍在 running，此時 `sessions_send` 正會重演剛診斷出的傷人動作 → **更正改以檔案落盤**（gengar 讀得到同一 `memory/` 目錄），把「規則自己先遵守」當成硬約束。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — lane 序列化是真正瓶頸 + heartbeat 兩段死法（2026-11-23 19:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **「ce=0 洗掉整輪死亡」第 2 例，但這次死的是別人的 job（2026-11-23 19:02 實測）**：`bcf270b8 heartbeat-mrmime` 在 **16:01:07 error / dur=600,004ms「cron: job execution timed out」→ 16:11:38 error / dur=249,653ms「heartbeat failed: agent-runner-failure」**，16:31 起 6 連 ok → `state.consecutiveErrors=0` → **`openclaw cron list --all --json` 完全看不到**。→ **`ce=0` 不只會藏「自己的 job 死過」，也會藏「fleet 裡任何一支 job 死過」**；每輪巡檢必做 `openclaw cron runs --id <完整uuid> --limit 8`（至少覆蓋 heartbeat-mrmime／三支 KA／dreaming）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **heartbeat 的兩段死法（600s timeout → retry → superseded）＝可複用的因果模板（19:02）**：① agent lane 被同 agent 的其他 job 佔住 → cron 600s timeout；② retry 與同 agent dir 的 plugin generation 撞車 → `prepared model runtime plugin generation was superseded`（durationMs 3–4ms）→ `lane task error` → `Embedded agent failed before reply` → receipt error。**journal 證據全在 `[diagnostic]` 級**（`lane task error` ×6 ＋ `lane wait exceeded` ＋ `Embedded agent failed before reply`），`[provider-transport-fetch]` 全 200。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **「superseded 是良性」有條件（推翻前六輪無條件判讀）**：落在 KA lane 時只影響回覆落地（回覆照常送達，良性）；**落在 heartbeat lane 且有 retry 時會直接釀成紅單**（11-22 16:01、11-23 16:11 兩次 `bcf270b8` 紅單同型）。判準＝**看該 lane 對應 job 的 receipt**，不要只看簽章本身。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「heartbeat 600s timeout ＝ Discord 斷線的下游症狀」不完整（19:02）**：本輪 Discord 乾淨段 14h28m、READY-fail 0，600s timeout 純粹由 **lane 排隊**造成 → **修法方向要一併看 lane 序列化**，不能只盯 Discord。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **agent lane 是單執行緒排隊佇列＝「併發槽」模型的第二個維度（19:02，24h 26 筆 `lane wait exceeded`）**：最大等待 **roaringmoon 1,598,136ms（26.6 分，08:34:50 同時爆 9 筆）**、rowlet 1,408,923ms（23.5 分）、mrmime 401,138ms、gengar 220,495ms。**三支 KA 的 lane 歸屬實測**：`9d8b6001` Gengar KA 與 `02eb0989` Picturecat KA **同跑 agent:rowlet**（24h 101 / 50 筆）、`880b5c17` Celesteela KA 跑自己的 agent:celesteela（8 筆）→ **前兩支 anchor 只差 2–8 秒 ＝ 實質共用一條單執行緒 lane**（16:15 gengar 等 351,961ms＝5.9 分）。→ **anchor 錯峰門檻由「≥3 分鐘」升為「≥15 分鐘」**（單輪實耗 2–14 分），且最好讓兩支脫離同一 lane。**「併發槽」模型補一維＝同 agent lane 的工作數**（晨間情報 08:34 九筆同時排隊＝純 lane 問題、與 provider 無關）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **Discord/gateway 全綠基準（19:02）**：gateway MainPID 4137629、ActiveEnterTimestamp 04:48:17、**連續 14h14m 未重啟**、NRestarts=0、node v24.22.3、`/health` 200 in 1.3ms；Discord 8/8 connected；**乾淨段 ≈14h28m（最後 READY-fail + channel exited = 04:33:56）**；dreaming 風暴基準今日 `host timing gap` 4 筆（04:27/04:33/04:40/04:46）＝比 11-21(6)、11-22(6) 輕；selfheal `d4cd45bc` 6 槽全 ok 未誤開火（07:02 輪修的 fail-closed 守門持續有效）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 回應延遲確認「100–130 秒」是常態（19:02）**：本輪 elapsedMs=130,017（11-23 逐輪 117/161/105/101/117/130 秒）→ 「跌破 2 分鐘」確定是單點、不是趨勢。24h canonical 429 = 39、真實配額（`Token Plan usage limit reached: Upgra`）= 58 全部落 07h、529 = 0、真實 DNS = 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 17 次（19:02）**：gengar 19:02:02 → picturecat 19:02:10 → celesteela 19:02:12（8s / 2s，非 5ms 級）；superseded 競態噪音 3h 9 筆（良性）。**17 支 skill 缺 description 第 14 輪未修**（3h 238 行 / 24h 3,332 行 / 唯一 17 檔 / 每檔 196 次/日）→ 仍未授權，不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **巡檢覆蓋率查漏（19:02）**：Picturecat 本 job 今日 6 輪全有紀錄（dur 88.2s–1,238.3s，**無降級輪**）；Gengar 今日 6 輪全覆蓋（10:02 降級輪 12.8s 已由 lane 自報回填、13:02/07:02 硬失敗輪有替代紀錄）→ 三口徑（降級輪／硬失敗輪／真漏做）仍要分開。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — 19:02 輪（11-23）：ce 歸零 + SSH 來源定位到金鑰（2026-11-23 19:08 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **SSH 來源可用「金鑰指紋 → authorized_keys 比對」直接定位到人/機器，不必猜腳本**（2026-11-23 19:02 實測）：`journalctl | grep "Accepted publickey for .* from <IP>"` 取指紋 → `ssh-keygen -lf ~/.ssh/authorized_keys` 逐一比對。實例：192.168.50.2 近 2h **36 次**登入、近 30m **9 次**、**每 10 分鐘 3 次**（`:35` 長約 14s ＋ `:48`/`:49` 各約 1s，皆互動式 pty、journal 無 `Starting session: command`），指紋 `SHA256:BC2BuwA+zg3+yyNgs6bNP8xNawoVsSLfrKCpYVRiB6A` ＝ 本機 `authorized_keys` 的 **`linder@LAPTOP-MCBJQ92A`** → **來源＝Linder 自己的筆電**。→ **修正 11-23 04:47 那次 dreaming 窗內 gateway 重啟的結案**：不是「一次性人類互動」，而是**筆電端每 10 分鐘 3 次的固定 automation**；若它落在 04:25–05:05 會**第三次砍斷 dreaming** → 11-24 04:25 前必須確認筆電端那支排程。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本 job（9d8b6001）13:02 那次 error 是今天唯一一次，ce 已歸零**（2026-11-23 19:02 實測）：16:02 輪 receipt = **ok、dur 822.1s、error_text 空**（推翻上輪「可能被記成 error」的預測）、`consecutiveErrors=0` → 已從 fleet 紅單移除（紅單 3→2）；19:02 輪 dur 正常。**13:02 的根因＝投遞通道（provider 清白）已結案**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「lane wait ≠ job error」：疊窗的威脅等級要分兩層判**（2026-11-23 19:02 實測）：16:15:46 本 job 被 `lane wait exceeded waitedMs=351,961`（351.9s）→ **該輪 receipt 最終仍是 ok**。→ **anchor 疊窗（第 16/17 次）目前只造成延遲＋雜訊（stalled session、superseded、competing work），未造成本 job 失敗** → 修法（拉開 ≥3 分鐘）威脅等級由「致命」下修為「中」。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **「要問別的 lane 就寫檔、絕不投遞進正在跑的 cron session」的新規則實測有效**（2026-11-23 19:02 首次零反彈）：探針內明確禁止 `sessions_send` 回投 cron session → 耿鬼照做（只寫 `memory/keepalive-gengar-2026-11-23.md`），19:0x 窗**沒有再出現投遞型 lane task error**；且去程讀回＋回程落檔同時成立、token `LANE_OK_GENGAR_1902 = 6`、**數字三方一致**（3h 真實 429 = 1、60m = 0、DNS runtime truth = 0、cron timeout = 0）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **關鍵字計數一定要抽樣逐行看，口徑會漂**（2026-11-23 19:02 實測）：grep `overflow` 得到的 6 筆其實是 **07:29 gengar main 的 context-overflow 事件**，不是 Discord 100 指令限流（後者 24h 仍 0 筆）。與「自報文字迴音」同類：計數樣式會被 agent 的敘述文字命中。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **量「自己」的 openclaw 行程要用 systemd 的 `MainPID` + `ActiveEnterTimestamp` + `NRestarts`**（2026-11-23 19:02 實測）：`pgrep -f 'openclaw/dist/index.js'` 會命中**agent 自己正在跑的 CLI process** → 耿鬼因此連兩輪報錯 gateway uptime（報 00:06，真值 ≈14h18m）；真值 = MainPID 4137629、04:48:17 起、NRestarts=0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🟢 **429 不是「已恢復」而是「零星復發」**（2026-11-23 19:02 實測）：12:02→18:02 乾淨 6 小時後，**18:02:49 又 1 筆 canonical 429（elapsedMs=130,017）**；24h canonical = 39（07:xx 單時段佔 26 筆）；`status=529` = 0；真實 EAI_AGAIN = 0（3h 窗 4 筆命中全是自報／自寫文字迴音）；「Token Plan usage limit」3h 窗 = 0 → **07:00 那場配額牆未復發**。→ **別再引用「elapsed 續跌」敘事**（90.5s → 130.0s 是反轉）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — self-heal 會反噬關鍵 job：11-23 04:48 dreaming 腰斬的完整因果鏈（2026-11-24 01:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **自動重啟機制會殺掉它正要保護的對象——這是 11-23 那次事故的完整因果鏈（2026-11-24 01:02 實測，journal × cron receipt 交叉驗證）**：`36b493db Memory Dreaming Promotion` 04:25 起跑 → 併行觸發各 agent deep-phase narrative → **event loop 凍結**（04:33:56 `eventLoopDelayP99Ms=286,689ms`、04:46:16 `=306,285ms`、`eventLoopUtilization=1`）→ `host timing gap detected: process was frozen ~146s/~266s/~279s` → health-monitor 想重啟 channel 但 `host thaw channel restart deferred: gateway still has active work` → Discord channel 掉線（`channel exited: discord gateway opened but did not reach READY within 30000ms`）→ **04:46:17 `d4cd45bc` self-heal 開火**（slot 應為 04:43，**因凍結延遲 3 分鐘**）→ stdout `discord broken and dreaming idle -> scheduling gateway restart in 10s`，**但 dreaming 當時正在跑**（`agent:rowlet:cron:36b493db:…:run:7e6f09dd` state=processing age=206s）→ 守門的「dreaming idle」判定**錯了** → arm 重啟 → **04:48:17 gateway 重啟 → dreaming 在 04:48:26 被砍**（dur=1,406,869ms＝23.4 分，receipt `cron: job interrupted by gateway restart`，ce=1）。→ **通則：守門條件只要有一項是用「查詢狀態」實作，狀態查詢一旦 fail-open 就會反噬**；判定「某 job 沒在跑」必須同時用**獨立於該查詢**的訊號（未完成 receipt 列 + 時鐘窗 + API 失敗即視為「在跑」）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **11-23 07:02 的兩項修法正好切斷這條鏈（守門 fail-closed + 排程排除 04 整點 `13,43 0-3,5-23`）→ 2026-11-24 04:25 槽是決定性復驗**：即使再凍結、再掉線，也不會再有外部重啟去砍 dreaming；殘餘風險只剩 gateway 內建 health-monitor（idle 時才重啟 channel）與 dreaming 自身 2400s timeout（最晚 05:05 收）。**04:02 輪確認 expr 未被改回；07:02 輪驗收 receipt + gateway MainPID/ActiveEnterTimestamp 是否變。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「降級輪」口徑第一次抓到本 job 自己的實例**：11-23 22:02 那輪 receipt = **ok / dur=21,550ms（21.5s < 30s 門檻）**，summary 是通用模板（「Keep-alive OK — scheduled run fired and executed cleanly」），**完全沒寫 memory 檔**（11-23 檔 mtime 停在 19:05、`grep -c "2026-11-23 22:02 —"` = 0）→ **11-23 全天 = 8 次 run、7 個 `## ` 段落、1 個零紀錄降級輪**。⇒ 「檔案段落數 ≠ 實際 run 數」得到第一個直接反例；**查漏做必須用 `cron_run_receipts` 的 dur 明細 vs 當日檔 `^## ` 段落數**（MEMORY 19:02 輪寫的方法第一次派上用場）。**根因仍是 payload 只有一句 `keep-alive test`、沒有必做清單**（深度由 agent 自決）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **跨 lane ping 不是免費的：會在目標 agent dir 製造 superseded 競態（2026-11-24 01:02 實測）**：我 `sessions_send` → `agent:picturecat:main` 得到 pong 的同一毫秒區間，picturecat agent dir 立刻出現 2 筆 `prepared model runtime plugin generation was superseded`（lane=nested + lane=session、durationMs=**5**）→ ping 觸發目標 agent 的 runtime 重新生成並與既有生成撞車。落在 KA lane 仍屬良性（回覆照常落地），**但要知情**。→ 與 16:07 教訓的差別：16:07 禁的是「投遞進**正在跑的 cron run session**」；ping main lane 不同，且本輪 0 lane wait。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **cron CLI 的 JSON 欄位位置（踩過一次坑）**：`timeoutSeconds` / `fallbacks` / `model` 都在 **`.payload` 底下**，不在 job 頂層（查頂層會全拿到 null，會誤判 dreaming 沒 timeout）；dreaming 實際 `payload.timeoutSeconds=2400`。時間欄位用 `state.lastRunAtMs` / `state.nextRunAtMs` / `state.lastDurationMs`（**不是** `lastRunDurationMs`）。short id 查 runs 會回 "Automation not found" → 要完整 UUID。self-heal stamp 檔在 **`memory/discord-selfheal-last-restart.ts`**（不是 `~/.openclaw/state/`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **dreaming 併行會把 cron slot 拖遲（觀察時鐘的教訓）**：11-23 04:43 的 self-heal slot **實跑在 04:46:17**（延遲 3 分鐘，因 event loop 凍結）→ **判斷 self-heal 何時觸發一律用實際 `runAtIso`，不要用 expr 推算**。同理，429 尖峰與 KA 槽的對齊也要用實際 runAt。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本輪基準（2026-11-24 01:02）**：Discord 8/8 connected，**6h 窗（19:02→01:02, 1,308 行）READY-fail 0 / channel exited 0 / client initialized 0 / disconnected 0 / health-monitor 0 / host timing gap 0 / event-loop starvation 0 / lane wait exceeded 0**；reconnect 23 + websocket closed 23 ≈ 3.8/h（基線 2.6–3/h）；EAI_AGAIN 僅 1 筆；gateway MainPID 4137629、**連續 20h14m 未重啟**、NRestarts=0、/health 200 in 1.3ms；fleet 46 enabled → **ok 38 / error 2**（`36b493db` dreaming ＝ 被 self-heal 腰斬、`c5352a84` ＝ 11-20 DNS 舊因、next 11-28）/ skipped 5 / none 1；self-heal 19:13→00:43 **12 槽全 ok**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 18 次，且本輪 6h 內 2 筆 canonical 429 直接落在 :02 KA 槽**（21:01:52 / 23:01:29 / 23:03:42 / 00:02:35 → 23:01 與 00:02 兩組）→ 再次支持 **拉開 ≥15 分鐘**（原建議 ≥3 分鐘不足，見 11-23 19:02 輪量測：單輪實耗 picturecat 21.5s–1,238s、gengar 8.8s–822s、celesteela 90–416s）。真實配額 `Token Plan usage limit reached` 24h = 58 筆**全在 07h**（11-23 07:29–07:59 ＝ 07:00 槽配額牆），近 3h = 0 筆；`status=529` = 0。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **DNS 根因仍未除**：`resolvectl status` 顯示 **Link 2 (enp43s0) Current Scopes: none** → DNS 100% 靠 wlp0s20f3（Wi-Fi）+ tailscale0。本輪症狀僅 1 筆/6h（11-20 曾 755 筆/小時）＝症狀改善但**結構性風險未動**（待 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — 01:02 輪（11-24）：fallback 零冗餘 + 假重啟簽章 + 兩種 429 口徑（2026-11-24 01:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **fallback 鏈「寫了 ≠ 能用」：minimax 兩路全 429 時 job 直接死（本輪 07:02、13:02 兩次實測）**。本 job payload 的 fallbacks = `minimax/MiniMax-M3` + `minimax-portal/MiniMax-M2.7`，但 07:29 補跑的錯是 **`Explicit auth order for openai has no usable profiles`**（11-19 舊 receipt 同款 `All models failed (4) … rate_limit`）→ **跨廠冗餘＝0**：一旦 minimax 兩路配額/限流同時爆，cron job 直接死（ce=1）而不是降級存活。→ 修法二選一：**(a) 補一個可用的 openai profile（auth order 要有 usable profile）**；**(b) 把 provider 失敗判定寫進 payload**，讓 job 在全模型失敗時仍能完成「存活簽章」。**註：MEMORY.md 早前記的「4 個 fallback 全 MiniMax、跨廠冗餘 0」只說對了一半——實際 pool 還含 openai，但 openai 因 auth 無 usable profile 而不可用。**
- ⭐⭐ **journal 裡的 `systemctl --user restart openclaw-gateway` 字樣必須分辨真偽，否則會把 agent 訊息迴音算成重啟（本輪實測）**：**真指令**＝`systemd[1151]: Started /usr/bin/systemctl --user restart openclaw-gateway.`（本輪 24h 只有 04:46:50 / 04:47:46 兩筆）；**假訊號**＝`node[…]: […][agent:nested] session=… systemctl --user restart openclaw-gateway`（agent 把自己報告的文字寫進 log，13:04:50 / 13:15:58 兩筆）。→ **數真重啟只認 `systemd[pid]: Started /usr/bin/systemctl …` 這類行首前綴**；真正的重啟真相仍以 `systemctl --user show openclaw-gateway -p MainPID -p NRestarts` 為準。
- ⭐ **兩種 429 口徑要分開數，否則會誤判配額牆狀態（本輪 24h：canonical 43 vs usage-limit 文字 58；3h：3 vs 0）**：`model-fetch.*status=429` ＝ canonical（provider 真的回 429）；`Token Plan usage limit reached` ＝ **大多出現在 agent 的錯誤回報文字裡，不是 model-fetch 行** → 判斷「配額牆有沒有打到」**只能用 model-fetch 口徑**（本輪 3h 窗 usage-limit 文字 = 0 → 配額牆本窗未觸發，只有一般 rate-limit）。
- ⭐ **「dur<30s ≈ 降級跑」的後果再確認：降級輪不只是短，是根本沒寫檔**（本輪實測）：`02eb0989` Picturecat KA 22:02 輪 dur=**21,550ms**，而 `memory/keepalive-picturecat-2026-11-23.md` 的 `^## ` 段落只到 **19:02（第 7 輪）**、**22:02 槽完全沒有紀錄** → **數某日某 lane 檔的 `^## ` 段落數＝該 lane 當日真正巡檢了幾輪**，比翻 transcript 省事。
- ⚠️ **兩條 KA lane（gengar / rowlet）會寫到同一個 keepalive 檔名**（本輪實測：`memory/keepalive-gengar-2026-11-24.md` 由 gengar lane 先寫、rowlet lane 同名）→ **寫入一律 append，不要覆寫**，否則重演 11-22「1 輪紀錄寫錯檔、1 輪完全沒留檔」。**根治＝兩 lane 分檔（需 Linder 點頭）。**
- ✅ **「不投遞進 cron session」新規則連續第 2 輪生效**（22:02、01:02）：gengar lane 自報「未用 sessions_send 投遞進 rowlet 的 cron session、也未 announce 到任何外部頻道」，只寫檔 → **跨 lane 問答＝寫檔 + 內文回覆**，零反彈。
- ⏳ **dreaming 守門修法已就位，但驗證點仍未到**：`scripts/dreaming-running-check.py`（11-23 07:27）+ `discord-selfheal.sh` 第 2 步已改呼叫它（守門守住了）；**決定性驗證＝11-24 04:25 那次跑完（dur ≥30 分 且 status=ok）**，只有 07:02 輪能讀到結論；`memory/dreaming-schedule-check.log` 已停擺 5 天、`memory/gw-upgrade-guard.log` 仍不存在 → **04:25 前置沒有前瞻簽章**（未授權，仍不動）。

## Picturecat Keep-Alive 巡檢 — elle.service 43 天重啟迴圈 + ce=0 洗掉第 3 例 + sshd 污染簽章（2026-11-24 04:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **新故障型別 #5：`elle.service` 跑了 43 天的崩潰重啟迴圈（本輪首次發現）**：`/etc/elle.sh Compatibility`（systemd 系統單元、`Restart=on-failure`、ExecStart=`/etc/elle.sh` → `. /home/amr/elle_builder_package/exec/simulation.sh`）→ 腳本 sleep 30 秒後 **exit 1** → systemd 每 ~31 秒重啟一次；**NRestarts=119,872**（與 host uptime 43d9h49m 對得上 ≈43 天 × 3/分鐘）→ **從開機起就沒停過**。CPU 佔用極低（1ms/次），但每 30 秒 fork 一組 bash+sleep、systemd 每次寫 4–6 行 journal → 永久系統層噪音源。**與 openclaw 完全無關**（別誤判成 openclaw 的自癒機制在動）。修法＝`systemctl disable --now elle.service`（root 擁有，未經 Linder 點頭不動；本輪零改動）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「ce=0 洗掉整輪死亡」第 3 例，而且兩支死在同一場 3 分鐘網路事故**（11-24 03:00–03:05）：`40e09cd1 Jormungand daily all-agent health` 03:00 error（429 / dur=115,867ms）→ 03:02 重跑 ok（865,320ms）；`ca222989 OpenClaw 系統維護` 03:04:49 error（`All models failed (3): fetch failed`）→ 03:05:32 重跑 ok → **兩支 consecutiveErrors 都被洗成 0，`cron list --all --json` 完全看不到**。根因＝同一場事故：03:04:50 `ENETUNREACH`（15ms）→ 03:04:51 `ENETUNREACH`（1,032ms）→ 03:05:02 `EAI_AGAIN api.minimax.io`（10,014ms）→ **fallback 鏈三候選全滅（next=none）**。→ **每輪必做全 fleet receipt 掃描**（53 支 job 各取最近 6 筆 receipt 比對 `status=error`，約 1.5 分鐘），不能只看 `cron list` 的 `lastStatus`。<br/>**附帶：`embedded run failover decision` 的 `reason=timeout` 但 `rawError=fetch failed` —— reason 欄位會把網路層斷線寫成 timeout，歸因要看 rawError。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **簽章 grep 的污染又多一種來源：sshd**（本輪實測）：naive grep `disconnected` 得 **54 筆**、逐行看**全部是 sshd 的 `Received disconnect from 192.168.50.2`**（＝筆電 tunnel）→ **Discord disconnected 實際為 0**。→ **凡簽章名與其他服務共用（如 disconnected / session / timeout）必須逐行看前綴**（本機 journal 每行開頭是 `十一月 24 04:05:00 amr-… sshd[212524]:` 或 `… node[4137629]:`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **筆電端那支每 10 分鐘 3 次的 SSH automation「不執行任何指令」→ 前輪待決事項可降級**（本輪實測）：192.168.50.2（金鑰 `SHA256:BC2BuwA…` ＝ `linder@LAPTOP-MCBJQ92A`）3h 內 54 筆、30m 內 9 筆（末筆 03:57:48），**每個 session 都沒有 `Starting session: command`** → 登入後沒跑指令（純 tunnel/keepalive）；且 gateway **23h14m 內零重啟** → **它不是 11-23 04:47 那次重啟的元凶**（那次＝self-heal 開火，11-24 01:02 已定案）→ 「04:25 前必須確認筆電排程」從待決降為觀察；dreaming 殘餘風險只剩 gateway 內建 health-monitor（idle 才重啟 channel）＋ dreaming 自身 2400s timeout（最晚 05:05 收）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **跨 lane ping 的副作用第 2 次重現（可重現，非偶發）**：`sessions_send` → `agent:picturecat:main` 得到 pong 的同一毫秒，picturecat agent dir 出現 **2 筆** `prepared model runtime plugin generation was superseded for /home/amr/.openclaw/agents/picturecat/agent`（lane=nested + lane=session、durationMs 6/7）→ 本窗 `lane wait exceeded` = 0 → 落在 KA lane 仍良性（回覆照常落地）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **04:25 dreaming 槽前置條件全數就位（04:02 輪，剩 20 分鐘）**：self-heal expr `13,43 0-3,5-23` ⇒ **04 整點不跑**（receipt 證明 01:43→03:43 六槽全 ok、next 05:13）；守門三支 arm 路徑共用 `scripts/dreaming-running-check.py`（07:27）；stamp `memory/discord-selfheal-last-restart.ts` 停在 1795380377（11-23 04:46）→ 04:48 之後零重啟；gateway MainPID 4137629 連續 23h14m 未重啟。窗內只剩 3 支 job（05:00 / 05:05 / 05:05:20）。**判定＝07:02 槽驗 receipt（dur ≥1,800,000ms 且 status=ok）＋ MainPID 未變。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA anchor 疊窗第 19 次**：gengar 04:02:02.639 → picturecat 04:02:12.745 → celesteela 04:02:12.750（**10.1 秒 / 5ms**，同一組數字連續三輪）→ 「拉開 ≥15 分鐘」持續成立。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 17 輪仍未修**：3h 窗 255 行、唯一 17 檔（13 支 `description is required` ＋ 4 支 `invalid frontmatter`）、每檔每 3h 15 次 ≈120 次/日 → 未授權不動。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **本輪基準（2026-11-24 04:02）**：Discord 8/8 connected；3h 窗（1,335 行）READY-fail 0 / channel exited 0 / client initialized 0 / Discord disconnected 0 / health-monitor 0 / host timing gap 0 / event-loop starvation 0 / lane wait exceeded 0；reconnect 15 ＋ websocket closed 20；canonical 429 3h 窗 1 筆（elapsedMs=105,849）、24h 40 筆（07h 佔 26）、真實配額 24h=58 全在 07h、529=0；真實 DNS/網路錯誤 24h ＝ EAI_AGAIN 1 + ENETUNREACH 2（同在 03:04–03:05 那場）；fleet 46 enabled → ok 38 / error 2 / skipped 5 / none 1（紅單仍 2 支皆舊因）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — provider 失敗要四分法、600s idle timeout 會拖出 stalled session、cron 真相要從 CLI 讀（2026-11-24 04:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **provider 失敗要分四型計數，混算會把「網路事故」誤記成「provider 端問題」**（本輪實測）：①canonical 429（配額）`[provider-transport-fetch] [model-fetch] response … status=429 elapsedMs=…`；②**ENETUNREACH**（連線）`… [model-fetch] error … causeName=AggregateError causeCode=ENETUNREACH message=fetch failed`；③**EAI_AGAIN**（DNS）`… code=EAI_AGAIN message=getaddrinfo EAI_AGAIN api.minimax.io`；④**LLM idle timeout (600s)** `… message=LLM idle timeout (600s): no response from model`。本輪 03:04:50/03:04:51 ENETUNREACH → 03:05:02 EAI_AGAIN → 03:14:48 idle timeout。
- ⭐⭐ **連線層故障會「一次打穿整個 provider 家族」＝fallback 鏈的廠商冗餘真的是 0**：本輪三個候選（minimax-portal/MiniMax-M3、minimax/MiniMax-M3、minimax-portal/MiniMax-M2.7）在**同一個 3 分鐘網路事故**裡同時掛掉；配額型 429 只會讓 job 慢（elapsedMs 89k–130k），連線型故障則是全滅 → 要真冗餘必須有**非 minimax 家族**的可用 profile。
- ⭐⭐ **「stalled session」要往上游查 elapsedMs，不要怪 gateway**：本輪 3h 窗 stalled = **10**（03:11:02→03:15:32、每 30s 一筆、**全為同一 sessionKey** `agent:mrmime:cron:40e09cd1`）＝上游 `LLM idle timeout (600s)` 掛住整整 10 分鐘；該輪最後只留「The tool run finished, but no final summary was produced.」（`settled-finalization-fallback` 收尾）。**判定式**：`[diagnostic] stalled session: sessionKey=…` 連續 ≥10 筆 → 上游 hang；此時 gateway MainPID/NRestarts 未變即可排除 gateway 因子。**這是本系列第一次量到 stalled > 0**。
- ⚠️ **耗時欄位是 `elapsedMs=`，不是 `elapsed=`**：`grep -oE "elapsed=[0-9,]+ms"` 永遠空；要用 `elapsedMs=[0-9]+`。24h 末 8 筆 429 耗時＝109,109 / 90,510 / 130,017 / 106,188 / 89,046 / 116,722 / 106,578 / 105,849 ms → 帶 90–130s，**不宣告恢復**；600,104ms ＝ idle timeout 的極端值。
- ⭐ **cron 真相要從 CLI 讀**：`automations` 工具在本 agent 視角回 `jobs: []`、且 `get/runs` 對本 job id 回 not found → 改用 `openclaw cron list --json`（CLI 經 gateway，46 支全見）。jq 形狀：`.jobs[] | select(.name|test("Keep-Alive";"i")) | [(.id[0:8]), .name, .lastRunStatus, .state.consecutiveErrors, ((.nextRunAtMs/1000)|todateiso8601), .state.lastDurationMs] | @tsv`。**坑**：ms 直傳 `todateiso8601` 會爆成 58865 年，必須先 `/1000`。
- ⭐ **dreaming「開跑前」前置核對清單（可重用）**：`cron list` 讀 dreaming job 的 `nextRunAt` + payload `timeoutSeconds` → 推出結束時刻；`discord-selfheal-after-dreaming` 的 nextRunAt 應落在結束後數分鐘（守門在位，本輪 05:13 CST = 04:25+2400s=05:05 後 8 分鐘）；再用 `grep -ohE "[A-Za-z0-9_./-]*\.log" scripts/*.sh` 取守門腳本**真正**寫的 log 路徑（`gw-upgrade-guard.log` 真路徑＝`/home/amr/.openclaw/logs/`），避免「查錯路徑」被誤判成「檔案不存在」。
- ✅ **lane 回程新規則第 3 輪生效**：token `LANE_OK_GENGAR_0402_24 = 7` 逐字一致；對方自撰段落以 **append** 寫入同一檔（15,209 B → 本輪我方段落後 25,181 B，4 段），未覆寫、未投遞進 cron session、未 announce 外部。
- ⚠️ **KA anchor 疊窗第 19 次（連續三輪同一組數字）**：gengar 04:02:02.639 → picturecat 04:02:12.745 → celesteela 04:02:12.750 → **10.106s / 5ms**；上輪三支 dur 390.7s / 392.4s / 196.4s 全 >30s（無降級跑），但 picturecat 11-23 仍只有 7 段（**22:02 槽 dur 21.5s 無紀錄**）、celesteela lane 完全不留檔。

- ✅ **11-24 04:25 dreaming 槽驗收完成（04:02 輪的開放問題已結案）**：`36b493db` 實跑 04:25:01→dur **1,816,088ms（30.3 分）status=ok、未被腰斬**；Discord 風暴 04:27:53（8× ws closed 1000）→04:33:30（7 帳號 channel exited）→**04:55 最後一次 exited**→**05:00 client 重新 initialized，05:00 後 0 筆 READY timeout** ⇒ **失明 ≈33 分鐘、靠 dreaming 自己結束收斂**；gateway MainPID 4137629 / ActiveEnterTimestamp 11-23 04:48:17 / NRestarts=0（**26h14m 未重啟**）。⇒ **現行 self-heal expr `13,43 0-3,5-23` 排除 04 整點＝「保 dreaming、棄 Discord 救援」的取捨**，dreaming 預算 2400s 意味最壞失明可達 ~40 分。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🔴 **minimax-portal 429 已開始打紅單**：近 24h **44 筆** status=429（全來自 minimax-portal）、近 6h 7 筆；`每日論文討論`（`58fe15dc`，cron `0 7 * * *`）07:00 輪 **error / ce=1**（elapsedMs=79059、124312 兩筆 agent end isError）。**fallback 鏈實質冗餘＝0**：`minimax/*` 與 `minimax-portal/*` 共用額度池、`openai/gpt-5.4-mini` Auth=no → 需補第二廠商或錯開 07:00 job 密度。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — 07:02 輪（11-24）：探針失敗≠lane 死亡 + receipts 才是真相 + dreaming 驗證通過（2026-11-24 07:02 實測）
- ⭐⭐ **單次 `sessions_send` 探針失敗**不可直接定性為「lane 死亡」：本輪第一次探針回 status=error（07:04:30 `⚠️ minimax-portal/MiniMax-M3 request failed.`），但同一分鐘段**被探 lane 自己的 cron 也被打死**（gengar `88810bfe` error_text=`All models failed (3): … getaddrinfo EAI_AGAIN api.min…`、`ac9e7ada`=⚠️ API rate limit reached）＋本窗 canonical 429 落在 07:02:05/07:03:28 → **探針與被探 lane 同時被同一個 provider/網路事故命中**。**定性程序＝(a) 重試一次（第二次 ok、token 逐字一致）(b) 用被探 lane 自家 cron 的 receipt error_text 交叉歸因**。否則會把 provider 事故誤報成 lane 死亡。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **`cron_run_receipts` 才是 cron 真相的權威來源**（`state/openclaw.sqlite`，read-only python sqlite3；**本機無 sqlite3 CLI**）：`SELECT job_id,status,started_at_ms,finished_at_ms,error_text FROM cron_run_receipts WHERE started_at_ms BETWEEN ? AND ?` ＋ join `cron_jobs.name` → per-run status/error/dur 一次到位。**三個口徑陷阱**：① 每 ~30s 一張 cron 狀態表會重印「每支 job 的最後一次錯誤」→ grep `All models failed|EAI_AGAIN` 3h 窗得 169 行（灌水數十倍），事件數一律以 receipt error_text 為準；② `/stall/i` 假陽性命中 a2a-gateway plugin 的 `in**stall**ed plugin package requires compiled runtime output`，真 stalled signature 必須是 `stalled session: … sessionKey=… age=… queueDepth=0`；③ `[model-fetch]` transport 層**會漏掉 DNS 事故**（本輪 receipts 顯示 04:04:59、07:04:57 兩波 fleet 級 EAI_AGAIN，transport 層 0 行）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **dreaming 11-24 04:25 決定性驗證通過**：receipt status=**ok**、dur=**1,816,088ms（30.3 分）**、ce=0（三夜來第一次完整跑完；11-23 同槽為 `cron: job interrupted because owner is unavailable`）。守門 `d4cd45bc` 05:13/05:43/06:13/06:43 全 ok、dur 750–863ms，gateway MainPID 4137629 / NRestarts=0 / 連續 26h20m 零重啟 ⇒ **self-heal fail-open 腰斬 dreaming 的問題在 04:25 這輪未再發生**（可與 MEMORY 既有「selfheal 守門 fail-open 腰斬 dreaming」那節並讀）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🔴 **新失敗型別：fleet 級 heartbeat 600s timeout 群集**（2026-11-24 04:27–06:12 實測）：picturecat / roaringmoon / mrmime / gengar / rowlet / celesteela **6 支 heartbeat 同窗全部 `cron: job execution timed out`**（dur 600,003–669,588ms）→ 這是 429 擠壓的**次生效應**（heartbeat 被排隊拖到 600s 上限），不是 lane 死亡（下一輪全部恢復 ok）。同窗 `ae91b967`（每日 LLM Wiki 巡讀與擴寫 05:30）與 `58fe15dc`（每日論文討論 07:00）被 429 打死＝**rowlet 自家的實質損失**，兩支與 KA 同時段起跑，建議錯開 07:00–07:10 槽密度。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **receipt status=ok ≠ 有產出**：`40e09cd1`（Jormungand daily all-agent health）11-24 03:00 error（429, 115,867ms）→ 03:02 retry **ok**（865,320ms）但 summary = `The tool run finished, but no final summary was produced.` → 查漏必須讀 summary 內容，不能只看 receipt status（11-23 同槽是完整 10/10 PASS 報告）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📌 **本輪量測（供下輪對帳）**：3h 窗 canonical `status=429` = **6**（上輪 1）：133,353 / 98,980 / 156,070(新高) / 79,059(新低) / 124,312 / 113,891 ms；24h = 42；**配額牆文字 `Token Plan usage limit reached` 3h = 0**（仍未觸發，不宣告恢復）；transport 層 error 僅 3 筆 AbortError。KA anchor 第 20 次疊窗：picturecat↔celesteela **0.6ms**、gengar↔picturecat ≈12.4s。17 支 skill 缺 description 第 18 輪未修（今日 1,547 行 × 17 檔）。Discord 3h reconnect 64 / ws closed 58（上輪 15/15，出現 `invalid-session, resume=false` 群連）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 10:02 輪（11-24）：user-unit 坑 + 「ce=0 洗掉整輪死亡」第 4 例 + runs 的 jq 形狀（2026-11-24 10:02 實測）
- ⭐⭐ **gateway 健康必須用 `systemctl --user`，system 層查會誤判「掛掉」**（2026-11-24 10:02 實測）：`systemctl show openclaw-gateway` 回 **`MainPID=0`、`ActiveState=inactive`、`ActiveEnterTimestamp=n/a`**（gateway 是 **user unit**，`systemctl --user show openclaw-gateway` 才對：MainPID=4137629、NRestarts=0、ActiveEnterTimestamp=11-23 04:48:17 CST → 連續 **29h14m** 未重啟；`ps` etimes=105,303s 佐證）。⇒ **system 層的 `openclaw-gateway` 查不到是正常的（user unit），不是故障**；`elle.service` 反之是 **system** unit（system 層查、ActiveState=activating）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「ce=0 洗掉整輪死亡」第 4 例：heartbeat-mrmime 08:11→08:21 硬死（600s timeout），40 分鐘內自癒並把證據洗掉**（2026-11-24 10:02 實測）：`bcf270b8` receipt = `2026-11-24T00:21:35Z error 600000ms "cron: job execution timed out"` → 08:30 ok/501s → 08:31 ok/7s → 09:01/09:31/10:01 `skipped: quiet-hours`；**紅單掃描（`state.lastRunStatus`+ce）完全看不到**（末態 ok、ce=0）。**這是 mrmime heartbeat 第二次同型死法**（11-23 16:01 為 600s timeout → 16:11 `heartbeat failed: agent-runner-failure`）→ **heartbeat 類 job 的 10 分鐘 timeout ＝ 定時炸彈**。**可操作規則：每輪固定對 `bcf270b8` 跑 `cron runs --id`，不要只信紅單清單**；修法＝拉高 heartbeat 的 timeoutSeconds（>1200s）或讓它 600s 內主動結束（改 job 需點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **retry 也會洗掉紅單（40 分鐘內無痕跡）**（2026-11-24 10:02 實測）：`每日論文討論`（`58fe15dc`）07:00 輪 **error/208s（`⚠️ API rate limit reached`）** → **07:12:06 retry ok/486s** → ce=0 → 紅單清單只剩 1 支舊因 job。⇒ 「紅單清單乾淨」≠「這段時間沒紅過」；查 429 量測要看 journal，不看 ce。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`openclaw cron runs --id` 的 jq 形狀＝`.entries[]`**（2026-11-24 10:02 實測，踩過）：`(.runs//.items//.)[]` 會炸 `Cannot index array with string "runAtMs"`；正確為 `openclaw cron runs --id <uuid> --limit 8 | jq -r '.entries[] | [(.ts/1000|todateiso8601), .status, ((.durationMs//0)/1000|floor), (.error//"")] | @tsv'`（欄位：`ts`=結束時間、`runAtMs`、`durationMs`、`error`、`summary`）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **Discord 兩種「ws closed」要分型**（2026-11-24 10:02 實測）：近 3h 13 筆 `gateway websocket closed flow=…`＝**resume flow 良性續連**（09:26/09:28/09:32/09:45/09:54/09:58…），與 04:27-04:55 那種「8 筆 `code 1000` 整批換 client」不同型；本窗 **0 筆 READY、0 筆 channel exited** → **Discord 連續 5h 零症狀（05:00 起）**。判別式：**有 `flow=` 且無 READY timeout＝良性**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **429 量測有兩套口徑，別混算**（2026-11-24 10:02 實測）：`grep "status=429"` → 近 3h **4**、近 6h **9**、近 24h **19**（其中 16 筆明列 `provider=minimax-portal`）；`grep -ci "rate limit"` → 24h **45**。往輪的「24h=44」是後者口徑 → **兩輪數字不可直接比較**。對應 4 筆 `agent end isError=true`（07:03/07:04/08:01/08:32/09:02）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **KA anchor 疊窗第 21 次**：`state.nextRunAtMs` ＝ gengar `1795485723291` → picturecat `1795485735412` → celesteela `1795485735418`＝**12,121ms / 6ms**。三支 KA 今日全綠（Picturecat 07:02 dur=170,696ms、Gengar 539,317ms、Celesteela 614,821ms；Picturecat 今日 3 輪 dur=392s/390s/170s **無降級輪**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📌 **本輪量測（供下輪對帳）**：uptime 43d15:49、load 0.91/0.61/0.51、RAM available 20Gi、`/` 61%（178G free）；`elle.service` NRestarts **120,585**（上輪 120,229 → **+356/3h**）、24h 5,712 次啟動；DNS 近 3h 3 筆 EAI_AGAIN/ENETUNREACH **全在 gengar nested session 行內**（本 lane 0 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **`task_runs.terminal_summary` 才是「這一輪到底產出了什麼」的權威來源**（2026-11-24 10:02 實測）：receipt 只有 status/dur，看不出一輪寫了什麼；`task_runs` 有 `terminal_summary`（＋`terminal_outcome` / `status` / `created_at` / `ended_at`）。兩個用途：① **找「receipt=ok 但內容空」**：`WHERE terminal_summary LIKE '%no final summary was produced%'` → 全期 14 筆，**10 筆集中在 mrmime lane 的 健康回報(7) + OpenClaw 系統維護(3)**，Jormungand 只是首例 → 改 payload 的對象是 mrmime 那兩支，不是 Jormungand。② **`length(terminal_summary)` 是降級 run 的簽名**（≈8 = 只有 token 的空殼；≈2000 = 完整一輪）→ 例 11-23 10:02 celesteela dur=255,335ms 看似健康但 summary_len=8，**receipt 的 dur 判不出降級**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **state DB 的唯讀查詢不必被 exec guard 擋（第 388 行「sqlite3 被擋」的補充）**：被擋的是 `sqlite3` **CLI**；**`python3` + `sqlite3.connect('file:/home/amr/.openclaw/state/openclaw.sqlite?mode=ro', uri=True)` 完全可行**（2026-11-24 10:02 實測，成功讀 `cron_run_receipts` / `cron_jobs` / `task_runs`；機器上沒有 sqlite3 CLI）。→ 巡檢不必再退回 grep-only。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 有兩種型別，密度不可直接比較**（2026-11-24 10:02 實測）：**慢排空**（elapsed 79k–156kms，排隊到逾時，11-24 07:02 前都是這種）vs **立即拒絕**（elapsed 10–16ms，08:01:50 / 08:32:20 / 09:02:50 三筆全是這種）→ 前者是壅塞、後者是瞬時拒答；判「惡化或好轉」必須看 elapsed 形態而非筆數。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`heartbeat skipped: no-route / quiet-hours` 不是失敗**（2026-11-24 10:02 實測）：receipt `status=skipped` 且 `error_text` 前綴 `heartbeat skipped%` 的都是排程設計（無路由／靜默時段）→ 統計紅單必須排除（3h 窗 42 筆 non-ok 裡 **35 筆屬此類**；真實失敗只有 4 筆：3× 600s timeout ＋ 1× agent-runner-failure）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`elle.service` 的「已停用」結論不成立**（2026-11-24 10:02 實測）：`systemctl show elle.service` → `ActiveState=activating`、**`is-enabled` = enabled**、**NRestarts 120,589**（近 1h 476 行 elle.sh log、24h 5,700+ 次啟動）→ 先前那句「`systemctl disable --now elle.service` 已消掉 43 天重啟迴圈」**沒有生效或被復原**；它是 **system 層單元、需 root** 才能真停。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 13:02 輪（11-24）：dreaming 槽「部分驗收」+ flaaffy heartbeat 從未跑過 + 429 的整點指紋（2026-11-24 13:02 實測）
- ⭐⭐⭐ **04:25 dreaming 槽是「部分驗收通過」：dreaming 本體活了，但 event-loop 凍結把 6 支 heartbeat 全部打死**（2026-11-24 13:02 實測）：`36b493db` receipt = 04:25:01→04:55:18 **status=ok / dur=1,816,088ms（30.3 分）/ ce=0**，且 gateway **全程未重啟**（MainPID 4137629、ActiveEnterTimestamp 仍是 **11-23 04:48:17**、`ps` etimes=116,090s）⇒ **11-23 那條因果鏈（self-heal 誤判 dreaming idle → arm 重啟 → 腰斬 dreaming）已完全切斷**。**但同期 04:27:52 `host timing gap detected: process was frozen ~169,157ms`（2.8 分）、`eventLoopDelayP99Ms`=279,709/237,968/279,441/168,980、`eventLoopUtilization=1`、04:34:14 `memory pressure: rss=2.03 GiB rssGrowth=652.2 MiB thresholdRatio=127.4%`** → **12 輪 heartbeat 在 04:27–06:13 全部 `cron: job execution timed out`（picturecat/roaringmoon 各 2、gengar 2、rowlet 2、celesteela 2、mrmime 5 含 07:11 `agent-runner-failure` 與 08:11 的 600,009ms）**。**RSS 撐爆 → GC/事件迴圈餓死 → cron runner 的 600s timeout 在洞裡燒完**，這是本輪新取得的根因機制（Gengar 07:02 輪只抓到症狀）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **巡檢必須逐支跑 `cron runs --id`：`openclaw cron list` 會把整輪死亡洗掉**（2026-11-24 13:02 實測）：上述 12 輪硬死全部反映在 `state.lastRunStatus=skipped` + ce=0 ＋ `cron list` 只剩 `c5352a84` 一支紅單。**只掃紅單清單＝漏掉 12 輪死亡**；本輪 11 支逐支掃（`d82f78e3`/`46242a4c`/`7d633ff4`/`ffc90b7d`/`6525d155`/`3acd15c2`/`c29eca0f`/`bcf270b8`/`d7b0355b`/`40e09cd1`/`6e93c179`）才抓到。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **新 bug：`heartbeat-flaaffy`（`6e93c179`）從註冊到現在一次都沒跑過**（2026-11-24 13:02 實測）：`everyMs = 35,996,400,000`（599,940 分 ≈ 416.6 天），**其餘 8 支 heartbeat 全是 1,800,000ms（30 分）＝ 差 1000 倍**（典型 ms/單位打錯，35,996,400 ms ≈ 10 小時被寫成 35,996,400,000）；`anchorMs=1,814,183,940`、`nextRunAtMs=1,801,634,180,940`（**還要等 ~71 天**）、`lastRunAtMs=None`、`cron runs --id` entries=**0 筆**。⇒ **Flaaffy 的「我還活著」探針從未發射**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **429 的時段結構＝整點 job 密度的指紋**（2026-11-24 13:02 實測）：canonical `status=429` 近 3h **1** / 6h **4** / 24h **19**（16 筆明列 `provider=minimax-portal`）；24h 內時戳去重後為 **12:02 / 13:11 / 16:07 / 16:18 / 18:02 / 21:01 / 23:01 / 23:03 / 00:02 / 03:01 / 05:02 / 05:31 / 06:03 / 07:01 / 07:02** ⇒ **幾乎全落在整點後 1–11 分鐘**。本窗唯一一筆 12:03:01 是「慢排空」型（`elapsedMs=108,027` 才回 429）→ `rate-limit same-model retry 1/3 delayMs=10000` → **12:03:20 status=200 elapsedMs=9,273** 自癒。**429 本身可自癒；真正致命的是慢排空把 cron 撐過 600s。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`每日論文討論`（`58fe15dc`，cron `0 7 * * *`）07:00 槽連續第 3 天撞 429**（2026-11-24 13:02 實測）：11-21 07:03 error→07:12 ok、11-22 07:02 error→07:09 ok、**11-24 07:03 error/208,723ms→07:12:06 retry ok/486,124ms**（11-23 07:08 直接 ok）⇒ **07:00 這個槽本身有問題**，不是偶發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`40e09cd1` Jormungand daily all-agent health`（cron `0 3 * * *`）歷史 12 筆中 7 筆 error（58%）**（2026-11-24 13:02 實測）：11-24 03:00 error（429 / 115,867ms）→ 03:02 retry ok / 865,320ms → ce=0 被洗掉；11-23 03:00 同樣 429。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **Dreaming 的決定性驗證＝通過，但守門是「靠排程空窗」而非「靠判斷」**（2026-11-24 13:02 實測）：`d4cd45bc` self-heal 今日 **04:00–05:00 零執行**（排程 `13,43 0-3,5-23 * * *` 刻意不含 04 整點），05:13/05:43/06:13/06:43 四輪全 `discord healthy - no action` ⇒ dreaming 是靠「04 整點不跑 self-heal」活下來的，**不是靠 fail-closed 判斷**（11-23 的 fail-closed 三條 arm 路徑本輪無從驗證）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **Discord 兩種「ws closed」分型沿用（2026-11-24 13:02 實測）**：近 3h **10 筆 `gateway websocket closed flow=…` + 9 筆 `Gateway reconnect scheduled`** ＝ resume flow 良性續連；**3h 窗 READY 0 / channel exited 0 / disconnected 0 / host timing gap 0 / lane wait exceeded 0**（⇒ **連續 8h 零症狀**）。近 6h 仍有 2 筆 `client initialized`（05:00 前殘留）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **gateway 口徑再確認（2026-11-24 13:02 實測）**：`systemctl --user show openclaw-gateway` → MainPID **4137629**、NRestarts=**0**、ActiveState=active、ActiveEnterTimestamp=**Mon 2026-11-23 04:48:17 CST**、`/health` 200 in 1.5ms、**連續 32h14m 未重啟**；`systemctl show`（system 層）查 `openclaw-gateway` 仍會誤報 inactive（user unit）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **KA anchor 疊窗第 22 次**（2026-11-24 13:02 實測）：`state.nextRunAtMs` ＝ gengar `1795496523312` → picturecat `1795496535443` → celesteela `1795496535448`＝**12,131ms / 5ms**。三支 KA 今日 5 輪全綠：Picturecat 01:02/04:02/07:02/10:02 = **392,354 / 390,890 / 170,696 / 138,687 ms 全部非降級輪**（>30s 門檻）；Gengar 10:02 ok/259,428ms、Celesteela 10:02 ok/244,303ms。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📌 **本輪量測（供下輪對帳）**：uptime **43d18:49**、load 0.97/0.61/0.57、RAM available 20Gi、`/` 61%（178G free）；`elle.service` NRestarts **120,942**（上輪 120,585 → **+357/3h**，與上輪 +356/3h 一致）；journal 近 3h 623 行 / 近 6h 2,851 行；DNS 近 3h **2×EAI_AGAIN + 2×ENETUNREACH，全部在 gengar nested 行內**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`heartbeat-flaaffy` / `heartbeat-greninja` / `heartbeat-charizard` 的 skipped 要分型讀**（2026-11-24 13:02 實測）：greninja、charizard 近 24 筆**全 ok/skipped、零硬死**；flaaffy 是 **0 筆**（非 skipped，是從未執行）⇒ 三者長相相似但性質完全不同。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Gengar Keep-Alive 巡檢 — 13:02 輪（11-24）：429 型別判讀撤回 + superseded 已升級成 fallback 觸發 + 靜態 skill 掃描不等於 journal 口徑（2026-11-24 13:02 實測）

- ⭐⭐ **「429 兩型」只能以 status=429 行的 elapsedMs 分布為準**：24h 16 筆 canonical 429（`[model-fetch]`＋`status=429`）的 `elapsedMs` 全落在 **79,059–169,762ms** → 全部是**慢排空型**，24h 內沒有任何「立即拒絕（10–16ms）」型 → 10:02 輪的「型別改變＝fast-reject」**判讀撤回**。規則：型別判定必附 elapsedMs 分布＋行數，**禁止用字串口徑**（`rate limit reached` 21 ≠ canonical 16）推論。
- ⭐⭐ **跨 lane ping 的 superseded 副作用已升級為「會觸發 model-fallback」**：13:03:23 打 `agent:gengar:main` → 同毫秒 6 筆 `lane task error (nested/session, durationMs 5–7)` ＋ 2 筆 `[model-fallback/decision] candidate_failed` → fallback `minimax/MiniMax-M3` → 回覆照常落地（仍良性：本窗 `lane wait exceeded`=0）。同時段 picturecat KA 的探針也產生 2 筆 → **兩支 KA 同輪各自打 ping，副作用同步產生（8 筆）**。→ KA 探針應改用不需重建 runtime 的 lane 形式，並與 anchor 拉開 ≥15 分連動。
- ⭐ **靜態 frontmatter 掃描 ≠ journal 口徑（不可互換）**：靜態掃 60 支 SKILL.md 得 **9 支**缺 description；journal 24h unique 得 **17 檔**（13 支 `description is required` ＋ 4 支 `invalid frontmatter: BAD_INDENT`，**每檔 190 次/日**，136→190＝×1.4；3h 238 行、24h 3,230 行）。歷輪「17 支」＝journal 口徑，**靜態數字會低估，勿取代**。
- ⭐ **grep provider 失敗關鍵字會被 agent 回覆日誌污染**：13:03:23 那行 `Lane state: … 0 overloaded … 0 EAI_AGAIN` 是代理回覆文字被 journal 記錄 → 命中關鍵字。只認帶 `[model-fetch]` / `[agent/embedded]` / `[provider-transport-fetch]` 前綴的系統行。
- ⭐ **provider 429 的下游受害者要用 runId 反查 session**：12:03:01 的 429 → 同毫秒 `[agent/embedded] agent end isError=true` 打在 `agent:mrmime:discord:channel:1482069603512221927`（#魔牆人偶）＝本窗唯一 agent 死因；只看 provider 層會以為「只是數字」。
- ⭐ **ce=0 第 5 例**：heartbeat-mrmime `bcf270b8` 24h 7 筆錯誤（5×600s timeout ＋ 2×agent-runner-failure，最後 08:11）之後全 skipped/ok → ce=0 把整輪死亡洗掉。規則不變：**每輪固定查 bcf270b8 的 receipt**，紅單清單不足以代表沒出事。
- ⭐ **上輪交辦結案（降級 run 判定）**：10:02 槽三支 KA 最終 dur／summary_len ＝ gengar 259,428ms/2001、picturecat 138,687ms/2000、celesteela 244,303ms/1563 → summary_len ≫ 8 → **10:02 槽零降級輪**。降級 run 的簽名仍是 summary_len≈8（不看 dur）。
- 量測對帳（13:02）：canonical 429 3h/6h/24h = **1/4/16**（皆 slow-drain）；fleet receipt 24h = 605（ok 314／skipped 265／error 23／running 3），error 23 = heartbeat 18 ＋ provider 4 ＋ models-failed 1，四支每日 job 已全數 ce=0 復原；紅單只剩 `c5352a84` ce=1 ＋ legacy `a94330a9` ce=2；cron_jobs 53（enabled 46）；3h 窗 heartbeat 600s 群集 **0**（今日最後一次 08:11）；Discord 帳號 **8/8 connected**、3h reconnect 9（上輪 13 → 再降）、code-1000/1006 1；gateway user-unit MainPID 4137629、NRestarts=0、**32h15m** 未重啟、24h systemd 真重啟指令 0 筆；`elle.service` NRestarts **120,943**（+358/3h）仍 enabled 迴圈、1h 833 行 log；SSH 192.168.50.2 1h18/3h54/24h428 節奏未變；dreaming 下一槽 11-25 04:25；host up 43d18:50、load 1.19/0.69/0.60、RAM 20,604MB、/ 61%。

## Gengar Keep-Alive 巡檢 — 16:02 輪（11-24）：filler 摘要新型別 + superseded 連 4 輪觸發 fallback + elle.service 層陷阱（2026-11-24 16:02 實測）

- ⭐⭐ **新判準「filler 摘要」：receipt `status=ok` 不等於有真摘要**（2026-11-24 16:02 實測）：`13ac4b5a 健康回報` 11-24 **02:05:43** 槽 status=ok、dur=81,053ms、但 **summary 首句是 runner 佔位文字「The tool run finished, but no final summary was produced.」**（sumlen=97）；其餘 13 筆皆真摘要（首句「🛡️ 健康回報 HH:MM UTC」、sumlen 94–1293）。⇒ **降級 run 判定不可只看 `summary_len ≈ 8`**（那是「模板回覆」型）；還有「ok + 短摘要 + 佔位語意」型，規則升級為 **status=ok 但 summary 首句不符該 job 的正常格式 → 算降級輪**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **跨 lane ping 的 superseded 副作用已連續 4 輪、且每輪都伴隨 model-fallback 決策**（2026-11-24 16:02 實測）：探針 16:04:05 打 `agent:gengar:main` → 同毫秒 **6 筆** `lane task error (nested/session, durationMs=5–6)` ＋ **2 筆** `[model-fallback/decision] candidate_failed requested=minimax-portal/MiniMax-M3`（13:02 輪同型）→ 從「診斷噪音」升級為**固定成本**（被探 lane 重建 + fallback 額度）。回覆仍照常落地、`lane wait exceeded`=0 屬良性。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **elle.service 必須用 system 層查，`--user` 層是誤導（第 8 輪實測同款層陷阱）**：`systemctl --user show elle.service` → `inactive` / `NRestarts=0`（看似已停）；`systemctl show elle.service` → `enabled` + `activating` + **NRestarts 121,303**（13:02 輪 120,943 → **+360/3h**，節奏穩定）。→ **凡是 user unit 之外的服務，`--user` 層會回 inactive 假象**（與 gateway 層陷阱同源，gateway 則相反：用 `--user` 才對）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **抓 heartbeat timeout 必須排除 `[model-fetch]` 行**：本輪 `grep -iE "timeout"` 抓到 8 筆全是 `model-fetch … timeout=…` 的**正常 200 回應**（易誤判成 600s timeout 群集）→ 口徑＝`agent-runner-failure|cron.*timeout|timed out` **且**排除 model-fetch；正確口徑下 3h 窗 timeout = **0**（今日最後一次群集仍停在 08:11）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **KA anchor 疊窗第 23 次、偏移完全固定**：`state.nextRunAtMs` gengar **16:02:03** → picturecat **16:02:15**（12,143ms）→ celesteela **16:02:15**（6ms）；13:02 槽 lastRunAt 同序同值 → 偏移量一字不差地重現，證實是 anchor 設定重疊而非排程漂移。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **canonical 429 三窗口徑照抄即可（3h 0 / 6h 1 / 24h 16）**：24h 16 筆 `elapsedMs` 全落 **79,059–169,762ms → 仍全為慢排空型**（無立即拒絕型），配額牆 `usage limit`/quota 24h = **0**，3h 窗 `agent end isError=true` = **0**（無下游受害者）。**3h 窗連 2 輪歸零**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 量測對帳（16:02）：cron_jobs **53**（enabled 46）、紅單僅 `c5352a84` ce=1 ＋ legacy disabled `a94330a9` ce=2（無新增）；19 支 cron 型 job 全 last=ok ce=0；skills 缺 description **17 檔**（24h 3,213 行、每檔 189 次/日，密度 ×1.0 持平；journal 口徑 ≠ 靜態 9 檔）；13:02 槽三支 KA 最終 dur/sumlen = 215,202/2000、173,018/1999、171,302/1517 → **零降級輪**（16:02 槽 picturecat 已完 145,332/1999）；gateway MainPID 4137629 / NRestarts 0 / 連續 35h19m；Discord 8/8 connected、eventLoop degraded=false；SSH 24h 427；host load 1.58/0.96/0.71、RAM avail 20,843MB、/ 61%；`gw-upgrade-guard.log` 第 9 輪仍不存在、`dreaming-schedule-check.log` 仍停擺 11-19 22:33；dreaming 下一槽 11-25 04:25。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📉 **canonical 429 三窗口徑（22:02 輪）**：60m ＝ 0（272 行全納入、排除巢狀 13）／3h ＝ **1**（唯一命中 `21:01:33`、elapsedMs=**87,500**、請求起點 `21:00:06.283`）／24h ＝ **16**（elapsedMs 全落 79,059–169,762 → **仍全為慢排空型**、配額牆 `usage limit` 24h ＝ **0**）；**429 命中時刻全落在整點後 :01–:03 分** ＝ fleet 排程撞在一起的尖峰，不是隨機。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA 路由空殼第 6 輪仍未修**：`9d8b6001` / `02eb0989` 的 `cron_jobs.agent_id` 仍為 **None** → 兩支仍由 **rowlet** 執行（worker placement 佐證）、`lastDeliveryStatus` 仍 **not-requested** → 結果照舊不回報；另 `9d8b6001` 的 fallbacks 只有 minimax×2（**跨廠冗餘 0**，比 `02eb0989` 少一支 `openai/gpt-5.4-mini`）、`880b5c17` 是唯一 `agent_id=celesteela` 的正確樣板。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **19:02 槽三支 KA 零降級輪（連 4 槽：10:02／13:02／16:02／19:02）**：gengar 321.5s、picturecat 358.8s、celesteela 151.0s，全 ok / ce=0；22:02 槽 celesteela 已完 155.9s ok。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🔴 **heartbeat 600s timeout 群集第 5 輪 ＝ 1**：`bcf270b8 heartbeat-mrmime` 21:01:08 dur=600.0s（`cron: job execution timed out`）→ 21:11:38 同支 error 81.0s（`agent-runner-failure`）→ 21:31:04 恢復 ok；**疑似**與同分鐘 `21:01:33` 的 429 空轉（87.5s）耦合 —— 兩支 receipt 起點不重疊（21:00:05 vs 21:01:08），**未證實同一條因果鏈**，留待下輪對齊請求起點。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 🧩 **量測三坑（本輪各踩一次）**：① SSH 樣式 `Accepted PublicKey`（大寫 P）＝ 0，真值是 `Accepted publickey` → 一律用**大小寫不敏感**的 `Accepted `（本輪 18/h、3h 54、24h 426）；② `cron_jobs.job_id` 是**完整 UUID**，8 碼前綴 `IN (...)` 查不到 → 必須 `LIKE '9d8b6001%'`；③ `sqlite3` CLI 對 state 目錄直接被拒 → 須 cp 三檔（sqlite/-wal/-shm）到 /tmp 再 `file:…?mode=ro` 開啟；④ 巢狀 agent 回音會落在 `node[…]` 系統行內 → 規則＝系統前綴**且**排除 `[agent:nested]/[agent:side]/[agent/embedded]`（24h 排除 266 行，否則自己的探針字串會被算成 overloaded 命中）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📈 **17 支 skill 缺 description 第 23 輪未修、密度 ×1.06**：每檔 **198 次/日**（上輪 187）、≈**3,366 行/日**（13 支 `description is required` ＋ 4 支 `BAD_INDENT`）；口徑：17 ＝ 全艦，gengar 自家 lane ＝ 9/57。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **常駐雜項（22:02 輪）**：`elle.service` 仍 `UnitFileState=enabled` ＋ 重啟迴圈（**+357/3h**、NRestarts 122,016、journal `Scheduled restart` 3h ＝ 357 自證）→ 需 root；`gw-upgrade-guard.log` 第 11 輪仍不存在、`dreaming-schedule-check.log` 停擺在 11-19 22:33；gateway MainPID 4137629 / NRestarts 0 / 連續 41h+；dreaming 上一槽 11-24 04:25 ok 1,816,088ms ce0 → 下一槽 **11-25 04:25**；superseded 副作用第 6 次（3h 9 筆／24h 80 筆）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->


## Picturecat Keep-Alive 巡檢 — 01:02 槽（2026-11-25 01:02 實測）

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「skipped 卻跑了近 5 分鐘」＝600s 炸彈的前哨，本窗再度重現且是最接近的一次**：`heartbeat-rowlet` 23:08:22 那輪 **status=skipped 卻 dur=298,856ms（600s 預算的 49.8%）**，且 **`heartbeat-celesteela` 23:12:51 那輪（30,026ms）與它同一毫秒收尾（23:13:21.560）**，而 rowlet lane 當時正在跑 `5b7c1082 每日模型排行前十` 的第三次嘗試（23:13:21.532 收尾）→ **高度符合「同 lane 併發把 heartbeat 卡住等待 → dur 暴增 → 撞 600s 就死」**（11-24 21:11 的 mrmime 硬死是同型）。⚠️ **但同日 Gengar 01:02 輪對 21:01–21:11 窗的量測判定為「runner hang、非上游慢」** → **兩說並存、尚未定案**（阻塞為真、致命那一步可能是 hang）→ **低風險先做：錯開整點槽的 job 密度（消掉同 lane 併發與 429 重試鏈），再談拉高 heartbeat 的 timeoutSeconds**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **heartbeat-mrmime「每 2 小時死一次」的週期假設已被證偽（負結果同樣要記）**：11-24 21:11 的 600s 硬死之後，21:31／22:01／22:31／23:01／23:31／00:01／00:31／01:01 **共 8 輪全綠**（dur 4.7–186.7s）→ 08:21 與 21:11 兩次硬死**間隔 12h50m**，不構成 2 小時週期 → 待決事項「把 mrmime 槽錯開整點」的優先級可下修。⚠️ **對照：Gengar 同輪量到 21:01:08–21:11:08 窗內 provider 端 model-fetch 71 筆、200=35、最大間隔 59s → 該次死因偏向 runner hang** → **「上游 busy 拖慢」與「runner hang」兩種機制可能同時存在，別只押一邊**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「整點槽 3 次嘗試」＝429 的新形態（11-24 23:00 槽）**：`5b7c1082 每日模型排行前十` **23:00:00 error/79,795ms → 23:01:49 error/109,341ms → 23:04:39 ok/522,352ms**，`ce=0`＋`lastRunStatus=ok` → **紅單清單完全看不到這兩次死亡**（第 6 例「ce=0 洗掉整輪死亡」）。對應 429 = **23:01:19 elapsedMs=66,098 ＋ 23:03:38 elapsedMs=103,797**，**兩顆相隔僅 139 秒、都是 `overloaded_error: server is busy`**（近 5 天都是「首輪 error → 隔 7–9 分鐘 retry ok」）。→ **「同 job 內部連續重試」才是兩顆背靠背的來源，整點併發只是放大器**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **併發密度是放大器、不是充分條件**：本輪實測 **23:00 槽起跑數＝3 支**（`5b7c1082` 23:00:00／`ca222989 系統維護` 23:04:49／`13ac4b5a 健康回報` 23:05:21；`911eee45 每日資安建議` 在 **21:00:05**、不在 23:00 槽）→ **23:00 槽並非全日最密**（03:00／07:00／08:00 槽皆 ≥4 支）；而 **00:00 槽只查到 2 支**（`d7b0355b` A2A heartbeat 00:00:30／`ca222989` 00:04:48）**仍出現 1 筆 429**。⚠️ 此處起跑數是「本輪實際查詢到的 job」＝**下限估計**，非全 53 支逐槽普查。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **本窗 429 數據（canonical：`[provider-transport-fetch] … status=429`）**：3h 窗 **3 筆**（23:01:19 elapsed 66,098／23:03:38 elapsed 103,797／00:02:31 elapsed 118,738）→ **每顆都超過 1 分鐘**；**24h 共 16 筆、`Token Plan usage limit`（真配額）＝ 0 筆**（全是 busy 型）；逐時：11-24 03×1／05×2／06×1／07×3／08×2／09×1／12×1／18×1／21×1／23×2、11-25 00×1 → **「整點後 1–11 分鐘」指紋持續成立**。✅ 同窗 00:02:31 那顆被 `rate-limit same-model retry 1/3 delayMs=10000` 吃掉 → `d7b0355b A2A heartbeat` **ok/157,266ms**（**429 自癒 ≠ 這輪 job 安全**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **KA anchor 疊窗第 26 次，且「順序」會翻轉、不能靠上輪紀錄推論**：`state.nextRunAtMs` ＝ gengar `1795539724195` → picturecat `1795539738333` → celesteela `1795539738339` ＝ **14,138ms / 6ms**（上輪 22:02 是 gengar→picturecat 12,126ms、picturecat↔celesteela 6ms）→ **gengar 與 picturecat 已自然錯開，但 picturecat ↔ celesteela 固定差 6ms** → **重點威脅已從「三支同搶」縮成「兩支同搶」**（修法：拉開 ≥15 分鐘，待 Linder 點頭）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **Discord 乾淨段續長到 20h08m**（自 11-24 04:55:41 之後）：3h 窗 `did not reach READY`=0、`channel exited`=0、`host timing gap detect`=0；`Gateway reconnect scheduled`=12（**全 `resume=true`**）、`websocket closed`=14（code=1005/1006）＝ **安靜期基線 ≈4–4.7 次/小時**；唯一一次 `client initialized`（22:10:57，picturecat bot probe 相鄰）**自癒完成、無 READY 失敗**；24h 的 26 筆 READY-fail／13 筆 channel-exited／6 筆 host-timing-gap **全部落在 11-24 04:25 dreaming 窗**（末筆 04:55:41）→ 與基準表一致。⚠️ **判 Discord 是否失明要看整組簽章**（READY-fail＋channel exited＋reconnect/websocket closed），**只看 `channels status` 會誤判沒事**；⚠️ **重連兩簽章要一起數**（只數 READY-fail 會低估約 10 倍：24h 26 vs 150）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **gateway 連續 44h15m 未重啟**：`systemctl --user show openclaw-gateway` → ActiveEnterTimestamp=2026-11-23 04:48:17、MainPID 4137629、NRestarts=0 → **查 gateway 務必用 `--user`**（system 層會誤報 inactive/MainPID=0）；⚠️ **但 NRestarts=0 ≠ 沒重開過**（systemd 主動 restart 不計入，見 11-23 條目）。✅ **self-heal `d4cd45bc` 守門零開火**：窗內 6 輪（22:13→00:43）全 ok、dur 745–786ms、全為「discord healthy - no action」；且 **04 整點空窗確認**（schedule 13,43 → 04:13/04:43 天然不跑，dreaming 04:25 期間無 Discord 救援）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **17 支 skill 缺 description 第 24 輪仍未修、密度續升**：3h 窗 raw **544 行**、24h raw **3,689 行**、唯一檔 **17 支**、每檔每 3h **32 次**（≈**256 次/日**，上輪 198）→ **仍未授權，不動**。⚠️ 事件形式＝`[skills] Skipping invalid skill: file=… error=description is required`（另有 4 支 `BAD_INDENT`）；**驗證方式是「看它們不在 `<available_skills>` 清單裡」，不是看 log 有沒有報錯**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **superseded 競態噪音續增但仍屬良性**：3h **8 筆**、24h **113 筆**（上輪 80）；24h `Embedded agent failed before reply` = **3 筆**（11-24 16:09、21:12、11-23 16:11）→ 本窗 **0 筆新增**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **巡檢方法論補充（11-25 01:02）**：`openclaw cron runs --id <完整 UUID> --json` 的可用欄位＝`runAtIso`（**起跑**）／`tsIso`（結束）／`durationMs`／`status`／`completionStatus`／`deliveryStatus`／`sessionKey`／`model`／`provider`／`summary` → **本輪新增用法：用 `runAtIso` 逐支列出某個整點槽實際起跑的 job 數**（這是「併發密度」唯一可靠口徑）。⚠️ **`state.nextRunAtMs` ≠ 上次實際起跑時間、也不是本次排定的 fire 時間**（本 job 自身 nextRunAtMs ≈ 01:11，實際起跑 01:02；因 nextRunAt 是執行結束時重算的）→ **起跑時間一律以 `runAtIso` 為準**。⚠️ 短 id 會安靜回 `Automation not found`（tot=0）→ 一律用完整 UUID。⚠️ `automations` 工具在 restricted automation-run session 仍回空清單（非故障）。⚠️ **journal 簽章要大小寫敏感**：`grep -c "READY"`（3h）＝**0**，而 `grep -i ready` 會命中 `already succeeded`（outbound/deliver 噪音）→ 寫全 `did not reach READY`／`READY within 30000ms`。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

- ⭐⭐ **11-25 04:02 輪（keepalive-gengar 第 10 輪）**：lane 探針 PASS（`sessions_send` → `agent:gengar:main` runId `0f26d0ab-104f-4d25-9d88-296cd6ddfda6`、status=ok、token **`LANE_OK_GENGAR_0402_25 = 7`** 逐字一致、對方只 append 落檔 21,061 B 未回送）；**3h canonical 429 = 1**（新一筆 11-25 03:01:46 elapsed 89,808ms → 歸因 `40e09cd1` 03:00:02 首跑 429，補跑 03:02:17 ok 243,106ms）、**24h = 16**（配額牆 0、慢排空型 elapsed 66,098–169,762ms）；**60m = 0**（已納入 1,521 行／系統 1,232／去巢狀 1,219／model-fetch 96）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **決定性驗證：健康回報 `13ac4b5a` 11-25 02:05 槽確實是 filler（連 2 天）** —— `task_runs.terminal_summary` len=**97**、內容 = `The tool run finished, but no final summary was produced. I did not repeat any completed actions.`、status=succeeded、dur 50,717ms、delivery=delivered（**startswith 口徑，非 LIKE**）。7 天同 job 6 次 filler（11-18 20:05／11-19 02:05／11-21 17:05／11-22 11:05／11-24 02:05／11-25 02:05）；⚠️ **更正上輪**：11-18 那次是 **20:05** 不是 02:05，上輪的 8.1% 只涵蓋單支 job → fleet 全域 7 天 1,893 筆有摘要 run 中 filler **10 筆＝0.5%**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「skipped 卻跑了 7.2 分鐘」前哨再現，而且在我自己的 lane、且強度上升** —— `d82f78e3 heartbeat-rowlet` **11-25 01:08:24 status=skipped 卻 dur=431,168ms（600s 預算 71.9%）**（上輪同型 23:08:22 dur=298,856ms＝49.8%）；24h 內 skipped-dur≥300s 共 **4 筆**（`d82f78e3`×3 + `46242a4c`×1）；同 job 11-24 04:39:02 曾被 616,973ms 直接砍死。⭐ **機制判定**：6 支 `heartbeat-*` 全部 **timeoutSeconds=None** → 能殺它們的是 lane runner 內部 600s 預算；「skipped」代表排程已判 no-route，但 **runner 仍佔著 lane 直到 7 分鐘後才收尾** → 這就是「同 lane 併發卡住 heartbeat」的機制。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **`40e09cd1 Jormungand` 連 3 天首跑 429 死亡**（11-23 03:00:01 error/223,049ms、11-24 03:00:00 error/115,867ms、11-25 03:00:02 error/104,794ms），但**補跑結果不穩**：11-23 → 2000 字真摘要、11-24 → filler(97)、11-25 → 2001 字真摘要（"All green. Run complete."）→ **真正缺陷是首跑被打死，補跑只是把損失轉成 filler 或真摘要的擲骰**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **口徑更正（上輪數字有誤）**：raw grep `EAI_AGAIN` 24h = 16 筆，但 **16 筆全在 `[agent:nested]` 自報回音行**（gengar lane 把自己的報告文字寫進日誌再被 gateway 記一次）→ canonical 應為 **0**；上輪報的「EAI_AGAIN=4／ENETUNREACH=2」是未排除巢狀造成的高估。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA 路由空殼第 8 輪確認**：`9d8b6001`／`02eb0989` agent_id 仍 None、payload 仍只有 `keep-alive test`、`lastDeliveryStatus` 仍 not-requested；`880b5c17` agent_id=celesteela（唯一正確者）；`ee14ba4c` Rowlet KA 仍 disabled → **本輪審查前提不變**。**anchor 疊窗第 27 次**：gengar 04:02:04 → picturecat 04:02:18 → celesteela 04:02:18（**同秒 0ms**）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`02eb0989` 未設 timeoutSeconds 的風險本輪實質顯現**：01:02 槽 picturecat dur **797,261ms**（歷來最長，上輪 430,720ms）→ 另兩支 1800s 會砍、它沒有上限；**這是補 timeoutSeconds=1800 的第 7 輪理由（現在有實測佐證）**。同槽三支 KA 零降級（**連 6 槽**）：gengar 522,302ms/1,997、picturecat 797,261ms/1,933、celesteela 152,763ms/1,423。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **dreaming「連續兩夜」說法經 receipts 更正（失敗模式＝gateway 重啟打斷，不是 timeout）** —— `36b493db` 11-20 **interrupted**(675,658)／11-21 ok(1,918,841)／11-22 ok(1,852,428)／11-23 **interrupted**(1,406,872, owner is unavailable)／11-24 ok(1,816,088) → 上輪「連續兩夜完整」不成立（11-23 是 interrupted）；11-23 04:25 起跑、04:48:17 gateway 重啟 → 時間吻合。11-25 04:25 槽本輪尚未起跑，順延 07:02 驗證。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **600s timeout 群集第 7 輪＝0**（3h 與 6h 窗皆 0；24h 仍 15 筆，全在 11-24 04:27–08:11 早高峰，最後一筆 08:01:04）；**mrmime lane 近 8 輪全綠**（dur 4,770–45,543ms）→ 上輪「lane runner hang」定案成立且未復發。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📈 **skill 缺 description 第 25 輪未修、密度持平**：17 檔、3h 374 行、24h **3,689 行**、**每檔 217 次/日**（上輪持平）；⚠️ superseded 第 8 次（3h 9 筆／24h 81 筆，持平）；`c5352a84` ce=1 仍是唯一 ce>0 的 enabled job；⚠️ `6e93c179 heartbeat-flaaffy` enabled=1 但 lastRun=None、next=2027-02-04（排了但永遠不會跑）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **系統面**：gateway MainPID 4137629／NRestarts 0／連續 **47h17m** 零重啟（查 gateway 務必 `systemctl --user`）；elle.service NRestarts **122,731**（+357/3h 持平）、仍 enabled/activating；SSH Accepted-only 18/h、54/3h、**426/24h**（基線持平）；磁碟 61%、RAM 9G/31G、load 0.72；Discord 3h closed 12／reconnect 12（全 resume=true）／channel exited **0**；`gw-upgrade-guard.log` 第 13 輪不存在、`dreaming-schedule-check.log` 停擺第 6 天（mtime 11-19 22:33）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

- ⭐⭐⭐ **11-25 05:44｜每日 LLM Wiki 巡讀 #3 的獨立複核抓到 4 個「看起來很合理」的錯**（arXiv:2610.30151 *The Cost of Saying Hello* 頁面）：①「論文 Table 2 與釋出 artifact 差**固定 +49 ms**」錯——legacy 是 **+106.9 ms**（3 條 TCP 連線），只有單連線協定才是 ≈+49；且「**協定層 vs 端到端**」的解釋錯——**repo README 明寫 "The paper's numbers are measured under kernel-level emulation"**，但論文 §4.4/§4.5 自述是 macOS+userspace relay 且 *"exclude transport setup entirely"*，artifact `meta.json` 是 **2026-09-30 另一台 Linux 機**（tc-netem）→ **是兩個不同 run，不可相減當成本項**（★ **一擊否掉結構性解釋的對照格＝同一份 repo 的 S4a 只差 1–12 ms**）；②認證表**把 rtt50 的中位數標成 loopback**——`auth.jsonl` 每格含 local 與 rtt50 各 50 runs，混合取中位數會得到**不屬於任何條件**的數字（真值：auth-first loopback 5.81/4.16/1.01 ms、rtt50 747.73/632.94/183.35 ms；`auth_tls.jsonl` 只有 rtt50tls 故乾淨）；連帶「5.9×／4–4.5×」要重算為**同條件比較的 3.06×→4.08×→4.11×**；③capability 頁「A2A 2.08 ms、MCP modern 8.50 ms」**8.50 查無來源**；④「其餘降到個位數 ms」應為論文 §5.2 的 7.8/2.6/7.1 ms。★ **可一般化的四條教訓（已寫入 wiki/log.md）**：**(a)「兩份數字不一致」的第一反應應是「它們是同一個實驗嗎？」而不是「它們量的東西不同」**（後者容易編出漂亮但站不住的解釋表）；**(b) 驗證差異歸因要找「同一份來源、不同情境」的對照格**；**(c) 混合不同條件的資料取中位數，是最容易被「看起來很合理」掩蓋的錯**；**(d)「引用時要註明口徑」這條規則本身也會錯——我原本的「協定層 vs 端到端」二分法錯了，正確的註明單位是「來源 run」（環境＋日期＋模擬方式）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **11-25 06:46｜每日 Agent × 軟體開發情報（第二輪）複核：★ 報告數字全對，但 abstract 裡 12 個明載數字／限制被壓縮掉了** —— SchemaCaps 漏 **645/1,197/2,004/617** 對照與**限制句「相同 schema 背後的行為改變 out of reach」**、漏「8 個 client 中 **2 個無法判定**」；Tool-Call Smuggling 漏 **7,412**、漏**修法完整三段式（解析一次含 JSON 文字＋只留已批准欄位＋以 call ID 封緘）**、漏**主動攻擊版（惡意伺服器複製合法 schema 多加一欄）**、漏**「模型把 key 逐字複製進 JSON 文字→分歧可只發生在一個字串內部」**；IntentFlow 漏 **CaMeL 式擋全 50 卻拒掉 16/50 良性**（★ 概念頁原寫「原摘要此處截斷，未取得完整比較基準」是**錯的**——abstract 數字完整，是抽取沒讀到，卻用「截斷」當永久事實把反例藏了起來）；Transport-Safe Eval 漏 **48 格規模／MAE 0.018–0.020／無校正支援時改報敏感度集合／e-process 任意停止仍有效**。★ 另修 **2 個 self-only orphan**（trusted-value、architectural-constraints 原本 in=1 且來源是自己）＋ **1 個連結大小寫錯**（`agent-harness-as-first-class-citizen` → 實際檔名 `Agent Harness as First-Class Citizen.md`）。★ **可一般化的三條**：**(a) 報告與 wiki 頁的最後一道關卡是「回原文比對」而不是「把報告讀順」——報告常壓縮掉的恰恰是「限制句」與「對照組數字」，而那兩類決定結論能否站住；(b) 看到「原摘要此處截斷」要立刻懷疑**，那是抽取失敗被寫成永久事實的典型；(c) 漏掉的東西有共同形狀：每篇至少一個限制句、一個對照組數字，報告只留效果數字。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

- ⭐⭐⭐ **11-25 07:02 輪（keepalive-gengar 第 11 輪）決定性根因修正：heartbeat 600s timeout 群集的「上游」是 Discord provider startup 風暴，不是缺 timeoutSeconds** —— 3h 內 Discord 事件：`websocket closed code=1005` 31、closed 1000 26、`code=1006` 9、`Opening handshake has timed out` 5、**`gateway opened but did not reach READY within 30000ms` 11（→ 11 筆 channel exit、7 個帳號：celesteela/flaaffy/picturecat/roaringmoon 各 2、charizard/gengar/rowlet 各 1）**、`READY wait timed out after 15000ms` 9、`113 commands exceed the 100-command Discord limit` 24、`[rowlet] delaying provider startup 70s to reduce Discord startup rate limits` 4（roaringmoon 60s）；**04:54:40 之後無任何成功 READY 落地（3h 與 24h 的 READY 事件皆 17 次且全是 timeout）**，06:42 起 heartbeat 恢復（0–15s）。⇒ **14 筆 heartbeat 600s timeout（04:27–06:38，picturecat 2/charizard 2/roaringmoon 2/mrmime 1/gengar 2/rowlet 2/celesteela 1，全為 `cron: job execution timed out`）＋ skipped-dur≥300s 24h 10 筆（上輪 4）**，runner 序列化再實證：06:24:57–06:26:18 五支依序 greninja 407s→celesteela 358s→roaringmoon 326s→picturecat 344s→charizard 416s。**修法排序：① 查每 skill 註冊指令數（100 指令上限＝最上游觸發點）② 錯開 provider startup ③ 補 timeoutSeconds 只算放大器不是根因**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **健康回報 11-25 05:05 槽「不是 filler」（summary_len=335、標準 🛡️ 格式）→ filler 連 2 天未延長**；但同輪抓到**健康回報的結構性漏報**：該份報告稱「最近一小時 12 個 job 全 ok/skipped」，而同窗 `cron_run_receipts` 有 **14 筆 heartbeat timeout ＋ 2 筆 429 error** → **健康回報只讀 `openclaw cron list` 的 `state.lastRunStatus`（heartbeat 的 state 顯示 skipped/ok），看不到 receipts 的 error/error_text ⇒ 結構性漏報**。修法＝步驟 3 改以 receipts（status='error' AND started_at_ms ≥ now−3600000）為準。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **dreaming 11-25 04:25 槽 ok dur=1,793,022ms → 11-24＋11-25 連續兩夜完整**（11-23 是 interrupted，receipts 覆核與 gengar 自報一致）→ 上輪交辦②結案。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📈 **3h canonical 429 = 7（已納入 582 行 `[model-fetch] response`：200×575、429×7）＝ 上輪 ×7**；時點 05:02:13/05:32:45/06:02:21/06:31:44/07:01:04/07:02:28/07:03:28（24h 17/2,142）；其中 6 筆以 `embedded run agent end … HTTP 429 overloaded_error` 形式＝Discord 原生 agent run 直接被 provider 429 打死。與 gengar 自報 6 筆差 1 的原因＝其視窗 04:03:08–07:03:08 截掉 07:03:28。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **KA 路由空殼第 9 輪 + anchor 疊窗第 28 輪**：`9d8b6001`／`02eb0989` agent_id 仍 None、payload 仍只有 `keep-alive test`、lastDeliveryStatus 仍 not-requested → 仍跑在 rowlet（placements 確認）；04:02 槽三支 KA 零降級＝**連 7 槽**（gengar 282s/1,999、picturecat 307s/1,998、celesteela 60s/1,170）；07:02 槽 anchor gengar 07:02:05→picturecat 07:02:19→celesteela 07:02:21。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 📈 **skill 缺 description 第 26 輪未修**：17 檔、**每檔 209 次/日**（上輪 217）、24h **3,553 行**、3h 1,156 行 → 清單不變，仍需 Linder 點頭。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **`40e09cd1 Jormungand` 連 4 天首跑 429 死**（11-25 03:00:02 error 105s → 03:02:17 補跑 ok 243s）；`c5352a84` ce=1 仍是唯一 ce>0 的 enabled job；`6e93c179 heartbeat-flaaffy` 仍 enabled=1 但 lastRun=None／next=2027-02-04。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **系統面**：gateway MainPID 4137629／NRestarts 0／連續 **50h16m** 零重啟（`systemctl --user`）；elle.service NRestarts **123,086**（+355/3h、journal Scheduled restart 357/3h、2,857/24h）→ 需 root；SSH Accepted-only 48/3h、426/24h（sshd 總行 234/3h、2,125/24h）；磁碟 61%、RAM 9G/31G、load 0.97；**Discord 風暴期間 delivery_queue 3h 8 筆全 completed（投遞未受損）**；journal 3h 總行 6,223。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 600s 硬死量測口徑翻案 + dreaming 因果證實 + 飽和假說（2026-11-25 07:02 實測） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **「600s timeout 群集 = 0」是假陰性：journal 裡根本沒有 cron timeout 簽章，權威來源只有 receipts**（2026-11-25 07:02 實測，推翻 11-25 04:02 輪的「第 7 輪＝0」）：本輪用 `openclaw cron runs --id <完整UUID>` 逐支重算，近 3h **9 筆硬死**（picturecat 2、roaringmoon 2、charizard 1、mrmime 1、rowlet 2、celesteela 1），而同時段 journal grep `cron: job execution timed out` / `timed out after 600` = **0（3h 與 24h 都是 0）**。→ **判 600s 群集只能用 receipts：`cause=timeout` 且 `dur≈600005`（含 `dur=685,882` 這種超標型）**；journal grep 會把「有事故」判成「零症狀」（與 11-23 `^` anchor 踩坑同一類：查錯地方）。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **dreaming 窗的因果關係首次被「同毫秒起跑」直接證實**：2026-11-25 `heartbeat-picturecat` 與 `heartbeat-roaringmoon` 的 04:27:53 兩輪**起跑時刻＝04:27:53.312 / 04:27:53.328**，而 dreaming 窗**第一個 `host timing gap detect` 正是 04:27:53** → 不是巧合。兩支各等 685,882/685,907ms（>600s 預算）→ 04:39:19.194/.235 **同毫秒釋放**並判 timeout；下一槽 04:39:50.950/.962 又等 607,546/607,576ms → 04:49:58.496/.538 同刻釋放（charizard 04:49:58.538 一併釋放）→ **「同一毫秒整批釋放」＝序列化 flush 指紋**。dreaming 本輪 04:25:00→04:54:53 ok/1,793,022ms → **連續第 2 夜完整活下來**，11-23 那次 self-heal 造成的 gateway 重啟打斷未再重演。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **「600s 炸彈真兇＝長 KA job」被證偽，真凶換人＝heartbeat fleet 自我飽和**：本窗 9 筆硬死**沒有任何一筆落在 KA 窗內**（三支 KA 只在 04:02–04:07 跑）→ 上輪「KA 加 `timeoutSeconds:300` 是唯一槓桿」**只解決 01:02 類 KA 窗 stall，不是本窗死因**。② 05:41／05:48／06:25／06:48 那四筆的佔用者**不是任何 cron job**（系統維護 70–105s、健康回報 41–51s、轉錄監控 1.2s 都太短）→ 候選真因＝**8 條 heartbeat lane × 每小時 2 槽 = 16 次/小時 × 實測每次佔用 runner 200–600s ≈ 64–80 min/hr，逼近／超過序列化 runner 的 60 min/hr** → 隊列必然積出 600s 長尾（06:31:44.496 同一毫秒釋放 greninja/picturecat/celesteela/roaringmoon 四支＝前一支 heartbeat 佔住 runner 的證據）。**修法排序（待 Linder 點頭）：(a) heartbeat 降頻/縮範圍（治本）→ (b) heartbeat timeout 600→900（吸收長尾）→ (c) 去序列化（架構級）**。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⚠️ **skill 缺 description 的正確集合是 17 支**（11-25 07:02 實測：3h 1,003 行＝767 `description is required` ＋ 236 `invalid`/BAD_INDENT、唯一 17 檔、每檔每 3h 59 次 ≈ 472 次/日/檔）；**11-25 04:02 輪寫的「9 支」是只數 `~/.openclaw/skills` 的口徑**，漏掉 rosclaw plugin 4 支 ＋ BAD_INDENT 4 支 → 驗證仍以「不在 `<available_skills>` 清單裡」為準。**未授權不動。**<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ **整點槽「首輪死、靠重試救回」三槽齊了**：03:00（`40e09cd1` 連 4 天首輪 error）、07:00（`58fe15dc` 11-21/22/24 首輪 error）、23:00（`5b7c1082` 11-24 同槽 **3 次嘗試**才 ok）→ 整點槽需要 **2–3 次嘗試**是常態，429 子型仍全為 `overloaded_error`、真配額 `Token Plan usage limit` 仍 0 筆。<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->

## Picturecat Keep-Alive 巡檢 — 13:02 輪（11-25）：600s 硬死第 2 次重現（08:00 槽、飽和 112%）+ 配額牆成主因 + openai auth order 新失效型別（2026-11-25 13:02 實測） <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐⭐ **飽和假說第 2 次被實測支持，且已可量化**：receipts 實測 06:30–13:05 窗內 heartbeat lane 的 Σ dur，**08:00 槽 10,706 lane-s ＝ 8 lane × 2 槽 × 600s 上限的 112%**，該槽同時爆出 **7 筆 dur=600,003/600,004ms**（hb-rowlet ×3、hb-mrmime ×3、hb-celesteela ×1，`cron: job execution timed out`）；06:00 槽 42%、07:00 槽 25% 就沒事。**分母要用「lane × 槽數 × 600s」，不是 3600s。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **quota 型 429 首次成為主因**（09:00–13:00 連續 4 小時）：逐時 429＝09:66 / 10:91 / 11:63 / 12:75，其中 `Token Plan usage limit reached`（code 2056）**09:00 起才出現**（前三輪都報 quota=0）→ `OpenClaw 系統維護` 每小時 job **連死 7 次**（09:04→12:04，最後成功 08:04）、`健康回報` 連死 4 次（11:05–11:12）、Celesteela KA 10:02 死、Gengar KA 10:02/10:03/10:08 連死 3 次。**根因＝4 個 fallback 全是 MiniMax 系列、跨廠冗餘 0，配額一耗盡整 fleet 同死。** <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐⭐ **新型別失效（分層判讀必要）**：`Explicit auth order for openai has no usable profiles.` → 發生在 **lane 派發期（durationMs=12）**，模型**完全沒被呼叫**，與 429 是不同層級；rowlet `agents.defaults.models` 內含 `openai/gpt-5.3-codex`/`gpt-5.5`/`gpt-5.4-mini` 等 openai 條目 → 任何需要跨廠 fallback 的 job 都可能隨時 12ms 秒死。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **「越壞越快＝越安靜」**：配額牆期間（10:00–12:00）lane 佔用率掉到 **1%**，因為每個 job 2–5s 就死 → **fleet 狀態表在事故期看起來比健康期更安靜**；`consecutiveErrors` / `lastStatus` / 佔用率都不能單獨當綠燈。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **隱性佔用型別**：`heartbeat skipped: no-route` 但 dur 347–510s（4 筆）→ heartbeat 在判定「沒有 route」前會先阻塞 5–8 分鐘，狀態表只看得到 skipped。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ **死亡輪不留紀錄**：本 job 10:02 輪 error 2.3s（openai auth order）→ 報告檔 mtime 停在 07:11，**巡檢連續性只能靠 receipts 回推**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ✅ 本輪校正：`每日論文討論` 07:00 → ok 762.2s（連 3 天「首輪死、重試救回」型別今日未出現）；`heartbeat-flaaffy` next ＝ 2027-02-03 05:56（每輪必查）、`everyMs=35,996,400,000`（≈416 天）→ **上輪寫的「everyMs 應為 3,600,000」本身是錯的**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ Discord 零症狀連續：06:40:16 出現 `gateway reconnect (resume=true)` → **上一輪的「自 04:54:40 起零症狀」在 06:40 就斷了**；12:50:43 `close, resume=false`、12:52:34 與 12:53:01 兩次 reconnect → 最新零症狀起點＝**12:53:01**。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- ⭐ KA anchor 疊窗：picturecat 13:02:19 ↔ celesteela 13:02:23（**Δ 4s**）、gengar 13:02:02（Δ 17s）→ 疊窗第 30 次，本輪只要跑超過 4 秒就與 celesteela 同時在跑。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
- 💡 **巡檢方法論新增**：批次抓 receipts（一次迴圈抓 8 lane + 5 支重點 job ＋ journal 一次掃描）可在 **≈160s** 內做完 → **300s 自我上限做得到**；不要逐 lane 重複 `openclaw cron runs`。 <!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
